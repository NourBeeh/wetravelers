import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_card.dart';

class HomeSectionWidget extends StatelessWidget {
  final HomeSection section;
  const HomeSectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(section.title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildItems(context),
        ],
      ),
    );
  }

  Widget _buildItems(BuildContext context) {
    switch (section.layout) {
      case HomeSectionLayout.vertical:
        return ListView.builder(
          itemCount: section.items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemBuilder: (_, i) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: HomeCard(item: section.items[i]),
          ),
        );
      case HomeSectionLayout.horizontal:
      case HomeSectionLayout.horizontalPeek:
        return SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: section.items.length,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemBuilder: (_, i) => SizedBox(
              width: 220,
              child: Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: HomeCard(item: section.items[i]),
              ),
            ),
          ),
        );
      case HomeSectionLayout.grid:
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: section.items.length,
          itemBuilder: (_, i) => HomeCard(item: section.items[i]),
        );
    }
  }
}
