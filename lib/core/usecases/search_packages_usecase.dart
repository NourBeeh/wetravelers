import 'package:flutter/foundation.dart';
import '../repositories/contracts/package_repository.dart';
import '../domain/models/offers/travel_package_offer.dart';
import '../network/api_result.dart';

@immutable
class SearchPackagesUseCase {
  const SearchPackagesUseCase(this.repository);

  final PackageRepository repository;

  Future<ApiResult<List<TravelPackageOffer>>> call({
    String? destination,
    int? minDays,
    int? maxDays,
  }) {
    return repository.search(
      destination: destination,
      minDays: minDays,
      maxDays: maxDays,
    );
  }
}
