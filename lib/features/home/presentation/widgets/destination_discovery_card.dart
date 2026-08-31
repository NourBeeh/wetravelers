import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart';

/// Destination discovery card for Home horizontal carousels.
///
/// Vertical, image-first card. Image is the dominant visual element.
/// Bottom gradient overlay with destination name and country.
/// NO price, rating, duration, CTA, Bag, price tracking.
/// Tap → Destination Discovery (navigates to search with destination pre-filled if supported).
class DestinationDiscoveryCard extends StatelessWidget {
  const DestinationDiscoveryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final HomeItem item;
  final VoidCallback? onTap;

  String? _getCountry() {
    final country = item.metadata['country']?.toString();
    if (country != null && country.isNotEmpty) return country;
    final region = item.metadata['region']?.toString();
    if (region != null && region.isNotEmpty) return region;
    if (item.subtitle != null && item.subtitle!.isNotEmpty) return item.subtitle;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final country = _getCountry();
    final targetWidth = HomeCardDimensions.cardWidthForType(HomeCardType.destination);
    final targetHeight = HomeCardDimensions.cardHeightForType(HomeCardType.destination);

    final semanticParts = <String>[
      'Destination',
      item.title,
      if (country != null) country,
    ];
    final semanticLabel = semanticParts.join(', ');

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: targetWidth,
          height: targetHeight,
          child: Stack(
            children: [
              // Full-bleed image - dominant element
              Positioned.fill(
                child: CardImage(
                  url: item.imageUrl,
                  fallbackIcon: Icons.photo_camera_outlined,
                  semanticLabel: item.title,
                  fit: BoxFit.cover,
                ),
              ),
              // Bottom gradient overlay with content
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
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Destination name
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      // Country
                      if (country != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              country,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ],
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