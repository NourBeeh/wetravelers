import 'package:flutter/foundation.dart';

/// Base normalized offer fields shared across all travel products.
/// Concrete offers extend this with product-specific data.
@immutable
abstract class BaseOffer {
  const BaseOffer({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    required this.price,
    required this.currency,
    this.availability,
    this.validUntil,
    this.metadata = const {},
    this.rating,
    this.reviewCount,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final double price;
  final String currency;
  final bool? availability;
  final DateTime? validUntil;
  final Map<String, dynamic> metadata;
  final double? rating;
  final int? reviewCount;

  /// Normalized identifier for UI rendering.
  String get offerType;
}