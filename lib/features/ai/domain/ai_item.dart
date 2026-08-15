import 'package:flutter/foundation.dart';

import 'package:wetravellers/core/domain/models/home/home_types.dart';

import 'ai_action.dart';

/// Parses the canonical card-type string used by the AI contract, mirroring
/// the home repository fallback so unknown types render as a plain deal.
HomeCardType _parseCardType(String? s) {
  switch (s?.toLowerCase()) {
    case 'flight':
      return HomeCardType.flight;
    case 'hotel':
      return HomeCardType.hotel;
    case 'car':
      return HomeCardType.car;
    case 'package':
      return HomeCardType.package;
    case 'destination':
      return HomeCardType.destination;
    case 'deal':
      return HomeCardType.deal;
    case 'experience':
      return HomeCardType.experience;
    case 'story':
      return HomeCardType.story;
    default:
      return HomeCardType.deal;
  }
}

Map<String, dynamic> _asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<AiAction> _parseActions(Object? value) {
  final actions = <AiAction>[];
  if (value is List) {
    for (final entry in value) {
      if (entry is Map<String, dynamic>) {
        actions.add(AiAction.fromMap(entry));
      }
    }
  }
  return actions;
}

/// A single card in an AI prompt response.
///
/// Shaped as a superset of the home feed rendering fields (`HomeItem`) so the
/// existing HomeCard engine renders it unchanged through a small mapper at the
/// boundary, while AI-only extras (`order`, `data`, `actions`) stay out of the
/// home domain models.
@immutable
class AiItem {
  const AiItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.price,
    this.currency,
    this.rating,
    this.reviewCount,
    this.badge,
    this.highlights = const [],
    this.tags = const [],
    this.actionLabel,
    this.rawPrice,
    this.order,
    this.data = const {},
    this.actions = const [],
    this.metadata = const {},
  });

  final String id;
  final HomeCardType type;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final double? price;
  final String? currency;
  final double? rating;
  final int? reviewCount;
  final String? badge;
  final List<String> highlights;
  final List<String> tags;
  final String? actionLabel;
  final double? rawPrice;

  /// Explicit ordering hint; when absent the list order wins.
  final int? order;

  /// Type-specific card payload (e.g. flight `route`) merged onto
  /// `HomeItem.metadata` by the mapper so the existing cards keep rendering
  /// their details exactly as they do on the home feed.
  final Map<String, dynamic> data;

  /// Future action envelope (`book`, `view`, `call`...) — not rendered yet.
  final List<AiAction> actions;

  final Map<String, dynamic> metadata;

  factory AiItem.fromMap(Map<String, dynamic> map) {
    return AiItem(
      id: map['id']?.toString() ?? '',
      type: _parseCardType(map['type']?.toString()),
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString(),
      description: map['description']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      price: double.tryParse(map['price']?.toString() ?? ''),
      currency: map['currency']?.toString(),
      rating: double.tryParse(map['rating']?.toString() ?? ''),
      reviewCount: int.tryParse(map['reviewCount']?.toString() ?? ''),
      badge: map['badge']?.toString(),
      highlights: (map['highlights'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      actionLabel: map['action']?.toString() ?? map['actionLabel']?.toString(),
      rawPrice: double.tryParse(map['rawPrice']?.toString() ?? ''),
      order: int.tryParse(map['order']?.toString() ?? ''),
      data: _asMap(map['data']),
      actions: _parseActions(map['actions']),
      metadata: _asMap(map['metadata']),
    );
  }
}