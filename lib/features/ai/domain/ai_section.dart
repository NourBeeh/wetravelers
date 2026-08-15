import 'package:flutter/foundation.dart';

import 'package:wetravellers/core/domain/models/home/home_types.dart';

import 'ai_item.dart';

/// Parses the layout string, reusing the home section vocabulary.
HomeSectionLayout _parseLayout(String? s) {
  switch (s?.toLowerCase()) {
    case 'horizontal':
      return HomeSectionLayout.horizontal;
    case 'horizontalpeek':
      return HomeSectionLayout.horizontalPeek;
    case 'grid':
      return HomeSectionLayout.grid;
    default:
      return HomeSectionLayout.vertical;
  }
}

/// One semantic block inside an AI response — maps 1:1 onto a home section.
///
/// [layout] reuses [HomeSectionLayout] (same vocabulary, including the
/// `horizontalPeek` example) so rendering needs no translation.
@immutable
class AiSection {
  const AiSection({
    required this.title,
    this.id,
    this.subtitle,
    this.layout = HomeSectionLayout.vertical,
    this.items = const [],
    this.order,
    this.metadata = const {},
  });

  final String? id;
  final String title;
  final String? subtitle;
  final HomeSectionLayout layout;

  /// Ordered cards inside this section.
  final List<AiItem> items;

  /// Explicit ordering hint among sibling sections.
  final int? order;

  final Map<String, dynamic> metadata;

  factory AiSection.fromMap(Map<String, dynamic> map) {
    final items = <AiItem>[];
    final rawItems = map['items'] as List? ?? const [];
    for (final entry in rawItems) {
      if (entry is Map<String, dynamic>) {
        items.add(AiItem.fromMap(entry));
      }
    }
    return AiSection(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString(),
      layout: _parseLayout(map['layout']?.toString()),
      items: items,
      order: int.tryParse(map['order']?.toString() ?? ''),
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
    );
  }
}