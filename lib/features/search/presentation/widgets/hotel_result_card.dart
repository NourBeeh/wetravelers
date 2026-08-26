import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';

class HotelResultCard extends StatelessWidget {
  final HotelOffer offer;
  const HotelResultCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final semanticLabel = '${offer.title}, ${offer.city}, ${offer.country}, Price ${offer.price.toStringAsFixed(0)} ${offer.currency}';
    return Semantics(
      label: semanticLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardImage(
              url: offer.imageUrl,
              height: 140,
              fallbackIcon: Icons.hotel,
              semanticLabel: offer.title,
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${offer.city}, ${offer.country}'),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Spacer(),
                      CardPrice(price: offer.price, currency: offer.currency),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
