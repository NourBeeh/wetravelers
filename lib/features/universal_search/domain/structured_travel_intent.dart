import 'package:flutter/foundation.dart';

/// The structured travel intent a natural query is compiled into
/// (US-0 contract §10): AI never answers with bare text — the query is
/// parsed into this shape, then fed into the EXISTING search controllers.
@immutable
class StructuredTravelIntent {
  const StructuredTravelIntent({
    required this.type,
    this.origin,
    this.destination,
    this.date,
    this.returnDate,
    this.guests,
    this.budgetMax,
  });

  /// `flight` | `hotel` | `car` | `package` — mirrors the existing search
  /// verticals, never invents a new service.
  final String type;

  final String? origin;
  final String? destination;

  final DateTime? date;
  final DateTime? returnDate;

  final int? guests;

  final double? budgetMax;

  /// Applies a follow-up patch (US-0 §12): cheaper/more premium/... return
  /// a NEW intent with the patched field — the original stays immutable.
  StructuredTravelIntent copyWith({
    String? type,
    String? origin,
    String? destination,
    DateTime? date,
    DateTime? returnDate,
    int? guests,
    double? budgetMax,
  }) {
    return StructuredTravelIntent(
      type: type ?? this.type,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      returnDate: returnDate ?? this.returnDate,
      guests: guests ?? this.guests,
      budgetMax: budgetMax ?? this.budgetMax,
    );
  }
}

/// The parsed follow-up patch vocabulary (US-0 §12) — only the follow-ups
/// that map DIRECTLY onto existing search params in US-1.
enum FollowUpAction { cheaper, morePremium }
