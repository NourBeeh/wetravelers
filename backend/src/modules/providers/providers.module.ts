import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Provider } from '../../database/entities/provider.entity';
import { ProviderRegistryImpl } from '../../common/providers/provider.registry.impl';
import { MockFlightProvider } from './adapters/mock.flight.provider';
import { MockHotelProvider } from './adapters/mock.hotel.provider';
import { MockCarProvider } from './adapters/mock.car.provider';
import { SearchController } from './search.controller';
import { SearchService } from './search.service';

@Module({
  imports: [TypeOrmModule.forFeature([Provider])],
  controllers: [SearchController],
  providers: [
    ProviderRegistryImpl,
    SearchService,
    MockFlightProvider,
    MockHotelProvider,
    MockCarProvider,
  ],
  exports: [ProviderRegistryImpl, SearchService],
})
export class ProvidersModule {}

