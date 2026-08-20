import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Duffel } from '@duffel/api';

@Injectable()
export class DuffelService {
  private duffelClient: Duffel;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('DUFFEL_API_KEY');
    if (!apiKey) {
      throw new Error('DUFFEL_API_KEY is not defined in environment variables');
    }
    this.duffelClient = new Duffel({ token: apiKey });
  }

  async searchFlights(originIata: string, destinationIata: string, departureDate: string, passengersCount: number) {
            try {
              // بنضيف وقت الإقلاع الافتراضي (صباحاً) لتحقيق المتطلبات
              const request = await this.duffelClient.offerRequests.create({
                slices: [
                  {
                    origin: originIata,
                    destination: destinationIata,
                    departure_date: departureDate,
                    departure_time: '10:00:00',
                    arrival_time: '14:00:00',
                  }
                ],
                passengers: Array(passengersCount).fill({ type: 'adult' }),
              });
              return request.data;
            } catch (error) {
              throw new Error(`Failed to search flights: ${(error as Error).message}`);
            }
          }

          async createOrder(offerId: string, passengers: any[], payments: any[]) {
            try {
              // لازم نضيف type: 'instant' عشان هو المطلوب في Duffel API
              const response = await this.duffelClient.orders.create({
                type: 'instant',
                selected_offers: [offerId],
                passengers,
                payments,
              });
              return response.data;
            } catch (error) {
              throw new Error(`Failed to create booking: ${(error as Error).message}`);
            }
          }
}