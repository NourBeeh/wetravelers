import 'package:flutter/material.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/features/home/presentation/widgets/hotel_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/flight_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/car_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/package_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/destination_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/deal_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/experience_card.dart';
import 'package:wetravellers/features/home/presentation/widgets/story_card.dart';

class HomeCard extends StatelessWidget {
  final HomeItem item;
  const HomeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case HomeCardType.hotel:
        return HotelCard(item: item);
      case HomeCardType.flight:
        return FlightCard(item: item);
      case HomeCardType.car:
        return CarCard(item: item);
      case HomeCardType.package:
        return PackageCard(item: item);
      case HomeCardType.destination:
        return DestinationCard(item: item);
      case HomeCardType.deal:
        return DealCard(item: item);
      case HomeCardType.experience:
        return ExperienceCard(item: item);
      case HomeCardType.story:
        return StoryCard(item: item);
    }
  }
}
