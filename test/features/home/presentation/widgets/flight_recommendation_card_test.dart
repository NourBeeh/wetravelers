import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/features/home/presentation/widgets/flight_recommendation_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 300, height: 250, child: child))));

HomeItem _makeItem({
  String id = 'f1',
  String title = 'EgyptAir',
  String? subtitle,
  String? imageUrl,
  double? price = 15000,
  String? currency = 'EGP',
  Map<String, dynamic>? metadata,
}) =>
    HomeItem(
      id: id,
      type: HomeCardType.flight,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      price: price,
      currency: currency,
      metadata: metadata ?? {},
    );

void main() {
  group('FlightRecommendationCard', () {
    testWidgets('renders all core elements for direct flight', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(
        imageUrl: null,
        metadata: {
          'origin': 'CAI',
          'destination': 'DXB',
          'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
          'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
          'airline': 'EgyptAir',
          'flightNumber': 'MS 123',
          'stops': 0,
          'cabinClass': 'Economy',
          'baggage': '1 bag (23kg)',
        },
      ))));

      expect(find.text('CAI'), findsOneWidget);
      expect(find.text('DXB'), findsOneWidget);
      expect(find.text('EgyptAir'), findsOneWidget);
      expect(find.text('MS 123'), findsOneWidget);
      expect(find.textContaining('Economy'), findsOneWidget);
      expect(find.textContaining('1 bag'), findsOneWidget);
      expect(find.text('EGP 15000'), findsOneWidget);
      expect(find.byType(CardImage), findsOneWidget);
      expect(find.byType(CardPrice), findsOneWidget);
      expect(find.byType(CardFavorite), findsOneWidget);
    });

    testWidgets('renders cheapest recommendation badge', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        'recommendation': 'cheapest',
      }))));

      expect(find.text('Cheapest'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      // Badge should be glass variant
      final badge = tester.widget<CardBadge>(find.byType(CardBadge).first);
      expect(badge.variant, CardBadgeVariant.glass);
    });

    testWidgets('renders fastest recommendation badge', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        'recommendation': 'fastest',
      }))));

      expect(find.text('Fastest'), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
    });

    testWidgets('renders best value recommendation badge', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        'recommendation': 'best_value',
      }))));

      expect(find.text('Best Value'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders one stop with airport', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 13)).toIso8601String(),
        'stops': 1,
        'stopAirport': 'JED',
      }))));

      expect(find.textContaining('1 stop'), findsOneWidget);
      expect(find.textContaining('JED'), findsOneWidget);
      // Stop badge should be glass variant and centered
      final badges = tester.widgetList<CardBadge>(find.byType(CardBadge));
      final stopBadge = badges.firstWhere((b) => b.label?.contains('stop') == true);
      expect(stopBadge.variant, CardBadgeVariant.glass);
    });

    testWidgets('renders multiple stops', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 15)).toIso8601String(),
        'stops': 2,
      }))));

      expect(find.textContaining('2 stops'), findsOneWidget);
    });

    testWidgets('wishlist heart renders as glass variant and toggles', (tester) async {
      var lastCallbackValue = false;
      await tester.pumpWidget(_wrap(FlightRecommendationCard(
        item: _makeItem(
          imageUrl: null,
          metadata: {
            'origin': 'CAI',
            'destination': 'DXB',
            'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
            'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
          },
        ),
        onWishlistChanged: (v) => lastCallbackValue = v,
      )));

      final favorite = tester.widget<CardFavorite>(find.byType(CardFavorite));
      expect(favorite.onImage, true);
      expect(favorite.value, false);
      await tester.pump(); // Allow AnimatedSwitcher to render

      // Tap the heart - should call onChanged with true
      await tester.tap(find.byType(CardFavorite));
      expect(lastCallbackValue, true);
    });

    testWidgets('onTap callback fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(FlightRecommendationCard(
        item: _makeItem(metadata: {
          'origin': 'CAI',
          'destination': 'DXB',
          'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
          'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        }),
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(FlightRecommendationCard));
      expect(taps, 1);
    });

    testWidgets('price uses CardPrice with white color over scrim', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(
        price: 25000,
        currency: 'EGP',
        metadata: {
          'origin': 'CAI',
          'destination': 'DXB',
          'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
          'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        },
      ))));

      final price = tester.widget<CardPrice>(find.byType(CardPrice));
      expect(price.color, Colors.white);
      expect(find.text('EGP 25000'), findsOneWidget);
    });

    testWidgets('semantics label aggregates all info', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        'recommendation': 'fastest',
        'airline': 'EgyptAir',
        'flightNumber': 'MS 123',
        'stops': 0,
        'cabinClass': 'Business',
        'baggage': '2 bags',
      }))));

      final semantics = tester.getSemantics(find.byType(FlightRecommendationCard));
      expect(semantics.label, contains('Recommended flight'));
      expect(semantics.label, contains('Fastest'));
      expect(semantics.label, contains('EgyptAir'));
      expect(semantics.label, contains('Flight MS 123'));
      expect(semantics.label, contains('CAI'));
      expect(semantics.label, contains('DXB'));
      expect(semantics.label, contains('Business'));
      expect(semantics.label, contains('2 bags'));
      expect(semantics.label, contains('Price 15000 EGP'));
    });

    testWidgets('long airline name ellipsizes in scrim', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        'airline': 'Very Long Airline Name That Should Be Truncated',
      }))));

      expect(find.byType(FlightRecommendationCard), findsOneWidget);
    });

    testWidgets('long airport names ellipsize in route line', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'VeryLongOriginCode',
        'destination': 'VeryLongDestinationCode',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
      }))));

      expect(find.byType(FlightRecommendationCard), findsOneWidget);
    });

    testWidgets('dark mode renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: FlightRecommendationCard(item: _makeItem(metadata: {
          'origin': 'CAI',
          'destination': 'DXB',
          'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
          'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        }))),
      ));

      expect(find.byType(FlightRecommendationCard), findsOneWidget);
    });

    testWidgets('RTL layout renders without overflow', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: FlightRecommendationCard(item: _makeItem(metadata: {
          'origin': 'CAI',
          'destination': 'DXB',
          'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
          'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
        }))),
      ));

      expect(find.byType(FlightRecommendationCard), findsOneWidget);
    });

    testWidgets('no recommendation badge when not in metadata', (tester) async {
      await tester.pumpWidget(_wrap(FlightRecommendationCard(item: _makeItem(metadata: {
        'origin': 'CAI',
        'destination': 'DXB',
        'departureTime': DateTime.now().add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'arrivalTime': DateTime.now().add(const Duration(days: 1, hours: 11)).toIso8601String(),
      }))));

      // Should have badges for wishlist, airline logo (not CardBadge)
      // Recommendation badge should not exist
      final recommendationBadges = tester.widgetList<CardBadge>(find.byType(CardBadge))
          .where((b) => b.label == 'Cheapest' || b.label == 'Fastest' || b.label == 'Best Value');
      expect(recommendationBadges, isEmpty);
    });
  });
}