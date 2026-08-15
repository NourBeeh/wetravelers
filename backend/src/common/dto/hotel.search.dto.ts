import { IsString, IsDateString, IsOptional, IsInt, Min } from 'class-validator';

export class HotelSearchDto {
  @IsString()
  city: string;

  @IsDateString()
  checkIn: Date;

  @IsDateString()
  checkOut: Date;

  @IsOptional()
  @IsInt()
  @Min(1)
  guests?: number;
}
