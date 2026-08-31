import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_favorite.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';
import 'package:wetravellers/core/widgets/cards/card_rating.dart';

/// Hotel discovery card for Home horizontal carousels.
///
/// Full-bleed image with gradient scrim carrying title, location, and price.
/// Overlays: wishlist (top-right), badge (top-left), rating (top-right).
/// Uses shared Card Design System primitives — no custom glass/price logic.
class HotelDiscoveryCard extends StatelessWidget {
  const HotelDiscoveryCard({
    super.key,
    required this.item,
    this.onTap,
    this.onWishlistChanged,
  });

  final HomeItem item;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onWishlistChanged;

  @override
  Widget build(BuildContext context) {
    final isWishlisted = item.metadata['isWishlisted'] == true;
    final semanticLabel = [
      item.title,
      if (item.subtitle != null) item.subtitle,
      if (item.rating != null) '${item.rating!.toStringAsFixed(1)} stars',
      if (item.reviewCount != null) '${item.reviewCount} reviews',
      if (item.price != null) 'Price ${item.price!.toStringAsFixed(0)} ${item.currency ?? ''}',
      if (item.badge != null) 'Badge ${item.badge}',
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          height: 240,
          child: Stack(
            children: [
              Positioned.fill(
                child: CardImage(
                  url: item.imageUrl,
                  fallbackIcon: Icons.hotel,
                  semanticLabel: item.title,
                ),
              ),
              // Badge pill — top-left corner of the image (glass variant for on-image).
              if (item.badge != null && item.badge!.isNotEmpty)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: CardBadge(
                    label: item.badge,
                    variant: CardBadgeVariant.glass,
                  ),
                ),
              // Wishlist heart — top-right corner of the image (glass variant).
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: CardFavorite(
                  value: isWishlisted,
                  onChanged: onWishlistChanged,
                  onImage: true,
                  size: 32,
                ),
              ),
              // Rating pill — top-right, below wishlist (glass variant for on-image).
              if (item.rating != null)
                Positioned(
                  top: AppSpacing.sm + 36,
                  right: AppSpacing.sm,
                  child: CardRating(
                    rating: item.rating!,
                    reviewCount: item.reviewCount,
                    onImage: true,
                  ),
                ),
              // Bottom gradient scrim carrying the text content.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          item.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      CardPrice(
                        price: item.price,
                        currency: item.currency,
                        rawPrice: item.rawPrice,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}