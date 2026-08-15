import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_image.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_price.dart';

class DealCard extends StatelessWidget {
  final HomeItem item;
  const DealCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final label = '${item.title} deal, price ${item.price} ${item.currency ?? ''}';
    return Semantics(
      label: label,
      child: Card(
      child: Column(
        children: [
          CardImage(url: item.imageUrl, height: 120),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CardPrice(price: item.price, currency: item.currency),
          ),
        ],
      ),
    ),
    );
  }
}
