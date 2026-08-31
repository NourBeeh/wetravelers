import 'package:wetravellers/core/widgets/cards/badge_config.dart';

/// Helper to extract badges from metadata consistently across cards
class CardBadgeExtractor {
  /// Extract badges from HomeItem/TravelOffer metadata
  static List<BadgeType> extractBadges(Map<String, dynamic> metadata, {BadgeCategory? category}) {
    final badges = <BadgeType>[];
    
    // Commercial
    if (metadata['discount'] == true) badges.add(BadgeType.discount);
    if (metadata['limitedDeal'] == true) badges.add(BadgeType.limitedDeal);
    if (metadata['memberPrice'] == true) badges.add(BadgeType.memberPrice);
    
    // Trust
    if (metadata['verified'] == true) badges.add(BadgeType.verified);
    if (metadata['topRated'] == true) badges.add(BadgeType.topRated);
    
    // Booking
    if (metadata['freeCancellation'] == true) badges.add(BadgeType.freeCancellation);
    if (metadata['payLater'] == true) badges.add(BadgeType.payLater);
    if (metadata['instantConfirmation'] == true) badges.add(BadgeType.instantConfirmation);
    
    // Flight
    if (metadata['cheapest'] == true) badges.add(BadgeType.cheapest);
    if (metadata['fastest'] == true) badges.add(BadgeType.fastest);
    if (metadata['best'] == true) badges.add(BadgeType.best);
    if (metadata['selfTransfer'] == true) badges.add(BadgeType.selfTransfer);
    if (metadata['airportChange'] == true) badges.add(BadgeType.airportChange);
    if (metadata['riskyConnection'] == true) badges.add(BadgeType.riskyConnection);
    
    // Hotel
    if (metadata['breakfastIncluded'] == true) badges.add(BadgeType.breakfastIncluded);
    if (metadata['limitedRooms'] == true) badges.add(BadgeType.limitedRooms);
    
    // Filter by category if specified
    if (category != null) {
      final specs = BadgeRegistry.getByCategory(category);
      final categoryTypes = specs.map((s) => s.type).toSet();
      badges.retainWhere(categoryTypes.contains);
    }
    
    return badges;
  }

  /// Extract primary badge (first by priority)
  static BadgeType? extractPrimaryBadge(Map<String, dynamic> metadata) {
    final badges = extractBadges(metadata);
    if (badges.isEmpty) return null;
    
    final specs = BadgeRegistry.getAll();
    final priorityMap = {for (var s in specs) s.type: s.priority};
    
    badges.sort((a, b) => 
      (priorityMap[a] ?? 999).compareTo(priorityMap[b] ?? 999));
    
    return badges.first;
  }

  /// Extract badges by category
  static Map<BadgeCategory, List<BadgeType>> extractByCategory(Map<String, dynamic> metadata) {
    final result = <BadgeCategory, List<BadgeType>>{};
    
    for (final category in BadgeCategory.values) {
      final badges = extractBadges(metadata, category: category);
      if (badges.isNotEmpty) {
        result[category] = badges;
      }
    }
    
    return result;
  }
}