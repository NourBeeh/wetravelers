import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/features/search/presentation/widgets/flight_standard_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))));

FlightOffer _makeOffer({
  String id = 'f1',
  String title = 'Cairo to Dubai',
  String airline = 'EgyptAir',
  String flightNumber = 'MS 123',
  String origin = 'CAI',
  String destination = 'DXB',
  DateTime? departureTime,
  DateTime? arrivalTime,
  int? stops = 0,
  String? cabinClass = 'Economy',
  String? imageUrl,
  double price = 15000,
  String currency = 'EGP',
  Map<String, dynamic>? metadata,
}) =>
    FlightOffer(
      id: id,
      providerId: 'p1',
      providerName: 'Test Provider',
      title: title,
      airline: airline,
      flightNumber: flightNumber,
      origin: origin,
      destination: destination,
      departureTime: departureTime ?? DateTime.now().add(const Duration(days: 1, hours: 8)),
      arrivalTime: arrivalTime ?? DateTime.now().add(const Duration(days: 1, hours: 11)),
      stops: stops,
      cabinClass: cabinClass,
      imageUrl: imageUrl,
      price: price,
      currency: currency,
      metadata: metadata ?? {},
    );

void main() {
  group('FlightStandardCard', () {
    testWidgets('renders all core elements for direct flight', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer())));

      expect(find.text('EgyptAir'), findsOneWidget);
      expect(find.text('EG MS 123'), findsOneWidget); // Airline code + flight number
      expect(find.text('CAI'), findsOneWidget);
      expect(find.text('DXB'), findsOneWidget);
      expect(find.text('Non-stop'), findsOneWidget);
      expect(find.text('Economy'), findsOneWidget);
      expect(find.byType(CardPriceBlock), findsOneWidget);
      expect(find.byType(CardPrimaryAction), findsOneWidget);
      expect(find.text('Select Flight'), findsOneWidget);
    });

    testWidgets('renders stops correctly for one stop with airport', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        stops: 1,
        metadata: {'stopAirport': 'JED'},
      ))));

      expect(find.textContaining('1 stop'), findsOneWidget);
      expect(find.textContaining('JED'), findsOneWidget);
    });

    testWidgets('renders stops correctly for multiple stops', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        stops: 2,
      ))));

      expect(find.textContaining('2 stops'), findsOneWidget);
    });

    testWidgets('renders recommendation badge when in metadata', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'recommendation': 'cheapest',
      }))));

      expect(find.text('Cheapest'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('renders fastest recommendation badge', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'recommendation': 'fastest',
      }))));

      expect(find.text('Fastest'), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
    });

    testWidgets('renders best value recommendation badge', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'recommendation': 'best_value',
      }))));

      expect(find.text('Best Value'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders self-transfer warning', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'warnings': ['self_transfer'],
      }))));

      expect(find.text('Self-transfer'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('renders airport change warning', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'warnings': ['airport_change'],
      }))));

      expect(find.text('Airport change'), findsOneWidget);
      expect(find.byIcon(Icons.flight_land), findsOneWidget);
    });

    testWidgets('renders tight connection warning', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'warnings': ['tight_connection'],
      }))));

      expect(find.text('Tight connection'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('renders overnight warning', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'warnings': ['overnight'],
      }))));

      expect(find.text('Overnight'), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    });

    testWidgets('renders long layover warning', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'warnings': ['long_layover'],
      }))));

      expect(find.text('Long layover'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    });

    testWidgets('renders baggage when available in metadata', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'baggage': '1 bag (23kg)',
      }))));

      expect(find.textContaining('1 bag'), findsOneWidget);
    });

    testWidgets('does not render baggage when not in metadata', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer())));

      // Should not have baggage text unless it's in features from cabin/flight
      expect(find.textContaining('bag'), findsNothing);
    });

    testWidgets('renders price per traveler and total when available', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'pricePerTraveler': 18450,
        'totalPrice': 36900,
      }))));

      expect(find.textContaining('Per traveler'), findsOneWidget);
      expect(find.textContaining('Total'), findsOneWidget);
    });

    testWidgets('renders base price when no per-traveler/total in metadata', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        price: 15000,
        currency: 'EGP',
      ))));

      expect(find.text('EGP 15000'), findsOneWidget);
    });

    testWidgets('onTap callback fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(FlightStandardCard(
        offer: _makeOffer(),
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(BaseCard));
      expect(taps, 1);
    });

    testWidgets('disabled: reduced opacity, tap swallowed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(FlightStandardCard(
        offer: _makeOffer(),
        enabled: false,
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(BaseCard));
      expect(taps, 0);

      final opacity = tester.widget<Opacity>(find.descendant(
        of: find.byType(BaseCard),
        matching: find.byType(Opacity),
      ).first);
      expect(opacity.opacity, 0.55);
    });

    testWidgets('loading: shows progress indicator, tap blocked', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(FlightStandardCard(
        offer: _makeOffer(),
        loading: true,
        onTap: () => taps++,
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(BaseCard));
      expect(taps, 0);
    });

    testWidgets('flight number format: airline code + number', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        airline: 'Saudi Airlines',
        flightNumber: 'SV 456',
      ))));

      expect(find.text('SA SV 456'), findsOneWidget); // First 2 chars of airline + flight number
    });

    testWidgets('flight number only when airline not available', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        airline: '',
        flightNumber: '999',
      ))));

      expect(find.text('999'), findsOneWidget);
    });

    testWidgets('semantics label aggregates all available info', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(metadata: {
        'recommendation': 'cheapest',
        'warnings': ['self_transfer'],
        'baggage': '2 bags',
        'pricePerTraveler': 1000,
        'totalPrice': 2000,
      }))));

      final semantics = tester.getSemantics(find.byType(FlightStandardCard));
      expect(semantics.label, contains('EgyptAir'));
      expect(semantics.label, contains('EG MS 123')); // Airline code + flight number
      expect(semantics.label, contains('CAI'));
      expect(semantics.label, contains('DXB'));
      expect(semantics.label, contains('Non-stop'));
      expect(semantics.label, contains('Economy'));
      expect(semantics.label, contains('Cheapest'));
      expect(semantics.label, contains('Self-transfer'));
      expect(semantics.label, contains('Per traveler'));
      expect(semantics.label, contains('Total'));
    });

    testWidgets('long airline name ellipsizes', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        airline: 'Very Long Airline Name That Should Be Truncated Properly',
      ))));

      expect(find.byType(FlightStandardCard), findsOneWidget);
    });

    testWidgets('long airport names ellipsize', (tester) async {
      await tester.pumpWidget(_wrap(FlightStandardCard(offer: _makeOffer(
        origin: 'VeryLongOriginAirportCode',
        destination: 'VeryLongDestinationAirportCode',
      ))));

      expect(find.byType(FlightStandardCard), findsOneWidget);
    });

    testWidgets('dark mode renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: FlightStandardCard(offer: _makeOffer())),
      ));

      expect(find.byType(FlightStandardCard), findsOneWidget);
    });

    testWidgets('RTL layout renders without overflow', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: FlightStandardCard(offer: _makeOffer())),
      ));

      expect(find.byType(FlightStandardCard), findsOneWidget);
    });
  });
}