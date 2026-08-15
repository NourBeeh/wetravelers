import '../../../core/domain/models/offers/hotel_offer.dart';

abstract interface class HotelProvider {
  String get providerId;
  String get providerName;

  Future<List<HotelOffer>> searchHotels({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  });
}