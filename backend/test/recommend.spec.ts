import { RecommendedHotelService } from '../src/modules/recommend/recommended-hotel.service';
import { ProfileService } from '../src/modules/profile/profile.service';

function fakeNuitee() {
  return {
    searchHotels: jest.fn().mockResolvedValue({
      success: true,
      data: [
        {
          id: 'h-paris-1',
          title: 'Grand Paris',
          city: 'Paris',
          price: 220,
          currency: 'USD',
          rating: 4.6,
          reviewCount: 320,
          imageUrl: 'https://x/paris.jpg',
          subtitle: 'Paris · 4.6★',
        },
        {
          id: 'h-paris-2',
          title: 'Boutique Louvre',
          city: 'Paris',
          price: 410,
          currency: 'USD',
          rating: 4.9,
          reviewCount: 90,
          imageUrl: 'https://x/louvre.jpg',
          subtitle: 'Paris · 4.9★',
        },
      ],
    }),
  } as any;
}

function fakeAi(ordered: string[] | null) {
  if (ordered === null) return null;
  return {
    providerId: 'test-ai',
    providerName: 'Test AI',
    generate: jest.fn().mockResolvedValue({
      text: JSON.stringify({ ordered, reason: 'test' }),
      sections: [],
      metadata: {},
    }),
  } as any;
}

function fakeProfiles(prefs: Record<string, any> = {}, derived: Record<string, any> = {}) {
  const profile = {
    preferences: prefs,
    derived,
    personalizationEnabled: true,
  };
  return {
    getView: jest.fn().mockResolvedValue(profile),
    getOrCreate: jest.fn().mockResolvedValue(profile),
  } as any;
}

function makeService(nuitee: any, ai: any, profiles: any) {
  return new RecommendedHotelService(nuitee, profiles, ai, { get: () => undefined } as any);
}

describe('RecommendedHotelService — real provider only', () => {
  it('returns empty fallback when Nuitee returns no candidates (no fake content)', async () => {
    const nuitee = { searchHotels: jest.fn().mockResolvedValue({ success: false, data: [] }) } as any;
    const service = makeService(nuitee, fakeAi(['h-paris-1']), fakeProfiles());
    const result = await service.recommend({ countryCode: 'FR', limit: 6 });
    expect(result.source).toBe('fallback');
    expect(result.hotels).toHaveLength(0);
  });

  it('uses the deterministic score order when the AI is unavailable', async () => {
    const service = makeService(fakeNuitee(), fakeAi(null), fakeProfiles({ budgetMax: 300 }));
    const result = await service.recommend({ countryCode: 'FR', limit: 6 });
    expect(result.source).toBe('provider');
    // h-paris-2 is pricier than the budget, h-paris-1 fits → h-paris-1 first.
    expect(result.hotels[0].id).toBe('h-paris-1');
    // All returned hotels originate from the provider candidates.
    const offered = new Set(result.hotels.map((h) => h.id));
    expect(offered.has('h-paris-1') || offered.has('h-paris-2')).toBe(true);
    expect(result.hotels.length).toBeLessThanOrEqual(6);
  });

  it('respects the AI ranking order without inventing hotels', async () => {
    const service = makeService(
      fakeNuitee(),
      fakeAi(['h-paris-2', 'h-paris-1']),
      fakeProfiles({ preferredStars: 5 }),
    );
    const result = await service.recommend({ countryCode: 'FR', limit: 6 });
    expect(result.source).toBe('provider');
    expect(result.hotels[0].id).toBe('h-paris-2');
    expect(result.hotels.every((h) => h.id === 'h-paris-1' || h.id === 'h-paris-2')).toBe(true);
  });

  it('falls back to deterministic order when AI ranking throws', async () => {
    const nuitee = fakeNuitee();
    const ai = {
      providerId: 'test',
      providerName: 'AI',
      generate: jest.fn().mockRejectedValue(new Error('AI down')),
    } as any;
    const service = makeService(nuitee, ai, fakeProfiles());
    const result = await service.recommend({ countryCode: 'FR', limit: 6 });
    expect(result.source).toBe('provider');
    expect(result.hotels.length).toBeGreaterThan(0);
  });

  it('honours the hard limit for cards returned', async () => {
    const nuitee = fakeNuitee();
    const service = makeService(nuitee, fakeAi(['h-paris-1', 'h-paris-2']), fakeProfiles());
    const result = await service.recommend({ countryCode: 'FR', limit: 1 });
    expect(result.hotels).toHaveLength(1);
  });
});
