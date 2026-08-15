import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Cars')),
      body: Column(
        children: [
          const CarSearchFormWidget(),
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
  const CarSearchFormWidget({super.key});
  @override
  ConsumerState<CarSearchFormWidget> createState() => _CarSearchFormWidgetState();
}

class _CarSearchFormWidgetState extends ConsumerState<CarSearchFormWidget> {
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();
  DateTime _pickupTime = DateTime.now().add(const Duration(days: 1));
  DateTime _dropoffTime = DateTime.now().add(const Duration(days: 2));

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
