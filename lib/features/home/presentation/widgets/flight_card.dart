import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_price.dart';

class FlightCard extends StatelessWidget {
  final HomeItem item;
  const FlightCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final route = item.metadata['route']?.toString() ?? '';
    final label = '${item.title}${item.subtitle != null ? ', ${item.subtitle}' : ''}${route.isNotEmpty ? ', route $route' : ''}, price ${item.price} ${item.currency ?? ''}'.trim();
    return Semantics(
      label: label,
      child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
              child: item.imageUrl == null ? const Icon(Icons.flight) : null,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                  if (item.subtitle != null) Text(item.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.metadata['route']?.toString() ?? '', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            CardPrice(price: item.price, currency: item.currency, rawPrice: item.rawPrice),
          ],
        ),
      ),
    ),
    );
  }
}
