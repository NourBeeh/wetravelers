import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';

/// Price block with optional strikethrough original price for discounts.
///
/// When [originalPrice] is null (or not higher than [currentPrice]) only the
/// current price renders — identical layout either way. Price strings flow
/// through the shared [formatCardPrice] so no per-widget formatting logic is
/// duplicated.
class CardPriceBlock extends StatelessWidget {
  const CardPriceBlock({
    super.key,
    required this.currentPrice,
    this.originalPrice,
    this.currency = 'USD',
    this.color,
    this.originalColor,
    this.showCurrency = true,
  });

  final double currentPrice;

  /// Shown struck-through when provided and greater than [currentPrice].
  final double? originalPrice;
  final String? currency;
  final Color? color;

  /// Muted color for the struck-through original price; defaults to
  /// onSurfaceVariant at reduced opacity.
  final Color? originalColor;
  final bool showCurrency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDiscount =
        originalPrice != null && originalPrice! > currentPrice;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatCardPrice(price: currentPrice, currency: currency, showCurrency: showCurrency),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            formatCardPrice(price: originalPrice, currency: currency, showCurrency: showCurrency),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color:
                      originalColor ?? scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );
  }
}
