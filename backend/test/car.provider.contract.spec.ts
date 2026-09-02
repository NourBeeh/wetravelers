import { MockCarProvider } from '../src/modules/providers/adapters/mock.car.provider';

/**
 * Car catalogue mock contract (spec point 30): proves the deterministic
 * catalogue honours the shared CarProvider interface and computes totals
 * from the rental window, so a real vendor adapter can drop in later
 * without domain/UI changes.
 */

describe('MockCarProvider (CarProvider contract)', () => {
  const provider = new MockCarProvider();

  it('implements the shared CarProvider contract', () => {
    expect(provider.providerId).toBe('mock-car');
    expect(typeof provider.searchCars).toBe('function');
  });

  it('returns a full catalogue with computed totals for the rental window', async () => {
    const result = await provider.searchCars({
      pickupLocation: 'Cairo',
      pickupTime: new Date('2026-10-01T10:00:00Z'),
      dropoffTime: new Date('2026-10-05T10:00:00Z'), // 4 days
    });
    expect(result.success).toBe(true);
    expect(result.data!.length).toBeGreaterThanOrEqual(4);

    for (const car of result.data!) {
      expect(car.type).toBe('car');
      expect(car.providerId).toBe('mock-car');
      expect(car.price).toBeGreaterThan(0);
      expect(car.currency).toBe('USD');
      expect(car.metadata.rentalDays).toBe(4);
      // Provenance + expiry (spec point 7)
      expect(car.metadata.expiresAt).toBeTruthy();
      expect(car.metadata.retrievedAt).toBeTruthy();
      // Enriched display data for the UI cards
      expect(car.carType).toBeTruthy();
      expect(car.transmission).toBeTruthy();
      expect(car.seats).toBeGreaterThan(0);
      expect(car.imageUrl).toBeTruthy();
      expect(car.supplier).toBeTruthy();
    }

    // 4 days × daily rate consistency
    const economy = result.data!.find(c => c.title === 'Toyota Corolla');
    expect(economy!.price).toBe(32 * 4);
  });

  it('resolves pickup locations for Arabic city names', async () => {
    const result = await provider.searchCars({
      pickupLocation: 'القاهرة',
      pickupTime: new Date('2026-10-01T10:00:00Z'),
      dropoffTime: new Date('2026-10-03T10:00:00Z'),
    });
    expect(result.data![0].pickupLocation).toContain('Cairo');
  });

  it('clamps same-day rentals to a minimum of one rental day', async () => {
    const result = await provider.searchCars({
      pickupLocation: 'Dubai',
      pickupTime: new Date('2026-10-01T08:00:00Z'),
      dropoffTime: new Date('2026-10-01T20:00:00Z'),
    });
    expect(result.data![0].metadata.rentalDays).toBe(1);
  });
});
