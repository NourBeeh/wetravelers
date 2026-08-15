import '../../../core/domain/models/offers/car_offer.dart';

abstract interface class CarProvider {
  String get providerId;
  String get providerName;

  Future<List<CarOffer>> searchCars({
    required String pickupLocation,
    required DateTime pickupTime,
    required DateTime dropoffTime,
  });
}