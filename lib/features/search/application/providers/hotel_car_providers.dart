import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/repositories/impl/hotel_repository_impl.dart';
import 'package:wetravellers/core/repositories/impl/car_repository_impl.dart';
import 'package:wetravellers/core/network/http_api_client.dart';
import 'package:wetravellers/features/search/application/controllers/hotel_search_controller.dart';
import 'package:wetravellers/features/search/application/controllers/car_search_controller.dart';

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
  return HotelSearchController(repo);
});

final carSearchControllerProvider = StateNotifierProvider<CarSearchController, CarSearchState>((ref) {
  final repo = ref.watch(carRepositoryProvider);
  return CarSearchController(repo);
});
