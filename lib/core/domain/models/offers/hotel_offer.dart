import 'package:flutter/foundation.dart';
import 'base_offer.dart';

@immutable
class HotelOffer extends BaseOffer {
  const HotelOffer({
    required super.id,
    required super.providerId,
    required super.providerName,
    required super.title,
    super.subtitle,
    super.description,
    super.imageUrl,
    required super.price,
    required super.currency,
    super.availability,
    super.validUntil,
    super.metadata,
    super.rating,
    super.reviewCount,
    required this.city,
    required this.country,
    required this.checkIn,
    required this.checkOut,
    required this.roomType,
    this.amenities = const [],
  });

  final String city;
  final String country;
  final DateTime checkIn;
  final DateTime checkOut;
  final String roomType;
  final List<String> amenities;

  @override
  String get offerType => 'hotel';
}