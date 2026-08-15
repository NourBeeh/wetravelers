import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wetravellers/core/domain/models/search/flight_search_params.dart';
import 'package:wetravellers/features/search/application/providers/search_providers.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';

class FlightSearchForm extends ConsumerStatefulWidget {
  const FlightSearchForm({super.key});

  @override
  ConsumerState<FlightSearchForm> createState() => _FlightSearchFormState();
}

class _FlightSearchFormState extends ConsumerState<FlightSearchForm> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  DateTime _departure = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          TextField(controller: _originCtrl, decoration: const InputDecoration(labelText: 'Origin')),
          SizedBox(height: AppSpacing.sm),
          TextField(controller: _destCtrl, decoration: const InputDecoration(labelText: 'Destination')),
          SizedBox(height: AppSpacing.sm),
          ListTile(
            title: const Text('Departure date'),
            subtitle: Text('${_departure.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _departure,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _departure = picked);
            },
          ),
          SizedBox(height: AppSpacing.sm),
          ElevatedButton(
            onPressed: () {
              final params = FlightSearchParams(
                origin: _originCtrl.text,
                destination: _destCtrl.text,
                departureDate: _departure,
              );
              ref.read(flightSearchControllerProvider.notifier).search(params);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
