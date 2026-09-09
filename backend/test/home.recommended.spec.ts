import { HomeRecommendedService } from '../src/modules/home/home.recommended.service';
import { NuiteeService } from '../src/modules/nuitee/nuitee.service';

/**
 * Phase 7B-slice (user-approved 2026-09-08) — GET /home/recommended:
 * the real Nuitee-backed source behind the Nuitee-only Home hotel rail.
 * Until now the Flutter call 404'd silently and the Home stayed on the
 * empty preview forever. Contracts pinned here:
 * - real provider data only, nothing invented;
 * - provider failure → honest EMPTY list (never fake hotels);
 * - limit clamped server-side (1..20);
 * - successful non-empty results cached with a SHORT ttl (Home opens
 *   constantly — the provider is not hammered on every cold start);
 * - cached prices are presentation snapshots, never booking truth.
 */

function nullCache() {
  return {
    get: async () => null,
    set: async () => undefined,
    delete: async () => undefined,
    invalidate: async () => undefined,
  } as any;
}

function recordingCache() {
  const sets: Array<{ key: string; ttl?: number }> = [];
  const store = new Map<string, any>();
  return {
    sets,
    cache: {
      get: async (key: string) => store.get(key) ?? null,
      set: async (key: string, value: any, ttl?: number) => {
        sets.push({ key, ttl });
        store.set(key, value);
      },
      delete: async () => undefined,
      invalidate: async () => undefined,
    } as any,
  };
}

function fakeNuitee(hotels: any[] = [], success = true) {
  return {
    searchHotels: jest.fn().mockResolvedValue({
      success,
      providerId: 'nuitee',
      providerName: 'Nuitee Connect',
      data: hotels,
      error: success ? undefined : 'NUITEE_API_KEY missing',
    }),
  } as unknown as NuiteeService;
}

function hotelOffer(overrides: Record<string, any> = {}) {
  return {
    id: 'rate-1',
    providerId: 'nuitee',
    providerName: 'Nuitee Connect',
    title: 'Cairo Grand Hotel',
    subtitle: 'Cairo · 4.5★',
    description: 'A real hotel.',
    imageUrl: 'https://x/photo.jpg',
    price: 120,
    currency: 'USD',
    rating: 4.5,
    reviewCount: 320,
    metadata: {
      providerRateId: 'rate-1',
      providerHotelId: 'H1',
      refundable: true,
      expiresAt: '2026-12-01T00:00:00.000Z',
    },
    ...overrides,
  };
}

describe('HomeRecommendedService — GET /home/recommended (7B slice)', () => {
  it('maps real Nuitee offers into the Home card contract verbatim', async () => {
    const service = new HomeRecommendedService(fakeNuitee([hotelOffer()]), nullCache());
    const result = await service.getRecommendedHotels(6);

    expect(result.hotels).toHaveLength(1);
    const hotel = result.hotels[0];
    expect(hotel.id).toBe('rate-1');
    expect(hotel.title).toBe('Cairo Grand Hotel');
    expect(hotel.imageUrl).toBe('https://x/photo.jpg');
    expect(hotel.price).toBe(120);
    expect(hotel.currency).toBe('USD');
    expect(hotel.rating).toBe(4.5);
    // Provenance survives for the tap-through/revalidation path.
    expect(hotel.metadata.providerId).toBe('nuitee');
    expect(hotel.metadata.providerRateId).toBe('rate-1');
    expect(hotel.metadata.refundable).toBe(true);
  });

  it('provider failure → honest EMPTY list, never fake hotels', async () => {
    const service = new HomeRecommendedService(fakeNuitee([], false), nullCache());
    const result = await service.getRecommendedHotels(6);
    expect(result.hotels).toEqual([]);
  });

  it('provider success with zero inventory → empty list', async () => {
    const service = new HomeRecommendedService(fakeNuitee([]), nullCache());
    const result = await service.getRecommendedHotels(6);
    expect(result.hotels).toEqual([]);
  });

  it('limit is clamped server-side (0 → 1, 999 → 20)', async () => {
    // Two DISTINCT hotels (the dedup guard drops same-hotel duplicates —
    // this test is about the limit clamp, not duplicates).
    const nuitee = fakeNuitee([
      hotelOffer({
        id: 'a',
        metadata: {
          providerRateId: 'a',
          providerHotelId: 'HA',
          refundable: true,
          expiresAt: '2026-12-01T00:00:00.000Z',
        },
      }),
      hotelOffer({
        id: 'b',
        metadata: {
          providerRateId: 'b',
          providerHotelId: 'HB',
          refundable: true,
          expiresAt: '2026-12-01T00:00:00.000Z',
        },
      }),
    ]);
    const service = new HomeRecommendedService(nuitee, nullCache());

    const zero = await service.getRecommendedHotels(0);
    expect(zero.hotels).toHaveLength(1); // clamped up to 1

    const huge = await service.getRecommendedHotels(999);
    expect(huge.hotels).toHaveLength(2); // only 2 available, cap 20 not hit
  });

  it('successful non-empty snapshot is cached with a SHORT ttl (5 min)', async () => {
    const { cache, sets } = recordingCache();
    const service = new HomeRecommendedService(fakeNuitee([hotelOffer()]), cache);

    await service.getRecommendedHotels(6);
    expect(sets).toHaveLength(1);
    expect(sets[0].ttl).toBe(5 * 60);
    expect(sets[0].key).toContain('home:recommended:');
  });

  it('failed/empty results are NOT cached (the provider may recover)', async () => {
    const { cache, sets } = recordingCache();
    const service = new HomeRecommendedService(fakeNuitee([], false), cache);

    await service.getRecommendedHotels(6);
    expect(sets).toHaveLength(0);
  });

  it('a cached snapshot short-circuits the provider entirely', async () => {
    const { cache } = recordingCache();
    const nuitee = fakeNuitee([hotelOffer()]);
    const first = new HomeRecommendedService(nuitee, cache);
    await first.getRecommendedHotels(6);
    expect((nuitee as any).searchHotels).toHaveBeenCalledTimes(1);

    // Second call within the TTL window: served from cache, provider NOT hit.
    const second = new HomeRecommendedService(nuitee, cache);
    const result = await second.getRecommendedHotels(6);
    expect((nuitee as any).searchHotels).toHaveBeenCalledTimes(1);
    expect(result.hotels).toHaveLength(1);
  });

  it('prices with a non-number type are dropped, never invented', async () => {
    const service = new HomeRecommendedService(
      fakeNuitee([hotelOffer({ price: 'not-a-number' })]),
      nullCache(),
    );
    const result = await service.getRecommendedHotels(6);
    expect(result.hotels[0].price).toBeUndefined();
  });

  it('BUGFIX 2026-09-08: duplicate hotels (same providerHotelId) never reach the rail — defense in depth', async () => {
    // The adapter already dedups per hotel; this guards the Home contract
    // even if the adapter ever regresses: same hotel, two rates/prices.
    const duplicated = [
      hotelOffer({ id: 'rate-a', price: 120 }),
      hotelOffer({
        id: 'rate-b',
        price: 180,
        metadata: {
          providerRateId: 'rate-b',
          providerHotelId: 'H1',
          refundable: false,
          expiresAt: '2026-12-01T00:00:00.000Z',
        },
      }),
      hotelOffer({
        id: 'rate-c',
        price: 90,
        metadata: {
          providerRateId: 'rate-c',
          providerHotelId: 'H2',
          expiresAt: '2026-12-01T00:00:00.000Z',
        },
      }),
    ];
    const service = new HomeRecommendedService(fakeNuitee(duplicated), nullCache());
    const result = await service.getRecommendedHotels(6);

    // H1 appears ONCE (first/cheapest wins) and H2 keeps its offer.
    expect(result.hotels).toHaveLength(2);
    const ids = result.hotels.map((h: any) => h.metadata.providerHotelId);
    expect(ids).toEqual(['H1', 'H2']);
    expect(result.hotels[0].price).toBe(120); // the H1 offer that came first
  });
});
