import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_favorite.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';

/// Car discovery card for Home horizontal carousels.
///
/// Full-bleed image with gradient scrim carrying title, category, specs, and price.
/// Overlays: category badge (top-left), wishlist (top-right).
/// Uses shared Card Design System primitives — no custom glass/price logic.
class CarDiscoveryCard extends StatelessWidget {
  const CarDiscoveryCard({
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
    final category = item.metadata['type']?.toString() ?? '';
    final transmission = item.metadata['transmission']?.toString();
    final seats = item.metadata['seats'];
    final luggage = item.metadata['luggage']?.toString();
    final ac = item.metadata['ac']?.toString();

    final semanticParts = <String>[
      item.title,
      if (category.isNotEmpty) category,
      if (transmission != null) transmission,
      if (seats != null) '${seats} seats',
      if (luggage != null) luggage,
      if (ac != null) 'AC',
      if (item.price != null) 'Price ${item.price!.toStringAsFixed(0)} ${item.currency ?? ''}',
    ];
    final semanticLabel = semanticParts.join(', ');

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: 280,
          height: 220,
          child: Stack(
            children: [
              // Full-bleed image
              Positioned.fill(
                child: CardImage(
                  url: item.imageUrl,
                  fallbackIcon: Icons.directions_car,
                  semanticLabel: item.title,
                ),
              ),
              // Category badge — top-left (glass variant for on-image)
              if (category.isNotEmpty)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: CardBadge(
                    label: category,
                    variant: CardBadgeVariant.glass,
                    icon: Icons.directions_car,
                  ),
                ),
              // Wishlist heart — top-right
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
              // Bottom gradient scrim with content
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
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                      // Specs
                      if (_specs.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: _specs.map((spec) => _SpecChip(label: spec)).toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      // Price
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
    if (seats != null && seats.toString().isNotEmpty) specs.add('${seats} seats');
    final luggage = item.metadata['luggage']?.toString();
    if (luggage != null && luggage.isNotEmpty) specs.add(luggage);
    final ac = item.metadata['ac']?.toString();
    if (ac != null && ac.isNotEmpty) specs.add('AC');
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
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
    );
  }
}