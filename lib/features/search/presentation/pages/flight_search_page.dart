import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/features/search/application/providers/search_providers.dart';
import 'package:wetravellers/features/search/application/controllers/flight_search_controller.dart';
import 'package:wetravellers/features/search/presentation/widgets/flight_search_form.dart';
import 'package:wetravellers/features/search/presentation/widgets/flight_result_card.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/search/presentation/widgets/sort_selector.dart';
import 'package:wetravellers/features/search/domain/sort_option.dart';
import 'package:wetravellers/features/search/application/sort_utils.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/features/search/domain/search_filters.dart';
import 'package:wetravellers/features/search/presentation/widgets/filter_panel.dart';

final flightSortProvider = StateProvider<SortOption>((ref) => SortOption.recommended);
final flightFiltersProvider = StateProvider<SearchFilters>((ref) => const SearchFilters());

class FlightSearchPage extends ConsumerWidget {
  const FlightSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: AppBar(title: const Text('Flights')),
      body: Column(
        children: [
          FlightSearchForm(
            initialOrigin: initialOrigin,
            initialDestination: initialDestination,
            initialDeparture: initialDeparture,
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                SortSelector(selected: sort, onChanged: (v) => ref.read(flightSortProvider.notifier).state = v),
                const Spacer(),
                TextButton(onPressed: () => _showFilters(context, ref), child: const Text('Filters')),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(state, sort, filters, ref),
          ),
        ],
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

  Widget _buildBody(FlightSearchState state, SortOption sort, SearchFilters filters, WidgetRef ref) {
    switch (state.status) {
      case SearchStatus.idle:
        return const Center(child: Text('Enter search criteria'));
      case SearchStatus.loading:
        return ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Container(height: 100, color: Colors.grey.shade200),
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
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => Semantics(
            button: true,
            label: 'Select flight ${items[i].airline} ${items[i].origin} to ${items[i].destination}',
            child: GestureDetector(
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
                Navigator.of(ref.context).pushNamed('/booking/review');
              },
              child: FlightResultCard(offer: items[i]),
            ),
          ),
        );
      case SearchStatus.empty:
        return const Center(child: Text('No flights found'));
      case SearchStatus.error:
        return Center(
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
        );
    }
  }
}