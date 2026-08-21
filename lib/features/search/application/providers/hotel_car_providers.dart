import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/repositories/impl/hotel_repository_impl.dart';
import 'package:wetravellers/core/repositories/impl/car_repository_impl.dart';
import 'package:wetravellers/core/network/http_api_client.dart';
import 'package:wetravellers/features/search/application/controllers/hotel_search_controller.dart';
import 'package:wetravellers/features/search/application/controllers/car_search_controller.dart';
import 'package:wetravellers/core/storage/offline_cache_providers.dart';

final httpClientProvider = Provider((ref) => HttpApiClient());

final hotelRepositoryProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  return HotelRepositoryImpl(client);
});

final carRepositoryProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  return CarRepositoryImpl(client);
});

final hotelSearchControllerProvider = StateNotifierProvider<HotelSearchController, HotelSearchState>((ref) {
  final repo = ref.watch(hotelRepositoryProvider);
  final cache = ref.watch(offlineCacheProvider);
  return HotelSearchController(repo, cache);
});

final carSearchControllerProvider = StateNotifierProvider<CarSearchController, CarSearchState>((ref) {
  final repo = ref.watch(carRepositoryProvider);
  final cache = ref.watch(offlineCacheProvider);
  return CarSearchController(repo, cache);
});
