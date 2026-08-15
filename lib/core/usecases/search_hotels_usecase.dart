import 'package:flutter/foundation.dart';
import '../repositories/contracts/hotel_repository.dart';
import '../domain/models/offers/hotel_offer.dart';
import '../network/api_result.dart';

@immutable
class SearchHotelsUseCase {
  const SearchHotelsUseCase(this.repository);

  final HotelRepository repository;

  Future<ApiResult<List<HotelOffer>>> call({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  }) {
    return repository.search(
      city: city,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
    );
  }
}
