import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/repositories/contracts/booking_repository.dart';
import 'package:wetravellers/features/booking/domain/booking_record.dart';
import 'package:wetravellers/features/booking/application/idempotency_store.dart';

class ConfirmBookingUseCase {
  final BookingRepository repository;

  ConfirmBookingUseCase(this.repository);

  Future<ApiResult<BookingRecord>> call({
    required String offerId,
    required String providerId,
    required String idempotencyKey,
    required List<dynamic> travelers,
  }) async {
    if (IdempotencyStore.contains(idempotencyKey)) {
      final cached = IdempotencyStore.get<BookingRecord>(idempotencyKey);
      if (cached != null) {
        return ApiResult.success(cached);
      }
    }

    final res = await repository.createBooking(
      offerId,
      providerId,
      idempotencyKey,
      travelers,
    );

    return res.when(
      success: (record) {
        IdempotencyStore.put(idempotencyKey, record);
        return ApiResult.success(record);
      },
      failure: (error) => ApiResult.failure(error),
    );
  }
}
