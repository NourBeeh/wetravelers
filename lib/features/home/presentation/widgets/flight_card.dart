import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/widgets/cards/card_price.dart';

/// Compact pill-style flight card (~200px wide) designed to live inside a
/// horizontal [SectionContainerCard], matching the search pages' visual
/// language.
class FlightCard extends StatelessWidget {
  final HomeItem item;
  const FlightCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final route = item.metadata['route']?.toString() ?? '';
    final label = '${item.title}${item.subtitle != null ? ', ${item.subtitle}' : ''}${route.isNotEmpty ? ', route $route' : ''}, price ${item.price} ${item.currency ?? ''}'.trim();

    // Route strings are free-form ("CAI-JED", "CAI - JED"); split into
    // origin/destination legs when a separator is present so the plane icon
    // can sit between them.
    final legs = route
        .split(RegExp(r'\s*(?:-|–|—|→|>)\s*'))
        .where((leg) => leg.trim().isNotEmpty)
        .toList();
    final origin = legs.isNotEmpty ? legs.first.trim() : '';
    final destination = legs.length > 1 ? legs.last.trim() : '';
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      // Inner texts are visual only — the curated [label] above is the single
      // source of truth for assistive tech, preventing merged duplicates.
      child: ExcludeSemantics(
        child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage:
                      item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
                  child: item.imageUrl == null
                      ? const Icon(Icons.flight, size: 14)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(Icons.flight, size: 16, color: AppColors.brand),
                Expanded(
                  child: Text(
                    destination,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            if (item.subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.bottomRight,
              child: CardPrice(
                price: item.price,
                currency: item.currency,
                rawPrice: item.rawPrice,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
