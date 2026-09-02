import { NuiteeService, NUITEE_FIXTURES } from '../src/modules/nuitee/nuitee.service';

/**
 * Nuitee adapter contract tests (spec points 25, 47) — deterministic fixture
 * coverage, offline. Proves the live Rates->Prebook->Book response mapping
 * (data[].roomTypes[].rates[] + snake_case hotel metadata) and the
 * sandbox-guards (no key => structured failure, never a crash).
 */

describe('NuiteeService (HotelProvider)', () => {
  function serviceWith(key: string | undefined): NuiteeService {
    const config = { get: (name: string) => (name === 'NUITEE_API_KEY' ? key : undefined) };
    return new NuiteeService(config as any);
  }

  it('implements the shared HotelProvider contract', () => {
    const s = serviceWith('sand_test-key');
    expect(s.providerId).toBe('nuitee');
    expect(typeof s.searchHotels).toBe('function');
    expect(typeof s.prebookHotel).toBe('function');
    expect(typeof s.bookHotel).toBe('function');
  });

  it('returns a structured failure (never throws) when the key is missing', async () => {
    const s = serviceWith(undefined);
    const result = await s.searchHotels({
      city: 'Cairo',
      checkIn: new Date('2026-10-01'),
      checkOut: new Date('2026-10-05'),
    });
    expect(result.success).toBe(false);
    expect(result.data).toEqual([]);
    expect(result.error).toContain('NUITEE_API_KEY');
  });

  it('maps the LIVE rates-search shape into the shared hotel offer contract', () => {
    const s = serviceWith('sand_test-key');
    const entries = s.extractRateResults(NUITEE_FIXTURES.ratesSearchResponse);
    // Two rates on one room type — the cheapest one surfaces.
    expect(entries).toHaveLength(1);
    expect(entries[0].rate.rateId).toBe('fixture-rate-1');

    const hotelMeta = new Map<string, any>([['fixture-hotel-1', NUITEE_FIXTURES.ratesSearchResponse.data.hotels[0]]]);
    const offer = s.mapRateToOffer(
      entries[0],
      hotelMeta,
      { city: 'Cairo', checkIn: new Date('2026-10-01'), checkOut: new Date('2026-10-05') },
      '2026-10-01',
      '2026-10-05',
    );
    expect(offer.type).toBe('hotel');
    expect(offer.providerId).toBe('nuitee');
    expect(offer.title).toBe('Fixture Grand Hotel');
    expect(offer.price).toBe(180);
    expect(offer.currency).toBe('USD');
    expect(offer.city).toBe('Cairo');
    // Nuitee 10-scale rating halves to the 5-star display scale.
    expect(offer.rating).toBeCloseTo(4.8, 1);
    expect(offer.reviewCount).toBe(312);
    expect(offer.imageUrl).toBe('https://example.com/hotel1.jpg');
    expect(offer.roomType).toBe('Deluxe King');
    expect(offer.subtitle).toContain('Free cancellation');
    // Provider provenance survives as metadata (spec point 7)
    expect(offer.metadata.providerRateId).toBe('fixture-rate-1');
    expect(offer.metadata.providerOfferId).toBe('fixture-offer-1');
    expect(offer.metadata.providerHotelId).toBe('fixture-hotel-1');
    expect(offer.metadata.paymentType).toBe('ACC_CREDIT_CARD');
    expect(offer.metadata.expiresAt).toBeTruthy();
    expect(offer.metadata.refundable).toBe(true);
  });

  it('picks the cheapest rate when multiple rates exist per room type', () => {
    const s = serviceWith('sand_test-key');
    const entries = s.extractRateResults({
      data: [
        {
          hotelId: 'h1',
          roomTypes: [
            {
              offerId: 'o1',
              roomTypeName: 'Std',
              rates: [
                { rateId: 'exp', retailRate: { total: [{ amount: 500, currency: 'USD' }] } },
                { rateId: 'cheap', retailRate: { total: [{ amount: 90, currency: 'USD' }] } },
              ],
            },
          ],
        },
      ],
    });
    expect(entries[0].rate.rateId).toBe('cheap');
  });

  it('prebook preserves prebookId/transactionId (not recoverable after loss — spec O.3)', async () => {
    const s = serviceWith('sand_test-key');
    const fetchSpy = jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: true,
      text: async () => JSON.stringify(NUITEE_FIXTURES.prebookResponse),
    } as any);

    const result = await s.prebookHotel({ rateId: 'fixture-rate-1' });
    expect(result.success).toBe(true);
    expect(result.prebookId).toBe('fixture-prebook-1');
    expect(result.transactionId).toBe('fixture-transaction-1');
    expect(result.priceChanged).toBe(false);
    expect(result.newPrice).toBe(180);

    // The request carried offerId (rate id) — the documented contract.
    const body = JSON.parse((fetchSpy.mock.calls[0][1] as any).body);
    expect(body.offerId).toBe('fixture-rate-1');
    expect(body.usePaymentSdk).toBe(false);
    fetchSpy.mockRestore();
  });

  it('book maps the confirmation payload to the internal booking shape', async () => {
    const s = serviceWith('sand_test-key');
    const fetchSpy = jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: true,
      text: async () =>
        JSON.stringify({
          data: {
            bookingId: 'book-123',
            hotelConfirmationNumber: 'HCN-77',
            status: 'CONFIRMED',
            currency: 'USD',
            total: [{ amount: 180, currency: 'USD' }],
          },
        }),
    } as any);

    const result = await s.bookHotel({
      prebookId: 'pre-1',
      transactionId: 'tx-1',
      holderName: 'Nour Traveller',
      guestNames: ['Nour Traveller'],
    });
    expect(result.success).toBe(true);
    expect(result.data.bookingId).toBe('book-123');
    expect(result.data.reference).toBe('HCN-77');
    expect(result.data.status).toBe('CONFIRMED');
    expect(result.data.total).toBe(180);

    const body = JSON.parse((fetchSpy.mock.calls[0][1] as any).body);
    expect(body.payment.method).toBe('ACC_CREDIT_CARD');
    expect(body.prebookId).toBe('pre-1');
    expect(body.transactionId).toBe('tx-1');
    fetchSpy.mockRestore();
  });

  it('surfaces provider errors as structured failures, never raw throws', async () => {
    const s = serviceWith('sand_test-key');
    const fetchSpy = jest
      .spyOn(globalThis, 'fetch')
      .mockRejectedValue(new Error('boom'));
    const result = await s.prebookHotel({ rateId: 'r' });
    expect(result.success).toBe(false);
    expect(result.error).toContain('prebook failed');
    fetchSpy.mockRestore();
  });

  it('maps provider HTTP error bodies into readable messages', async () => {
    const s = serviceWith('sand_test-key');
    const fetchSpy = jest.spyOn(globalThis, 'fetch').mockResolvedValue({
      ok: false,
      status: 401,
      text: async () => JSON.stringify({ error: { message: 'Invalid API key' } }),
    } as any);
    const result = await s.prebookHotel({ rateId: 'r' });
    expect(result.success).toBe(false);
    expect(result.error).toContain('401');
    expect(result.error).toContain('Invalid API key');
    fetchSpy.mockRestore();
  });
});
