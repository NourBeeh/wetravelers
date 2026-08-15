import 'package:flutter/foundation.dart';

@immutable
class TripSummary {
  final String tripId;
  final String bookingId;
  final String type;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double total;
  final String currency;
  final String bookingReference;
  final String providerName;

  const TripSummary({
    required this.tripId,
    required this.bookingId,
    required this.type,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.total,
    required this.currency,
    required this.bookingReference,
    required this.providerName,
  });
}

@immutable
class ItineraryStage {
  final String name;
  final DateTime? dateTime;
  final String status;
  final String? location;

  const ItineraryStage({
    required this.name,
    this.dateTime,
    required this.status,
    this.location,
  });
}
