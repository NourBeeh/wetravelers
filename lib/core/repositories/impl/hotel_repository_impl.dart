import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/repositories/contracts/hotel_repository.dart';
import 'package:wetravellers/core/network/http_api_client.dart';
import 'package:wetravellers/core/network/api_result.dart';

class HotelRepositoryImpl implements HotelRepository {
  final HttpApiClient client;
  HotelRepositoryImpl(this.client);

  @override
  Future<ApiResult<List<HotelOffer>>> search({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
  }) async {
    try {
      final result = await client.post<Map<String, dynamic>>(
        '/search/hotels',
        body: {
          'city': city,
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
          'guests': guests ?? 2,
          'rooms': 1,
        },
      );

      return result.when(
        success: (data) {
          final offers = _parseHotels(data);
          if (offers.isEmpty) {
            return const ApiResult.success([]);
          }
          return ApiResult.success(offers);
        },
        failure: (error) => ApiResult.failure(error),
      );
    } catch (e) {
      return ApiResult.failure(
        ApiNetworkError(message: e.toString(), cause: e),
      );
    }
  }

  List<HotelOffer> _parseHotels(Map<String, dynamic> data) {
    final offers = <HotelOffer>[];

    // Backend returns { successes: [ { success, data: [...] } ], failures: [] }
    final successes = data['successes'] as List? ?? [];
    for (final providerResult in successes) {
      if (providerResult is! Map) continue;
      final items = providerResult['data'] as List? ?? [];
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        try {
          final offer = _parseHotelItem(item);
          if (offer != null) offers.add(offer);
        } catch (_) {
          // skip malformed items
        }
      }
    }

    return offers;
  }

  HotelOffer? _parseHotelItem(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) return null;

    final checkInRaw = item['checkIn']?.toString();
    final checkOutRaw = item['checkOut']?.toString();

    DateTime checkIn;
    DateTime checkOut;
    try {
      checkIn = checkInRaw != null ? DateTime.parse(checkInRaw) : DateTime.now().add(const Duration(days: 7));
      checkOut = checkOutRaw != null ? DateTime.parse(checkOutRaw) : DateTime.now().add(const Duration(days: 10));
    } catch (_) {
      checkIn = DateTime.now().add(const Duration(days: 7));
      checkOut = DateTime.now().add(const Duration(days: 10));
    }

    return HotelOffer(
      id: id,
      providerId: item['providerId']?.toString() ?? 'duffel',
      providerName: item['providerName']?.toString() ?? 'Duffel',
      title: item['title']?.toString() ?? 'Hotel',
      subtitle: item['subtitle']?.toString(),
      description: item['description']?.toString(),
      imageUrl: item['imageUrl']?.toString(),
      price: _parseDouble(item['price']) ?? 0,
      currency: item['currency']?.toString() ?? 'USD',
      rating: _parseDouble(item['rating']),
      reviewCount: _parseInt(item['reviewCount']),
      city: item['city']?.toString() ?? '',
      country: item['country']?.toString() ?? '',
      checkIn: checkIn,
      checkOut: checkOut,
      roomType: item['roomType']?.toString() ?? 'Standard Room',
      amenities: (item['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  @override
  Future<ApiResult<HotelOffer>> getById(String id) async {
    return ApiResult.failure(
      const ApiClientError(message: 'getById not implemented', statusCode: 501),
    );
  }
}
