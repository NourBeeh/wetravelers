import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price_block.dart';
import 'package:wetravellers/core/widgets/cards/deal_presentation.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';

/// Deal placeholder card for Home discovery when no real data is available.
///
/// Vertical layout with full-width image and deal presentation.
/// Shows the approved Deal design with skeleton/placeholder content.
/// NO original/strikethrough price, NO countdown.
class DealPlaceholderCard extends StatelessWidget {
  const DealPlaceholderCard({super.key, this.onTap, this.onWishlistChanged});

  final VoidCallback? onTap;
  final ValueChanged<bool>? onWishlistChanged;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      semanticsLabel: 'Deal placeholder',
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full-width image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CardImage(
              url: null,
              fallbackIcon: Icons.local_offer,
              semanticLabel: 'Deal placeholder',
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
                // Discount % badge placeholder
                CardBadge(
                  label: 'XX% OFF',
                  icon: Icons.local_offer,
                  variant: CardBadgeVariant.tinted,
                  type: BadgeType.discount,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Title
                _PlaceholderText(width: 0.7, height: 20),
                // Subtitle
                _PlaceholderText(width: 0.5, height: 14),
                const SizedBox(height: AppSpacing.sm),
                // Deal presentation (discount %, savings, validity)
                DealPresentation(
                  discountPercent: null,
                  savingsAmount: null,
                  validUntil: null,
                  currency: null,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Price block - ONLY current deal price, no original/strikethrough
                CardPriceBlock(
                  currentPrice: 0,
                  currency: '',
                  showCurrency: false,
                  loading: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderText extends StatelessWidget {
  final double width;
  final double height;
  const _PlaceholderText({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
