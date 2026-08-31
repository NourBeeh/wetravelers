import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/features/home/presentation/widgets/hotel_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/car_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/package_placeholder_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/destination_discovery_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/deal_vertical_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/flight_placeholder_card.dart';

class HomeCard extends StatelessWidget {
  final HomeItem item;
  const HomeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case HomeCardType.hotel:
        return HotelPlaceholderCard(item: item);
      case HomeCardType.flight:
        return FlightPlaceholderCard(item: item);
      case HomeCardType.car:
        return CarPlaceholderCard(item: item);
      case HomeCardType.package:
        return PackagePlaceholderCard(item: item);
      case HomeCardType.destination:
        return DestinationDiscoveryCard(item: item);
      case HomeCardType.deal:
        return DealVerticalCard(item: item);
    }
  }
}
