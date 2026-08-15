import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_image.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_price.dart';

class CarCard extends StatelessWidget {
  final HomeItem item;
  const CarCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item.metadata['type']?.toString() ?? '';
    final label = '${item.title}${type.isNotEmpty ? ', $type' : ''}, price ${item.price} ${item.currency ?? ''}'.trim();
    return Semantics(
      label: label,
      child: Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardImage(url: item.imageUrl, height: 140),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(item.metadata['type']?.toString() ?? '', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Spacer(),
                    CardPrice(price: item.price, currency: item.currency, rawPrice: item.rawPrice),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
