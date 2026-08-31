import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';
import 'package:wetravellers/core/widgets/cards/badge_config.dart';

/// Flight recommendation list for Home page.
///
/// A single compact container showing multiple flight rows.
/// Each row contains: airline logo, route, times, price, recommendation badge.
/// Rows are separated by subtle dividers.
/// Tap row → Flight Details (/booking/review).
/// "View All" button → Flight Search page (/flights).
class FlightRecommendationList extends StatelessWidget {
  const FlightRecommendationList({
    super.key,
    required this.items,
    this.onTapFlight,
    this.onViewAll,
    this.onWishlistChanged,
    this.title = 'Recommended Flights',
    this.maxRows = 3,
  });

  final List<HomeItem> items;
  final void Function(HomeItem flight)? onTapFlight;
  final VoidCallback? onViewAll;
  final void Function(String flightId, bool value)? onWishlistChanged;
  final String title;
  final int maxRows;

  DateTime? _parseTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _calculateDuration(DateTime? dep, DateTime? arr) {
    if (dep == null || arr == null) return '';
    final diff = arr.difference(dep);
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

  String _buildStopsText(dynamic stops, String? stopAirport) {
    final s = stops is int ? stops : int.tryParse(stops?.toString() ?? '0') ?? 0;
    if (s == 0) return 'Non-stop';
    if (s == 1) {
      return stopAirport != null && stopAirport.isNotEmpty
          ? '1 stop ($stopAirport)'
          : '1 stop';
    }
    return '$s stops';
  }

  CardBadge? _buildRecommendationBadge(BuildContext context, String? recommendation) {
    final rec = recommendation?.toLowerCase();
    if (rec == 'cheapest' || rec == 'fastest' || rec == 'best_value' || rec == 'best value') {
      String label;
      IconData icon;

      switch (rec) {
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
          label = rec!;
          icon = Icons.star;
      }

      final badgeTypeName = rec == 'best_value' || rec == 'best value' ? 'best' : rec!;
      return CardBadge(
        label: label,
        icon: icon,
        variant: CardBadgeVariant.glass,
        type: BadgeType.values.byName(badgeTypeName),
      );
    }
    return null;
  }

  CardBadge? _buildSeatsLeftBadge(BuildContext context, dynamic seatsLeft) {
    final seats = seatsLeft is int ? seatsLeft : int.tryParse(seatsLeft?.toString() ?? '');
    if (seats != null && seats > 0 && seats <= 9) {
      return CardBadge(
        label: 'Only $seats seat${seats > 1 ? 's' : ''} left',
        icon: Icons.event_seat,
        variant: CardBadgeVariant.tinted,
        type: BadgeType.limitedRooms,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final displayItems = items.take(maxRows).toList();

    if (displayItems.isEmpty) return const SizedBox.shrink();

    return BaseCard(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and View All
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          // Flight rows
          ...displayItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == displayItems.length - 1;

            final depTime = _parseTime(item.metadata['departureTime']);
            final arrTime = _parseTime(item.metadata['arrivalTime']);
            final origin = item.metadata['origin']?.toString() ?? '';
            final destination = item.metadata['destination']?.toString() ?? '';
            final stops = item.metadata['stops'];
            final stopAirport = item.metadata['stopAirport']?.toString();
            final cabin = item.metadata['cabinClass']?.toString();
            final baggage = item.metadata['baggage']?.toString();
            final airline = item.metadata['airline']?.toString() ?? item.title;
            final flightNumber = item.metadata['flightNumber']?.toString();
            final duration = _calculateDuration(depTime, arrTime);
            final stopsText = _buildStopsText(stops, stopAirport);
            final recommendation = item.metadata['recommendation']?.toString();
            final seatsLeft = item.metadata['seatsLeft'];
            final recommendationBadge = _buildRecommendationBadge(context, recommendation);
            final seatsBadge = _buildSeatsLeftBadge(context, seatsLeft);

            final semanticParts = <String>[
              'Recommended flight',
              if (recommendation != null) recommendation,
              airline,
              if (flightNumber != null) 'Flight $flightNumber',
              '$origin to $destination',
              if (depTime != null) 'Departs at ${_formatTime(depTime)}',
              if (arrTime != null) 'Arrives at ${_formatTime(arrTime)}',
              if (duration.isNotEmpty) 'Duration $duration',
              if (stopsText.isNotEmpty) stopsText,
              if (cabin != null && cabin.isNotEmpty) cabin,
              if (baggage != null && baggage.isNotEmpty) baggage,
              if (item.price != null) 'Price ${item.price!.toStringAsFixed(0)} ${item.currency ?? ''}',
              if (seatsLeft != null) 'Only $seatsLeft seats left',
            ];
            final semanticLabel = semanticParts.join(', ');

            return Semantics(
              label: semanticLabel,
              button: onTapFlight != null,
              child: InkWell(
                onTap: onTapFlight != null ? () => onTapFlight!(item) : null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: scheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Airline logo
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: scheme.primaryContainer,
                        backgroundImage: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? NetworkImage(item.imageUrl!)
                            : null,
                        onBackgroundImageError: (_, __) {},
                        child: item.imageUrl == null || item.imageUrl!.isEmpty
                            ? Icon(Icons.flight, size: 16, color: scheme.onPrimaryContainer)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Route + times + duration
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Airline + flight number
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    airline,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                if (flightNumber != null && flightNumber.isNotEmpty) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    flightNumber,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            // Route line: origin → destination
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    origin.isNotEmpty ? origin : '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Icon(
                                  Icons.flight,
                                  size: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    destination.isNotEmpty ? destination : '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            if (stopsText != 'Non-stop') ...[
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
                      ),
                      // Times + duration + price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Departure - Arrival times
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (depTime != null)
                                Text(
                                  _formatTime(depTime),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              if (depTime != null && arrTime != null) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 10,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                              if (arrTime != null)
                                Text(
                                  _formatTime(arrTime),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          // Duration
                          if (duration.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                duration,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          // Price
                          CardPrice(
                            price: item.price,
                            currency: item.currency,
                            rawPrice: item.rawPrice,
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Badges column (recommendation, seats left)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (recommendationBadge != null) ...[
                            recommendationBadge,
                            const SizedBox(height: AppSpacing.xxs),
                          ],
                          if (seatsBadge != null) seatsBadge,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}