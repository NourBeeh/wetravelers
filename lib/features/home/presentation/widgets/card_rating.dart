import 'package:flutter/material.dart';

class CardRating extends StatelessWidget {
  final double? rating;
  final int? reviewCount;
  const CardRating({super.key, this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          rating!.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text('($reviewCount)', style: Theme.of(context).textTheme.labelSmall),
        ],
      ],
    );
  }
}
