import {
  IsBoolean,
  IsDateString,
  IsIn,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  Length,
  Max,
  Min,
} from 'class-validator';

/**
 * Memory DTOs (Phase 2A — Foundation).
 *
 * The memory spine stores STRUCTURED FACTS only: `key → value` with a
 * provenance source and a validated confidence. Full conversation
 * transcripts and any sensitive material are rejected BEFORE persistence —
 * `containsSensitiveData()` performs a recursive scan of the value tree so a
 * forbidden key cannot hide at any nesting depth.
 */

/** All memory categories the spine understands. */
export const MEMORY_TYPES = [
  'preference',
  'behavior',
  'conversation',
  'derived',
] as const;

/** All provenance sources a memory record can carry. */
export const MEMORY_SOURCES = [
  'user_explicit',
  'behavior_event',
  'ai_conversation',
  'system_derived',
] as const;

/**
 * Keys that must NEVER be persisted in a memory value — at any depth.
 * Covers credentials, payment material, and precise location (country-level
 * geo is fine; coordinates are not).
 */
const SENSITIVE_KEY_FRAGMENTS = [
  'password',
  'passwd',
  'token',
  'secret',
  'credential',
  'authorization',
  'card',
  'payment',
  'cvv',
  'latitude',
  'longitude',
  'accesstoken',
  'refreshtoken',
];

export function containsSensitiveData(value: unknown): boolean {
  return _scan(value);
}

function _scan(node: unknown): boolean {
  if (node === null || node === undefined) return false;
  if (Array.isArray(node)) return node.some((entry) => _scan(entry));
  if (typeof node === 'object') {
    for (const [key, child] of Object.entries(node as Record<string, unknown>)) {
      const normalized = key.toLowerCase().replace(/[^a-z]/g, '');
      if (SENSITIVE_KEY_FRAGMENTS.some((frag) => normalized.includes(frag))) {
        return true;
      }
      if (_scan(child)) return true;
    }
  }
  return false;
}

export class CreateMemoryDto {
  @IsIn(MEMORY_TYPES as unknown as string[])
  type!: string;

  @IsString()
  @Length(1, 120)
  key!: string;

  /** Structured fact value (object) or a scalar fact. */
  @IsObject()
  value!: Record<string, any>;

  @IsIn(MEMORY_SOURCES as unknown as string[])
  source!: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  confidence?: number;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class UpdateMemoryDto {
  /** Value/source/confidence/expiresAt only — `type` and `key` are the
   * record's identity and are immutable through update (the upsert path is
   * the only way to "change" them, by rewriting the same logical fact). */
  @IsOptional()
  @IsObject()
  value?: Record<string, any>;

  @IsOptional()
  @IsIn(MEMORY_SOURCES as unknown as string[])
  source?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  confidence?: number;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class ListMemoryQueryDto {
  @IsOptional()
  @IsIn(MEMORY_TYPES as unknown as string[])
  type?: string;

  @IsOptional()
  @IsIn(MEMORY_SOURCES as unknown as string[])
  source?: string;

  /** When true, expired records are included in the listing (the default
   * hides them; documented + tested Phase 2A behaviour). */
  @IsOptional()
  @IsBoolean()
  includeExpired?: boolean;
}
