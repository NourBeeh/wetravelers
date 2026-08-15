import { Injectable } from '@nestjs/common';
import { ProviderRegistryImpl } from '../../common/providers/provider.registry.impl';
import { CacheService } from '../cache/cache.service';

@Injectable()
export class SearchService {
  constructor(
    private readonly registry: ProviderRegistryImpl,
    private readonly cache: CacheService,
  ) {}

  async searchFlights(params: any) {
    const cacheKey = `search:flights:${JSON.stringify(params)}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;
    const providers = this.registry.getFlightProviders();
    const results = await Promise.allSettled(
      providers.map(p => p.searchFlights(params))
    );
    const aggregated = this.aggregate(results);
    await this.cache.set(cacheKey, aggregated, 300);
    return aggregated;
  }

  async searchHotels(params: any) {
    const providers = this.registry.getHotelProviders();
    const results = await Promise.allSettled(
      providers.map(p => p.searchHotels(params))
    );
    return this.aggregate(results);
  }

  async searchCars(params: any) {
    const providers = this.registry.getCarProviders();
    const results = await Promise.allSettled(
      providers.map(p => p.searchCars(params))
    );
    return this.aggregate(results);
  }

  private aggregate(results: PromiseSettledResult<any>[]) {
    const successes = [];
    const failures = [];
    for (const r of results) {
      if (r.status === 'fulfilled') {
        successes.push(r.value);
      } else {
        failures.push({ error: r.reason });
      }
    }
    return { successes, failures };
  }
}
