import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/core/domain/models/search/hotel_search_params.dart';
import 'package:wetravellers/features/search/application/providers/hotel_car_providers.dart';
import 'package:wetravellers/features/search/application/controllers/hotel_search_controller.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/search/presentation/widgets/hotel_result_card.dart';

class HotelSearchPage extends ConsumerWidget {
  const HotelSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hotelSearchControllerProvider);
    
    // Extract initial search parameters from GoRouter state
    final goRouterState = GoRouterState.of(context);
    final extra = goRouterState.extra as Map<String, dynamic>?;
    final initialCity = extra?['city'] as String?;
    final initialCheckIn = extra?['checkIn'] as DateTime?;
    final initialCheckOut = extra?['checkOut'] as DateTime?;

    return Scaffold(
      appBar: AppBar(title: const Text('Hotels')),
      body: Column(
        children: [
          HotelSearchFormWidget(
            initialDestination: initialCity,
            initialCheckIn: initialCheckIn,
            initialCheckOut: initialCheckOut,
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildBody(context, state, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, HotelSearchState state, WidgetRef ref) {
    switch (state.status) {
      case HotelSearchStatus.idle:
        return const Center(child: Text('Enter search criteria'));
      case HotelSearchStatus.loading:
        return ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => Padding(padding: EdgeInsets.all(AppSpacing.md), child: Container(height: 120, color: Colors.grey.shade200)),
        );
      case HotelSearchStatus.success:
        return ListView.builder(
          itemCount: state.results.length,
          itemBuilder: (_, i) => HotelResultCard(offer: state.results[i]),
        );
      case HotelSearchStatus.empty:
        return const Center(child: Text('No hotels found'));
      case HotelSearchStatus.error:
        return Center(child: Text(state.errorMessage ?? 'Error'));
    }
  }
}

class HotelSearchFormWidget extends ConsumerStatefulWidget {
  final String? initialDestination;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;

  const HotelSearchFormWidget({
    super.key,
    this.initialDestination,
    this.initialCheckIn,
    this.initialCheckOut,
  });
  
  @override
  ConsumerState<HotelSearchFormWidget> createState() => _HotelSearchFormWidgetState();
}

class _HotelSearchFormWidgetState extends ConsumerState<HotelSearchFormWidget> {
  late final TextEditingController _dest;
  late DateTime _in;
  late DateTime _out;
  final int _rooms = 1;
  final int _adults = 2;

  @override
  void initState() {
    super.initState();
    _dest = TextEditingController(text: widget.initialDestination ?? '');
    _in = widget.initialCheckIn ?? DateTime.now().add(const Duration(days: 7));
    _out = widget.initialCheckOut ?? DateTime.now().add(const Duration(days: 10));
  }

  @override
  void dispose() {
    _dest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _dest, decoration: const InputDecoration(labelText: 'Destination')),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _dateTile('Check-in', _in, (d){ setState(()=> _in = d); })),
              Expanded(child: _dateTile('Check-out', _out, (d){ setState(()=> _out = d); })),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          ElevatedButton(
            onPressed: () {
              final params = HotelSearchParams(destination: _dest.text, checkIn: _in, checkOut: _out, rooms: _rooms, adults: _adults);
              ref.read(hotelSearchControllerProvider.notifier).search(params);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _dateTile(String title, DateTime date, ValueChanged<DateTime> onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(date.toLocal().toString().split(' ')[0]),
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (d != null) onChanged(d);
      },
    );
  }
}