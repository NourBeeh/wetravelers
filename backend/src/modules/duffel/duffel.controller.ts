import { Controller, Post, Body } from '@nestjs/common';
import { DuffelService } from './duffel.service';

@Controller('api/duffel')
export class DuffelController {
  constructor(private readonly duffelService: DuffelService) {}

  @Post('search-flights')
          async searchFlights(
            @Body() body: { origin: string; destination: string; departureDate: string; passengers: number },
          ) {
            return this.duffelService.searchFlights({
              origin: body.origin,
              destination: body.destination,
              departure: new Date(body.departureDate),
              passengers: body.passengers,
            });
          }

  @Post('create-booking')
          async createBooking(
            @Body() body: { offerId: string; passengers: any[]; payments: any[] },
          ) {
            return this.duffelService.createOrder(
              body.offerId,
              body.passengers,
              body.payments,
            );
          }
}