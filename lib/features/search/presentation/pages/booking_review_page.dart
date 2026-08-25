import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/booking/domain/booking_record.dart';
import 'package:wetravellers/features/booking/application/booking_state.dart';
import 'package:wetravellers/features/booking/application/booking_providers.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/features/bag/domain/trip.dart';

class BookingReviewPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOffer = ref.watch(selectedOfferProvider);
    final bookingState = state ?? ref.watch(bookingControllerProvider);
    final bookingNotifier = ref.read(bookingControllerProvider.notifier);

    if (booking == null && bookingState?.record == null && selectedOffer == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(child: Text('No booking selected')),
        ),
      );
    }
    final record = booking ?? bookingState?.record;
    final phase = bookingState?.phase ?? BookingPhase.idle;

    final effectivePrepare = onPrepare ?? (selectedOffer != null ? () {
      bookingNotifier.prepare(
        offerId: selectedOffer.offerId,
        providerId: selectedOffer.providerId,
        searchId: selectedOffer.searchId,
      );
    } : null);

    final effectiveRevalidate = onRevalidate ?? (record != null ? () {
      bookingNotifier.revalidate(bookingId: record.bookingReference, oldPrice: record.authoritativePrice);
    } : null);

    final effectiveAcceptPrice = onAcceptPrice ?? () {
      bookingNotifier.acceptNewPrice();
    };

    final effectiveConfirm = onConfirm ?? () {
      bookingNotifier.confirm();
    };

    final effectiveViewTrip = onViewTrip ?? () {
      context.go('/bag');
    };

    return Scaffold(
      // No AppBar — the shell's fixed header provides the title.
      body: SafeArea(
        child: Padding(
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
            ] else if (selectedOffer != null) ...[
              Text('Selected: ${selectedOffer.offerType.toUpperCase()}'),
              const SizedBox(height: AppSpacing.sm),
              Text('Provider: ${selectedOffer.providerName}'),
              Text('Price: ${selectedOffer.price.toStringAsFixed(2)} ${selectedOffer.currency}'),
            ],
            const SizedBox(height: AppSpacing.md),
            _buildPhaseContent(phase, bookingState),
            const Spacer(),
            _buildActions(
              phase,
              bookingState,
              onPrepare: effectivePrepare,
              onRevalidate: effectiveRevalidate,
              onAcceptPrice: effectiveAcceptPrice,
              onConfirm: effectiveConfirm,
              onViewTrip: effectiveViewTrip,
            ),
          ],
          ),
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

  Widget _buildActions(
    BookingPhase phase,
    BookingState? state, {
    VoidCallback? onPrepare,
    VoidCallback? onRevalidate,
    VoidCallback? onAcceptPrice,
    VoidCallback? onConfirm,
    VoidCallback? onViewTrip,
  }) {
    final effectivePrepare = onPrepare ?? this.onPrepare;
    final effectiveRevalidate = onRevalidate ?? this.onRevalidate;
    final effectiveAcceptPrice = onAcceptPrice ?? this.onAcceptPrice;
    final effectiveConfirm = onConfirm ?? this.onConfirm;
    final effectiveViewTrip = onViewTrip ?? this.onViewTrip;

    return Row(
      children: [
        if (phase == BookingPhase.idle || phase == BookingPhase.prepared)
          Expanded(
            child: Semantics(
              button: true,
              label: 'Prepare booking',
              child: ElevatedButton(
                onPressed: effectivePrepare,
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
                onPressed: effectiveRevalidate,
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
                onPressed: effectiveAcceptPrice,
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
                onPressed: effectiveConfirm,
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
                onPressed: effectiveViewTrip,
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
                onPressed: effectiveConfirm,
                child: const Text('Retry'),
              ),
            ),
          ),
      ],
    );
  }
}
