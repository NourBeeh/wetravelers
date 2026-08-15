import 'package:flutter/foundation.dart';
import '../repositories/contracts/car_repository.dart';
import '../domain/models/offers/car_offer.dart';
import '../network/api_result.dart';

@immutable
class SearchCarsUseCase {
  const SearchCarsUseCase(this.repository);

  final CarRepository repository;

  Future<ApiResult<List<CarOffer>>> call({
    required String pickupLocation,
    required DateTime pickupTime,
    required DateTime dropoffTime,
  }) {
    return repository.search(
      pickupLocation: pickupLocation,
      pickupTime: pickupTime,
      dropoffTime: dropoffTime,
    );
  }
}
