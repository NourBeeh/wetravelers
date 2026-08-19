import 'package:flutter/foundation.dart';

/// Immutable context describing where the user currently is within the app
/// when an AI query is triggered.
@immutable
class AiQueryContext {
  const AiQueryContext({
    required this.route,
    this.screenTitle,
    this.selectedOfferIds = const [],
    this.metadata = const {},
  });

  /// The current page/route identifier (e.g. 'home', 'flights', 'hotels', 'cars', 'bag', 'other').
  final String route;

  /// Optional human-readable screen title.
  final String? screenTitle;

  /// Optional lightweight selected offer or item identifiers on the current page.
  final List<String> selectedOfferIds;

  /// Optional arbitrary metadata payload.
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'route': route,
      if (screenTitle != null) 'screenTitle': screenTitle,
      if (selectedOfferIds.isNotEmpty) 'selectedOfferIds': selectedOfferIds,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  factory AiQueryContext.fromMap(Map<String, dynamic> map) {
    return AiQueryContext(
      route: map['route'] as String? ?? 'home',
      screenTitle: map['screenTitle'] as String?,
      selectedOfferIds: (map['selectedOfferIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      metadata: map['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiQueryContext &&
        other.route == route &&
        other.screenTitle == screenTitle &&
        listEquals(other.selectedOfferIds, selectedOfferIds);
  }

  @override
  int get hashCode => Object.hash(route, screenTitle, Object.hashAll(selectedOfferIds));
}
