import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_rating.dart';
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart';

/// Hotel placeholder card for Home discovery when no real data is available.
///
/// Shows the approved Hotel card design with skeleton/placeholder content.
/// No fake hotel names, prices, or ratings.
class HotelPlaceholderCard extends StatelessWidget {
  const HotelPlaceholderCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final targetHeight = HomeCardDimensions.cardHeightForType(HomeCardType.hotel);

    return Semantics(
      label: 'Hotel placeholder',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: SizedBox(
          height: targetHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CardImage(
                  url: null,
                  fallbackIcon: Icons.hotel,
                  semanticLabel: 'Hotel placeholder',
                ),
              ),
              // Placeholder badge pill — top-left
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _PlaceholderBadge(label: 'HOTEL'),
              ),
              // Placeholder rating pill — top-right
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _PlaceholderRatingPill(),
              ),
              // Bottom gradient scrim with placeholder content
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
                      // Placeholder title
                      _PlaceholderText(width: 0.7, height: 20),
                      const SizedBox(height: AppSpacing.xs),
                      // Placeholder subtitle
                      _PlaceholderText(width: 0.5, height: 14),
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

class _PlaceholderBadge extends StatelessWidget {
  final String label;
  const _PlaceholderBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: _PlaceholderText(width: 0.4, height: 12),
    );
  }
}

class _PlaceholderRatingPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: _PlaceholderText(width: 0.5, height: 12),
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