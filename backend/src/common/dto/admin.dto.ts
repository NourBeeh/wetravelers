import {
  IsArray,
  IsBoolean,
  IsDateString,
  IsIn,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

/** Section layouts exactly as the Flutter Home repository parses them. */
export const SECTION_LAYOUTS = [
  'horizontal',
  'horizontalpeek',
  'grid',
  'vertical',
] as const;

/** Card types exactly as HomeCardType on the Flutter side. */
export const CARD_TYPES = [
  'flight',
  'hotel',
  'car',
  'package',
  'destination',
  'deal',
] as const;

/** Content lifecycle: drafts stay invisible to the public home feed. */
export const CONTENT_STATUSES = ['draft', 'published'] as const;

export class CreateSectionDto {
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  subtitle?: string;

  @IsIn(SECTION_LAYOUTS as unknown as string[])
  layout!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;

  @IsOptional()
  @IsBoolean()
  isVisible?: boolean;

  @IsOptional()
  @IsIn(CONTENT_STATUSES as unknown as string[])
  status?: string;

  /** Publication time: the public feed hides the section until then. */
  @IsOptional()
  @IsDateString()
  publishAt?: string;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class UpdateSectionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  subtitle?: string;

  @IsOptional()
  @IsIn(SECTION_LAYOUTS as unknown as string[])
  layout?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;

  @IsOptional()
  @IsBoolean()
  isVisible?: boolean;

  @IsOptional()
  @IsIn(CONTENT_STATUSES as unknown as string[])
  status?: string;

  @IsOptional()
  @IsDateString()
  publishAt?: string;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class CreateCardDto {
  @IsString()
  @MinLength(1)
  sectionId!: string;

  @IsIn(CARD_TYPES as unknown as string[])
  cardType!: string;

  /** Presentation payload: title/price/rating/... (flattened by HomeService). */
  @IsObject()
  content!: Record<string, any>;

  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;

  @IsOptional()
  @IsBoolean()
  isVisible?: boolean;

  @IsOptional()
  @IsIn(CONTENT_STATUSES as unknown as string[])
  status?: string;

  @IsOptional()
  @IsDateString()
  publishAt?: string;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class UpdateCardDto {
  @IsOptional()
  @IsIn(CARD_TYPES as unknown as string[])
  cardType?: string;

  /** Partial patch: provided keys are merged into the persisted content. */
  @IsOptional()
  @IsObject()
  content?: Record<string, any>;

  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;

  @IsOptional()
  @IsBoolean()
  isVisible?: boolean;

  @IsOptional()
  @IsIn(CONTENT_STATUSES as unknown as string[])
  status?: string;

  @IsOptional()
  @IsDateString()
  publishAt?: string;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class ReorderDto {
  /** Entity ids in their new display order. */
  @IsArray()
  @IsString({ each: true })
  ids!: string[];
}

export class UpdateProviderStatusDto {
  @IsBoolean()
  isActive!: boolean;
}

export class UpdateProviderPriorityDto {
  @IsInt()
  @Min(0)
  priority!: number;
}

export class UpdateProviderConfigDto {
  @IsObject()
  config!: Record<string, any>;
}
