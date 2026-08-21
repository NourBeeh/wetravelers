import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/features/home/presentation/home_controller.dart';
import 'package:wetravellers/core/repositories/impl/home_repository_impl.dart';
import 'package:wetravellers/core/network/http_api_client.dart';
import 'package:wetravellers/core/storage/offline_cache_providers.dart';

final apiClientProvider = Provider((ref) => HttpApiClient());

final homeRepositoryProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(offlineCacheProvider);
  return HomeRepositoryImpl(client, offlineCache: cache);
});

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return HomeController(repo);
});
