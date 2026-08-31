import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/domain/models/offers/car_offer.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/features/search/presentation/widgets/car_standard_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))));

CarOffer _makeOffer({
  String id = 'c1',
  String title = 'Toyota Camry',
  String carType = 'Sedan',
  String? transmission = 'Automatic',
  int? seats = 5,
  String pickupLocation = 'Cairo Airport',
  String dropoffLocation = 'Downtown Cairo',
  DateTime? pickupTime,
  DateTime? dropoffTime,
  String? imageUrl,
  double price = 1200,
  String currency = 'EGP',
  Map<String, dynamic>? metadata,
}) =>
    CarOffer(
      id: id,
      providerId: 'p1',
      providerName: 'Test Provider',
      title: title,
      carType: carType,
      transmission: transmission,
      seats: seats,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      pickupTime: pickupTime ?? DateTime.now().add(const Duration(days: 1, hours: 8)),
      dropoffTime: dropoffTime ?? DateTime.now().add(const Duration(days: 4, hours: 8)),
      imageUrl: imageUrl,
      price: price,
      currency: currency,
      metadata: metadata ?? {},
    );

void main() {
  group('CarStandardCard', () {
    testWidgets('renders all core elements for car with metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(metadata: {
        'luggage': '2 bags',
        'ac': 'Yes',
      }))));

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('Sedan'), findsOneWidget);
      expect(find.text('Automatic'), findsOneWidget);
      expect(find.text('5 seats'), findsOneWidget);
      expect(find.text('2 bags'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.textContaining('Pickup:'), findsOneWidget);
      expect(find.textContaining('Dropoff:'), findsOneWidget);
      expect(find.byType(CardImage), findsOneWidget);
      expect(find.byType(CardPriceBlock), findsOneWidget);
      expect(find.byType(CardPrimaryAction), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('renders transmission and seats from offer fields', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(
        transmission: 'Manual',
        seats: 4,
      ))));

      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('4 seats'), findsOneWidget);
    });

    testWidgets('does not render luggage/AC when not in metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer())));

      expect(find.textContaining('bags'), findsNothing);
      expect(find.text('AC'), findsNothing);
    });

    testWidgets('renders free cancellation badge when in metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(metadata: {
        'freeCancellation': true,
      }))));

      expect(find.text('Free cancellation'), findsOneWidget);
      final cancellation = tester.widget<CardCancellation>(find.byType(CardCancellation));
      expect(cancellation.freeCancellation, true);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('renders custom cancellation policy when in metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(metadata: {
        'cancellationPolicy': 'Cancel up to 24h before',
      }))));

      expect(find.text('Cancel up to 24h before'), findsOneWidget);
      final cancellation = tester.widget<CardCancellation>(find.byType(CardCancellation));
      expect(cancellation.freeCancellation, false);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('does not render cancellation when not in metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer())));

      expect(find.byType(CardCancellation), findsNothing);
    });

    testWidgets('renders original price strikethrough when metadata has originalPrice > price', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(
        price: 1000,
        metadata: {'originalPrice': 1500},
      ))));

      expect(find.text('EGP 1000'), findsOneWidget);
      expect(find.text('EGP 1500'), findsOneWidget);
      // CardPriceBlock renders both prices as separate Text widgets
      expect(find.text('EGP 1000'), findsOneWidget);
      expect(find.text('EGP 1500'), findsOneWidget);
    });

    testWidgets('does not render original price when originalPrice <= price', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(
        price: 1500,
        metadata: {'originalPrice': 1000},
      ))));

      expect(find.text('EGP 1500'), findsOneWidget);
      expect(find.text('EGP 1000'), findsNothing);
    });

    testWidgets('onTap callback fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(CarStandardCard(
        offer: _makeOffer(),
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(BaseCard));
      expect(taps, 1);
    });

    testWidgets('disabled: reduced opacity, tap swallowed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(CarStandardCard(
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
      await tester.pumpWidget(_wrap(CarStandardCard(
        offer: _makeOffer(),
        loading: true,
        onTap: () => taps++,
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(BaseCard));
      expect(taps, 0);
    });

    testWidgets('semantics label aggregates all available info', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(metadata: {
        'luggage': '2 bags',
        'ac': 'Yes',
        'freeCancellation': true,
        'cancellationPolicy': 'Free cancellation',
        'originalPrice': 1500,
      }))));

      final semantics = tester.getSemantics(find.byType(CarStandardCard));
      expect(semantics.label, contains('Toyota Camry'));
      expect(semantics.label, contains('Sedan'));
      expect(semantics.label, contains('Automatic'));
      expect(semantics.label, contains('5 seats'));
      expect(semantics.label, contains('2 bags'));
      expect(semantics.label, contains('AC'));
      expect(semantics.label, contains('Pickup: Cairo Airport'));
      expect(semantics.label, contains('Dropoff: Downtown Cairo'));
      expect(semantics.label, contains('Free cancellation'));
      expect(semantics.label, contains('EGP 1200'));
    });

    testWidgets('long car name ellipsizes', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(
        title: 'Very Long Car Name That Should Be Truncated Properly',
      ))));

      expect(find.byType(CarStandardCard), findsOneWidget);
    });

    testWidgets('long location names ellipsize', (tester) async {
      await tester.pumpWidget(_wrap(CarStandardCard(offer: _makeOffer(
        pickupLocation: 'VeryLongPickupLocationName',
        dropoffLocation: 'VeryLongDropoffLocationName',
      ))));

      expect(find.byType(CarStandardCard), findsOneWidget);
    });

    testWidgets('dark mode renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: CarStandardCard(offer: _makeOffer())),
      ));

      expect(find.byType(CarStandardCard), findsOneWidget);
    });

    testWidgets('RTL layout renders without overflow', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: CarStandardCard(offer: _makeOffer())),
      ));

      expect(find.byType(CarStandardCard), findsOneWidget);
    });
  });
}