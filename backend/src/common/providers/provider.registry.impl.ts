import { Injectable } from '@nestjs/common';

@Injectable()
export class ProviderRegistryImpl {
  private flightProviders: any[] = [];
  private hotelProviders: any[] = [];
  private carProviders: any[] = [];

  registerFlight(provider: any) {
    this.flightProviders.push(provider);
  }

  registerHotel(provider: any) {
    this.hotelProviders.push(provider);
  }

  registerCar(provider: any) {
    this.carProviders.push(provider);
  }

  getFlightProviders() {
    return this.flightProviders;
  }

  getHotelProviders() {
    return this.hotelProviders;
  }

  getCarProviders() {
    return this.carProviders;
  }

  findFlightProvider(id: string) {
    return this.flightProviders.find(p => p.providerId === id);
  }

  findHotelProvider(id: string) {
    return this.hotelProviders.find(p => p.providerId === id);
  }

  findCarProvider(id: string) {
    return this.carProviders.find(p => p.providerId === id);
  }
}
