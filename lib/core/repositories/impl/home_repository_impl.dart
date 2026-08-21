import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/network/api_client.dart';
import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/repositories/contracts/home_repository.dart';
import 'package:wetravellers/core/storage/offline_cache.dart';

import 'demo_home_data.dart';

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
  HomeRepositoryImpl(this.apiClient, {OfflineCache? offlineCache})
      : _offlineCache = offlineCache;

  final ApiClient apiClient;
  final OfflineCache? _offlineCache;

  static const String _cacheKey = 'home|sections';

  @override
  Future<ApiResult<List<HomeSection>>> getHomeSections() async {
    final result = await apiClient.get<List<dynamic>>('/home/sections');
    return result.when(
      success: (data) async {
        final sections = _parseSections(data);
        if (sections.isNotEmpty) {
          // Write-through snapshot so a later empty/failed feed still shows
          // the last real content instead of a blank screen.
          await _cacheSections(sections);
          return ApiResult.success(sections);
        }
        // Backend reachable but feed empty (e.g. unseeded database).
        final cached = await _readCachedSections();
        if (cached != null && cached.isNotEmpty) {
          return ApiResult.success(cached);
        }
        return ApiResult.success(demoHomeSections());
      },
      failure: (error) async {
        final cached = await _readCachedSections();
        if (cached != null && cached.isNotEmpty) {
          return ApiResult.success(cached);
        }
        return ApiResult.success(demoHomeSections());
      },
    );
  }

  Future<List<HomeSection>?> _readCachedSections() async {
    final cache = _offlineCache;
    if (cache == null) return null;
    try {
      final map = await cache.read(_cacheKey);
      if (map == null) return null;
      return _sectionsFromCacheMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheSections(List<HomeSection> sections) async {
    final cache = _offlineCache;
    if (cache == null || sections.isEmpty) return;
    try {
      await cache.write(_cacheKey, <String, dynamic>{
        'sections': sections.map(_sectionToMap).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Best-effort; never crash the UI on storage failure.
    }
  }

  List<HomeSection> _parseSections(List<dynamic> data) {
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
              actionLabel: c['actionLabel']?.toString() ?? c['action']?.toString(),
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
    return sections;
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

/// JSON-safe snapshot of one section for the offline cache.
Map<String, dynamic> _sectionToMap(HomeSection s) {
  return <String, dynamic>{
    'id': s.id,
    'title': s.title,
    'subtitle': s.subtitle,
    'layout': s.layout.name,
    'items': s.items.map(_itemToMap).toList(),
  };
}

Map<String, dynamic> _itemToMap(HomeItem i) {
  return <String, dynamic>{
    'id': i.id,
    'type': i.type.name,
    'title': i.title,
    'subtitle': i.subtitle,
    'description': i.description,
    'imageUrl': i.imageUrl,
    if (i.price != null) 'price': i.price,
    'currency': i.currency,
    if (i.rating != null) 'rating': i.rating,
    if (i.reviewCount != null) 'reviewCount': i.reviewCount,
    'badge': i.badge,
    'highlights': i.highlights,
    'tags': i.tags,
    'actionLabel': i.actionLabel,
  };
}

List<HomeSection> _sectionsFromCacheMap(Map<String, dynamic> map) {
  final sections = <HomeSection>[];
  for (final raw in (map['sections'] as List? ?? [])) {
    if (raw is! Map) continue;
    final s = Map<String, dynamic>.from(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
    final cards = <HomeItem>[];
    for (final rawCard in (s['items'] as List? ?? [])) {
      if (rawCard is! Map) continue;
      final c = Map<String, dynamic>.from(
        rawCard.map((k, v) => MapEntry(k.toString(), v)),
      );
      cards.add(HomeItem(
        id: c['id']?.toString() ?? '',
        type: _parseCardType(c['type']?.toString()),
        title: c['title']?.toString() ?? '',
        subtitle: c['subtitle']?.toString(),
        description: c['description']?.toString(),
        imageUrl: c['imageUrl']?.toString(),
        price: c['price'] is num ? (c['price'] as num).toDouble() : null,
        currency: c['currency']?.toString(),
        rating: c['rating'] is num ? (c['rating'] as num).toDouble() : null,
        reviewCount:
            c['reviewCount'] is int ? c['reviewCount'] as int : null,
        badge: c['badge']?.toString(),
        highlights:
            (c['highlights'] as List?)?.map((e) => e.toString()).toList() ?? [],
        tags: (c['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        actionLabel: c['actionLabel']?.toString(),
      ));
    }
    sections.add(HomeSection(
      id: s['id']?.toString() ?? '',
      title: s['title']?.toString() ?? '',
      subtitle: s['subtitle']?.toString(),
      layout: _parseLayout(s['layout']?.toString()),
      items: cards,
    ));
  }
  return sections;
}
