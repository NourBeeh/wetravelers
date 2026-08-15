import { Inject, Injectable } from '@nestjs/common';

import { AiResponseDto } from '../../common/dto/ai.dto';
import { AI_PROVIDER, AiProvider } from './ai.provider';

/**
 * AI orchestration layer.
 *
 * Kept intentionally thin: validates/forwards to the bound AI provider behind
 * the [AiProvider] abstraction. Future phases add guardrails, multi-provider
 * fallback or aggregation here without touching the controller or Flutter.
 */
@Injectable()
export class AiService {
  constructor(@Inject(AI_PROVIDER) private readonly provider: AiProvider) {}

  async query(prompt: string): Promise<AiResponseDto> {
    return this.provider.generate(prompt);
  }
}