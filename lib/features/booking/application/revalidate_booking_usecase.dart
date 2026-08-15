import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/repositories/contracts/booking_repository.dart';
import 'package:wetravellers/features/booking/domain/booking_record.dart';

class RevalidateBookingUseCase {
  final BookingRepository repository;
  RevalidateBookingUseCase(this.repository);

  Future<ApiResult<BookingRecord>> call({required String bookingId}) async {
    return repository.revalidateBooking(bookingId);
  }
}
