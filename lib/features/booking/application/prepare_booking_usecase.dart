import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/repositories/contracts/booking_repository.dart';
import 'package:wetravellers/features/booking/domain/booking_record.dart';

class PrepareBookingUseCase {
  final BookingRepository repository;
  PrepareBookingUseCase(this.repository);

  Future<ApiResult<BookingRecord>> call({
    required String offerId,
    required String providerId,
    required String searchId,
  }) async {
    return repository.prepareBooking(offerId, providerId, searchId);
  }
}
