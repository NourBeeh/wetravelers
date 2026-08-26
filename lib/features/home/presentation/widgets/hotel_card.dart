import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';

/// Luxury hotel card: full-bleed image with a bottom gradient scrim carrying
/// title/subtitle/price (matching PackageCard), a badge pill top-left and a
/// translucent rating pill top-right over the image.
class HotelCard extends StatelessWidget {
  final HomeItem item;
  const HotelCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final ratingText = item.rating != null ? '${item.rating!.toStringAsFixed(1)} stars' : null;
    final reviewsText = item.reviewCount != null ? '${item.reviewCount} reviews' : null;
    final priceText = item.price != null ? '${item.price!.toStringAsFixed(0)} ${item.currency ?? ''}' : null;
    final semanticLabel = [
      item.title,
      if (item.subtitle != null) item.subtitle,
      ?ratingText,
      ?reviewsText,
      if (priceText != null) 'Price $priceText',
      if (item.badge != null) 'Badge ${item.badge}',
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      // Card is not interactive itself; children provide their own semantics
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
              // Badge pill — top-left corner of the image.
              if (item.badge != null && item.badge!.isNotEmpty)
                Positioned(top: AppSpacing.sm, left: AppSpacing.sm, child: CardBadge(label: item.badge)),
              // Rating pill — top-right corner of the image.
              if (item.rating != null)
                Positioned(top: AppSpacing.sm, right: AppSpacing.sm, child: _RatingPill(rating: item.rating!, reviewCount: item.reviewCount)),
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
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
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

/// Translucent dark pill showing rating (+ optional review count) in white.
class _RatingPill extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  const _RatingPill({required this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
          if (reviewCount != null)
            Text(
              ' ($reviewCount)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}
