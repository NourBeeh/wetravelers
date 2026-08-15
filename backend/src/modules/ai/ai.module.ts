import { Module } from '@nestjs/common';

import { AI_PROVIDER } from './ai.provider';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { OpenAiAiProvider } from './openai.ai.provider';

/**
 * AI module.
 *
 * The controller/service only see the AiProvider abstraction. The live
 * binding is the real OpenAI-compatible provider, configured entirely through
 * environment variables (AI_API_KEY / AI_BASE_URL / AI_MODEL) — no secrets in
 * code. The MockAiProvider stays available for local/dev use but is no longer
 * bound.
 */
@Module({
  controllers: [AiController],
  providers: [AiService, { provide: AI_PROVIDER, useClass: OpenAiAiProvider }],
})
export class AiModule {}
