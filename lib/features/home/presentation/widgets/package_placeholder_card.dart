import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price_block.dart';
import 'package:wetravellers/core/widgets/cards/card_feature_list.dart';
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart';

/// Package placeholder card for Home discovery when no real data is available.
///
/// Shows the approved Package card design with skeleton/placeholder content.
/// No fake package names, destinations, prices, or inclusions.
class PackagePlaceholderCard extends StatelessWidget {
  const PackagePlaceholderCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final targetHeight = HomeCardDimensions.cardHeightForType(HomeCardType.package);

    return Semantics(
      label: 'Package placeholder',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: SizedBox(
          height: targetHeight,
          child: Stack(
            children: [
              // Full-bleed image - approximately 55-60% width
              Expanded(
                flex: 6,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CardImage(
                    url: null,
                    fallbackIcon: Icons.card_travel,
                    semanticLabel: 'Package placeholder',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Content section - approximately 40-45% width
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Package name placeholder
                      _PlaceholderText(width: 0.8, height: 20),
                      const SizedBox(height: AppSpacing.xs),
                      // Cities/destinations placeholder
                      _PlaceholderText(width: 0.6, height: 14),
                      const SizedBox(height: AppSpacing.sm),
                      // Duration placeholder
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          _PlaceholderText(width: 0.5, height: 14),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Inclusions placeholder (up to 3)
                      if (true) ...[
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: List.generate(3, (index) => _PlaceholderInclusionChip()),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      // Subtitle placeholder
                      _PlaceholderText(width: 0.6, height: 14),
                      const SizedBox(height: AppSpacing.xs),
                      // Price per person placeholder
                      CardPriceBlock(
                        currentPrice: 0,
                        currency: '',
                        showCurrency: true,
                        loading: true,
                        unit: 'person',
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

class _PlaceholderText extends StatelessWidget {
  final double width;
  final double height;
  const _PlaceholderText({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PlaceholderInclusionChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: _PlaceholderText(width: 0.4, height: 12),
    );
  }
}