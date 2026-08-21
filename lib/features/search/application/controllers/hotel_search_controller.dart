import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/search/hotel_search_params.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/repositories/contracts/hotel_repository.dart';
import 'package:wetravellers/core/storage/offline_cache.dart';
import 'package:wetravellers/core/storage/offline_cache_serializers.dart';

enum HotelSearchStatus { idle, loading, success, empty, error }

class HotelSearchState {
  final HotelSearchStatus status;
  final List<HotelOffer> results;
  final String? errorMessage;
  final bool fromCache;

  const HotelSearchState({this.status = HotelSearchStatus.idle, this.results = const [], this.errorMessage, this.fromCache = false});
  HotelSearchState copyWith({HotelSearchStatus? status, List<HotelOffer>? results, String? errorMessage, bool? fromCache}) {
    return HotelSearchState(status: status ?? this.status, results: results ?? this.results, errorMessage: errorMessage ?? this.errorMessage, fromCache: fromCache ?? this.fromCache);
  }
}

class HotelSearchController extends StateNotifier<HotelSearchState> {
  final HotelRepository repository;
  final OfflineCache _cache;
  HotelSearchController(this.repository, this._cache) : super(const HotelSearchState());

  Future<void> search(HotelSearchParams params) async {
    final cacheKey = hotelSearchCacheKey(
      city: params.destination,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      guests: params.adults,
    );

    // Try to load from cache first
    final cached = await _cache.read(cacheKey);
    if (cached != null) {
      final offers = <HotelOffer>[];
      for (final item in (cached['offers'] as List? ?? [])) {
        if (item is Map<String, dynamic>) {
          final offer = offerFromMap(item) as HotelOffer?;
          if (offer != null) offers.add(offer);
        }
      }
      if (offers.isNotEmpty) {
        state = state.copyWith(status: HotelSearchStatus.success, results: offers, fromCache: true);
      }
    }

    state = state.copyWith(status: HotelSearchStatus.loading);
    final result = await repository.search(
      city: params.destination,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      guests: params.adults,
    );
    await result.when<Future<void>>(
      success: (offers) async {
        if (offers.isEmpty) {
          state = state.copyWith(status: HotelSearchStatus.empty, results: [], fromCache: false);
        } else {
          // Write to cache (best-effort)
          try {
            await _cache.write(cacheKey, {
              'offers': offers.map(offerToMap).toList(),
              'timestamp': DateTime.now().toIso8601String(),
            });
          } catch (_) {
            // Ignore cache write failures
          }
          state = state.copyWith(status: HotelSearchStatus.success, results: offers, fromCache: false);
        }
      },
      failure: (e) async {
        if (state.fromCache && state.results.isNotEmpty) {
          state = state.copyWith(
            status: HotelSearchStatus.success,
            errorMessage: userFacingMessage(e, subject: 'hotel search'),
          );
        } else {
          state = state.copyWith(
            status: HotelSearchStatus.error,
            errorMessage: userFacingMessage(e, subject: 'hotel search'),
            fromCache: false,
          );
        }
      },
    );
  }
}