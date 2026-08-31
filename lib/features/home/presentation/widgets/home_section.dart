import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/widgets/deal_vertical_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/destination_discovery_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/flight_recommendation_list.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/car_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/deal_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/destination_discovery_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/flight_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/hotel_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/package_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/home_card_dimensions.dart';

typedef FlightTapCallback = void Function(HomeItem flight);
typedef ViewAllCallback = void Function();
typedef WishlistChangedCallback = void Function(String flightId, bool value);

class HomeSectionWidget extends StatelessWidget {
  const HomeSectionWidget({
    super.key,
    required this.section,
    this.onFlightTap,
    this.onViewAllFlights,
    this.onWishlistChanged,
  });

  final HomeSection section;
  final FlightTapCallback? onFlightTap;
  final ViewAllCallback? onViewAllFlights;
  final WishlistChangedCallback? onWishlistChanged;

  @override
  Widget build(BuildContext context) {
    // Flight recommendation list renders its own header, so skip the section title
    if (section.layout == HomeSectionLayout.flightRecommendationList) {
      return _buildFlightRecommendationList(context);
    }

    // Deal vertical list renders its own header
    if (section.layout == HomeSectionLayout.verticalDealList) {
      return _buildDealVerticalList(context);
    }

    // For sections with only flights, render as FlightRecommendationList regardless of layout
    if (_isFlightOnlySection) {
      return _buildFlightRecommendationList(context);
    }

    // For sections with only deals, render as vertical deal list
    if (_isDealOnlySection) {
      return _buildDealVerticalList(context);
    }

    // For sections with only destinations, render as horizontal destination cards
    if (_isDestinationOnlySection) {
      return _buildDestinationCarousel(context);
    }

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

  bool get _isFlightOnlySection =>
      section.items.isNotEmpty && section.items.every((item) => item.type == HomeCardType.flight);

  bool get _isDealOnlySection =>
      section.items.isNotEmpty && section.items.every((item) => item.type == HomeCardType.deal);

  bool get _isDestinationOnlySection =>
      section.items.isNotEmpty && section.items.every((item) => item.type == HomeCardType.destination);

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
            child: _buildItemCard(context, section.items[i]),
          ),
        );
      case HomeSectionLayout.horizontal:
        return _buildHorizontalCarousel(context, peek: false);
      case HomeSectionLayout.horizontalPeek:
        return _buildHorizontalCarousel(context, peek: true);
      case HomeSectionLayout.grid:
        return _buildResponsiveGrid(context);
      case HomeSectionLayout.flightRecommendationList:
        return _buildFlightRecommendationList(context);
      case HomeSectionLayout.verticalDealList:
        return _buildDealVerticalList(context);
    }
  }

  Widget _buildItemCard(BuildContext context, HomeItem item) {
    switch (item.type) {
      case HomeCardType.destination:
        return DestinationDiscoveryCard(item: item);
      case HomeCardType.deal:
        return DealVerticalCard(item: item);
      case HomeCardType.flight:
        // For vertical layout, use FlightRecommendationList with single item
        return FlightRecommendationList(
          items: [item],
          title: '',
          maxRows: 1,
          onTapFlight: onFlightTap,
          onViewAll: onViewAllFlights,
          onWishlistChanged: onWishlistChanged,
        );
      case HomeCardType.hotel:
        return HotelPlaceholderCard(item: item);
      case HomeCardType.car:
        return CarPlaceholderCard(item: item);
      case HomeCardType.package:
        return PackagePlaceholderCard(item: item);
      default:
        return HomeCard(item: item);
    }
  }

  Widget _buildFlightRecommendationList(BuildContext context) {
    // Filter only flight items for this layout
    final flightItems = section.items
        .where((item) => item.type == HomeCardType.flight)
        .toList();

    if (flightItems.isEmpty) return const SizedBox.shrink();

    return FlightRecommendationList(
      items: flightItems,
      title: section.title,
      onTapFlight: onFlightTap,
      onViewAll: onViewAllFlights,
      onWishlistChanged: onWishlistChanged,
    );
  }

  Widget _buildHorizontalCarousel(BuildContext context, {required bool peek}) {
    final primaryType = section.items.isNotEmpty ? section.items.first.type : HomeCardType.hotel;
    final cardHeight = HomeCardDimensions.cardHeightForType(primaryType);
    final cardWidth = HomeCardDimensions.cardWidthForType(primaryType);

    final carouselHeight = cardHeight + 8;
    final itemWidth = cardWidth;
    final peekExtent = peek ? 48.0 : 0.0;

    return SizedBox(
      height: carouselHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: section.items.length,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemBuilder: (_, i) => SizedBox(
          width: itemWidth + peekExtent,
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: _buildHorizontalItemCard(context, section.items[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalItemCard(BuildContext context, HomeItem item) {
    switch (item.type) {
      case HomeCardType.destination:
        return DestinationDiscoveryCard(item: item);
      case HomeCardType.flight:
        // For horizontal layout, use FlightRecommendationList with single item
        return FlightRecommendationList(
          items: [item],
          title: '',
          maxRows: 1,
          onTapFlight: onFlightTap,
          onViewAll: onViewAllFlights,
          onWishlistChanged: onWishlistChanged,
        );
      case HomeCardType.deal:
        // For horizontal, use DealVerticalCard (approved card)
        return DealVerticalCard(
          item: item,
          onTap: onFlightTap,
          onWishlistChanged: onWishlistChanged,
        );
      default:
        return HomeCard(item: item);
    }
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    final primaryType = section.items.isNotEmpty ? section.items.first.type : HomeCardType.hotel;
    final crossAxisCount = HomeCardDimensions.gridCrossAxisCount(context);
    final childAspectRatio = HomeCardDimensions.gridChildAspectRatio(primaryType);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: section.items.length,
      itemBuilder: (_, i) => _buildGridItemCard(context, section.items[i]),
    );
  }

  Widget _buildGridItemCard(BuildContext context, HomeItem item) {
    switch (item.type) {
      case HomeCardType.destination:
        return DestinationDiscoveryCard(item: item);
      case HomeCardType.deal:
        return DealVerticalCard(item: item);
      default:
        return HomeCard(item: item);
    }
  }

  Widget _buildDestinationCarousel(BuildContext context) {
    final destinationItems = section.items
        .where((item) => item.type == HomeCardType.destination)
        .toList();

    if (destinationItems.isEmpty) return const SizedBox.shrink();

    final cardHeight = HomeCardDimensions.cardHeightForType(HomeCardType.destination);
    final cardWidth = HomeCardDimensions.cardWidthForType(HomeCardType.destination);
    final carouselHeight = cardHeight + 8;
    final itemWidth = cardWidth;

    return SizedBox(
      height: carouselHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: destinationItems.length,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemBuilder: (_, i) => SizedBox(
          width: itemWidth,
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: DestinationDiscoveryCard(item: destinationItems[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildDealVerticalList(BuildContext context) {
    // Filter only deal items for this layout
    final dealItems = section.items
        .where((item) => item.type == HomeCardType.deal)
        .toList();

    if (dealItems.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      itemCount: dealItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: DealVerticalCard(
          item: dealItems[i],
          onTap: () {
            // Navigate to booking review for the deal
            // The deal item should have metadata with provider info
            // For now, this would need a callback from parent
          },
          onWishlistChanged: (value) {
            // Handle wishlist change if needed
          },
        ),
      ),
    );
  }
}