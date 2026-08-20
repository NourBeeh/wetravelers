import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Duffel } from '@duffel/api';
import { FlightProvider } from '../../common/providers/flight.provider';
import { ProviderResult } from '../../common/providers/provider.result';

@Injectable()
export class DuffelService implements FlightProvider {
  providerId = 'duffel-flight';
  providerName = 'Duffel Flight Provider';
  
  private duffelClient?: Duffel;

  constructor(private configService: ConfigService) {
    // Try primary token first, fall back to API key alias for backward compatibility
    const apiKey = this.configService.get<string>('DUFFEL_ACCESS_TOKEN') || this.configService.get<string>('DUFFEL_API_KEY');
    if (!apiKey) {
      // Log warning but don't throw - allows app to start without Duffel token
      console.warn('DUFFEL_ACCESS_TOKEN (and DUFFEL_API_KEY as fallback) are not defined - Duffel flights will be disabled');
    } else {
      this.duffelClient = new Duffel({ token: apiKey });
    }
  }

  async searchFlights(params: {
    origin: string;
    destination: string;
    departure: Date;
    returnDate?: Date;
    passengers?: number;
  }): Promise<ProviderResult<any[]>> {
    // If no API key configured, return empty results
    if (!this.duffelClient) {
      return {
        success: true,
        providerId: this.providerId,
        providerName: this.providerName,
        data: [],
        timestamp: new Date(),
      };
    }

    try {
      const departureDate = params.departure.toISOString().split('T')[0];
      const passengersCount = params.passengers ?? 1;

      // Create offer request with Duffel API
      const request = await this.duffelClient?.offerRequests.create({
        slices: [
          {
            origin: params.origin,
            destination: params.destination,
            departure_date: departureDate,
            departure_time: {
              from: '06:00:00',
              to: '20:00:00'
            },
          } as any
        ],
        passengers: Array(passengersCount).fill({ type: 'adult' })
      });

      // Map Duffel's response to the shared flight offer format
      const mappedOffers = (request.data?.offers || []).map((offer: any) => ({
        id: offer.id,
        providerId: this.providerId,
        origin: offer.origin,
        destination: offer.destination,
        departureDate: offer.departure_date,
        arrivalDate: offer.arrival_date,
        price: parseFloat(offer.total_amount),
        currency: offer.currency,
        airline: offer.airline?.name,
        flightNumber: offer.flight_number,
        duration: offer.duration,
        stops: offer.stops || 0,
      }));

      return {
        success: true,
        providerId: this.providerId,
        providerName: this.providerName,
        data: mappedOffers,
        timestamp: new Date(),
      };
    } catch (error) {
      return {
        success: false,
        providerId: this.providerId,
        providerName: this.providerName,
        error: `Failed to search flights: ${(error as Error).message}`,
        data: [],
        timestamp: new Date(),
      };
    }
  }

  // Legacy method for backward compatibility with existing AI service
  async searchFlightsLegacy(originIata: string, destinationIata: string, departureDate: string, passengersCount: number) {
    const params = {
      origin: originIata,
      destination: destinationIata,
      departure: new Date(departureDate),
      passengers: passengersCount,
    };
    const result = await this.searchFlights(params);
    return { offers: result.data };
  }

  async createOrder(offerId: string, passengers: any[], payments: any[]) {
    if (!this.duffelClient) {
      throw new Error('Duffel API is not configured - cannot create booking');
    }
    
    try {
      const response = await this.duffelClient.orders.create({
        type: 'instant',
        selected_offers: [offerId],
        passengers,
        payments
      });
      return response.data;
    } catch (error) {
      throw new Error(`Failed to create booking: ${(error as Error).message}`);
    }
  }
}