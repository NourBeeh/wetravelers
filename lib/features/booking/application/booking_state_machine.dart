enum ExtendedBookingStatus {
  draft,
  pending,
  revalidating,
  awaitingPayment,
  paymentProcessing,
  paid,
  confirming,
  confirmed,
  failed,
  cancelled,
  expired,
}

class BookingStateMachine {
  static bool canTransition(ExtendedBookingStatus from, ExtendedBookingStatus to) {
    switch (from) {
      case ExtendedBookingStatus.draft:
        return to == ExtendedBookingStatus.pending;
      case ExtendedBookingStatus.pending:
        return to == ExtendedBookingStatus.revalidating || to == ExtendedBookingStatus.cancelled;
      case ExtendedBookingStatus.revalidating:
        return to == ExtendedBookingStatus.awaitingPayment || to == ExtendedBookingStatus.failed;
      case ExtendedBookingStatus.awaitingPayment:
        return to == ExtendedBookingStatus.paymentProcessing || to == ExtendedBookingStatus.expired || to == ExtendedBookingStatus.cancelled;
      case ExtendedBookingStatus.paymentProcessing:
        return to == ExtendedBookingStatus.paid || to == ExtendedBookingStatus.failed;
      case ExtendedBookingStatus.paid:
        return to == ExtendedBookingStatus.confirming;
      case ExtendedBookingStatus.confirming:
        return to == ExtendedBookingStatus.confirmed || to == ExtendedBookingStatus.failed;
      case ExtendedBookingStatus.confirmed:
        return to == ExtendedBookingStatus.cancelled;
      case ExtendedBookingStatus.failed:
        return false;
      case ExtendedBookingStatus.cancelled:
        return false;
      case ExtendedBookingStatus.expired:
        return false;
    }
  }

  static void assertTransition(ExtendedBookingStatus from, ExtendedBookingStatus to) {
    if (!canTransition(from, to)) {
      throw StateError('Invalid transition $from -> $to');
    }
  }
}
