import 'package:flutter/material.dart';
import 'package:wetravellers/features/bag/domain/trip.dart';

class TripDetailsPage extends StatelessWidget {
  final TripSummary trip;
  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trip.destination)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${trip.type}', style: Theme.of(context).textTheme.titleMedium),
            Text('Status: ${trip.status}'),
            Text('Dates: ${trip.startDate.toLocal()} - ${trip.endDate.toLocal()}'),
            Text('Provider: ${trip.providerName}'),
            Text('Reference: ${trip.bookingReference}'),
            Text('Total: ${trip.total} ${trip.currency}'),
          ],
        ),
      ),
    );
  }
}
