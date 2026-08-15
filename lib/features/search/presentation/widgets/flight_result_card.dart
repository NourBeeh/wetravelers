import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';

class FlightResultCard extends StatelessWidget {
  final FlightOffer offer;
  const FlightResultCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final label = '${offer.airline}, ${offer.origin} to ${offer.destination}, price ${offer.price}';
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
            Text(offer.airline, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('${offer.origin} → ${offer.destination}'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Spacer(),
                Text('Price: ${offer.price.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
