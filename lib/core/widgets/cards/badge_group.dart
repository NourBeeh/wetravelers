import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';

/// Renders a controlled group of badges with max limit and primary emphasis
class BadgeGroup extends StatelessWidget {
  const BadgeGroup({
    super.key,
    required this.badges,
    this.maxBadges = 3,
    this.primaryBadge,
    this.spacing = AppSpacing.xs,
    this.runSpacing = AppSpacing.xs,
    this.variant = CardBadgeVariant.tinted,
  });

  /// List of badge types to display
  final List<BadgeType> badges;

  /// Maximum number of badges to show (default 3)
  final int maxBadges;

  /// Primary badge to emphasize (shown first, can be styled differently)
  final BadgeType? primaryBadge;

  /// Horizontal spacing between badges
  final double spacing;

  /// Vertical spacing between wrapped rows
  final double runSpacing;

  /// Variant for all badges in the group
  final CardBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final visibleBadges = _getVisibleBadges();
    
    if (visibleBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: visibleBadges.map((type) {
        final isPrimary = primaryBadge != null && type == primaryBadge;
        return _BadgeWithType(
          type: type,
          variant: variant,
          isPrimary: isPrimary,
        );
      }).toList(),
    );
  }

  List<BadgeType> _getVisibleBadges() {
    if (badges.isEmpty) return [];
    
    final seen = <BadgeType>{};
    final ordered = <BadgeType>[];
    
    // Add primary badge first if it's in the list
    if (primaryBadge != null && badges.contains(primaryBadge)) {
      ordered.add(primaryBadge!);
      seen.add(primaryBadge!);
    }
    
    // Add remaining badges in priority order (using registry priority)
    final remaining = badges.where((b) => b != primaryBadge).toList();
    final specs = BadgeRegistry.getAll();
    final priorityMap = {for (var s in specs) s.type: s.priority};
    
    remaining.sort((a, b) => 
      (priorityMap[a] ?? 999).compareTo(priorityMap[b] ?? 999));
    
    for (final type in remaining) {
      if (seen.add(type) && ordered.length < maxBadges) {
        ordered.add(type);
      }
    }
    
    return ordered.take(maxBadges).toList();
  }
}

class _BadgeWithType extends StatelessWidget {
  const _BadgeWithType({
    required this.type,
    required this.variant,
    required this.isPrimary,
  });

  final BadgeType type;
  final CardBadgeVariant variant;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return CardBadge(
      type: type,
      variant: variant,
      // Primary badges could be styled differently in the future
    );
  }
}