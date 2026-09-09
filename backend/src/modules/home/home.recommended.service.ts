import { Injectable, Logger } from '@nestjs/common';
import { NuiteeService } from '../nuitee/nuitee.service';
import { CacheService } from '../cache/cache.service';

/**
 * Phase 7B-slice (user-approved 2026-09-08) — the real source behind the
 * Nuitee-only Home hotel rail.
 *
 * The Flutter Home already calls `GET /home/recommended?limit=N`; until now
 * the route did not exist, so the call 404'd silently and the Home stayed on
 * the empty development preview forever. This service supplies the real
 * provider-backed hotels:
 *
 * - Hotels come from the live Nuitee adapter (searchHotels) — real names,
 *   prices, images. Nothing is invented.
 * - Short cache (5 min): the Home opens constantly; every cold start must
 *   not hammer the provider. Cached prices are presentation snapshots —
 *   booking truth is always /offers/revalidate (spec point 44).
 * - Default city is Cairo (the launch market). The city is configuration,
 *   not a user preference — personalization stays out of this slice (7A/PH-7
 *   own that).
 */

/** Home rail cache: short TTL, provider-backed snapshot only. */
const RECOMMENDED_TTL_SECONDS = 5 * 60;

/** Launch-market default (EG). Configuration, not personalization. */
const DEFAULT_CITY = 'Cairo';
const DEFAULT_COUNTRY = 'EG';
const DEFAULT_GUESTS = 2;

@Injectable()
export class HomeRecommendedService {
  private readonly logger = new Logger(HomeRecommendedService.name);

  constructor(
    private readonly nuitee: NuiteeService,
    private readonly cache: CacheService,
  ) {}

  /**
   * Real recommended hotels for the Home rail. Falls back to an EMPTY list
   * on provider failure (never fake data); the caller decides how to render
   * the honest empty state.
   */
  async getRecommendedHotels(limit = 6): Promise<{ hotels: any[] }> {
    const boundedLimit = Math.min(Math.max(limit, 1), 20);
    const cacheKey = `home:recommended:${DEFAULT_CITY}:${boundedLimit}`;

    const cached = await this.cache.get<{ hotels: any[] }>(cacheKey);
    if (cached) return cached;

    const result = await this.nuitee.searchHotels({
      city: DEFAULT_CITY,
      country: DEFAULT_COUNTRY,
      checkIn: this.nextCheckIn(),
      checkOut: this.nextCheckOut(),
      guests: DEFAULT_GUESTS,
      rooms: 1,
    });

    // Provider failure or empty inventory → honest empty (caller renders
    // the no-content state; nothing is invented).
    if (!result.success || !Array.isArray(result.data) || result.data.length === 0) {
      if (!result.success && result.error) {
        this.logger.warn(`Home recommended: Nuitee unavailable (${result.error})`);
      }
      return { hotels: [] };
    }

    // BUGFIX (user report 2026-09-08): defense-in-depth — the Nuitee adapter
    // already deduplicates per hotel (one offer per hotel = the cheapest
    // room), but the Home must NEVER show the same hotel twice even if the
    // adapter regresses. Dedup by providerHotelId (falling back to offer id)
    // BEFORE slicing to the limit.
    const seenHotelIds = new Set<string>();
    const hotels = result.data
      .filter((offer: any) => {
        const hotelKey = String(
          offer?.metadata?.providerHotelId ?? offer?.id ?? '',
        );
        if (!hotelKey || seenHotelIds.has(hotelKey)) return false;
        seenHotelIds.add(hotelKey);
        return true;
      })
      .slice(0, boundedLimit)
      .map((offer: any) => ({
      id: offer.id,
      title: offer.title,
      subtitle: offer.subtitle,
      description: offer.description,
      imageUrl: offer.imageUrl,
      price: typeof offer.price === 'number' ? offer.price : undefined,
      currency: offer.currency,
      rating: offer.rating,
      reviewCount: offer.reviewCount,
      // Provenance for the tap-through (revalidation before booking).
      metadata: {
        providerId: offer.providerId,
        providerName: offer.providerName,
        providerRateId: offer.metadata?.providerRateId,
        providerHotelId: offer.metadata?.providerHotelId,
        refundable: offer.metadata?.refundable,
        expiresAt: offer.metadata?.expiresAt,
      },
    }));
    const payload = { hotels };
    // Cache only a successful, non-empty snapshot.
    if (hotels.length > 0) {
      await this.cache.set(cacheKey, payload, RECOMMENDED_TTL_SECONDS);
    }
    return payload;
  }

  /** Check-in = tomorrow (stable within the cache window). */
  private nextCheckIn(): Date {
    const d = new Date();
    d.setDate(d.getDate() + 1);
    return d;
  }

  /** Check-out = three nights after check-in (a typical short stay). */
  private nextCheckOut(): Date {
    const d = new Date();
    d.setDate(d.getDate() + 4);
    return d;
  }
}
