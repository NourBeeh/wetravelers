import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/search/car_search_params.dart';
import 'package:wetravellers/core/domain/models/offers/car_offer.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/repositories/contracts/car_repository.dart';

enum CarSearchStatus { idle, loading, success, empty, error }

class CarSearchState {
  final CarSearchStatus status;
  final List<CarOffer> results;
  final String? errorMessage;
  const CarSearchState({this.status = CarSearchStatus.idle, this.results = const [], this.errorMessage});
  CarSearchState copyWith({CarSearchStatus? status, List<CarOffer>? results, String? errorMessage}) {
    return CarSearchState(status: status ?? this.status, results: results ?? this.results, errorMessage: errorMessage ?? this.errorMessage);
  }
}

class CarSearchController extends StateNotifier<CarSearchState> {
  final CarRepository repository;
  CarSearchController(this.repository) : super(const CarSearchState());

  Future<void> search(CarSearchParams params) async {
    state = state.copyWith(status: CarSearchStatus.loading);
    final result = await repository.search(
      pickupLocation: params.pickupLocation,
      pickupTime: params.pickupDateTime,
      dropoffTime: params.dropoffDateTime,
    );
    result.when(
      success: (offers) {
        if (offers.isEmpty) {
          state = state.copyWith(status: CarSearchStatus.empty, results: []);
        } else {
          state = state.copyWith(status: CarSearchStatus.success, results: offers);
        }
      },
      failure: (e) => state = state.copyWith(
        status: CarSearchStatus.error,
        errorMessage: userFacingMessage(e, subject: 'car search'),
      ),
    );
  }
}
