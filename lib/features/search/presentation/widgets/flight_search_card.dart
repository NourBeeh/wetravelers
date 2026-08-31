import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';
import 'package:wetravellers/features/search/presentation/widgets/flight_route_line.dart';

/// Flight search result card for vertical list in search results.
///
/// Compact horizontal card with:
/// - Airline logo + name + flight number
/// - Visual route line with times, stops, layover
/// - Features (cabin, baggage) as chips
/// - Warning badges (self-transfer, airport change, risky connection)
/// - Price block (per traveler + total)
/// - Remaining seats indicator (when real data exists)
/// - Entire card is tappable → Flight Details (/booking/review)
class FlightSearchCard extends StatelessWidget {
  const FlightSearchCard({
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

  String _formatFlightNumber() {
    if (offer.airline.isNotEmpty && offer.flightNumber.isNotEmpty) {
      final code = offer.airline.length >= 2
          ? offer.airline.substring(0, 2).toUpperCase()
          : offer.airline.toUpperCase();
      return '$code ${offer.flightNumber}';
    }
    return offer.flightNumber;
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
          BadgeType? badgeType;
          IconData icon;
          String label;

          if (lower.contains('self.transfer') ||
              lower.contains('self transfer') ||
              lower.contains('self_transfer')) {
            badgeType = BadgeType.selfTransfer;
            icon = Icons.swap_horiz;
            label = 'Self-transfer';
          } else if (lower.contains('airport.change') ||
              lower.contains('airport change') ||
              lower.contains('airport_change')) {
            badgeType = BadgeType.airportChange;
            icon = Icons.flight_land;
            label = 'Airport change';
          } else if (lower.contains('tight') ||
              lower.contains('risky') ||
              lower.contains('connection')) {
            badgeType = BadgeType.riskyConnection;
            icon = Icons.warning_amber;
            label = 'Risky connection';
          } else if (lower.contains('overnight')) {
            badgeType = null;
            icon = Icons.nightlight_round;
            label = 'Overnight';
          } else if (lower.contains('long.layover') ||
              lower.contains('long layover') ||
              lower.contains('long_layover')) {
            badgeType = null;
            icon = Icons.hourglass_top;
            label = 'Long layover';
          } else {
            badgeType = null;
            icon = Icons.warning_amber;
            label = warning;
          }

          return CardBadge(
            label: label,
            icon: icon,
            variant: CardBadgeVariant.tinted,
            type: badgeType,
          );
        })
        .toList();
  }

  CardBadge? _buildRecommendationBadge(BuildContext context) {
    final rec = offer.metadata['recommendation']?.toString().toLowerCase();
    if (rec == 'cheapest' || rec == 'fastest' || rec == 'best_value' || rec == 'best value') {
      String label;
      IconData icon;
      BadgeType? badgeType;

      switch (rec) {
        case 'cheapest':
          label = 'Cheapest';
          icon = Icons.attach_money;
          badgeType = BadgeType.cheapest;
          break;
        case 'fastest':
          label = 'Fastest';
          icon = Icons.speed;
          badgeType = BadgeType.fastest;
          break;
        case 'best_value':
        case 'best value':
          label = 'Best Value';
          icon = Icons.star;
          badgeType = BadgeType.best;
          break;
        default:
          label = rec ?? '';
          icon = Icons.star;
          badgeType = null;
      }

      return CardBadge(
        label: label,
        icon: icon,
        variant: CardBadgeVariant.tinted,
        type: badgeType,
      );
    }
    return null;
  }

  double? _getSeatsLeft() {
    final metadata = offer.metadata;
    final seats = metadata['seatsLeft'];
    if (seats is int) return seats.toDouble();
    if (seats is num) return seats.toDouble();
    final seatsStr = metadata['seats_left']?.toString() ?? metadata['remainingSeats']?.toString();
    if (seatsStr != null) {
      return double.tryParse(seatsStr);
    }
    return null;
  }

  Map<String, double?> _buildPriceInfo() {
    final metadata = offer.metadata;
    final perTraveler = metadata['pricePerTraveler'];
    final total = metadata['totalPrice'];

    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return {
      'perTraveler': parsePrice(perTraveler),
      'total': parsePrice(total),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = _calculateDuration();
    final stopsText = _buildStopsText();
    final features = _buildFeatures(context);
    final warnings = _buildWarnings(context);
    final priceInfo = _buildPriceInfo();
    final recommendationBadge = _buildRecommendationBadge(context);
    final seatsLeft = _getSeatsLeft();
    final hasPricePerTraveler = priceInfo['perTraveler'] != null && priceInfo['perTraveler']! > 0;
    final hasTotalPrice = priceInfo['total'] != null && priceInfo['total']! > 0;

    final semanticParts = <String>[
      offer.airline,
      'Flight ${_formatFlightNumber()}',
      '${offer.origin} to ${offer.destination}',
      'Departs at ${DateFormat.Hm().format(offer.departureTime)}',
      'Arrives at ${DateFormat.Hm().format(offer.arrivalTime)}',
      'Duration $duration',
      if (stopsText.isNotEmpty) stopsText,
      if (features.isNotEmpty) features.join(', '),
      if (hasPricePerTraveler) 'Per traveler ${offer.currency} ${priceInfo['perTraveler']!.toStringAsFixed(0)}',
      if (hasTotalPrice) 'Total ${offer.currency} ${priceInfo['total']!.toStringAsFixed(0)}',
      if (seatsLeft != null && seatsLeft > 0) 'Only ${seatsLeft.toInt()} seats left',
      if (recommendationBadge != null) recommendationBadge.label!,
      if (warnings.isNotEmpty) warnings.map((w) => w.label).join(', '),
    ];
    final semanticLabel = semanticParts.join(', ');

    return BaseCard(
      onTap: onTap,
      enabled: enabled,
      loading: loading,
      semanticsLabel: semanticLabel,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Airline logo + name + flight number + recommendation badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Airline logo
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.primaryContainer,
                  backgroundImage: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                      ? NetworkImage(offer.imageUrl!)
                      : null,
                  onBackgroundImageError: (_, __) {},
                  child: offer.imageUrl == null || offer.imageUrl!.isEmpty
                      ? Icon(Icons.flight, size: 20, color: scheme.onPrimaryContainer)
                      : null,
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
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatFlightNumber(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Recommendation badge (top area)
                if (recommendationBadge != null) recommendationBadge,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Route line with times, stops, duration, layover
            FlightRouteLine(
              departureTime: offer.departureTime,
              arrivalTime: offer.arrivalTime,
              origin: offer.origin,
              destination: offer.destination,
              stops: offer.stops ?? 0,
              stopAirport: offer.metadata['stopAirport']?.toString(),
              layoverDuration: offer.metadata['layoverDuration']?.toString(),
              duration: duration,
            ),
            const SizedBox(height: AppSpacing.md),
            // Features (cabin, baggage, flight number)
            if (features.isNotEmpty) ...[
              CardFeatureList(
                features: features,
                direction: Axis.horizontal,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            // Warnings (self-transfer, airport change, risky connection)
            if (warnings.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: warnings,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            // Price block: per traveler + total
            if (hasPricePerTraveler && hasTotalPrice) ...[
              CardPriceBlock(
                currentPrice: priceInfo['perTraveler']!,
                currency: offer.currency,
                showCurrency: true,
                perTraveler: priceInfo['perTraveler'],
                total: priceInfo['total'],
              ),
            ] else if (hasTotalPrice) ...[
              CardPriceBlock(
                currentPrice: priceInfo['total']!,
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
            // Remaining seats indicator (only when real data exists)
            if (seatsLeft != null && seatsLeft > 0 && seatsLeft <= 9) ...[
              const SizedBox(height: AppSpacing.sm),
              CardAvailability(
                status: CardAvailabilityStatus.limited,
                label: 'Only ${seatsLeft.toInt()} seat${seatsLeft > 1 ? 's' : ''} left',
              ),
            ],
          ],
        ),
      ),
    );
  }
}