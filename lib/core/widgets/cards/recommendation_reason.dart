import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';

/// A lightweight widget that displays a recommendation reason for a card item.
///
/// Reads the reason from item metadata (prefers `metadata['recommendationReason']`).
/// Does not contain hardcoded recommendation texts - only renders what's provided
/// in the item's metadata. If no reason is available, renders nothing (zero-size).
class RecommendationReason extends StatelessWidget {
  const RecommendationReason({
    super.key,
    required this.reason,
    this.showIcon = true,
  });

  final String? reason;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    if (reason == null || reason!.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use semantic colors from theme - no hardcoded colors
    final backgroundColor = scheme.primaryContainer;
    final textColor = scheme.onPrimaryContainer;
    final iconColor = scheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxs),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Text(
                reason!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to extract recommendation reason from item metadata
extension RecommendationReasonExt on Map<String, dynamic> {
  String? get recommendationReason {
    // Priority order for recommendation reason fields
    const reasonKeys = [
      'recommendationReason',
      'recommendation_reason',
      'whyRecommended',
      'why_recommended',
      'recommendationDetail',
    ];

    for (final key in reasonKeys) {
      final value = this[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}