import '../../../core/domain/models/offers/flight_offer.dart';

abstract interface class FlightProvider {
  String get providerId;
  String get providerName;

  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departure,
    DateTime? returnDate,
    int? passengers,
  });
}