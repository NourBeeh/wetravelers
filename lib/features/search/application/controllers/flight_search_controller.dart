import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/search/flight_search_params.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/usecases/search_flights_usecase.dart';

enum SearchStatus { idle, loading, success, empty, error }

class FlightSearchState {
  final SearchStatus status;
  final List<FlightOffer> results;
  final String? errorMessage;
  final bool isRefreshing;

  const FlightSearchState({
    this.status = SearchStatus.idle,
    this.results = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  FlightSearchState copyWith({
    SearchStatus? status,
    List<FlightOffer>? results,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return FlightSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class FlightSearchController extends StateNotifier<FlightSearchState> {
  final SearchFlightsUseCase usecase;
  FlightSearchController(this.usecase) : super(const FlightSearchState());

  Future<void> search(FlightSearchParams params) async {
    state = state.copyWith(status: SearchStatus.loading);
    final result = await usecase.call(
      origin: params.origin,
      destination: params.destination,
      departure: params.departureDate,
      returnDate: params.returnDate,
      passengers: params.adults,
    );
    result.when(
      success: (offers) {
        if (offers.isEmpty) {
          state = state.copyWith(status: SearchStatus.empty, results: []);
        } else {
          state = state.copyWith(status: SearchStatus.success, results: offers);
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: userFacingMessage(error, subject: 'flight search'),
        );
      },
    );
  }
}
