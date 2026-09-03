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
  final List<HomeItem> recommendedHotels;
  final String? errorMessage;
  final bool isRefreshing;

  const HomeState({
    this.status = HomeStatus.loading,
    this.sections = const [],
    this.recommendedHotels = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<HomeSection>? sections,
    List<HomeItem>? recommendedHotels,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      recommendedHotels: recommendedHotels ?? this.recommendedHotels,
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
      success: (sections) async {
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
      failure: (error) async {
        final message = userFacingMessage(error, subject: 'home feed');
        if (state.sections.isEmpty) {
          state = state.copyWith(status: HomeStatus.error, errorMessage: message, isRefreshing: false);
        } else {
          state = state.copyWith(status: HomeStatus.partial, errorMessage: message, isRefreshing: false);
        }
      },
    );
    // Fetch recommended hotels in parallel — non-blocking
    loadRecommendedHotels();
  }

  Future<void> loadRecommendedHotels() async {
    final result = await repository.getRecommendedHotels();
    result.when(
      success: (hotels) {
        if (hotels.isNotEmpty) {
          state = state.copyWith(recommendedHotels: hotels);
        }
      },
      failure: (_) {
        // Silently ignore — recommended hotels are supplementary
      },
    );
  }

  List<HomeSection> _developmentPreviewSections() {
    // Development preview — shown while the backend home feed is empty.
    //
    // Renders the approved card layouts as skeleton/loading UI ONLY. The
    // HomeItem entries carry NO fake travel data: empty titles, null images,
    // null prices, empty metadata. Cards detect these empty items via
    // `_isSkeletonItem` in HomeSectionWidget and render their loading state.
    HomeItem skeleton(HomeCardType type, int index) => HomeItem(
          id: 'dev-${type.name}-$index',
          type: type,
          title: '',
          subtitle: '',
          description: '',
          imageUrl: null,
          price: null,
          currency: null,
          metadata: const <String, dynamic>{},
        );

    return <HomeSection>[
      HomeSection(
        id: 'dev-flights',
        title: 'Flight Recommendations',
        subtitle: 'Recommended flights will appear here',
        layout: HomeSectionLayout.flightRecommendationList,
        items: <HomeItem>[
          skeleton(HomeCardType.flight, 0),
          skeleton(HomeCardType.flight, 1),
        ],
      ),
      HomeSection(
        id: 'dev-hotels',
        title: 'Hotels',
        subtitle: 'Top-rated stays will appear here',
        layout: HomeSectionLayout.horizontalPeek,
        items: <HomeItem>[
          skeleton(HomeCardType.hotel, 0),
          skeleton(HomeCardType.hotel, 1),
        ],
      ),
      HomeSection(
        id: 'dev-cars',
        title: 'Car Rentals',
        subtitle: 'Drive offers will appear here',
        layout: HomeSectionLayout.horizontalPeek,
        items: <HomeItem>[
          skeleton(HomeCardType.car, 0),
          skeleton(HomeCardType.car, 1),
        ],
      ),
      HomeSection(
        id: 'dev-packages',
        title: 'Tour Packages',
        subtitle: 'Curated journeys will appear here',
        layout: HomeSectionLayout.horizontalPeek,
        items: <HomeItem>[
          skeleton(HomeCardType.package, 0),
          skeleton(HomeCardType.package, 1),
        ],
      ),
      HomeSection(
        id: 'dev-deals',
        title: 'Hot Deals',
        subtitle: 'Limited-time offers will appear here',
        layout: HomeSectionLayout.verticalDealList,
        items: <HomeItem>[
          skeleton(HomeCardType.deal, 0),
          skeleton(HomeCardType.deal, 1),
        ],
      ),
      HomeSection(
        id: 'dev-destinations',
        title: 'Destinations',
        subtitle: 'Discover your next adventure',
        layout: HomeSectionLayout.horizontal,
        items: <HomeItem>[
          skeleton(HomeCardType.destination, 0),
          skeleton(HomeCardType.destination, 1),
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
