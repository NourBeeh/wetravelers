import { IsInt, IsOptional, Max, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export class RecommendedHotelsQueryDto {
  /** Number of cards to return (5-10, default 6). */
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  @Min(1)
  @Max(12)
  limit?: number;

  /** Country code (ISO-2). The engine enriches from the profile/geo when absent. */
  @IsOptional()
  code?: string;
}
