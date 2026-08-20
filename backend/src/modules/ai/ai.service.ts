import {
  Inject,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { DuffelService } from '../duffel/duffel.service';

import { AiResponseDto, AiContextDto } from '../../common/dto/ai.dto';
import {
  AI_FALLBACK_PROVIDER,
  AI_PROVIDER,
  AiFailureCategory,
  AiProvider,
  categoryOf,
  isFallbackEligible,
  upstreamStatusOf,
} from './ai.provider';

/**
 * The complete set of facts recorded for one provider attempt.
 *
 * Phase 10D deliberately models the log line as a closed record of scalars
 * rather than a free-form string. Nothing here can hold a prompt, a response
 * body, a header or a credential: `provider` is a hardcoded provider id,
 * `category` comes from a fixed vocabulary, and the rest are booleans/numbers.
 */
interface AiAttemptRecord {
  provider: string;
  fallbackUsed: boolean;
  outcome: 'success' | 'failure';
  latencyMs: number;
  category?: AiFailureCategory;
  upstreamStatus?: number;
}

/** Renders an attempt as a stable, greppable `key=value` line. */
export function formatAiAttempt(record: AiAttemptRecord): string {
  const parts = [
    `provider=${record.provider}`,
    `fallbackUsed=${record.fallbackUsed}`,
    `outcome=${record.outcome}`,
    `latencyMs=${record.latencyMs}`,
  ];
  if (record.category !== undefined) {
    parts.push(`category=${record.category}`);
  }
  if (record.upstreamStatus !== undefined) {
    parts.push(`upstreamStatus=${record.upstreamStatus}`);
  }
  return `ai.query ${parts.join(' ')}`;
}

/**
 * AI orchestration layer.
 *
 * Forwards to the bound primary provider behind the [AiProvider] abstraction
 * and, since Phase 10C, applies a fallback policy when a secondary provider is
 * configured. The controller, the `/ai/query` contract and [AiResponseDto] are
 * untouched: a fallback answer is an ordinary normalized response.
 *
 * Fallback is attempted only for transient primary failures — network failure,
 * timeout, HTTP 5xx and an unusable upstream completion — all of which arrive
 * as a retryable `AiProviderFailure`. HTTP 4xx, request validation problems and
 * a missing primary configuration are never retried: a second provider would
 * reject the same request, and masking them would hide real faults.
 *
 * Phase 10D adds one log line per provider attempt through the framework's
 * [Logger] — no telemetry service, no new dependency. Prompts and responses are
 * never recorded.
 */
@Injectable()
export class AiService {
  constructor(
    @Inject(AI_PROVIDER) private readonly provider: AiProvider,
    @Inject(AI_FALLBACK_PROVIDER) private readonly fallback: AiProvider | null,
    private readonly duffelService: DuffelService,
  ) {}

  // استخراج بيانات البحث عن سفر من النص العربي
  private extractTravelSearchData(prompt: string): { isTravelSearch: boolean; searchData?: any } {
    const travelKeywords = ['طيران', 'رحلة', 'سفر', 'حجز', 'أريد طيران', 'عايز طيران', 'ابغى سفر', 'حجز تذكرة'];
    const isTravelSearch = travelKeywords.some(keyword => prompt.includes(keyword));
    
    if (!isTravelSearch) return { isTravelSearch: false };

    const citiesPattern = /من\s*([\u0600-\u06FF\w]+)\s*إلى\s*([\u0600-\u06FF\w]+)/;
    const datePattern = /في\s*(\d{4}-\d{2}-\d{2})|يوم\s*(\d{1,2})\s*(\w+)/;
    
    const citiesMatch = prompt.match(citiesPattern);
    const dateMatch = prompt.match(datePattern);

    const defaultDate = new Date();
    defaultDate.setDate(defaultDate.getDate() + 7); // إفتراضي: بعد أسبوع

    const searchData = {
      origin: citiesMatch?.[1] || '',
      destination: citiesMatch?.[2] || '',
      departureDate: dateMatch?.[1] || defaultDate.toISOString().split('T')[0],
      passengers: 1,
    };

    return { isTravelSearch: true, searchData };
  }

  private readonly logger = new Logger(AiService.name);

  async query(prompt: string, context?: AiContextDto | null): Promise<AiResponseDto> {
    const startedAt = Date.now();
    // Prepend context to the prompt if it exists, enhance context-aware prompt for geolocation/travelDates
    let fullPrompt = prompt;
    if (context) {
      const contextParts: string[] = [];
      contextParts.push(`route: ${context.route}`);
      if (context.screenTitle) contextParts.push(`screenTitle: ${context.screenTitle}`);
      if (context.geolocation?.lat && context.geolocation?.lng) {
        contextParts.push(`userLocation: lat ${context.geolocation.lat}, lng ${context.geolocation.lng}`);
      }
      if (context.travelDates?.from && context.travelDates?.to) {
        contextParts.push(`travelPeriod: from ${context.travelDates.from} to ${context.travelDates.to}`);
      }
      if (context.selectedOfferIds?.length) contextParts.push(`selectedOffers: ${context.selectedOfferIds.join(', ')}`);
      if (context.metadata && Object.keys(context.metadata).length) {
        contextParts.push(`metadata: ${JSON.stringify(context.metadata)}`);
      }
      
      const contextStr = contextParts.join('\n');
      fullPrompt = `Current application context:\n${contextStr}\n\nUser's actual query: ${prompt}`;
    }

    // التحقق إذا كان الطلب بحث عن سفر
    const { isTravelSearch, searchData } = this.extractTravelSearchData(prompt);
    if (isTravelSearch && searchData && searchData.origin && searchData.destination) {
      try {
        const flights = await this.duffelService.searchFlights(
          searchData.origin,
          searchData.destination,
          searchData.departureDate,
          searchData.passengers,
        );

        // تحويل النتائج لتنسيق AiResponseDto
        const flightItems = (flights.offers || []).map((offer: any) => ({
          id: offer.id,
          type: 'flight',
          title: `${searchData.origin} → ${searchData.destination}`,
          subtitle: offer.origin_city || 'رحلة جوية',
          price: parseFloat(offer.total_amount),
          currency: offer.currency,
        }));

        this.record({
          provider: this.provider.providerId,
          fallbackUsed: false,
          outcome: 'success',
          latencyMs: Date.now() - startedAt,
        });

        return {
          text: `تم العثور على ${flightItems.length} رحلة متاحة من ${searchData.origin} إلى ${searchData.destination}!`,
          sections: [{
            id: 'flight-results',
            title: 'الرحلات المتاحة',
            layout: 'vertical',
            items: flightItems,
          }],
          metadata: { searchData, flightCount: flightItems.length },
        };
      } catch (searchError) {
        this.logger.error(`Failed to search flights: ${(searchError as Error).message}`);
      }
    }

    try {
      const response = await this.provider.generate(fullPrompt);
      this.record({
        provider: this.provider.providerId,
        fallbackUsed: false,
        outcome: 'success',
        latencyMs: Date.now() - startedAt,
      });
      return response;
    } catch (error) {
      this.record({
        provider: this.provider.providerId,
        fallbackUsed: false,
        outcome: 'failure',
        latencyMs: Date.now() - startedAt,
        category: categoryOf(error),
        upstreamStatus: upstreamStatusOf(error),
      });

      if (this.fallback === null || !isFallbackEligible(error)) {
        throw error;
      }
      return this.queryFallback(fullPrompt);
    }
  }

  /**
   * Runs the secondary provider once.
   *
   * When it also fails the caller receives a single generic 503. Neither
   * provider's message is forwarded, so no upstream body, host or credential
   * can travel out through the combined failure.
   */
  private async queryFallback(prompt: string): Promise<AiResponseDto> {
    const fallback = this.fallback;
    if (fallback === null) {
      throw new ServiceUnavailableException('All AI providers are unavailable.');
    }

    const startedAt = Date.now();
    try {
      const response = await fallback.generate(prompt);
      this.record({
        provider: fallback.providerId,
        fallbackUsed: true,
        outcome: 'success',
        latencyMs: Date.now() - startedAt,
      });
      return response;
    } catch (error) {
      this.record({
        provider: fallback.providerId,
        fallbackUsed: true,
        outcome: 'failure',
        latencyMs: Date.now() - startedAt,
        category: categoryOf(error),
        upstreamStatus: upstreamStatusOf(error),
      });
      throw new ServiceUnavailableException('All AI providers are unavailable.');
    }
  }

  /** Emits one sanitized line: successes at log level, failures at warn. */
  private record(record: AiAttemptRecord): void {
    const line = formatAiAttempt(record);
    if (record.outcome === 'success') {
      this.logger.log(line);
    } else {
      this.logger.warn(line);
    }
  }
}