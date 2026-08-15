import { CarProvider } from '../../../common/providers/car.provider';
import { ProviderResult } from '../../../common/providers/provider.result';

export class MockCarProvider implements CarProvider {
  providerId = 'mock-car';
  providerName = 'Mock Car Provider';

  async searchCars(params: any): Promise<ProviderResult<any[]>> {
    return {
      success: true,
      providerId: this.providerId,
      providerName: this.providerName,
      data: [],
      timestamp: new Date(),
    };
  }
}
