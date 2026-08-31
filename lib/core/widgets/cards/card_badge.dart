import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';
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
    this.type,
  });

  /// Text label for the badge (for backward compatibility with custom labels)
  final String? label;

  /// Icon for the badge (for backward compatibility with custom icons)
  final IconData? icon;

  /// Visual variant: tinted (solid) or glass (frosted)
  final CardBadgeVariant variant;

  /// Semantic badge type for consistent theming and priority
  /// When provided, label and icon are derived from the badge spec
  final BadgeType? type;

  /// Create a badge from a semantic type
  factory CardBadge.fromType(
    BadgeType type, {
    CardBadgeVariant variant = CardBadgeVariant.tinted,
  }) {
    return CardBadge(type: type, variant: variant);
  }

  @override
  Widget build(BuildContext context) {
    final spec = type != null ? BadgeRegistry.getSpec(type!) : null;
    final effectiveLabel = label ?? spec?.label;
    final effectiveIcon = icon ?? spec?.icon;

    if ((effectiveLabel == null || effectiveLabel.isEmpty) && effectiveIcon == null) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final onDark = variant == CardBadgeVariant.glass;
    final isPrimary = type != null && spec?.emphasis == BadgeEmphasis.primary;

    Color foreground;
    Color background;

    if (onDark) {
      foreground = Colors.white;
      background = spec?.getBackgroundColor(context) ?? Colors.white.withValues(alpha: 0.14);
    } else if (spec != null) {
      foreground = spec.getColor(context);
      background = spec.getBackgroundColor(context);
    } else {
      foreground = scheme.onPrimaryContainer;
      background = scheme.primaryContainer;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (effectiveIcon != null) ...[
          Icon(effectiveIcon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.xs),
        ],
        if (effectiveLabel != null && effectiveLabel.isNotEmpty)
          Text(
            effectiveLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                ),
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
        tint: background,
        borderColor: Colors.white.withValues(alpha: 0.25),
        child: content,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: content,
    );
  }
}