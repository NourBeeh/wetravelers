import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { AI_FALLBACK_PROVIDER, AI_PROVIDER, AiProvider } from './ai.provider';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { MockAiProvider } from './mock.ai.provider';
import { OpenAiAiProvider } from './openai.ai.provider';

/** Fallback providers selectable through `AI_FALLBACK_PROVIDER`. */
const FALLBACK_FACTORIES: Record<string, () => AiProvider> = {
  mock: () => new MockAiProvider(),
};

/**
 * Resolves the optional secondary provider from configuration.
 *
 * An empty or absent `AI_FALLBACK_PROVIDER` yields `null`, which disables the
 * fallback policy and leaves single-provider behaviour exactly as it was. An
 * unrecognised value fails at boot rather than silently disabling fallback,
 * so a typo cannot masquerade as "fallback intentionally off".
 */
export function resolveFallbackProvider(config: ConfigService): AiProvider | null {
  const configured = (config.get<string>('AI_FALLBACK_PROVIDER') ?? '')
    .trim()
    .toLowerCase();
  if (configured === '') {
    return null;
  }
  const factory = FALLBACK_FACTORIES[configured];
  if (factory === undefined) {
    throw new Error(
      `Unsupported AI_FALLBACK_PROVIDER "${configured}". ` +
        `Supported values: ${Object.keys(FALLBACK_FACTORIES).join(', ')}, ` +
        `or empty to disable fallback.`,
    );
  }
  return factory();
}

/**
 * AI module.
 *
 * The controller/service only see the AiProvider abstraction. The live
 * binding is the real OpenAI-compatible provider, configured entirely through
 * environment variables (AI_API_KEY / AI_BASE_URL / AI_MODEL) — no secrets in
 * code. `AI_FALLBACK_PROVIDER` optionally binds a second provider that
 * [AiService] consults only for transient primary failures.
 */
@Module({
  controllers: [AiController],
  providers: [
    AiService,
    { provide: AI_PROVIDER, useClass: OpenAiAiProvider },
    {
      provide: AI_FALLBACK_PROVIDER,
      inject: [ConfigService],
      useFactory: resolveFallbackProvider,
    },
  ],
})
export class AiModule {}
