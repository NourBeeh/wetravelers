import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_image.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_price.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_badge.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_rating.dart';

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
      if (ratingText != null) ratingText,
      if (reviewsText != null) reviewsText,
      if (priceText != null) 'Price $priceText',
      if (item.badge != null) 'Badge ${item.badge}',
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      // Card is not interactive itself; children provide their own semantics
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardImage(url: item.imageUrl, height: 160),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                  if (item.subtitle != null) Text(item.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.sm),
                  CardRating(rating: item.rating, reviewCount: item.reviewCount),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Spacer(),
                      CardPrice(price: item.price, currency: item.currency, rawPrice: item.rawPrice),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  CardBadge(label: item.badge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
