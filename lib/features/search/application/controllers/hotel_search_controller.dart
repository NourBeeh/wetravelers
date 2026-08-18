import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/search/hotel_search_params.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/repositories/contracts/hotel_repository.dart';

enum HotelSearchStatus { idle, loading, success, empty, error }

class HotelSearchState {
  final HotelSearchStatus status;
  final List<HotelOffer> results;
  final String? errorMessage;
  const HotelSearchState({this.status = HotelSearchStatus.idle, this.results = const [], this.errorMessage});
  HotelSearchState copyWith({HotelSearchStatus? status, List<HotelOffer>? results, String? errorMessage}) {
    return HotelSearchState(status: status ?? this.status, results: results ?? this.results, errorMessage: errorMessage ?? this.errorMessage);
  }
}

class HotelSearchController extends StateNotifier<HotelSearchState> {
  final HotelRepository repository;
  HotelSearchController(this.repository) : super(const HotelSearchState());

  Future<void> search(HotelSearchParams params) async {
    state = state.copyWith(status: HotelSearchStatus.loading);
    final result = await repository.search(
      city: params.destination,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      guests: params.adults ?? 1,
    );
    result.when(
      success: (offers) {
        if (offers.isEmpty) {
          state = state.copyWith(status: HotelSearchStatus.empty, results: []);
        } else {
          state = state.copyWith(status: HotelSearchStatus.success, results: offers);
        }
      },
      failure: (e) => state = state.copyWith(
        status: HotelSearchStatus.error,
        errorMessage: userFacingMessage(e, subject: 'hotel search'),
      ),
    );
  }
}
