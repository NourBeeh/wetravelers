import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/offers/car_offer.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';

class CarResultCard extends StatelessWidget {
  final CarOffer offer;
  const CarResultCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final label = '${offer.title}, ${offer.carType}, price ${offer.price} ${offer.currency}';
    return Semantics(
      label: label,
      child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(offer.carType),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Spacer(),
                Text('Price: ${offer.price.toStringAsFixed(0)} ${offer.currency}'),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
