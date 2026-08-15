import { IsString, IsDateString, IsOptional, IsInt, Min } from 'class-validator';

export class FlightSearchDto {
  @IsString()
  origin: string;

  @IsString()
  destination: string;

  @IsDateString()
  departure: Date;

  @IsOptional()
  @IsDateString()
  returnDate?: Date;

  @IsOptional()
  @IsInt()
  @Min(1)
  passengers?: number;
}
