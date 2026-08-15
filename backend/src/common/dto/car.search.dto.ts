import { IsString, IsDateString } from 'class-validator';

export class CarSearchDto {
  @IsString()
  pickupLocation: string;

  @IsDateString()
  pickupTime: Date;

  @IsDateString()
  dropoffTime: Date;
}
