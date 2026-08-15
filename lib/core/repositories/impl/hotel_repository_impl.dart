import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/repositories/contracts/hotel_repository.dart';
import 'package:wetravellers/core/network/http_api_client.dart';
import 'package:wetravellers/core/network/api_result.dart';

class HotelRepositoryImpl implements HotelRepository {
  final HttpApiClient client;
  HotelRepositoryImpl(this.client);
  @override
  Future<ApiResult<List<HotelOffer>>> search({required String city, required DateTime checkIn, required DateTime checkOut, int? guests}) async {
    return const ApiResult.success([]);
  }
  @override
  Future<ApiResult<HotelOffer>> getById(String id) async => ApiResult.success(HotelOffer(id: id, providerId: 'p', providerName: 'n', title: 't', price: 0, currency: 'USD', city: 'c', country: 'c', checkIn: DateTime.now(), checkOut: DateTime.now(), roomType: 'r'));
}
