import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/usecases/search_flights_usecase.dart';
import 'package:wetravellers/features/search/application/controllers/flight_search_controller.dart';
import 'package:wetravellers/core/repositories/impl/flight_repository_impl.dart';
import 'package:wetravellers/core/network/http_api_client.dart';

final flightApiClientProvider = Provider((ref) => HttpApiClient());

final flightRepositoryProvider = Provider((ref) {
  final client = ref.watch(flightApiClientProvider);
  return FlightRepositoryImpl(client);
});

final searchFlightsUseCaseProvider = Provider((ref) {
  final repo = ref.watch(flightRepositoryProvider);
  return SearchFlightsUseCase(repo);
});

final flightSearchControllerProvider = StateNotifierProvider<FlightSearchController, FlightSearchState>((ref) {
  final usecase = ref.watch(searchFlightsUseCaseProvider);
  return FlightSearchController(usecase);
});
