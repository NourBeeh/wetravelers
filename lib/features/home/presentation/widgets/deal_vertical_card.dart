import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price_block.dart';
import 'package:wetravellers/core/widgets/cards/deal_presentation.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';

/// Deal vertical card for Home discovery sections.
///
/// Vertical layout with full-width image and deal presentation.
/// Uses shared Card Design System primitives.
/// Shows current price, discount/savings, validity.
/// NO original/strikethrough price, NO countdown.
class DealVerticalCard extends StatelessWidget {
  const DealVerticalCard({
    super.key,
    required this.item,
    this.onTap,
    this.onWishlistChanged,
  });

  final HomeItem item;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onWishlistChanged;

  double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      final parsed = DateTime.tryParse(value.toString());
      if (parsed == null) return null;
      return parsed.isUtc ? parsed.toLocal() : parsed;
    } catch (_) {
      return null;
    }
  }

  String? _buildValidityText(DateTime? validUntil) {
    if (validUntil == null) return null;
    final now = DateTime.now();
    if (validUntil.isBefore(now)) return null;
    return 'Valid until ${DateFormat.MMMd().format(validUntil)}';
  }

  @override
  Widget build(BuildContext context) {
    final discountedPrice = item.price;
    final savingsPercent = item.metadata['savingsPercent'];
    final savingsAmount = _parsePrice(item.metadata['savingsAmount']);
    final validUntil = _parseDateTime(item.metadata['validUntil']);
    final validityText = _buildValidityText(validUntil);

    final semanticParts = <String>[
      'Deal',
      item.title,
      if (item.subtitle != null) item.subtitle!,
      if (discountedPrice != null) 'Price ${NumberFormat.currency(symbol: '', locale: 'en_US').format(discountedPrice)} ${item.currency ?? ''}',
      if (savingsPercent != null) 'Save $savingsPercent%',
      if (savingsAmount != null) 'Save ${NumberFormat.currency(symbol: '', locale: 'en_US').format(savingsAmount)} ${item.currency ?? ''}',
      if (validityText != null) validityText!,
    ];
    final semanticLabel = semanticParts.join(', ');

    return BaseCard(
      onTap: onTap,
      semanticsLabel: semanticLabel,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full-width image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CardImage(
              url: item.imageUrl,
              fallbackIcon: Icons.local_offer,
              semanticLabel: item.title,
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Discount % badge
                if (savingsPercent != null && savingsPercent! > 0) ...[
                  CardBadge(
                    label: '$savingsPercent% OFF',
                    icon: Icons.local_offer,
                    variant: CardBadgeVariant.tinted,
                    type: BadgeType.discount,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                // Title
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                // Subtitle
                if (item.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                // Deal presentation (discount %, savings, validity)
                DealPresentation(
                  discountPercent: item.metadata['savingsPercent'] as int?,
                  savingsAmount: _parsePrice(item.metadata['savingsAmount']),
                  validUntil: item.metadata['validUntil'],
                  currency: item.currency,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Price block - ONLY current deal price, no original/strikethrough
                CardPriceBlock(
                  currentPrice: item.price ?? 0,
                  currency: item.currency ?? 'USD',
                  showCurrency: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}