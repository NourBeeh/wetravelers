import '../../domain/models/home/home_item.dart';
import '../../domain/models/home/home_section.dart';
import '../../domain/models/home/home_types.dart';

/// Built-in demo marketplace sections shown when the backend home feed is
/// empty or unreachable and no cached snapshot exists. Uses the exact same
/// `HomeSection`/`HomeItem` models the live API path renders, so the HomeCard
/// engine needs no special-casing.
List<HomeSection> demoHomeSections() {
  return <HomeSection>[
    const HomeSection(
      id: 'demo-recommended',
      title: 'Recommended for you',
      subtitle: 'Hand-picked stays and flights this week',
      layout: HomeSectionLayout.horizontalPeek,
      items: <HomeItem>[
        HomeItem(
          id: 'demo-hotel-1',
          type: HomeCardType.hotel,
          title: 'Grand Palm Hotel',
          subtitle: 'Paris, France',
          imageUrl: 'https://loremflickr.com/400/300/paris,hotel',
          price: 320,
          currency: 'USD',
          rating: 4.6,
          reviewCount: 214,
          badge: 'Popular',
          tags: <String>['4-star', 'City center'],
        ),
        HomeItem(
          id: 'demo-flight-1',
          type: HomeCardType.flight,
          title: 'Cairo → Istanbul',
          subtitle: 'Round trip · 7 days',
          imageUrl: 'https://loremflickr.com/400/300/istanbul,skyline',
          price: 289,
          currency: 'USD',
          rating: 4.4,
          reviewCount: 96,
          badge: 'Deal',
          tags: <String>['Direct', 'Economy'],
        ),
        HomeItem(
          id: 'demo-deal-1',
          type: HomeCardType.deal,
          title: 'Weekend in Alexandria',
          subtitle: 'Hotel + breakfast included',
          imageUrl: 'https://loremflickr.com/400/300/alexandria,egypt',
          price: 145,
          currency: 'USD',
          rating: 4.2,
          reviewCount: 58,
          badge: '-30%',
        ),
      ],
    ),
    const HomeSection(
      id: 'demo-destinations',
      title: 'Trending destinations',
      subtitle: 'Where travellers are heading now',
      layout: HomeSectionLayout.grid,
      items: <HomeItem>[
        HomeItem(
          id: 'demo-dest-1',
          type: HomeCardType.destination,
          title: 'Istanbul',
          subtitle: 'Turkey',
          imageUrl: 'https://loremflickr.com/400/300/istanbul,skyline',
          description: 'Bridges, bazaars and Bosphorus views.',
        ),
        HomeItem(
          id: 'demo-dest-2',
          type: HomeCardType.destination,
          title: 'Dubai',
          subtitle: 'UAE',
          imageUrl: 'https://loremflickr.com/400/300/dubai,skyline',
          description: 'Skyline dining and desert adventures.',
        ),
        HomeItem(
          id: 'demo-dest-3',
          type: HomeCardType.destination,
          title: 'Rome',
          subtitle: 'Italy',
          imageUrl: 'https://loremflickr.com/400/300/rome,street',
          description: 'Ancient streets and unforgettable food.',
        ),
      ],
    ),
    const HomeSection(
      id: 'demo-packages',
      title: 'Tour packages',
      subtitle: 'Everything arranged, just pack',
      layout: HomeSectionLayout.horizontal,
      items: <HomeItem>[
        HomeItem(
          id: 'demo-package-1',
          type: HomeCardType.package,
          title: 'Sharm El Sheikh · 5 days',
          subtitle: 'Flights + resort + transfers',
          imageUrl: 'https://loremflickr.com/400/300/redsea,resort',
          price: 599,
          currency: 'USD',
          rating: 4.7,
          reviewCount: 132,
          highlights: <String>['All inclusive', 'Airport transfer'],
        ),
        HomeItem(
          id: 'demo-package-2',
          type: HomeCardType.package,
          title: 'Luxor & Aswan cruise · 4 nights',
          subtitle: 'Nile cruise with guided tours',
          imageUrl: 'https://loremflickr.com/400/300/luxor,nile,cruise',
          price: 749,
          currency: 'USD',
          rating: 4.8,
          reviewCount: 87,
          highlights: <String>['Guided temples', 'Full board'],
        ),
      ],
    ),
    const HomeSection(
      id: 'demo-experiences',
      title: 'Experiences & stories',
      subtitle: 'Ideas for your next trip',
      layout: HomeSectionLayout.vertical,
      items: <HomeItem>[
        HomeItem(
          id: 'demo-exp-1',
          type: HomeCardType.experience,
          title: 'Sunset felucca ride',
          subtitle: 'Aswan, Egypt',
          imageUrl: 'https://loremflickr.com/400/300/nile,felucca,sunset',
          price: 25,
          currency: 'USD',
          rating: 4.9,
          reviewCount: 41,
        ),
        HomeItem(
          id: 'demo-story-1',
          type: HomeCardType.story,
          title: '48 hours in old Cairo',
          subtitle: 'Community story',
          imageUrl: 'https://loremflickr.com/400/300/cairo,bazaar',
          description: 'Khan el-Khalili, hidden cafés and the citadel at dusk.',
        ),
      ],
    ),
  ];
}
