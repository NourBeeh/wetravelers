import 'package:flutter/foundation.dart';

@immutable
class FlightSearchParams {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String tripType;
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;
  final bool directOnly;

  const FlightSearchParams({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    this.tripType = 'oneway',
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = 'economy',
    this.directOnly = false,
  });

  FlightSearchParams copyWith({
    String? origin,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    String? tripType,
    int? adults,
    int? children,
    int? infants,
    String? cabinClass,
    bool? directOnly,
  }) {
    return FlightSearchParams(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      tripType: tripType ?? this.tripType,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      cabinClass: cabinClass ?? this.cabinClass,
      directOnly: directOnly ?? this.directOnly,
    );
  }
}
