import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart';

/// Car placeholder card for Home discovery when no real data is available.
///
/// Shows the approved Car card design with skeleton/placeholder content.
/// No fake car models, prices, or specifications.
class CarPlaceholderCard extends StatelessWidget {
  const CarPlaceholderCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Car placeholder',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: SizedBox(
          height: 220,
          child: Stack(
            children: [
              Positioned.fill(
                child: CardImage(
                  url: null,
                  fallbackIcon: Icons.directions_car,
                  semanticLabel: 'Car placeholder',
                  fit: BoxFit.cover,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Placeholder model name
                      _PlaceholderText(width: 0.6, height: 20),
                      // Placeholder specs
                      if (false) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (int i = 0; i < 3; i++) ...[
                              _PlaceholderSpecChip(),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      // Placeholder price
                      CardPrice(
                        price: 0,
                        currency: '',
                        color: Colors.white,
                        isPlaceholder: true,
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

class _PlaceholderSpecChip extends StatelessWidget {
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