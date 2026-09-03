import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/theme/app_typography.dart';
import 'package:wetravellers/core/widgets/shimmer.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/features/home/presentation/home_controller.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_section.dart';
import 'package:wetravellers/features/home/providers/home_providers.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/features/bag/application/bag_controller.dart';
import 'package:wetravellers/features/bag/domain/trip.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final bag = ref.watch(bagControllerProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Seamless merged header — present across every feed state.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _HomeTopActions(),
                    const SizedBox(height: AppSpacing.md),
                    const _HomeWelcome(),
                  ],
                ),
              ),
              Expanded(child: _buildBody(state, ref, bag)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(HomeState state, WidgetRef ref, BagState bag) {
    switch (state.status) {
      case HomeStatus.loading:
        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.lg),
          itemCount: 5,
          itemBuilder: (_, _) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _SkeletonCard(height: 180),
          ),
        );
      case HomeStatus.success:
      case HomeStatus.partial:
      case HomeStatus.developmentPreview:
        return CustomScrollView(
          slivers: [
            // Continue planning — current trips from the unified Bag.
            if (bag.currentTrips.isNotEmpty)
              SliverToBoxAdapter(child: _ContinuePlanningRow(trips: bag.currentTrips)),
            // Recommended hotels from Nuitee (real data)
            if (state.recommendedHotels.isNotEmpty)
              SliverToBoxAdapter(
                child: _RecommendedHotelsCarousel(hotels: state.recommendedHotels),
              ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => HomeSectionWidget(
                    section: state.sections[index],
                    onFlightTap: (HomeItem flight) {
                      // Set selected offer and navigate to booking review
                      final metadata = flight.metadata;
                      ref.read(selectedOfferProvider.notifier).state = SelectedOffer(
                        offerId: flight.id,
                        providerId: metadata['providerId']?.toString() ?? '',
                        providerName: metadata['providerName']?.toString() ?? '',
                        price: flight.price ?? 0,
                        currency: flight.currency ?? 'USD',
                        searchId: '',
                        offerType: 'flight',
                      );
                      context.push('/booking/review');
                    },
                    onViewAllFlights: () {
                      context.push('/flights');
                    },
                    onFavorite: (flightId, value) {
                      // Handle wishlist change
                    },
                  ),
                  childCount: state.sections.length,
                ),
              ),
            ],
        );
      case HomeStatus.empty:
        return const Center(child: Text('No content available'));
      case HomeStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage ?? 'Something went wrong. Please try again.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(homeControllerProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }
}

/// "Continue planning" — horizontal strip of current trips from the unified
/// Bag, shown above the feed so users resume where they left off.
class _ContinuePlanningRow extends StatelessWidget {
  const _ContinuePlanningRow({required this.trips});

  final List<TripSummary> trips;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Continue planning',
                  style: typography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/bag'),
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: typography.captionSemibold.copyWith(
                    color: AppColors.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _ContinueTripTile(trip: trip);
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueTripTile extends StatelessWidget {
  const _ContinueTripTile({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    final dateFormat = (DateTime d) =>
        '${d.day}/${d.month}';
    return Material(
      color: AppColors.brandContainer,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/bag'),
        child: SizedBox(
          width: 240,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.luggage_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        trip.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.bodyLargeMedium.copyWith(
                          color: AppColors.onBrandContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${dateFormat(trip.startDate)} → ${dateFormat(trip.endDate)} · ${trip.status}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.caption.copyWith(
                          color: AppColors.onBrandContainer.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seamless merged header actions — the page flows directly under the status
/// bar with no fixed shell header. Bag (my trips), notifications and profile.
class _HomeTopActions extends StatelessWidget {
  const _HomeTopActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Travellers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.weightExtraBold,
                color: AppColors.brand,
              ),
        ),
        const Spacer(),
        _TopAction(
          icon: Icons.luggage_outlined,
          tooltip: 'My trips',
          onTap: () => context.push('/bag'),
        ),
        _TopAction(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          onTap: () => context.push('/notifications'),
        ),
        _TopAction(
          icon: Icons.person_outline_rounded,
          tooltip: 'Profile',
          onTap: () => context.push('/profile'),
        ),
      ],
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22, color: AppColors.textPrimary),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }
}

/// Compact welcome line — the hero search card now lives on the Search tab;
/// Home leads directly with the discovery feed.
class _HomeWelcome extends StatelessWidget {
  const _HomeWelcome();

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.homeWelcome,
          style: typography.headline.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.homeWelcomeSub,
          style: typography.body.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

/// Horizontal carousel of recommended hotels sourced from Nuitee.
class _RecommendedHotelsCarousel extends StatelessWidget {
  const _RecommendedHotelsCarousel({required this.hotels});

  final List<HomeItem> hotels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            'Recommended for You',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.weightBold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: hotels.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return _HotelCard(hotel: hotel);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel});

  final HomeItem hotel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty)
              Image.network(
                hotel.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.surfaceTertiary,
                  child: const Icon(Icons.image_not_supported_outlined, size: 32),
                ),
              )
            else
              Container(
                height: 120,
                color: AppColors.surfaceTertiary,
                child: const Icon(Icons.hotel_outlined, size: 32),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTypography.weightSemibold,
                      ),
                    ),
                    if (hotel.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        hotel.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        if (hotel.rating != null) ...[
                          Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 2),
                          Text(
                            hotel.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: AppTypography.weightSemibold,
                            ),
                          ),
                          if (hotel.reviewCount != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${hotel.reviewCount})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                        const Spacer(),
                        if (hotel.price != null)
                          Text(
                            '${hotel.currency ?? '\$'}${hotel.price!.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: AppTypography.weightBold,
                              color: AppColors.brand,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

/// Page-level loading placeholder while the Home feed loads. Uses the shared
/// [ShimmerBox] primitive — no hardcoded greys, theme-aware in both modes.
class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      height: height,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flexible image placeholder — absorbs height changes so the
          // fixed text rows below can never overflow the card.
          const Expanded(child: ShimmerBox(width: double.infinity)),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(height: 14, width: 180),
          const SizedBox(height: AppSpacing.xs),
          const ShimmerBox(height: 12, width: 120),
        ],
      ),
    );
  }
}
