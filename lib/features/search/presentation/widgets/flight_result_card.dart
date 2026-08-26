import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';

class FlightResultCard extends StatelessWidget {
  final FlightOffer offer;
  const FlightResultCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final label = '${offer.airline}, ${offer.origin} to ${offer.destination}, price ${offer.price}';
    return Semantics(
      label: label,
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
              fallbackIcon: Icons.flight,
              semanticLabel: offer.airline,
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.airline, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${offer.origin} → ${offer.destination}'),
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
