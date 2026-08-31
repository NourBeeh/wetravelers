import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/offers/car_offer.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';

/// Standard car card for search results and comparison.
///
/// Composes shared Card Design System primitives: BaseCard, CardImage,
/// CardPriceBlock, CardFeatureList, CardCancellation, CardPrimaryAction.
class CarStandardCard extends StatelessWidget {
  const CarStandardCard({
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final features = _buildFeatures();
    final cancellation = _buildCancellation(context);
    final priceInfo = _buildPriceInfo();

    final semanticParts = <String>[
      offer.title,
      offer.carType,
      if (offer.transmission != null) offer.transmission!,
      if (offer.seats != null) '${offer.seats} seats',
      if (offer.metadata['luggage'] != null) 'Luggage: ${offer.metadata['luggage']}',
      if (offer.metadata['ac'] != null) 'AC',
      'Pickup: ${offer.pickupLocation} at ${_formatTime(offer.pickupTime)}',
      'Dropoff: ${offer.dropoffLocation} at ${_formatTime(offer.dropoffTime)}',
      if (cancellation != null) cancellation.label,
      'Price ${priceInfo}',
    ];
    final semanticLabel = semanticParts.join(', ');

    return BaseCard(
      onTap: onTap,
      enabled: enabled,
      loading: loading,
      semanticsLabel: semanticLabel,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car image
          CardImage(
            url: offer.imageUrl,
            height: 140,
            fallbackIcon: Icons.directions_car,
            semanticLabel: offer.title,
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + category
                Text(
                  offer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  offer.carType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Features (transmission, seats, luggage, AC)
                if (features.isNotEmpty) ...[
                  CardFeatureList(
                    features: features,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                // Pickup / Dropoff
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Pickup: ${offer.pickupLocation} at ${_formatTime(offer.pickupTime)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Dropoff: ${offer.dropoffLocation} at ${_formatTime(offer.dropoffTime)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
                // Cancellation
                if (cancellation != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  cancellation,
                ],
                const SizedBox(height: AppSpacing.md),
                // Price
                CardPriceBlock(
                  currentPrice: offer.price,
                  originalPrice: _getOriginalPrice(),
                  currency: offer.currency,
                  showCurrency: true,
                ),
                const SizedBox(height: AppSpacing.md),
                // Primary action
                CardPrimaryAction(
                  label: 'View Details',
                  onPressed: onTap,
                  expanded: true,
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final ac = offer.metadata['ac']?.toString();
    if (ac != null && ac.isNotEmpty) {
      features.add('AC');
    }
    return features;
  }

  CardCancellation? _buildCancellation(BuildContext context) {
    final freeCancellation = offer.metadata['freeCancellation'] == true;
    final policy = offer.metadata['cancellationPolicy']?.toString();
    if (!freeCancellation && (policy == null || policy.isEmpty)) {
      return null;
    }
    return CardCancellation(
      label: policy ?? (freeCancellation ? 'Free cancellation' : 'Cancellation policy applies'),
      freeCancellation: freeCancellation,
    );
  }

  String _buildPriceInfo() {
    final formatted = NumberFormat.currency(symbol: '', locale: 'en_US').format(offer.price);
    return '$formatted ${offer.currency}';
  }

  double? _getOriginalPrice() {
    final original = offer.metadata['originalPrice'];
    if (original == null) return null;
    final numVal = original is num ? original.toDouble() : double.tryParse(original.toString());
    if (numVal == null || numVal <= offer.price) return null;
    return numVal;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }
}