import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/features/search/application/providers/search_providers.dart';
import 'package:wetravellers/features/search/application/controllers/flight_search_controller.dart';
import 'package:wetravellers/features/search/presentation/widgets/flight_search_form.dart';
import 'package:wetravellers/features/search/presentation/widgets/flight_search_card.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/search/presentation/widgets/sort_selector.dart';
import 'package:wetravellers/features/search/domain/sort_option.dart';
import 'package:wetravellers/features/search/application/sort_utils.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/features/search/domain/search_filters.dart';
import 'package:wetravellers/features/search/presentation/widgets/filter_panel.dart';

final flightSortProvider = StateProvider<SortOption>((ref) => SortOption.recommended);
final flightFiltersProvider = StateProvider<SearchFilters>((ref) => const SearchFilters());

class FlightSearchPage extends ConsumerStatefulWidget {
  const FlightSearchPage({super.key});

  @override
  ConsumerState<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends ConsumerState<FlightSearchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerAnimation;

  String _routeLabel = '';
  bool _formExpanded = true;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _headerAnimation = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _collapseForm() {
    setState(() {
      _formExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightSearchControllerProvider);
    final sort = ref.watch(flightSortProvider);
    final filters = ref.watch(flightFiltersProvider);

    // Extract initial search parameters from GoRouter state
    final goRouterState = GoRouterState.of(context);
    final extra = goRouterState.extra as Map<String, dynamic>?;
    final initialOrigin = extra?['origin'] as String?;
    final initialDestination = extra?['destination'] as String?;
    final initialDeparture = extra?['departureDate'] as DateTime?;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _formExpanded ? 460 : 70,
            pinned: true,
            backgroundColor: AppColors.brand,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(initialOrigin, initialDestination, initialDeparture),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _formExpanded ? 0 : 1,
              child: Text(
                _routeLabel.isEmpty ? 'Flights' : 'Flights · $_routeLabel',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            actions: [
              if (!_formExpanded)
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: () => setState(() => _formExpanded = true),
                  tooltip: 'Edit Search',
                ),
            ],
          ),

          // ─── Sort & Filters row ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  SortSelector(selected: sort, onChanged: (v) => ref.read(flightSortProvider.notifier).state = v),
                  const Spacer(),
                  TextButton(onPressed: () => _showFilters(context, ref), child: const Text('Filters')),
                ],
              ),
            ),
          ),

          // ─── Results ────────────────────────────────────────────────────
          _buildResultsSliver(state, sort, filters, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(String? initialOrigin, String? initialDestination, DateTime? initialDeparture) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0057B3), AppColors.brand, Color(0xFF5EA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, MediaQuery.of(context).padding.top + 56, AppSpacing.lg, AppSpacing.lg),
      child: FadeTransition(
        opacity: _headerAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Flights', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Compare fares across airlines for your next trip',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: AppSpacing.md),
            FlightSearchForm(
              initialOrigin: initialOrigin,
              initialDestination: initialDestination,
              initialDeparture: initialDeparture,
              onRouteChanged: (origin, destination) {
                final label = [origin, destination].where((s) => s.trim().isNotEmpty).join(' → ');
                if (label != _routeLabel) setState(() => _routeLabel = label);
              },
              onSearchStarted: _collapseForm,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FilterPanel(
        filters: ref.read(flightFiltersProvider),
        onChanged: (f) => ref.read(flightFiltersProvider.notifier).state = f,
      ),
    );
  }

  Widget _buildResultsSliver(FlightSearchState state, SortOption sort, SearchFilters filters, WidgetRef ref) {
    switch (state.status) {
      case SearchStatus.idle:
        return const SliverToBoxAdapter(child: Center(child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('Enter search criteria'),
        )));
      case SearchStatus.loading:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => const _FlightCardSkeleton(),
            childCount: 6,
          ),
        );
      case SearchStatus.success:
        var items = List.of(state.results);
        items = sortFlights(items, sort);
        if (!filters.isEmpty && filters.priceMin != null) {
          items = items.where((o) => o.price >= filters.priceMin!).toList();
        }
        if (!filters.isEmpty && filters.priceMax != null) {
          items = items.where((o) => o.price <= filters.priceMax!).toList();
        }
        if (!filters.isEmpty && filters.maxStops != null) {
          items = items.where((o) => (o.stops ?? 0) <= filters.maxStops!).toList();
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => FlightSearchCard(
              offer: items[i],
              onTap: () {
                ref.read(selectedOfferProvider.notifier).state = SelectedOffer(
                  offerId: items[i].id,
                  providerId: items[i].providerId,
                  providerName: items[i].providerName,
                  price: items[i].price,
                  currency: items[i].currency,
                  searchId: '',
                  offerType: 'flight',
                );
                context.push('/booking/review');
              },
            ),
            childCount: items.length,
          ),
        );
      case SearchStatus.empty:
        return const SliverToBoxAdapter(child: Center(child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No flights found'),
        )));
      case SearchStatus.error:
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

class _FlightCardSkeleton extends StatefulWidget {
  const _FlightCardSkeleton();

  @override
  State<_FlightCardSkeleton> createState() => _FlightCardSkeletonState();
}

class _FlightCardSkeletonState extends State<_FlightCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final opacity = 0.5 + _anim.value * 0.3;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 180, color: Colors.grey.withValues(alpha: opacity), margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 12, width: 240, color: Colors.grey.withValues(alpha: opacity * 0.7), margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 12, width: 120, color: Colors.grey.withValues(alpha: opacity * 0.5), margin: const EdgeInsets.only(bottom: 12)),
                    Row(
                      children: [
                        Container(height: 32, width: 32, decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: opacity),
                          borderRadius: BorderRadius.circular(AppSpacing.xl),
                        )),
                        const Spacer(),
                        Container(height: 28, width: 90, color: Colors.grey.withValues(alpha: opacity * 0.7)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
