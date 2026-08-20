import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/core/domain/models/search/car_search_params.dart';
import 'package:wetravellers/features/search/application/providers/hotel_car_providers.dart';
import 'package:wetravellers/features/search/application/controllers/car_search_controller.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/search/presentation/widgets/car_result_card.dart';

class CarSearchPage extends ConsumerWidget {
  const CarSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(carSearchControllerProvider);
    
    // Extract initial search parameters from GoRouter state
    final goRouterState = GoRouterState.of(context);
    final extra = goRouterState.extra as Map<String, dynamic>?;
    final initialPickupLocation = extra?['pickupLocation'] as String?;
    final initialDropoffLocation = extra?['dropoffLocation'] as String?;
    final initialPickupDate = extra?['pickupDate'] as DateTime?;

    return Scaffold(
      appBar: AppBar(title: const Text('Cars')),
      body: Column(
        children: [
          CarSearchFormWidget(
            initialPickupLocation: initialPickupLocation,
            initialDropoffLocation: initialDropoffLocation,
            initialPickupTime: initialPickupDate,
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(CarSearchState state) {
    switch (state.status) {
      case CarSearchStatus.idle:
        return const Center(child: Text('Enter search criteria'));
      case CarSearchStatus.loading:
        return ListView.builder(itemCount: 6, itemBuilder: (_, __) => Padding(padding: EdgeInsets.all(AppSpacing.md), child: Container(height: 100, color: Colors.grey.shade200)));
      case CarSearchStatus.success:
        return ListView.builder(itemCount: state.results.length, itemBuilder: (_, i) => CarResultCard(offer: state.results[i]));
      case CarSearchStatus.empty:
        return const Center(child: Text('No cars found'));
      case CarSearchStatus.error:
        return Center(child: Text(state.errorMessage ?? 'Error'));
    }
  }
}

class CarSearchFormWidget extends ConsumerStatefulWidget {
  final String? initialPickupLocation;
  final String? initialDropoffLocation;
  final DateTime? initialPickupTime;

  const CarSearchFormWidget({
    super.key,
    this.initialPickupLocation,
    this.initialDropoffLocation,
    this.initialPickupTime,
  });
  
  @override
  ConsumerState<CarSearchFormWidget> createState() => _CarSearchFormWidgetState();
}

class _CarSearchFormWidgetState extends ConsumerState<CarSearchFormWidget> {
  late final TextEditingController _pickup;
  late final TextEditingController _dropoff;
  late DateTime _pickupTime;
  late DateTime _dropoffTime;

  @override
  void initState() {
    super.initState();
    _pickup = TextEditingController(text: widget.initialPickupLocation ?? '');
    _dropoff = TextEditingController(text: widget.initialDropoffLocation ?? '');
    _pickupTime = widget.initialPickupTime ?? DateTime.now().add(const Duration(days: 1));
    _dropoffTime = DateTime.now().add(const Duration(days: 2));
  }

  @override
  void dispose() {
    _pickup.dispose();
    _dropoff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _pickup, decoration: const InputDecoration(labelText: 'Pickup location')),
          SizedBox(height: AppSpacing.sm),
          TextField(controller: _dropoff, decoration: const InputDecoration(labelText: 'Dropoff location')),
          SizedBox(height: AppSpacing.sm),
          ListTile(title: const Text('Pickup'), subtitle: Text(_pickupTime.toString()), onTap: () async { final d = await showDatePicker(context: context, initialDate: _pickupTime, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setState(()=> _pickupTime = d); }),
          ListTile(title: const Text('Dropoff'), subtitle: Text(_dropoffTime.toString()), onTap: () async { final d = await showDatePicker(context: context, initialDate: _dropoffTime, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setState(()=> _dropoffTime = d); }),
          ElevatedButton(
            onPressed: () {
              final params = CarSearchParams(pickupLocation: _pickup.text, dropoffLocation: _dropoff.text, pickupDateTime: _pickupTime, dropoffDateTime: _dropoffTime);
              ref.read(carSearchControllerProvider.notifier).search(params);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}