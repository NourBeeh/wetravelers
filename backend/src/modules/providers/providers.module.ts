import { Module, OnModuleInit } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Provider } from '../../database/entities/provider.entity';
import { ProviderRegistryImpl } from '../../common/providers/provider.registry.impl';
import { MockFlightProvider } from './adapters/mock.flight.provider';
import { MockHotelProvider } from './adapters/mock.hotel.provider';
import { MockCarProvider } from './adapters/mock.car.provider';
import { SearchController } from './search.controller';
import { SearchService } from './search.service';
import { DuffelService } from '../duffel/duffel.service';
import { DuffelHotelService } from '../duffel/duffel.hotel.service';
import { NuiteeService } from '../nuitee/nuitee.service';
import { FxService } from '../../common/market/fx.service';
import { PricingService } from '../../common/market/pricing.service';

@Module({
  imports: [TypeOrmModule.forFeature([Provider])],
  controllers: [SearchController],
  providers: [
    ProviderRegistryImpl,
    SearchService,
    MockFlightProvider,
    MockHotelProvider,
    MockCarProvider,
    DuffelService,
    DuffelHotelService,
    NuiteeService,
    FxService,
    PricingService,
  ],
  exports: [
    ProviderRegistryImpl,
    SearchService,
    DuffelService,
    DuffelHotelService,
    NuiteeService,
    FxService,
    PricingService,
  ],
})
export class ProvidersModule implements OnModuleInit {
  constructor(
    private readonly registry: ProviderRegistryImpl,
    private readonly mockFlightProvider: MockFlightProvider,
    private readonly duffelService: DuffelService,
    private readonly duffelHotelService: DuffelHotelService,
    private readonly mockHotelProvider: MockHotelProvider,
    private readonly mockCarProvider: MockCarProvider,
    private readonly nuiteeService: NuiteeService,
  ) {}

  onModuleInit() {
    // Register all flight providers
    this.registry.registerFlight(this.mockFlightProvider);
    this.registry.registerFlight(this.duffelService);

    // Hotel providers: Nuitee is the first real provider (spec point 25).
    // The Duffel stays fallback stays registered behind it; the empty
    // MockHotelProvider keeps the contract warm for tests.
    this.registry.registerHotel(this.mockHotelProvider);
    this.registry.registerHotel(this.nuiteeService);
    this.registry.registerHotel(this.duffelHotelService);

    // Cars: rich catalogue mock until vendor selection completes
    // (spec point 30 — no vendor integration before evaluation).
    this.registry.registerCar(this.mockCarProvider);
  }
}
