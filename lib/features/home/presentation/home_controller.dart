import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/repositories/contracts/home_repository.dart';

enum HomeStatus { loading, success, empty, error, partial, developmentPreview }

class HomeState {
  final HomeStatus status;
  final List<HomeSection> sections;
  final String? errorMessage;
  final bool isRefreshing;

  const HomeState({
    this.status = HomeStatus.loading,
    this.sections = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<HomeSection>? sections,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final HomeRepository repository;
  HomeController(this.repository) : super(const HomeState()) {
    load();
  }

  Future<void> load() async {
    if (state.sections.isEmpty) {
      state = state.copyWith(status: HomeStatus.loading);
    } else {
      state = state.copyWith(isRefreshing: true);
    }
    final result = await repository.getHomeSections();
    result.when(
      success: (sections) {
        if (sections.isEmpty) {
          // Show development preview when no real data
          state = state.copyWith(
            status: HomeStatus.developmentPreview,
            sections: _developmentPreviewSections(),
            isRefreshing: false,
          );
        } else {
          state = state.copyWith(status: HomeStatus.success, sections: sections, isRefreshing: false);
        }
      },
      failure: (error) {
        final message = userFacingMessage(error, subject: 'home feed');
        if (state.sections.isEmpty) {
          state = state.copyWith(status: HomeStatus.error, errorMessage: message, isRefreshing: false);
        } else {
          state = state.copyWith(status: HomeStatus.partial, errorMessage: message, isRefreshing: false);
        }
      },
    );
  }

  List<HomeSection> _developmentPreviewSections() {
    // Return sections with skeleton/placeholder items (no fake travel data)
    // The approved cards will render their skeleton/loading states when data is null
    return [
      HomeSection(
        id: 'dev-flights',
        title: 'Flight Recommendations',
        subtitle: 'Cheapest & recommended flights',
        layout: HomeSectionLayout.flightRecommendationList,
        items: [
          HomeItem(
            id: 'dev-flight-1',
            type: HomeCardType.flight,
            title: '',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'origin': 'CAI',
              'destination': 'DXB',
              'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
              'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
              'airline': 'EgyptAir',
              'flightNumber': 'MS 123',
              'stops': 0,
              'cabinClass': 'Economy',
              'baggage': '1 bag (23kg)',
            },
          ),
          HomeItem(
            id: 'dev-flight-2',
            type: HomeCardType.flight,
            title: '',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'origin': 'JFK',
              'destination': 'LHR',
              'departureTime': DateTime.now().add(const Duration(days: 2, hours: 14)).toIso8601String(),
              'arrivalTime': DateTime.now().add(const Duration(days: 2, hours: 21)).toIso8601String(),
              'airline': 'British Airways',
              'flightNumber': 'BA 177',
              'stops': 0,
              'cabinClass': 'Business',
              'baggage': '2 bags (32kg)',
            },
          ),
          HomeItem(
            id: 'dev-flight-3',
            type: HomeCardType.flight,
            title: '',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'origin': 'DXB',
              'destination': 'SYD',
              'departureTime': DateTime.now().add(const Duration(days: 3, hours: 22)).toIso8601String(),
              'arrivalTime': DateTime.now().add(const Duration(days: 4, hours: 18)).toIso8601String(),
              'airline': 'Emirates',
              'flightNumber': 'EK 413',
              'stops': 1,
              'stopAirport': 'SIN',
              'cabinClass': 'Economy',
              'baggage': '1 bag (23kg)',
            },
          ),
        ],
      ),
      HomeSection(
        id: 'dev-hotels',
        title: 'Hotel Recommendations',
        subtitle: 'Top-rated stays',
        layout: HomeSectionLayout.horizontal,
        items: [
          HomeItem(
            id: 'dev-hotel-1',
            type: HomeCardType.hotel,
            title: '',
            subtitle: 'Paris, France',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'roomType': 'Deluxe King',
              'amenities': ['WiFi', 'Pool', 'Spa', 'Gym'],
            },
          ),
          HomeItem(
            id: 'dev-hotel-2',
            type: HomeCardType.hotel,
            title: '',
            subtitle: 'Tokyo, Japan',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'roomType': 'Premium Suite',
              'amenities': ['WiFi', 'Breakfast', 'Spa'],
            },
          ),
          HomeItem(
            id: 'dev-hotel-3',
            type: HomeCardType.hotel,
            title: '',
            subtitle: 'Dubai, UAE',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'roomType': 'Ocean View',
              'amenities': ['Pool', 'Beach Access', 'Spa'],
            },
          ),
        ],
      ),
      HomeSection(
        id: 'dev-packages',
        title: 'Tour Packages',
        subtitle: 'Curated journeys',
        layout: HomeSectionLayout.horizontal,
        items: [
          HomeItem(
            id: 'dev-package-1',
            type: HomeCardType.package,
            title: 'Turkey Discovery',
            subtitle: 'Istanbul · Cappadocia · Antalya',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'destination': 'Istanbul · Cappadocia · Antalya',
              'durationDays': 7,
              'inclusions': ['Flights', 'Hotels', 'Tours', 'Transfers', 'Breakfast'],
            },
          ),
          HomeItem(
            id: 'dev-package-2',
            type: HomeCardType.package,
            title: 'Japan Explorer',
            subtitle: 'Tokyo · Kyoto · Osaka',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'destination': 'Tokyo · Kyoto · Osaka',
              'durationDays': 10,
              'inclusions': ['Flights', 'Hotels', 'JR Pass', 'Tours'],
            },
          ),
          HomeItem(
            id: 'dev-package-3',
            type: HomeCardType.package,
            title: 'Greek Islands',
            subtitle: 'Santorini · Mykonos · Crete',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'destination': 'Santorini · Mykonos · Crete',
              'durationDays': 8,
              'inclusions': ['Flights', 'Hotels', 'Ferries', 'Tours'],
            },
          ),
        ],
      ),
      HomeSection(
        id: 'dev-cars',
        title: 'Car Rentals',
        subtitle: 'Drive your journey',
        layout: HomeSectionLayout.horizontal,
        items: [
          HomeItem(
            id: 'dev-car-1',
            type: HomeCardType.car,
            title: 'Toyota Camry',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'type': 'Sedan',
              'transmission': 'Automatic',
              'seats': 5,
              'luggage': '2 bags',
              'ac': 'Yes',
            },
          ),
          HomeItem(
            id: 'dev-car-2',
            type: HomeCardType.car,
            title: 'Toyota RAV4',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'type': 'SUV',
              'transmission': 'Automatic',
              'seats': 5,
              'luggage': '3 bags',
              'ac': 'Yes',
            },
          ),
          HomeItem(
            id: 'dev-car-3',
            type: HomeCardType.car,
            title: 'BMW 3 Series',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'type': 'Premium Sedan',
              'transmission': 'Automatic',
              'seats': 5,
              'luggage': '2 bags',
              'ac': 'Yes',
            },
          ),
        ],
      ),
      HomeSection(
        id: 'dev-deals',
        title: 'Hot Deals',
        subtitle: 'Limited time offers',
        layout: HomeSectionLayout.vertical,
        items: [
          HomeItem(
            id: 'dev-deal-1',
            type: HomeCardType.deal,
            title: 'Maldives Getaway',
            subtitle: '5 nights all-inclusive',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'savingsPercent': 35,
              'savingsAmount': 800.0,
              'validUntil': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            },
          ),
          HomeItem(
            id: 'dev-deal-2',
            type: HomeCardType.deal,
            title: 'European Rail Pass',
            subtitle: '15 days unlimited travel',
            imageUrl: null,
            price: null,
            currency: 'EUR',
            metadata: {
              'savingsPercent': 25,
              'savingsAmount': 150.0,
              'validUntil': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
            },
          ),
          HomeItem(
            id: 'dev-deal-3',
            type: HomeCardType.deal,
            title: 'Safari Adventure',
            subtitle: '5-day Kenya & Tanzania',
            imageUrl: null,
            price: null,
            currency: 'USD',
            metadata: {
              'savingsPercent': 20,
              'savingsAmount': 400.0,
              'validUntil': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
            },
          ),
        ],
      ),
      HomeSection(
        id: 'dev-destinations',
        title: 'Destinations',
        subtitle: 'Discover your next adventure',
        layout: HomeSectionLayout.horizontal,
        items: [
          HomeItem(
            id: 'dev-dest-1',
            type: HomeCardType.destination,
            title: 'Paris',
            subtitle: 'France',
            imageUrl: null,
            currency: 'EUR',
            metadata: {'country': 'France'},
          ),
          HomeItem(
            id: 'dev-dest-2',
            type: HomeCardType.destination,
            title: 'Tokyo',
            subtitle: 'Japan',
            imageUrl: null,
            currency: 'JPY',
            metadata: {'country': 'Japan'},
          ),
          HomeItem(
            id: 'dev-dest-3',
            type: HomeCardType.destination,
            title: 'New York',
            subtitle: 'USA',
            imageUrl: null,
            currency: 'USD',
            metadata: {'country': 'United States'},
          ),
          HomeItem(
            id: 'dev-dest-4',
            type: HomeCardType.destination,
            title: 'Dubai',
            subtitle: 'UAE',
            imageUrl: null,
            currency: 'AED',
            metadata: {'country': 'United Arab Emirates'},
          ),
          HomeItem(
            id: 'dev-dest-5',
            type: HomeCardType.destination,
            title: 'Bali',
            subtitle: 'Indonesia',
            imageUrl: null,
            currency: 'IDR',
            metadata: {'country': 'Indonesia'},
          ),
        ],
      ),
    ];
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await repository.refresh();
    await load();
    state = state.copyWith(isRefreshing: false);
  }
}
