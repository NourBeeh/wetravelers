import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/network/api_client.dart';
import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/repositories/contracts/home_repository.dart';

HomeCardType _parseCardType(String? s) {
  switch (s?.toLowerCase()) {
    case 'flight': return HomeCardType.flight;
    case 'hotel': return HomeCardType.hotel;
    case 'car': return HomeCardType.car;
    case 'package': return HomeCardType.package;
    case 'destination': return HomeCardType.destination;
    case 'deal': return HomeCardType.deal;
    case 'experience': return HomeCardType.experience;
    case 'story': return HomeCardType.story;
    default: return HomeCardType.deal;
  }
}

HomeSectionLayout _parseLayout(String? s) {
  switch (s?.toLowerCase()) {
    case 'horizontal': return HomeSectionLayout.horizontal;
    case 'horizontalpeek': return HomeSectionLayout.horizontalPeek;
    case 'grid': return HomeSectionLayout.grid;
    default: return HomeSectionLayout.vertical;
  }
}


class HomeRepositoryImpl implements HomeRepository {
  final ApiClient apiClient;

  HomeRepositoryImpl(this.apiClient);

  @override
  Future<ApiResult<List<HomeSection>>> getHomeSections() async {
    final result = await apiClient.get<List<dynamic>>('/home/sections');
    return result.when(
      success: (data) {
        final sections = <HomeSection>[];
        for (final s in data) {
          if (s is Map<String, dynamic>) {
            final cards = <HomeItem>[];
            final cardsJson = s['cards'] as List? ?? [];
            for (final c in cardsJson) {
              if (c is Map<String, dynamic>) {
                cards.add(HomeItem(
                  id: c['id']?.toString() ?? '',
                  type: _parseCardType(c['type']?.toString()),
                  title: c['title']?.toString() ?? '',
                  subtitle: c['subtitle']?.toString(),
                  description: c['description']?.toString(),
                  imageUrl: c['imageUrl']?.toString(),
                  price: double.tryParse(c['price']?.toString() ?? ''),
                  currency: c['currency']?.toString(),
                  rating: double.tryParse(c['rating']?.toString() ?? ''),
                  reviewCount: int.tryParse(c['reviewCount']?.toString() ?? ''),
                  badge: c['badge']?.toString(),
                  highlights: (c['highlights'] as List?)?.map((e)=>e.toString()).toList() ?? [],
                  tags: (c['tags'] as List?)?.map((e)=>e.toString()).toList() ?? [],
                  actionLabel: c['action']?.toString(),
                  rawPrice: double.tryParse(c['rawPrice']?.toString() ?? ''),
                  metadata: c['metadata'] is Map ? Map<String,dynamic>.from(c['metadata']) : {},
                ));
              }
            }
            sections.add(HomeSection(
              id: s['id']?.toString() ?? '',
              title: s['title']?.toString() ?? '',
              subtitle: s['subtitle']?.toString(),
              layout: _parseLayout(s['layout']?.toString()),
              items: cards,
            ));
          }
        }
        return ApiResult.success(sections);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }

  @override
  Future<ApiResult<void>> refresh() async {
    final result = await apiClient.post('/home/refresh');
    return result.when(
      success: (_) => ApiResult.success(null),
      failure: (error) => ApiResult.failure(error),
    );
  }
}
