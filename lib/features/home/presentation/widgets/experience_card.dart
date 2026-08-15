import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/features/home/presentation/widgets/card_image.dart';

class ExperienceCard extends StatelessWidget {
  final HomeItem item;
  const ExperienceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.title} experience',
      child: CardImage(url: item.imageUrl, height: 180, semanticLabel: item.title),
    );
  }
}
