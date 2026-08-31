import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_badge.dart';
import 'package:wetravellers/core/widgets/cards/card_favorite.dart';
import 'package:wetravellers/core/widgets/cards/card_image.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';
import 'package:wetravellers/core/widgets/cards/card_primary_action.dart';
import 'package:wetravellers/core/widgets/cards/recommendation_reason.dart';
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart';

/// Flight recommendation card for Home horizontal carousels.
///
/// Full-bleed image with gradient scrim carrying route, times, airline, and price.
/// Overlays: recommendation badge (top-left), airline logo (top-right), wishlist (top-right below logo).
/// Uses shared Card Design System primitives — no custom glass/price logic.
class FlightRecommendationCard extends StatelessWidget {
  const FlightRecommendationCard({
    super.key,
    required this.item,
    this.onTap,
    this.onWishlistChanged,
  });

  final HomeItem item;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onWishlistChanged;

  @override
  Widget build(BuildContext context) {
    final isWishlisted = item.metadata['isWishlisted'] == true;
    final recommendation = _getRecommendation();
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

    final semanticParts = <String>[
      'Recommended flight',
      if (recommendation != null) recommendation,
      airline,
      if (flightNumber != null) 'Flight $flightNumber',
      '$origin to $destination',
      if (depTime != null) 'Departs at ${DateFormat.Hm().format(depTime)}',
      if (arrTime != null) 'Arrives at ${DateFormat.Hm().format(arrTime)}',
      'Duration $duration',
      if (stopsText.isNotEmpty) stopsText,
      if (cabin != null && cabin.isNotEmpty) cabin,
      if (baggage != null && baggage.isNotEmpty) baggage,
      if (item.price != null) 'Price ${item.price!.toStringAsFixed(0)} ${item.currency ?? ''}',
    ];
    final semanticLabel = semanticParts.join(', ');

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: 280,
          height: 240,
          child: Stack(
            children: [
              // Full-bleed image
              Positioned.fill(
                child: CardImage(
                  url: item.imageUrl,
                  fallbackIcon: Icons.flight,
                  semanticLabel: airline,
                ),
              ),
              // Recommendation badge — top-left (glass variant for on-image)
              if (recommendation != null)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: _buildRecommendationBadge(context, recommendation),
                ),
              // Airline logo — top-right
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  backgroundImage: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? NetworkImage(item.imageUrl!)
                      : null,
                  child: item.imageUrl == null || item.imageUrl!.isEmpty
                      ? Icon(Icons.flight, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)
                      : null,
                ),
              ),
              // Wishlist — top-right, below airline logo
              Positioned(
                top: AppSpacing.sm + 40,
                right: AppSpacing.sm,
                child: CardFavorite(
                  value: isWishlisted,
                  onChanged: onWishlistChanged,
                  onImage: true,
                  size: 32,
                ),
              ),
              // Stop indicator — top-center (if stops > 0)
              if (stops != null && stops > 0)
                Positioned(
                  top: AppSpacing.sm,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CardBadge(
                      label: stopsText,
                      variant: CardBadgeVariant.glass,
                      icon: stops == 1 ? Icons.flight_takeoff : Icons.flight,
                    ),
                  ),
                ),
              // Bottom gradient scrim with content
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
                      // Route line
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              origin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.flight,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              destination,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Times + duration + stops
                      Row(
                        children: [
                          if (depTime != null)
                            Text(
                              DateFormat.Hm().format(depTime),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          if (depTime != null && arrTime != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          if (arrTime != null)
                            Text(
                              DateFormat.Hm().format(arrTime),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              duration,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Airline + flight number + cabin + baggage (compact)
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              airline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ),
                          if (flightNumber != null && flightNumber.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                flightNumber!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                          if (cabin != null && cabin.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                '· $cabin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ),
                          ],
                          if (baggage != null && baggage.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                '· $baggage',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Price
                      CardPrice(
                        price: item.price,
                        currency: item.currency,
                        rawPrice: item.rawPrice,
                        color: Colors.white,
                      ),
                      // Recommendation Reason (if available)
                      RecommendationReason(reason: item.metadata.recommendationReason),
                      const SizedBox(height: AppSpacing.sm),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _parseTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
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

  String _buildStopsText(int? stops, String? stopAirport) {
    final s = stops ?? 0;
    if (s == 0) return 'Non-stop';
    if (s == 1) {
      return stopAirport != null && stopAirport.isNotEmpty
          ? '1 stop ($stopAirport)'
          : '1 stop';
    }
    return '$s stops';
  }

  String? _getRecommendation() {
    final rec = item.metadata['recommendation']?.toString()?.toLowerCase();
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
      variant: CardBadgeVariant.glass,
    );
  }
}
