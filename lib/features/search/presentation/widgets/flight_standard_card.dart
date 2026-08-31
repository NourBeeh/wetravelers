import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';

/// Standard flight card for search results and comparison.
///
/// Composes shared Card Design System primitives: BaseCard, CardImage,
/// CardPriceBlock, CardFeatureList, CardBadge, CardPrimaryAction.
class FlightStandardCard extends StatelessWidget {
  const FlightStandardCard({
    super.key,
    required this.offer,
    this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final FlightOffer offer;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = _calculateDuration();
    final stopsText = _buildStopsText();
    final features = _buildFeatures(context);
    final warnings = _buildWarnings(context);
    final priceInfo = _buildPriceInfo();
    final recommendation = _getRecommendation();

    final semanticParts = <String>[
      offer.airline,
      'Flight ${_formatFlightNumber()}',
      '${offer.origin} to ${offer.destination}',
      'Departs at ${_formatTime(offer.departureTime)}',
      'Arrives at ${_formatTime(offer.arrivalTime)}',
      'Duration $duration',
      if (stopsText.isNotEmpty) stopsText,
      if (features.isNotEmpty) features.join(', '),
      if (priceInfo['perTraveler'] != null) 'Per traveler ${priceInfo['perTraveler']}',
      if (priceInfo['total'] != null) 'Total ${priceInfo['total']}',
      if (recommendation != null) recommendation,
      if (warnings.isNotEmpty) warnings.map((w) => w.label).join(', '),
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
          // Header: Airline + Recommendation badge
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Airline logo
                if (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(offer.imageUrl!),
                    onBackgroundImageError: (_, __) {},
                    child: offer.imageUrl == null ? const Icon(Icons.flight, size: 16) : null,
                  )
                else
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.flight, size: 16, color: scheme.onPrimaryContainer),
                  ),
                const SizedBox(width: AppSpacing.sm),
                // Airline name + flight number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        offer.airline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        _formatFlightNumber(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Recommendation badge (separate, top area)
                if (recommendation != null) _buildRecommendationBadge(context, recommendation),
              ],
            ),
          ),
          // Route & Times
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Departure row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(offer.departureTime),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            offer.origin,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Duration + stops
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            duration,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (stopsText.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            stopsText,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Arrival column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(offer.arrivalTime),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            offer.destination,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Features (cabin, baggage, flight number)
                if (features.isNotEmpty) ...[
                  CardFeatureList(
                    features: features,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                // Warnings
                if (warnings.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: warnings,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Price block
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (priceInfo['perTraveler'] != null && priceInfo['total'] != null) ...[
                  Row(
                    children: [
                      Text(
                        'Per traveler',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        priceInfo['perTraveler']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        priceInfo['total']!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ] else if (priceInfo['total'] != null) ...[
                  CardPriceBlock(
                    currentPrice: _parsePrice(priceInfo['total']!),
                    currency: offer.currency,
                    showCurrency: true,
                  ),
                ] else ...[
                  CardPriceBlock(
                    currentPrice: offer.price,
                    currency: offer.currency,
                    showCurrency: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Primary action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: CardPrimaryAction(
              label: 'Select Flight',
              onPressed: onTap,
              expanded: true,
              icon: Icons.arrow_forward,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  String _formatFlightNumber() {
    if (offer.airline.isNotEmpty && offer.flightNumber.isNotEmpty) {
      // Extract airline code (first 2 chars usually) or use full name
      final code = offer.airline.length >= 2 ? offer.airline.substring(0, 2).toUpperCase() : offer.airline.toUpperCase();
      return '$code ${offer.flightNumber}';
    }
    return offer.flightNumber;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }

  String _calculateDuration() {
    final diff = offer.arrivalTime.difference(offer.departureTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _buildStopsText() {
    final stops = offer.stops ?? 0;
    final stopAirport = offer.metadata['stopAirport']?.toString();
    if (stops == 0) {
      return 'Non-stop';
    } else if (stops == 1) {
      return stopAirport != null && stopAirport.isNotEmpty
          ? '1 stop ($stopAirport)'
          : '1 stop';
    } else {
      return '$stops stops';
    }
  }

  List<String> _buildFeatures(BuildContext context) {
    final features = <String>[];
    if (offer.cabinClass != null && offer.cabinClass!.isNotEmpty) {
      features.add(offer.cabinClass!);
    }
    final baggage = offer.metadata['baggage']?.toString();
    if (baggage != null && baggage.isNotEmpty) {
      features.add(baggage);
    }
    if (offer.flightNumber.isNotEmpty) {
      features.add('Flight ${_formatFlightNumber()}');
    }
    return features;
  }

  List<CardBadge> _buildWarnings(BuildContext context) {
    final warningsList = offer.metadata['warnings'] as List?;
    if (warningsList == null || warningsList.isEmpty) return [];

    return warningsList
        .whereType<String>()
        .map((warning) {
          final lower = warning.toLowerCase();
          IconData icon;
          String label;

          if (lower.contains('self.transfer') || lower.contains('self transfer') || lower.contains('self_transfer')) {
            icon = Icons.swap_horiz;
            label = 'Self-transfer';
          } else if (lower.contains('airport.change') || lower.contains('airport change') || lower.contains('airport_change')) {
            icon = Icons.flight_land;
            label = 'Airport change';
          } else if (lower.contains('tight') || lower.contains('risky') || lower.contains('connection')) {
            icon = Icons.access_time;
            label = 'Tight connection';
          } else if (lower.contains('overnight')) {
            icon = Icons.nightlight_round;
            label = 'Overnight';
          } else if (lower.contains('long.layover') || lower.contains('long layover') || lower.contains('long_layover')) {
            icon = Icons.hourglass_top;
            label = 'Long layover';
          } else {
            icon = Icons.warning_amber;
            label = warning;
          }

          return CardBadge(
            label: label,
            icon: icon,
            variant: CardBadgeVariant.tinted,
          );
        })
        .toList();
  }

  String? _getRecommendation() {
    final rec = offer.metadata['recommendation']?.toString()?.toLowerCase();
    if (rec == 'cheapest' || rec == 'fastest' || rec == 'best_value' || rec == 'best value') {
      return rec;
    }
    return null;
  }

  Widget _buildRecommendationBadge(BuildContext context, String recommendation) {
    String label;
    IconData icon;

    switch (recommendation) {
      case 'cheapest':
        label = 'Cheapest';
        icon = Icons.attach_money;
        break;
      case 'fastest':
        label = 'Fastest';
        icon = Icons.speed;
        break;
      case 'best_value':
      case 'best value':
        label = 'Best Value';
        icon = Icons.star;
        break;
      default:
        label = recommendation;
        icon = Icons.star;
    }

    return CardBadge(
      label: label,
      icon: icon,
      variant: CardBadgeVariant.tinted,
    );
  }

  Map<String, String?> _buildPriceInfo() {
    final metadata = offer.metadata;
    final perTraveler = metadata['pricePerTraveler'];
    final total = metadata['totalPrice'];

    String? formatPrice(dynamic value) {
      if (value == null) return null;
      final numVal = value is num ? value.toDouble() : double.tryParse(value.toString());
      if (numVal == null) return null;
      return NumberFormat.currency(symbol: '', locale: 'en_US').format(numVal) + ' ${offer.currency}';
    }

    return {
      'perTraveler': formatPrice(perTraveler),
      'total': formatPrice(total),
    };
  }

  double _parsePrice(String priceStr) {
    // Extract numeric value from formatted price string
    final match = RegExp(r'([\d,]+\.?\d*)').firstMatch(priceStr.replaceAll(',', ''));
    return double.tryParse(match?.group(1) ?? '') ?? offer.price;
  }
}