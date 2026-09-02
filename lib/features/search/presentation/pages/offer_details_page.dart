import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/core/domain/models/offers/car_offer.dart';
import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/domain/models/offers/travel_package_offer.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/theme/app_typography.dart';
import 'package:wetravellers/core/ui/app_button.dart';
import 'package:wetravellers/core/widgets/sticky_cta_bar.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

/// Unified offer-details page.
///
/// One premium layout for every vertical: hero image header with back/favorite
/// actions, a summary card, content sections specialised per offer type, and
/// a sticky price + book CTA bar.
class OfferDetailsPage extends ConsumerWidget {
  const OfferDetailsPage({
    super.key,
    required this.offer,
    this.hue = AppColors.brand,
  });

  final Object offer;
  final Color hue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = AppTypography.forLight();
    final l10n = AppLocalizations.of(context)!;
    final (title, subtitle, imageUrl, price, currency) = _offerSummary(offer);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              // Hero image header with back + favorite.
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: _CircleAction(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.canPop() ? context.pop() : context.go('/'),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _CircleAction(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroImage(imageUrl: imageUrl, hue: hue),
                ),
              ),
              // Content.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: typography.headline.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: typography.body.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SummaryCard(offer: offer),
                      const SizedBox(height: AppSpacing.xl),
                      _ContentSections(offer: offer),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomSheet: StickyCtaBar(
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.total,
                  style: typography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '$currency $price',
                  style: typography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: AppButton(
                label: l10n.bookNow,
                onPressed: () {
                  ref.read(selectedOfferProvider.notifier).state =
                      _selectedOfferFrom(offer);
                  context.push('/booking/review');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String, String?, double, String) _offerSummary(Object offer) {
    return switch (offer) {
      FlightOffer(:final title, :final origin, :final destination,
          :final price, :final currency, :final imageUrl) => (
        title,
        '$origin → $destination',
        imageUrl,
        price,
        currency,
      ),
      HotelOffer(:final title, :final city, :final country, :final price,
          :final currency, :final imageUrl) => (
        title,
        '$city, $country',
        imageUrl,
        price,
        currency,
      ),
      CarOffer(:final title, :final carType, :final price, :final currency,
          :final imageUrl) => (
        title,
        carType,
        imageUrl,
        price,
        currency,
      ),
      TravelPackageOffer(:final title, :final destination, :final price,
          :final currency, :final imageUrl) => (
        title,
        destination,
        imageUrl,
        price,
        currency,
      ),
      _ => ('', '', null, 0, 'USD'),
    };
  }

  SelectedOffer _selectedOfferFrom(Object offer) {
    return switch (offer) {
      FlightOffer o => SelectedOffer(
          offerId: o.id,
          providerId: o.providerId,
          providerName: o.providerName,
          price: o.price,
          currency: o.currency,
          searchId: '',
          offerType: o.offerType,
          metadata: o.metadata,
        ),
      HotelOffer o => SelectedOffer(
          offerId: o.id,
          providerId: o.providerId,
          providerName: o.providerName,
          price: o.price,
          currency: o.currency,
          searchId: '',
          offerType: o.offerType,
          metadata: o.metadata,
        ),
      CarOffer o => SelectedOffer(
          offerId: o.id,
          providerId: o.providerId,
          providerName: o.providerName,
          price: o.price,
          currency: o.currency,
          searchId: '',
          offerType: o.offerType,
          metadata: o.metadata,
        ),
      TravelPackageOffer o => SelectedOffer(
          offerId: o.id,
          providerId: o.providerId,
          providerName: o.providerName,
          price: o.price,
          currency: o.currency,
          searchId: '',
          offerType: o.offerType,
          metadata: o.metadata,
        ),
      _ => const SelectedOffer(
          offerId: '',
          providerId: '',
          providerName: '',
          price: 0,
          currency: 'USD',
          searchId: '',
          offerType: 'flight',
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl, required this.hue});

  final String? imageUrl;
  final Color hue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (imageUrl != null)
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _HueFallback(hue: hue),
          )
        else
          _HueFallback(hue: hue),
        // Soft scrim so the pinned bar stays legible over photography.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x33000000),
                Colors.transparent,
                Color(0x40000000),
              ],
              stops: <double>[0, 0.4, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _HueFallback extends StatelessWidget {
  const _HueFallback({required this.hue});

  final Color hue;

  @override
  Widget build(BuildContext context) {
    return Container(color: hue.withValues(alpha: 0.85));
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card — key facts per offer type
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.offer});

  final Object offer;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    final rows = _rowsFor(offer);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Icon(rows[i].$3, size: 18, color: AppColors.brand),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: typography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Text(
                  rows[i].$2,
                  style: typography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<(String, String, IconData)> _rowsFor(Object offer) {
    final dateFormat = (DateTime d) =>
        '${d.year}-${_pad(d.month)}-${_pad(d.day)} ${_pad(d.hour)}:${_pad(d.minute)}';
    return switch (offer) {
      FlightOffer o => <(String, String, IconData)>[
          ('Airline', o.airline, Icons.flight_rounded),
          ('Flight', o.flightNumber, Icons.confirmation_number_rounded),
          ('Departs', dateFormat(o.departureTime), Icons.schedule_rounded),
          ('Arrives', dateFormat(o.arrivalTime), Icons.flag_rounded),
          ('Cabin', o.cabinClass ?? 'Economy', Icons.event_seat_rounded),
          ('Stops', '${o.stops ?? 0}', Icons.alt_route_rounded),
        ],
      HotelOffer o => <(String, String, IconData)>[
          ('Check-in', dateFormat(o.checkIn), Icons.login_rounded),
          ('Check-out', dateFormat(o.checkOut), Icons.logout_rounded),
          ('Room', o.roomType, Icons.bed_rounded),
          ('Rating', '${o.rating ?? '-'} ★', Icons.star_rounded),
        ],
      CarOffer o => <(String, String, IconData)>[
          ('Pickup', o.pickupLocation, Icons.pin_drop_rounded),
          ('Drop-off', o.dropoffLocation, Icons.pin_drop_rounded),
          ('Type', o.carType, Icons.directions_car_rounded),
          ('Transmission', o.transmission ?? '-', Icons.settings_rounded),
          ('Seats', '${o.seats ?? '-'}', Icons.event_seat_rounded),
        ],
      TravelPackageOffer o => <(String, String, IconData)>[
          ('Destination', o.destination, Icons.place_rounded),
          ('Duration', '${o.durationDays} days', Icons.timelapse_rounded),
          ('Rating', '${o.rating ?? '-'} ★', Icons.star_rounded),
        ],
      _ => const <(String, String, IconData)>[],
    };
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}

// ---------------------------------------------------------------------------
// Content sections — specialised per offer type
// ---------------------------------------------------------------------------

class _ContentSections extends StatelessWidget {
  const _ContentSections({required this.offer});

  final Object offer;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    final widgets = <Widget>[];

    final description = switch (offer) {
      FlightOffer o => o.description,
      HotelOffer o => o.description,
      CarOffer o => o.description,
      TravelPackageOffer o => o.description,
      _ => null,
    };
    if (description != null && description.isNotEmpty) {
      widgets.addAll(<Widget>[
        _SectionTitle(typography: typography, title: 'About'),
        Text(
          description,
          style: typography.body.copyWith(color: AppColors.textSecondary),
        ),
      ]);
    }

    // Hotel amenities grid.
    if (offer is HotelOffer && (offer as HotelOffer).amenities.isNotEmpty) {
      final hotel = offer as HotelOffer;
      widgets.addAll(<Widget>[
        _SectionTitle(typography: typography, title: 'Amenities'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final amenity in hotel.amenities)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(
                  amenity,
                  style: typography.captionSemibold.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ]);
    }

    // Provider + policies footnotes for every offer.
    widgets.addAll(<Widget>[
      _SectionTitle(typography: typography, title: 'Provider'),
      Text(
        switch (offer) {
          FlightOffer o => o.providerName,
          HotelOffer o => o.providerName,
          CarOffer o => o.providerName,
          TravelPackageOffer o => o.providerName,
          _ => '',
        },
        style: typography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.typography, required this.title});

  final AppTypography typography;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: typography.title.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
