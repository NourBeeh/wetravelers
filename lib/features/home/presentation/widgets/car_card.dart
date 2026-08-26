import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';

/// Luxury car card — same gradient-scrim-over-image treatment as
/// Hotel/Package, plus compact spec chips (transmission / seats when
/// present in metadata) between title and price.
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
        child: SizedBox(
          height: 220,
          child: Stack(
            children: [
              Positioned.fill(
                child: CardImage(
                  url: item.imageUrl,
                  fallbackIcon: Icons.directions_car,
                  semanticLabel: item.title,
                ),
              ),
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
                      if (type.isNotEmpty)
                        Text(
                          type,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      // Spec chips — only render what the data actually has.
                      if (_specs.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final spec in _specs) ...[
                              _SpecChip(label: spec),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                          ],
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

  List<String> get _specs {
    final specs = <String>[];
    final transmission = item.metadata['transmission']?.toString();
    if (transmission != null && transmission.isNotEmpty) specs.add(transmission);
    final seats = item.metadata['seats'];
    if (seats != null && seats.toString().isNotEmpty) specs.add('$seats seats');
    return specs;
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  const _SpecChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
    );
  }
}
