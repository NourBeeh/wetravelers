import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';

/// Hotel search card for search results and comparison.
///
/// Horizontal layout with image (~50% width) on the left, content on the right.
/// Uses BaseCard for pressed/disabled/loading states and accessibility.
/// Composes shared Card Design System primitives: CardImage, CardRating, CardLocation,
/// CardFeatureList, CardCancellation, CardPriceBlock, CardFavorite.
/// NO CTA button - entire card is tappable → Hotel Details (booking review flow).
class HotelSearchCard extends StatelessWidget {
  const HotelSearchCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onWishlistChanged,
    this.isWishlisted = false,
    this.enabled = true,
    this.loading = false,
  });

  final HotelOffer offer;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onWishlistChanged;
  final bool isWishlisted;
  final bool enabled;
  final bool loading;

  int get _nights => offer.checkOut.difference(offer.checkIn).inDays;

  double? get _pricePerNight {
    final metadata = offer.metadata;
    final ppn = metadata['pricePerNight'];
    if (ppn is num) return ppn.toDouble();
    return null;
  }

  double? get _totalPrice {
    final metadata = offer.metadata;
    final total = metadata['totalPrice'];
    if (total is num) return total.toDouble();
    final pricePerNight = metadata['pricePerNight'];
    if (pricePerNight is num && _nights > 0) {
      return pricePerNight.toDouble() * _nights;
    }
    return null;
  }

  bool get _hasFreeCancellation {
    final metadata = offer.metadata;
    final fc = metadata['freeCancellation'];
    return fc == true;
  }

  String? get _cancellationLabel {
    final metadata = offer.metadata;
    return metadata['cancellationPolicy']?.toString();
  }

  List<String> get _displayFeatures {
    final features = <String>[];
    if (offer.roomType.isNotEmpty) features.add(offer.roomType);
    if (offer.amenities.isNotEmpty) {
      features.addAll(offer.amenities.take(2));
    }
    return features.take(3).toList();
  }

  double? get _taxesFees {
    final metadata = offer.metadata;
    final tf = metadata['taxesAndFees'];
    if (tf is num) return tf.toDouble();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pricePerNight = _pricePerNight;
    final totalPrice = _totalPrice;
    final hasPricePerNight = pricePerNight != null && pricePerNight > 0;
    final hasTotalPrice = totalPrice != null && totalPrice > 0;

    // Determine primary price display: per-night if available, else total if available, else base price
    final double primaryPrice;
    final String? unit;
    if (hasPricePerNight) {
      primaryPrice = pricePerNight;
      unit = 'night';
    } else if (hasTotalPrice && _nights > 0) {
      primaryPrice = totalPrice / _nights;
      unit = 'night';
    } else {
      primaryPrice = offer.price;
      unit = 'night';
    }

    final semanticParts = <String>[
      offer.title,
      '${offer.city}, ${offer.country}',
      if (offer.rating != null) '${offer.rating!.toStringAsFixed(1)} stars, ${offer.reviewCount} reviews',
      'Per $unit ${NumberFormat.currency(symbol: '', locale: 'en_US').format(primaryPrice)} ${offer.currency}',
      if (hasTotalPrice) 'Total ${NumberFormat.currency(symbol: '', locale: 'en_US').format(totalPrice)} ${offer.currency}',
      if (_hasFreeCancellation) 'Free cancellation',
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
          // Image section - approximately 50% width
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CardImage(
                url: offer.imageUrl,
                fallbackIcon: Icons.hotel,
                semanticLabel: offer.title,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content section - approximately 50% width
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + Wishlist
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      CardFavorite(
                        value: isWishlisted,
                        onChanged: onWishlistChanged,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Rating + review count
                  if (offer.rating != null) ...[
                    CardRating(
                      rating: offer.rating,
                      reviewCount: offer.reviewCount,
                      onImage: false,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  // Location
                  CardLocation(text: '${offer.city}, ${offer.country}'),
                  const SizedBox(height: AppSpacing.sm),
                  // Features (room type + up to 2 amenities)
                  if (_displayFeatures.isNotEmpty) ...[
                    CardFeatureList(
                      features: _displayFeatures,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Cancellation (only when free cancellation is actually available)
                  if (_hasFreeCancellation) ...[
                    CardCancellation(
                      label: _cancellationLabel ?? 'Free cancellation',
                      freeCancellation: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Price block: ONE primary price representation
                  CardPriceBlock(
                    currentPrice: primaryPrice,
                    currency: offer.currency,
                    showCurrency: true,
                    unit: unit,
                    // Show total as secondary line only when different from calculated per-night * nights
                    total: (hasTotalPrice && hasPricePerNight && totalPrice != pricePerNight * _nights)
                        ? totalPrice
                        : null,
                    // Taxes/fees only when explicitly provided
                    taxesExcluded: _taxesFees != null && _taxesFees! > 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}