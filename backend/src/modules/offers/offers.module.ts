import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Offer } from '../../database/entities/offer.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Offer])],
})
export class OffersModule {}
