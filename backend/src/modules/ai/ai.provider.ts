import { AiResponseDto } from '../../common/dto/ai.dto';

/** DI token so Phase 9 can bind Grok/Gemini/DeepSeek providers without
 *  touching the controller or the service. */
export const AI_PROVIDER = Symbol('AI_PROVIDER');

/**
 * AI provider abstraction.
 *
 * Every provider (mock today, real AI providers later) returns the same
 * normalized [AiResponseDto]; the provider identity never leaks into the
 * response so Flutter stays provider-agnostic.
 */
export interface AiProvider {
  readonly providerId: string;
  readonly providerName: string;

  /** Produces a normalized [AiResponseDto] for the given prompt. */
  generate(prompt: string): Promise<AiResponseDto>;
}