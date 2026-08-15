import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_image.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_price.dart';

class PackageCard extends StatelessWidget {
  final HomeItem item;
  const PackageCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final label = '${item.title}, price ${item.price} ${item.currency ?? ''}';
    return Semantics(
      label: label,
      child: SizedBox(
      height: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Stack(
          children: [
            CardImage(url: item.imageUrl, height: 220),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
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
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: AppSpacing.xs),
                    CardPrice(price: item.price, currency: item.currency, rawPrice: item.rawPrice),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
    );
  }
}
