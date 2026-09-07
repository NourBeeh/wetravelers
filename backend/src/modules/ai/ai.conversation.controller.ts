import { Body, Controller, Inject, Post, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';

import { AI_PROVIDER, AiProvider } from './ai.provider';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ProfileService } from '../profile/profile.service';
import { RelevantMemorySelector } from '../memory/relevant_memory_selector';
import { ConversationMemoryService } from '../memory/conversation_memory.service';
import {
  AiChatDto,
  AiContextDto,
  AiResponseDto,
} from '../../common/dto/ai.dto';

/**
 * Authenticated AI conversation endpoint (Phase 2C-B).
 *
 * POST /ai/chat — the ONLY surface where explicit conversation memories
 * (Phase 2C-A) reach the AI. Strictly JWT-guarded: a guest is rejected with
 * 401 before any memory lookup happens, and the userId used for selection
 * AND extraction always comes from the JWT — never from the body.
 *
 * Flow (§ the phase decision):
 *   user message
 *     → RelevantMemorySelector   (relevant explicit memories only, capped)
 *     → safe AI context block     (structured facts, already validated)
 *     → AI provider / OpenRouter  (block rides the SYSTEM prompt)
 *     → response                  (unchanged AiResponseDto contract)
 *
 * Failure isolation (§19 pattern): selector/extraction/context problems are
 * logged by COUNT only and swallowed — /ai/chat must answer exactly like
 * /ai/query when memory is unavailable. Personalization-disabled users get
 * the plain /ai/query behavior: no lookup, no context, no extraction.
 *
 * This endpoint is ADDITIVE: /ai/query keeps its guest-friendly,
 * memory-free contract untouched (Flutter calls it unchanged).
 */
@Controller('ai')
export class AiConversationController {
  constructor(
    private readonly aiService: AiService,
    private readonly profiles: ProfileService,
    private readonly selector: RelevantMemorySelector,
    private readonly conversationMemory: ConversationMemoryService,
    @Inject(AI_PROVIDER) private readonly ai: AiProvider,
  ) {}

  @Post('chat')
  @UseGuards(JwtAuthGuard)
  async chat(
    @Req() req: Request,
    @Body() dto: AiChatDto,
  ): Promise<AiResponseDto> {
    const userId = authenticatedUserId(req);

    // Personalization opt-out: NO memory lookup, NO memory context, NO
    // extraction — but the memories themselves stay in the DB untouched.
    let personalizationEnabled = true;
    try {
      const profile = await this.profiles.getOrCreate(userId);
      personalizationEnabled = profile.personalizationEnabled ?? true;
    } catch {
      personalizationEnabled = true; // Profile failure → default behavior.
    }

    let memoryContext: string | null = null;
    if (personalizationEnabled) {
      memoryContext = await this.buildMemoryContextSafe(userId, dto.prompt);
    }

    const response = await this.aiService.query(
      dto.prompt,
      dto.context ?? null,
      memoryContext,
    );

    // Extraction is fire-and-forget by contract: it must never change the
    // response the user already received. (Failure was already swallowed
    // inside the service; nothing here can throw past this point.)
    if (personalizationEnabled) {
      await this.extractMemoriesSafe(userId, dto.prompt, response);
    }

    return response;
  }

  /**
   * Relevant memories → one structured system-prompt block. Any failure
   * degrades to null (no context) — logged by count, never by value.
   */
  private async buildMemoryContextSafe(
    userId: string,
    message: string,
  ): Promise<string | null> {
    try {
      const relevant = await this.selector.selectRelevant(userId, message);
      if (relevant.length === 0) return null;
      return buildMemoryContextBlock(relevant);
    } catch (error) {
      return null; // Context construction failure → memory-free AI call.
    }
  }

  /** Best-effort explicit-memory extraction; never rethrows. */
  private async extractMemoriesSafe(
    userId: string,
    message: string,
    _response: AiResponseDto,
  ): Promise<void> {
    try {
      // The 2C-A service already swallows provider/parse/validation
      // failures; this guard covers unexpected wiring errors too.
      await this.conversationMemory.extractFromMessage(userId, message);
    } catch {
      // Extraction must never fail the chat response.
    }
  }
}

/**
 * The safe AI-context block built from RELEVANT explicit memories only
 * (never a dump). The values were validated at write time by the Phase 2C-A
 * vocabulary validator; the block is rebuilt here from the stored facts.
 */
export function buildMemoryContextBlock(memories: any[]): string {
  const lines: string[] = [];
  for (const memory of memories) {
    const value = (memory?.value ?? {}) as Record<string, any>;
    const kind = memory?.key?.split(':')[0] ?? '';
    switch (kind) {
      case 'preferred_destination':
        if (typeof value.destination === 'string' && value.destination) {
          lines.push(`- Preferred destination: ${value.destination}`);
        }
        break;
      case 'preferred_budget':
        lines.push(
          `- Preferred budget: ${formatBudget(value.min, value.max)}`,
        );
        break;
      case 'preferred_travel_style':
        if (Array.isArray(value.styles) && value.styles.length > 0) {
          lines.push(`- Preferred travel styles: ${value.styles.join(', ')}`);
        }
        break;
      default:
        break; // Unknown kinds are never rendered into the prompt.
    }
  }
  if (lines.length === 0) return '';
  return [
    'The user previously stated these travel preferences explicitly in past conversations:',
    ...lines,
    'Use them only when relevant to the current request.',
  ].join('\n');
}

function formatBudget(min: unknown, max: unknown): string {
  const parts: string[] = [];
  if (typeof min === 'number' && Number.isFinite(min)) parts.push(`min ${min}`);
  if (typeof max === 'number' && Number.isFinite(max)) parts.push(`max ${max}`);
  return parts.length > 0 ? parts.join(', ') : 'unspecified';
}

/** JWT user id — the only identity source for memory reads and writes. */
function authenticatedUserId(req: Request): string {
  const user = req.user as { id?: string } | undefined;
  if (!user?.id) throw new Error('Authenticated request missing user id.');
  return user.id;
}
