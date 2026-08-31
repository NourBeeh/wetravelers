import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart'
import 'package:wetravellers/core/widgets/cards/card_badge.dart'
import 'package:wetravellers/core/widgets/cards/card_favorite.dart'
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart'

/// Flight placeholder card for Home horizontal carousels.
///
/// Shows the approved Flight card design with skeleton/placeholder content.
/// No fake flight numbers, routes, prices, or airlines.
class FlightPlaceholderCard extends StatelessWidget {
  const FlightPlaceholderCard({super.key, this.onTap, this.onWishlistChanged});

  final VoidCallback? onTap;
  final ValueChanged<bool>? onWishlistChanged;

  @override
  Widget build(BuildContext context) {
    final targetWidth = HomeCardDimensions.cardWidthForType(HomeCardType.flight);

    return Semantics(
      label: 'Flight placeholder',
      child: SizedBox(
        width: targetWidth,
        height: 240,
        child: Stack(
          children: [
            // Full-bleed placeholder image
            Positioned.fill(
              child: CardImage(
                url: null,
                fallbackIcon: Icons.flight,
                semanticLabel: 'Flight placeholder',
              ),
            ),
            // DEAL badge — top-left (glass variant)
            Positioned(
              top: 8,
              left: 8,
              child: _PlaceholderBadge(label: 'FLIGHT'),
            ),
            // Wishlist — top-right
            Positioned(
              top: 8,
              right: 8,
              child: CardFavorite(
                value: false,
                onChanged: null,
                onImage: true,
                size: 32,
              ),
            ),
            // Bottom gradient scrim with placeholder content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
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
                    // Airline placeholder
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: _PlaceholderText(width: 0.3, height: 12),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PlaceholderText(width: 0.7, height: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Route placeholder
                    if (false) ...[
                      Row(
                        children: [
                          Expanded(child: _PlaceholderText(width: 1.0, height: 13)),
                          const Icon(Icons.flight, size: 14, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: _PlaceholderText(width: 1.0, height: 13)),
                        ],
                      ),
                    ],
                    // Subtitle placeholder
                    if (false) ...[
                      const SizedBox(height: 2),
                      _PlaceholderText(width: 0.5, height: 11),
                    ],
                    const SizedBox(height: 6),
                    // Price placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _PlaceholderPrice(),
                      ],
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: _PlaceholderText(width: 0.4, height: 12),
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

class _PlaceholderPrice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardPrice(
      price: 0,
      currency: '',
      color: Colors.white,
      isPlaceholder: true,
    );
  }
}