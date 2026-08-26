import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_glass.dart';

/// Badge variants: a tinted solid chip (default) or a frosted [glass] pill for
/// placing directly over a photo.
enum CardBadgeVariant { tinted, glass }

class CardBadge extends StatelessWidget {
  const CardBadge({
    super.key,
    this.label,
    this.icon,
    this.variant = CardBadgeVariant.tinted,
  });

  final String? label;
  final IconData? icon;
  final CardBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    if ((label == null || label!.isEmpty) && icon == null) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final onDark = variant == CardBadgeVariant.glass;
    final foreground = onDark ? Colors.white : scheme.onPrimaryContainer;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.xs),
        ],
        if (label != null && label!.isNotEmpty)
          Text(
            label!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
          ),
      ],
    );

    final padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    );

    if (onDark) {
      return CardGlass(
        padding: padding,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: content,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: content,
    );
  }
}
