import 'package:flutter/material.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/booking/domain/booking_record.dart';
import 'package:wetravellers/features/booking/application/booking_state.dart';
import 'package:wetravellers/features/bag/domain/trip.dart';
import 'package:wetravellers/features/bag/presentation/pages/trip_details_page.dart';

class BookingReviewPage extends StatelessWidget {
  final BookingRecord? booking;
  final BookingState? state;
  final void Function()? onPrepare;
  final void Function()? onRevalidate;
  final void Function()? onAcceptPrice;
  final void Function()? onConfirm;
  final TripSummary? trip;
  final VoidCallback? onViewTrip;

  const BookingReviewPage({
    super.key,
    this.booking,
    this.state,
    this.onPrepare,
    this.onRevalidate,
    this.onAcceptPrice,
    this.onConfirm,
    this.trip,
    this.onViewTrip,
  });

  @override
  Widget build(BuildContext context) {
    if (booking == null && state?.record == null) {
      return Scaffold(appBar: AppBar(title: const Text('Review Booking')), body: const Center(child: Text('No booking selected')));
    }
    final record = booking ?? state?.record;
    final phase = state?.phase ?? BookingPhase.idle;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Booking')),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record != null) ...[
              Text('Status: ${record.status.name}'),
              const SizedBox(height: AppSpacing.sm),
              Text('Provider: ${record.providerName}'),
              Text('Price: ${record.authoritativePrice} ${record.currency}'),
              Text('Reference: ${record.bookingReference}'),
            ],
            const SizedBox(height: AppSpacing.md),
            _buildPhaseContent(phase, state),
            const Spacer(),
            _buildActions(phase, state),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent(BookingPhase phase, BookingState? state) {
    switch (phase) {
      case BookingPhase.idle:
        return const Text('Select offer to start preparation');
      case BookingPhase.preparing:
        return const LinearProgressIndicator();
      case BookingPhase.prepared:
        return const Text('Preparation complete. Ready to revalidate price.');
      case BookingPhase.revalidating:
        return const LinearProgressIndicator();
      case BookingPhase.readyToConfirm:
        return const Text('Price validated. Ready to confirm.');
      case BookingPhase.priceChanged:
        final rev = state?.preparation?.revalidation;
        if (rev != null && rev.oldPrice != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price changed'),
              Text('Previous: ${rev.oldPrice} ${rev.currency}'),
              Text('New authoritative: ${rev.authoritativePrice} ${rev.currency}'),
            ],
          );
        }
        return const Text('Price changed');
      case BookingPhase.unavailable:
        return const Text('Booking unavailable. Please retry.');
      case BookingPhase.confirming:
        return const Column(children: [Text('Confirming booking...'), SizedBox(height: 8), LinearProgressIndicator()]);
      case BookingPhase.confirmed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking confirmed'),
            if (state?.record != null) Text('Reference: ${state!.record!.bookingReference}'),
            if (state?.record != null) Text('Price: ${state!.record!.authoritativePrice} ${state!.record!.currency}'),
          ],
        );
      case BookingPhase.failed:
        return Text('Confirmation failed: ${state?.errorMessage ?? 'Unknown'}');
      case BookingPhase.error:
        return Text('Error: ${state?.errorMessage ?? 'Unknown'}');
    }
  }

  Widget _buildActions(BookingPhase phase, BookingState? state) {
    return Row(
      children: [
        if (phase == BookingPhase.idle || phase == BookingPhase.prepared)
          Expanded(
            child: Semantics(
              button: true,
              label: 'Prepare booking',
              child: ElevatedButton(
                onPressed: onPrepare,
                child: const Text('Prepare booking'),
              ),
            ),
          ),
        if (phase == BookingPhase.prepared)
          const SizedBox(width: 12),
        if (phase == BookingPhase.prepared)
          Expanded(
            child: Semantics(
              button: true,
              label: 'Revalidate price',
              child: ElevatedButton(
                onPressed: onRevalidate,
                child: const Text('Revalidate price'),
              ),
            ),
          ),
        if (phase == BookingPhase.priceChanged)
          Expanded(
            child: Semantics(
              button: true,
              label: 'Accept new price',
              child: ElevatedButton(
                onPressed: onAcceptPrice,
                child: const Text('Accept new price'),
              ),
            ),
          ),
        if (phase == BookingPhase.readyToConfirm)
          Expanded(
            child: Semantics(
              button: true,
              label: 'Confirm booking',
              child: ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Confirm'),
              ),
            ),
          ),
        if (phase == BookingPhase.confirming)
          const Expanded(child: Text('Processing...')),
        if (phase == BookingPhase.confirmed)
          Expanded(
            child: Semantics(
              button: true,
              label: 'View trip details',
              child: ElevatedButton(
                onPressed: onViewTrip,
                child: const Text('View Trip'),
              ),
            ),
          ),
        if (phase == BookingPhase.failed)
          Expanded(
            child: Semantics(
              button: true,
              label: 'Retry confirmation',
              child: ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Retry'),
              ),
            ),
          ),
      ],
    );
  }
}
