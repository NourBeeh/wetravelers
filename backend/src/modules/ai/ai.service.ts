import {
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { DuffelService } from '../duffel/duffel.service';

import { AiResponseDto, AiContextDto } from '../../common/dto/ai.dto';
import {
  AI_PROVIDER,
  AiProvider,
  categoryOf,
  upstreamStatusOf,
} from './ai.provider';

interface AiAttemptRecord {
  provider: string;
  outcome: 'success' | 'failure';
  latencyMs: number;
  category?: string;
  upstreamStatus?: number;
}

export function formatAiAttempt(record: AiAttemptRecord): string {
  const parts = [
    `provider=${record.provider}`,
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

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(
    @Inject(AI_PROVIDER) private readonly provider: AiProvider,
    private readonly duffelService: DuffelService,
  ) {}

  private extractTravelSearchData(prompt: string): { isTravelSearch: boolean; searchData?: any } {
    const travelKeywords = ['طيران', 'رحلة', 'سفر', 'حجز', 'أريد طيران', 'عايز طيران', 'ابغى سفر', 'حجز تذكرة'];
    const isTravelSearch = travelKeywords.some(keyword => prompt.includes(keyword));
    
    if (!isTravelSearch) return { isTravelSearch: false };

    const citiesPattern = /من\s*([\u0600-\u06FF\w]+)\s*إلى\s*([\u0600-\u06FF\w]+)/;
    const datePattern = /في\s*(\d{4}-\d{2}-\d{2})|يوم\s*(\d{1,2})\s*(\w+)/;
    
    const citiesMatch = prompt.match(citiesPattern);
    const dateMatch = prompt.match(datePattern);

    const defaultDate = new Date();
    defaultDate.setDate(defaultDate.getDate() + 7);

    const searchData = {
      origin: citiesMatch?.[1] || '',
      destination: citiesMatch?.[2] || '',
      departureDate: dateMatch?.[1] || defaultDate.toISOString().split('T')[0],
      passengers: 1,
    };

    return { isTravelSearch: true, searchData };
  }

  async query(prompt: string, context?: AiContextDto | null): Promise<AiResponseDto> {
    const startedAt = Date.now();
    let fullPrompt = prompt;
    if (context) {
      const contextParts = [];
      if (context.route) contextParts.push(`Location: ${context.route}`);
      if (context.travelDates) contextParts.push(`Travel dates: ${context.travelDates}`);
      if (context.screenTitle) contextParts.push(`Budget: ${context.screenTitle}`);
      if (contextParts.length > 0) {
        fullPrompt = `${contextParts.join(', ')}. ${prompt}`;
      }
    }

    const { isTravelSearch, searchData } = this.extractTravelSearchData(prompt);
    if (isTravelSearch && searchData && searchData.origin && searchData.destination) {
      try {
        const flights = await this.duffelService.searchFlightsLegacy(
          searchData.origin,
          searchData.destination,
          searchData.departureDate,
          searchData.passengers,
        );

        const flightItems = (flights.offers || []).map((offer: any) => ({
          id: offer.id,
          type: 'flight',
          title: offer.title || `${searchData.origin} → ${searchData.destination}`,
          subtitle: offer.subtitle || offer.airline || 'رحلة جوية',
          price: typeof offer.price === 'number' ? offer.price : parseFloat(offer.price || '0'),
          currency: offer.currency || 'USD',
          airline: offer.airline,
          flightNumber: offer.flightNumber,
          data: {
            origin: offer.origin,
            destination: offer.destination,
            departureTime: offer.departureTime,
            arrivalTime: offer.arrivalTime,
          },
        }));

        if (flightItems.length > 0) {
          this.record({
            provider: 'duffel-flight',
            outcome: 'success',
            latencyMs: Date.now() - startedAt,
          });

          return {
            text: `تم العثور على ${flightItems.length} رحلة طيران متاحة من ${searchData.origin} إلى ${searchData.destination}:`,
            sections: [{
              id: 'flight-results',
              title: 'رحلات الطيران المتاحة',
              layout: 'vertical',
              items: flightItems,
            }],
            metadata: { searchData, flightCount: flightItems.length },
          };
        }
      } catch (searchError) {
        this.logger.warn(`Live flight search bypassed: ${(searchError as Error).message}`);
      }
    }

    try {
      const response = await this.provider.generate(fullPrompt);
      this.record({
        provider: this.provider.providerId,
        outcome: 'success',
        latencyMs: Date.now() - startedAt,
      });
      return response;
    } catch (error) {
      this.record({
        provider: this.provider.providerId,
        outcome: 'failure',
        latencyMs: Date.now() - startedAt,
        category: categoryOf(error),
        upstreamStatus: upstreamStatusOf(error),
      });
      throw error;
    }
  }

  private record(record: AiAttemptRecord): void {
    const line = formatAiAttempt(record);
    if (record.outcome === 'success') {
      this.logger.log(line);
    } else {
      this.logger.warn(line);
    }
  }
}
