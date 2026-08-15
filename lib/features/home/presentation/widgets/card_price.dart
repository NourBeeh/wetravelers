import 'package:flutter/material.dart';

class CardPrice extends StatelessWidget {
  final double? price;
  final String? currency;
  final double? rawPrice;

  const CardPrice({super.key, this.price, this.currency, this.rawPrice});

  @override
  Widget build(BuildContext context) {
    final value = price ?? rawPrice;
    if (value == null) return const SizedBox.shrink();
    final cur = currency ?? 'USD';
    return Text(
      '$cur ${value.toStringAsFixed(0)}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
