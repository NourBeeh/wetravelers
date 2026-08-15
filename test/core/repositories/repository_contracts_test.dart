import 'package:flutter_test/flutter_test.dart';
import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/network/api_error.dart';
import 'package:wetravellers/core/repositories/contracts/flight_repository.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';

class FakeFlightRepository implements FlightRepository {
  @override
  Future<ApiResult<List<FlightOffer>>> search({required String origin, required String destination, required DateTime departure, DateTime? returnDate, int? passengers}) async {
    return const ApiResult.success([]);
  }

  @override
  Future<ApiResult<FlightOffer>> getById(String id) async {
    return ApiResult.failure(const ApiUnknownError(message: 'not implemented'));
  }
}

void main() {
  test('FlightRepository contract is instantiable', () async {
    final repo = FakeFlightRepository();
    final result = await repo.search(origin: 'A', destination: 'B', departure: DateTime.now());
    expect(result.isSuccess, true);
  });
}