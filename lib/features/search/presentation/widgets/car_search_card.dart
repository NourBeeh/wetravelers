import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/offers/car_offer.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';
import 'package:wetravellers/core/widgets/cards/card_cancellation.dart';
import 'package:wetravellers/core/widgets/cards/card_feature_list.dart';
import 'package:wetravellers/core/widgets/cards/card_price_block.dart';

/// Car search card for search results.
///
/// Horizontal layout with image (~50-55% width) on the left, content on the right.
/// Uses BaseCard for pressed/disabled/loading states and accessibility.
/// Composes shared Card Design System primitives: CardImage, CardBadge, CardFeatureList,
/// CardCancellation, CardPriceBlock.
/// NO CTA button - entire card is tappable → Car Details (booking review flow).
class CarSearchCard extends StatelessWidget {
  const CarSearchCard({
    super.key,
    required this.offer,
    this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final CarOffer offer;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  int get _rentalDays {
    final diff = offer.dropoffTime.difference(offer.pickupTime);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    // Round up if there are remaining hours
    return days > 0 ? (hours > 0 ? days + 1 : days) : 1;
  }

  bool get _hasDiscount {
    final metadata = offer.metadata;
    final originalPrice = metadata['originalPrice'];
    if (originalPrice == null) return false;
    final numVal = originalPrice is num ? originalPrice.toDouble() : double.tryParse(originalPrice.toString());
    return numVal != null && numVal > offer.price;
  }

  int? _getDiscountPercent() {
    final metadata = offer.metadata;
    final originalPrice = metadata['originalPrice'];
    if (originalPrice == null) return null;
    final numVal = originalPrice is num ? originalPrice.toDouble() : double.tryParse(originalPrice.toString());
    if (numVal == null || numVal <= offer.price) return null;
    final discount = ((numVal - offer.price) / numVal * 100).round();
    return discount > 0 ? discount : null;
  }

  bool get _hasOrSimilar {
    final metadata = offer.metadata;
    return metadata['orSimilar'] == true;
  }

  String? get _mileagePolicy {
    final metadata = offer.metadata;
    final mileage = metadata['mileagePolicy']?.toString() ?? metadata['unlimitedMileage']?.toString();
    if (mileage == null) return null;
    if (mileage.toLowerCase() == 'true' || mileage.toLowerCase() == 'unlimited') {
      return 'Unlimited mileage';
    }
    return mileage;
  }

  bool get _hasFreeCancellation {
    final metadata = offer.metadata;
    return metadata['freeCancellation'] == true;
  }

  String? get _cancellationLabel {
    final metadata = offer.metadata;
    return metadata['cancellationPolicy']?.toString();
  }

  List<String> _buildFeatures() {
    final features = <String>[];
    if (offer.transmission != null && offer.transmission!.isNotEmpty) {
      features.add(offer.transmission!);
    }
    if (offer.seats != null) {
      features.add('${offer.seats} seats');
    }
    final luggage = offer.metadata['luggage']?.toString();
    if (luggage != null && luggage.isNotEmpty) {
      features.add(luggage);
    }
    return features;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final features = _buildFeatures();
    final discountPercent = _getDiscountPercent();
    final hasDiscount = _hasDiscount;
    final hasOrSimilar = _hasOrSimilar;
    final mileagePolicy = _mileagePolicy;
    final hasFreeCancellation = _hasFreeCancellation;
    final rentalDays = _rentalDays;

    final semanticParts = <String>[
      offer.title,
      offer.carType,
      if (offer.transmission != null) offer.transmission!,
      if (offer.seats != null) '${offer.seats} seats',
      if (features.isNotEmpty) features.join(', '),
      if (mileagePolicy != null) mileagePolicy!,
      'Pickup: ${offer.pickupLocation} at ${_formatTime(offer.pickupTime)}',
      'Dropoff: ${offer.dropoffLocation} at ${_formatTime(offer.dropoffTime)}',
      'Rental: $rentalDays day${rentalDays > 1 ? 's' : ''}',
      if (hasFreeCancellation) 'Free cancellation',
      'Price ${NumberFormat.currency(symbol: '', locale: 'en_US').format(offer.price)} ${offer.currency} / day',
    ];
    final semanticLabel = semanticParts.join(', ');

    return BaseCard(
      onTap: onTap,
      enabled: enabled,
      loading: loading,
      semanticsLabel: semanticLabel,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section - approximately 50-55% width
          Expanded(
            flex: 55,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CardImage(
                url: offer.imageUrl,
                fallbackIcon: Icons.directions_car,
                semanticLabel: offer.title,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content section - approximately 45-50% width
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Discount badge
                  if (hasDiscount && discountPercent != null) ...[
                    CardBadge(
                      label: '$discountPercent% OFF',
                      icon: Icons.local_offer,
                      variant: CardBadgeVariant.tinted,
                      type: BadgeType.discount,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  // Vehicle model
                  Text(
                    offer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  // Or similar
                  if (hasOrSimilar) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'or similar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  // Vehicle class
                  CardBadge(
                    label: offer.carType,
                    variant: CardBadgeVariant.tinted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Features (transmission, seats, luggage)
                  if (features.isNotEmpty) ...[
                    CardFeatureList(
                      features: features,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Mileage policy
                  if (mileagePolicy != null) ...[
                    CardBadge(
                      label: mileagePolicy,
                      icon: Icons.directions_car_filled,
                      variant: CardBadgeVariant.tinted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Rental duration
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '$rentalDays day${rentalDays > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Free cancellation
                  if (hasFreeCancellation) ...[
                    CardCancellation(
                      label: _cancellationLabel ?? 'Free cancellation',
                      freeCancellation: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Price
                  CardPriceBlock(
                    currentPrice: offer.price,
                    currency: offer.currency,
                    showCurrency: true,
                    unit: 'day',
                    perDay: offer.price,
                    total: rentalDays > 1 ? offer.price * rentalDays : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }
}