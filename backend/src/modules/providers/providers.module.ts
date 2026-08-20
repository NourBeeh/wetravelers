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
  ],
  exports: [ProviderRegistryImpl, SearchService, DuffelService],
})
export class ProvidersModule implements OnModuleInit {
  constructor(
    private readonly registry: ProviderRegistryImpl,
    private readonly mockFlightProvider: MockFlightProvider,
    private readonly duffelService: DuffelService,
    private readonly mockHotelProvider: MockHotelProvider,
    private readonly mockCarProvider: MockCarProvider,
  ) {}

  onModuleInit() {
    // Register all flight providers
    this.registry.registerFlight(this.mockFlightProvider);
    this.registry.registerFlight(this.duffelService);
    
    // Register hotel and car providers
    this.registry.registerHotel(this.mockHotelProvider);
    this.registry.registerCar(this.mockCarProvider);
  }
}