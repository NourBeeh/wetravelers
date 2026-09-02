import { IsString, IsDateString, IsOptional, IsInt, Min } from 'class-validator';

export class HotelSearchDto {
  @IsString()
  city!: string;

  @IsDateString()
  checkIn!: Date;

  @IsDateString()
  checkOut!: Date;

  @IsOptional()
  @IsInt()
  @Min(1)
  guests?: number;

  /** MarketContext selector (ISO-3166-1 alpha-2). Display currency/locale. */
  @IsOptional()
  @IsString()
  market?: string;
}
