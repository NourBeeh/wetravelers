enum BookingErrorCode {
  offer_not_found,
  provider_unavailable,
  price_changed,
  no_availability,
  booking_expired,
  validation_failed,
  unauthorized,
  provider_error,
  duplicate_request,
  unknown_error,
}

class BookingError {
  final BookingErrorCode code;
  final String message;
  final Map<String, dynamic> details;

  const BookingError(this.code, this.message, [this.details = const {}]);
}
