import { IsString, IsDateString, IsOptional, IsInt, Min } from 'class-validator';

export class FlightSearchDto {
  @IsString()
  origin!: string;

  @IsString()
  destination!: string;

  @IsDateString()
  departure!: Date;

  @IsOptional()
  @IsDateString()
  returnDate?: Date;

  @IsOptional()
  @IsInt()
  @Min(1)
  passengers?: number;

  /** MarketContext selector (ISO-3166-1 alpha-2). Display currency/locale. */
  @IsOptional()
  @IsString()
  market?: string;
}
