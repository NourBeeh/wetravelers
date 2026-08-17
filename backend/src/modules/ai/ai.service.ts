import {
  Inject,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';

import { AiResponseDto } from '../../common/dto/ai.dto';
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
  ) {}

  private readonly logger = new Logger(AiService.name);

  async query(prompt: string): Promise<AiResponseDto> {
    const startedAt = Date.now();
    try {
      const response = await this.provider.generate(prompt);
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
      return this.queryFallback(prompt);
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
