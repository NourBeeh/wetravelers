import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HomeSection } from '../../database/entities/home_section.entity';
import { HomeCard } from '../../database/entities/home_card.entity';
import { NuiteeModule } from '../nuitee/nuitee.module';
import { CacheModule } from '../cache/cache.module';
import { HomeController } from './home.controller';
import { HomeService } from './home.service';
import { HomeRecommendedService } from './home.recommended.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([HomeSection, HomeCard]),
    // Real hotel source (Nuitee) + the short-TTL snapshot cache.
    NuiteeModule,
    CacheModule,
  ],
  controllers: [HomeController],
  providers: [HomeService, HomeRecommendedService],
})
export class HomeModule {}
