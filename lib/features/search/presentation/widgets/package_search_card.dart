import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/offers/travel_package_offer.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';

/// Package search card for search results.
///
/// Horizontal layout with image (~55-60% width) on the left, content on the right.
/// Uses BaseCard for pressed/disabled/loading states and accessibility.
/// Composes shared Card Design System primitives: CardImage, CardLocation, CardFeatureList,
/// CardPriceBlock.
/// NO: guest rating, reviews, travel dates, tax/fee info, total price, CTA button.
/// Entire card is tappable → Package Details (booking review flow).
class PackageSearchCard extends StatelessWidget {
  const PackageSearchCard({
    super.key,
    required this.offer,
    this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final TravelPackageOffer offer;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  List<String> get _cities {
    return offer.destination
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _formatDuration(int days) {
    if (days <= 0) return '';
    if (days == 1) return '1 day';
    if (days < 7) return '$days days';
    if (days == 7) return '1 week';
    if (days < 14) return '1 week ${days - 7} days';
    final weeks = days ~/ 7;
    final remaining = days % 7;
    if (remaining == 0) return '$weeks weeks';
    return '$weeks weeks $remaining days';
  }

  List<String> get _displayInclusions {
    return offer.inclusions.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = _formatDuration(offer.durationDays);
    final citiesLine = _cities.join(' · ');

    final semanticParts = <String>[
      offer.title,
      'Package to $citiesLine',
      if (duration.isNotEmpty) 'Duration $duration',
      if (_displayInclusions.isNotEmpty) 'Includes ${_displayInclusions.join(', ')}',
      'Price ${NumberFormat.currency(symbol: '', locale: 'en_US').format(offer.price)} ${offer.currency} / person',
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
          // Image section - approximately 55-60% width
          Expanded(
            flex: 6,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CardImage(
                url: offer.imageUrl,
                fallbackIcon: Icons.card_travel,
                semanticLabel: offer.title,
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
                  // Package name
                  Text(
                    offer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Cities/Destinations
                  if (citiesLine.isNotEmpty) ...[
                    Text(
                      citiesLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  // Duration
                  if (duration.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Flexible(
                          child: Text(
                            duration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Inclusions (up to 3)
                  if (_displayInclusions.isNotEmpty) ...[
                    CardFeatureList(
                      features: _displayInclusions,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // Price per person
                  CardPriceBlock(
                    currentPrice: offer.price,
                    currency: offer.currency,
                    showCurrency: true,
                    unit: 'person',
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