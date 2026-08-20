import '../domain/models/offers/base_offer.dart';
import '../domain/models/offers/car_offer.dart';
import '../domain/models/offers/flight_offer.dart';
import '../domain/models/offers/hotel_offer.dart';
import '../domain/models/offers/travel_package_offer.dart';
import '../mappers/offer_mapper_fixed.dart';

/// Serialization helpers for the Phase 16 offline cache.
///
/// Offers are stored as plain JSON-safe maps and rehydrated with the same
/// `mapOffer` used by the live API repositories, so the offline path cannot
/// drift from the live path. The cache is write-through: it snapshots the
/// normalized map of a successful search result, and `mapOffer` reconstructs
/// the objects identically whether they came from the network or the cache.

String? _iso(Object? value) {
  if (value is DateTime) return value.toIso8601String();
  if (value == null) return null;
  return value.toString();
}

/// Serializes one normalized offer into the shared map shape consumed by
/// [mapOffer] (same keys, same semantics as the live API payloads).
Map<String, dynamic> offerToMap(BaseOffer offer) {
  final map = <String, dynamic>{
    'type': offer.offerType,
    'id': offer.id,
    'providerId': offer.providerId,
    'providerName': offer.providerName,
    'title': offer.title,
    'subtitle': offer.subtitle,
    'description': offer.description,
    'imageUrl': offer.imageUrl,
    'price': offer.price,
    'currency': offer.currency,
    'availability': offer.availability,
    'validUntil': _iso(offer.validUntil),
    'metadata': offer.metadata,
    'rating': offer.rating,
    'reviewCount': offer.reviewCount,
  };
  if (offer is FlightOffer) {
    return map..addAll(<String, dynamic>{
      'origin': offer.origin,
      'destination': offer.destination,
      'departureTime': _iso(offer.departureTime),
      'arrivalTime': _iso(offer.arrivalTime),
      'airline': offer.airline,
      'flightNumber': offer.flightNumber,
      'stops': offer.stops,
      'cabinClass': offer.cabinClass,
    });
  }
  if (offer is HotelOffer) {
    return map..addAll(<String, dynamic>{
      'city': offer.city,
      'country': offer.country,
      'checkIn': _iso(offer.checkIn),
      'checkOut': _iso(offer.checkOut),
      'roomType': offer.roomType,
      'amenities': offer.amenities,
    });
  }
  if (offer is CarOffer) {
    return map..addAll(<String, dynamic>{
      'pickupLocation': offer.pickupLocation,
      'dropoffLocation': offer.dropoffLocation,
      'pickupTime': _iso(offer.pickupTime),
      'dropoffTime': _iso(offer.dropoffTime),
      'carType': offer.carType,
      'transmission': offer.transmission,
      'seats': offer.seats,
    });
  }
  if (offer is TravelPackageOffer) {
    return map..addAll(<String, dynamic>{
      'destination': offer.destination,
      'durationDays': offer.durationDays,
      'inclusions': offer.inclusions,
    });
  }
  return map;
}

/// Rehydrates a stored offer map via the same mapper used by the live APIs.
/// Returns `null` for unknown/malformed entries instead of throwing.
BaseOffer? offerFromMap(Map<String, dynamic> map) => mapOffer(map);

/// Builds a deterministic cache key for a flight search.
String flightSearchCacheKey({
  required String origin,
  required String destination,
  required DateTime departure,
  DateTime? returnDate,
  int? passengers,
}) {
  final sb = StringBuffer();
  sb.write('flight|');
  sb.write(origin.toLowerCase());
  sb.write('|');
  sb.write(destination.toLowerCase());
  sb.write('|');
  sb.write(departure.toIso8601String());
  if (returnDate != null) {
    sb.write('|');
    sb.write(returnDate.toIso8601String());
  }
  if (passengers != null) {
    sb.write('|');
    sb.write(passengers);
  }
  return sb.toString();
}

/// Builds a deterministic cache key for a hotel search.
String hotelSearchCacheKey({
  required String city,
  required DateTime checkIn,
  required DateTime checkOut,
  int? guests,
}) {
  final sb = StringBuffer();
  sb.write('hotel|');
  sb.write(city.toLowerCase());
  sb.write('|');
  sb.write(checkIn.toIso8601String());
  sb.write('|');
  sb.write(checkOut.toIso8601String());
  if (guests != null) {
    sb.write('|');
    sb.write(guests);
  }
  return sb.toString();
}

/// Builds a deterministic cache key for a car search.
String carSearchCacheKey({
  required String pickupLocation,
  required DateTime pickupTime,
  required DateTime dropoffTime,
}) {
  final sb = StringBuffer();
  sb.write('car|');
  sb.write(pickupLocation.toLowerCase());
  sb.write('|');
  sb.write(pickupTime.toIso8601String());
  sb.write('|');
  sb.write(dropoffTime.toIso8601String());
  return sb.toString();
}