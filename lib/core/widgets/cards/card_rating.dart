import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_glass.dart';

/// Star rating row. Inline by default; pass [onImage] to render as a
/// translucent dark glass pill for placement over a photo (this is the single
/// implementation the duplicated per-card rating pills should adopt).
class CardRating extends StatelessWidget {
  const CardRating({
    super.key,
    this.rating,
    this.reviewCount,
    this.onImage = false,
    this.textColor,
  });

  final double? rating;
  final int? reviewCount;

  /// Render as a dark glass pill (white text) for on-image placement.
  final bool onImage;

  /// Optional override for the value/count text colour (inline mode).
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          rating!.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor ?? (onImage ? Colors.white : null),
              ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: onImage
                      ? Colors.white70
                      : (textColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
                ),
          ),
        ],
      ],
    );

    if (!onImage) return content;

    return CardGlass(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      tint: Colors.black.withValues(alpha: 0.45),
      borderColor: Colors.white.withValues(alpha: 0.25),
      child: content,
    );
  }
}
