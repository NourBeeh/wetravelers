import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Duffel } from '@duffel/api';
import { FlightProvider } from '../../common/providers/flight.provider';
import { ProviderResult } from '../../common/providers/provider.result';

export const CITY_TO_IATA: Record<string, string> = {
  // Egypt
  'cairo': 'CAI', 'القاهرة': 'CAI', 'القاهره': 'CAI', 'مصر': 'CAI', 'cai': 'CAI',
  'alexandria': 'HBE', 'الاسكندرية': 'HBE', 'الإسكندرية': 'HBE', 'الاسكندريه': 'HBE',
  'hurghada': 'HRG', 'الغردقة': 'HRG', 'الغردقه': 'HRG',
  'sharm el sheikh': 'SSH', 'شرم الشيخ': 'SSH',
  'luxor': 'LXR', 'الأقصر': 'LXR', 'الاقصر': 'LXR',
  'aswan': 'ASW', 'أسوان': 'ASW', 'اسوان': 'ASW',

  // UAE
  'dubai': 'DXB', 'دبي': 'DXB', 'dxb': 'DXB',
  'abu dhabi': 'AUH', 'أبوظبي': 'AUH', 'ابوظبي': 'AUH', 'auh': 'AUH',
  'sharjah': 'SHJ', 'الشارقة': 'SHJ', 'الشارقه': 'SHJ',

  // Saudi Arabia
  'riyadh': 'RUH', 'الرياض': 'RUH', 'ruh': 'RUH',
  'jeddah': 'JED', 'جدة': 'JED', 'جده': 'JED', 'jed': 'JED',
  'dammam': 'DMM', 'الدمام': 'DMM', 'dmm': 'DMM',
  'medina': 'MED', 'المدينة': 'MED', 'المدينة المنورة': 'MED', 'المدينه': 'MED',
  'mecca': 'JED', 'مكة': 'JED', 'مكة المكرمة': 'JED', 'مكه': 'JED',

  // UK & Europe
  'london': 'LHR', 'لندن': 'LHR', 'lhr': 'LHR', 'gatwick': 'LGW', 'lgw': 'LGW',
  'paris': 'CDG', 'باريس': 'CDG', 'cdg': 'CDG',
  'rome': 'FCO', 'روما': 'FCO', 'fco': 'FCO',
  'milan': 'MXP', 'ميلان': 'MXP', 'ميلانو': 'MXP', 'mxp': 'MXP',
  'madrid': 'MAD', 'مدريد': 'MAD', 'mad': 'MAD',
  'barcelona': 'BCN', 'برشلونة': 'BCN', 'برشلونه': 'BCN', 'bcn': 'BCN',
  'amsterdam': 'AMS', 'أمستردام': 'AMS', 'امستردام': 'AMS', 'ams': 'AMS',
  'berlin': 'BER', 'برلين': 'BER', 'ber': 'BER',
  'frankfurt': 'FRA', 'فرانكفورت': 'FRA', 'fra': 'FRA',
  'munich': 'MUC', 'ميونخ': 'MUC', 'ميونيخ': 'MUC', 'muc': 'MUC',
  'vienna': 'VIE', 'فيينا': 'VIE', 'vie': 'VIE',
  'istanbul': 'IST', 'اسطنبول': 'IST', 'إسطنبول': 'IST', 'ist': 'IST',
  'athens': 'ATH', 'أثينا': 'ATH', 'اثينا': 'ATH', 'ath': 'ATH',

  // USA & Americas
  'new york': 'JFK', 'نيويورك': 'JFK', 'jfk': 'JFK', 'nyc': 'JFK',
  'los angeles': 'LAX', 'لوس انجلوس': 'LAX', 'لوس أنجلوس': 'LAX', 'lax': 'LAX',
  'chicago': 'ORD', 'شيكاغو': 'ORD', 'ord': 'ORD',
  'miami': 'MIA', 'ميامي': 'MIA', 'mia': 'MIA',
  'san francisco': 'SFO', 'سان فرانسيسكو': 'SFO', 'sfo': 'SFO',
  'toronto': 'YYZ', 'تورونتو': 'YYZ', 'yyz': 'YYZ',

  // Middle East & North Africa
  'doha': 'DOH', 'الدوحة': 'DOH', 'الدوحه': 'DOH', 'قطر': 'DOH', 'doh': 'DOH',
  'kuwait': 'KWI', 'الكويت': 'KWI', 'kwi': 'KWI',
  'manama': 'BAH', 'المنامة': 'BAH', 'المنامه': 'BAH', 'البحرين': 'BAH', 'bah': 'BAH',
  'muscat': 'MCT', 'مسقط': 'MCT', 'عمان': 'MCT', 'سلطنة عمان': 'MCT', 'mct': 'MCT',
  'amman': 'AMM', 'عمان الأردن': 'AMM', 'عمّان': 'AMM', 'الأردن': 'AMM', 'amm': 'AMM',
  'beirut': 'BEY', 'بيروت': 'BEY', 'لبنان': 'BEY', 'bey': 'BEY',
  'casablanca': 'CMN', 'الدار البيضاء': 'CMN', 'كازابلانكا': 'CMN', 'المغرب': 'CMN', 'cmn': 'CMN',
  'tunis': 'TUN', 'تونس': 'TUN', 'tun': 'TUN',
  'algiers': 'ALG', 'الجزائر': 'ALG', 'alg': 'ALG',

  // Asia
  'tokyo': 'HND', 'طوكيو': 'HND', 'hnd': 'HND', 'nrt': 'NRT',
  'bangkok': 'BKK', 'بانكوك': 'BKK', 'تايلاند': 'BKK', 'bkk': 'BKK',
  'singapore': 'SIN', 'سنغافورة': 'SIN', 'سنغافوره': 'SIN', 'sin': 'SIN',
  'kuala lumpur': 'KUL', 'كوالالمبور': 'KUL', 'ماليزيا': 'KUL', 'kul': 'KUL',
};

export function resolveIataCode(input: string): string {
  if (!input) return '';
  const trimmed = input.trim().toLowerCase();
  if (CITY_TO_IATA[trimmed]) {
    return CITY_TO_IATA[trimmed];
  }
  // If it's already a 3-letter string, return it in uppercase
  if (/^[a-zA-Z]{3}$/.test(trimmed)) {
    return trimmed.toUpperCase();
  }
  return input.trim().toUpperCase();
}

@Injectable()
export class DuffelService implements FlightProvider {
  providerId = 'duffel-flight';
  providerName = 'Duffel Flight Provider';
  
  private duffelClient?: Duffel;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('DUFFEL_ACCESS_TOKEN') || this.configService.get<string>('DUFFEL_API_KEY');
    if (!apiKey) {
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
      const originCode = resolveIataCode(params.origin);
      const destCode = resolveIataCode(params.destination);
      const departureDate = params.departure instanceof Date 
        ? params.departure.toISOString().split('T')[0]
        : String(params.departure).split('T')[0];
      const passengersCount = params.passengers ?? 1;

      // Create offer request with Duffel API
      const request = await this.duffelClient?.offerRequests.create({
        slices: [
          {
            origin: originCode,
            destination: destCode,
            departure_date: departureDate,
          } as any
        ],
        passengers: Array(passengersCount).fill({ type: 'adult' }),
        return_offers: true,
      });

      // Map Duffel's response to the shared flight offer format matching Flutter contract
      const mappedOffers = (request?.data?.offers || []).map((offer: any) => {
        const firstSlice = offer.slices?.[0];
        const firstSegment = firstSlice?.segments?.[0];
        const lastSegment = firstSlice?.segments?.[firstSlice.segments.length - 1];
        const originIata = firstSlice?.origin?.iata_code ?? originCode;
        const destIata = firstSlice?.destination?.iata_code ?? destCode;
        const airlineName = offer.owner?.name ?? firstSegment?.marketing_carrier?.name ?? 'Airline';
        const flightNum = firstSegment?.marketing_carrier_flight_number
          ? `${firstSegment?.marketing_carrier?.iata_code ?? ''}${firstSegment.marketing_carrier_flight_number}`
          : '';

        return {
          id: offer.id,
          type: 'flight',
          providerId: this.providerId,
          providerName: this.providerName,
          title: `${originIata} → ${destIata}`,
          subtitle: airlineName,
          origin: originIata,
          destination: destIata,
          departureTime: firstSegment?.departing_at ?? departureDate,
          arrivalTime: lastSegment?.arriving_at ?? departureDate,
          airline: airlineName,
          flightNumber: flightNum,
          price: parseFloat(offer.total_amount || '0'),
          currency: offer.total_currency ?? offer.currency ?? 'USD',
          duration: firstSlice?.duration,
          stops: Math.max(0, (firstSlice?.segments?.length ?? 1) - 1),
          // Price provenance (spec point 7): search prices are provisional.
          metadata: {
            providerOfferId: offer.id,
            retrievedAt: new Date().toISOString(),
            expiresAt:
              offer.expires_at ??
              new Date(Date.now() + 30 * 60 * 1000).toISOString(),
          },
        };
      });

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

  /**
   * Revalidation (spec points 7-8): fetch the live offer and return its
   * authoritative price/availability + expiry. The caller (offers
   * controller) compares against the known price and produces a structured
   * PRICE_CHANGED outcome instead of charging silently.
   */
  async revalidateOffer(offerId: string): Promise<ProviderResult<any>> {
    if (!this.duffelClient) {
      return {
        success: false,
        providerId: this.providerId,
        providerName: this.providerName,
        error: 'Duffel API is not configured',
        timestamp: new Date(),
      };
    }
    try {
      const response = await this.duffelClient.offers.get(offerId);
      const offer = response?.data ?? response;
      const price = parseFloat(offer?.total_amount ?? '0');
      const currency = offer?.total_currency ?? 'USD';
      return {
        success: true,
        providerId: this.providerId,
        providerName: this.providerName,
        data: {
          price,
          currency,
          // Duffel offers expire; expose provider truth when present.
          expiresAt: offer?.expires_at ?? new Date(Date.now() + 30 * 60 * 1000).toISOString(),
          available: price > 0,
          rawId: offerId,
        },
        timestamp: new Date(),
      };
    } catch (error) {
      return {
        success: false,
        providerId: this.providerId,
        providerName: this.providerName,
        error: `Failed to revalidate offer: ${(error as Error).message}`,
        timestamp: new Date(),
      };
    }
  }
}