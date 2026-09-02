import { Injectable } from '@nestjs/common';
import { ProviderRegistryImpl } from '../../common/providers/provider.registry.impl';
import { CacheService } from '../cache/cache.service';
import { PricingService } from '../../common/market/pricing.service';
import { DEFAULT_MARKET } from '../../common/market/market-context';

@Injectable()
export class SearchService {
  constructor(
    private readonly registry: ProviderRegistryImpl,
    private readonly cache: CacheService,
    private readonly pricing: PricingService,
  ) {}

  /**
   * Fan-out search across eligible providers, then attach the customer
   * display price (MarketContext-aware, spec points 3-6/12) while keeping
   * every provider amount untouched.
   */
  async searchFlights(params: any, market?: string) {
    const cacheKey = `search:flights:${JSON.stringify(params)}:${market ?? DEFAULT_MARKET.marketCountry}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;
    const providers = this.registry.getFlightProviders();
    const results = await Promise.allSettled(
      providers.map(p => p.searchFlights(params)),
    );
    const aggregated = await this.aggregateWithPricing(results, market);
    await this.cache.set(cacheKey, aggregated, 120);
    return aggregated;
  }

  async searchHotels(params: any, market?: string) {
    const providers = this.registry.getHotelProviders();
    const results = await Promise.allSettled(
      providers.map(p => p.searchHotels(params)),
    );
    return this.aggregateWithPricing(results, market);
  }

  async searchCars(params: any, market?: string) {
    const providers = this.registry.getCarProviders();
    const results = await Promise.allSettled(
      providers.map(p => p.searchCars(params)),
    );
    return this.aggregateWithPricing(results, market);
  }

  /**
   * Partial-failure aggregation (spec point 12) + display-currency
   * enrichment per offer. Provider truth survives intact inside each offer.
   */
  private async aggregateWithPricing(
    results: PromiseSettledResult<any>[],
    market?: string,
  ) {
    const successes: any[] = [];
    const failures: any[] = [];
    for (const r of results) {
      if (r.status === 'fulfilled') {
        const value = r.value;
        const offers = (value?.data ?? []) as any[];
        const enrichedOffers: any[] = [];
        for (const offer of offers) {
          if (
            typeof offer?.price === 'number' &&
            typeof offer?.currency === 'string' &&
            !offer?.customerPrice
          ) {
            enrichedOffers.push(
              await this.pricing.enrichOffer(offer, { market }),
            );
          } else {
            enrichedOffers.push(offer);
          }
        }
        successes.push({ ...value, data: enrichedOffers });
      } else {
        failures.push({ error: String((r as PromiseRejectedResult).reason) });
      }
    }
    return { successes, failures };
  }
}
