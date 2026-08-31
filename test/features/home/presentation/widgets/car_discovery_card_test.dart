import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/features/home/presentation/widgets/car_discovery_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 300, height: 250, child: child))));

HomeItem _makeItem({
  String id = 'c1',
  String title = 'Toyota Camry',
  String? imageUrl,
  double? price = 1200,
  String? currency = 'EGP',
  Map<String, dynamic>? metadata,
}) =>
    HomeItem(
      id: id,
      type: HomeCardType.car,
      title: title,
      imageUrl: imageUrl,
      price: price,
      currency: currency,
      metadata: metadata ?? {},
    );

void main() {
  group('CarDiscoveryCard', () {
    testWidgets('renders all core elements for car with metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(
        imageUrl: null,
        metadata: {
          'type': 'Sedan',
          'transmission': 'Automatic',
          'seats': 5,
          'luggage': '2 bags',
          'ac': 'Yes',
        },
      ))));

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('Sedan'), findsAtLeast(1)); // Appears in badge and scrim
      expect(find.text('Automatic'), findsOneWidget);
      expect(find.text('5 seats'), findsOneWidget);
      expect(find.text('2 bags'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('EGP 1200'), findsOneWidget);
      expect(find.byType(CardImage), findsOneWidget);
      expect(find.byType(CardPrice), findsOneWidget);
      expect(find.byType(CardFavorite), findsOneWidget);
      expect(find.byType(CardBadge), findsOneWidget); // category badge
    });

    testWidgets('renders category badge as glass variant', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(
        imageUrl: null,
        metadata: {'type': 'SUV'},
      ))));

      expect(find.text('SUV'), findsAtLeast(1)); // Badge + scrim
      final badge = tester.widget<CardBadge>(find.byType(CardBadge).first);
      expect(badge.variant, CardBadgeVariant.glass);
      expect(badge.icon, Icons.directions_car);
    });

    testWidgets('does not render category badge when not in metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(imageUrl: null))));

      expect(find.byType(CardBadge), findsNothing);
    });

    testWidgets('wishlist heart renders as glass variant and toggles', (tester) async {
      var lastCallbackValue = false;
      await tester.pumpWidget(_wrap(CarDiscoveryCard(
        item: _makeItem(
          imageUrl: null,
          metadata: {
            'type': 'Sedan',
            'transmission': 'Automatic',
            'seats': 5,
          },
        ),
        onWishlistChanged: (v) => lastCallbackValue = v,
      )));

      final favorite = tester.widget<CardFavorite>(find.byType(CardFavorite));
      expect(favorite.onImage, true);
      expect(favorite.value, false);
      await tester.pump();

      await tester.tap(find.byType(CardFavorite));
      expect(lastCallbackValue, true);
    });

    testWidgets('onTap callback fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(CarDiscoveryCard(
        item: _makeItem(
          imageUrl: null,
          metadata: {'type': 'Sedan'},
        ),
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(CarDiscoveryCard));
      expect(taps, 1);
    });

    testWidgets('price uses CardPrice with white color over scrim', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(
        price: 2500,
        currency: 'EGP',
        imageUrl: null,
        metadata: {'type': 'SUV'},
      ))));

      final price = tester.widget<CardPrice>(find.byType(CardPrice));
      expect(price.color, Colors.white);
      expect(find.text('EGP 2500'), findsOneWidget);
    });

    testWidgets('does not render transmission/seats/luggage/AC when not in metadata', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(
        imageUrl: null,
        metadata: {'type': 'Sedan'},
      ))));

      expect(find.text('Automatic'), findsNothing);
      expect(find.text('seats'), findsNothing);
      expect(find.text('bags'), findsNothing);
      expect(find.text('AC'), findsNothing);
    });

    testWidgets('semantics label aggregates all info', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(
        imageUrl: null,
        metadata: {
          'type': 'Sedan',
          'transmission': 'Automatic',
          'seats': 5,
          'luggage': '2 bags',
          'ac': 'Yes',
        },
      ))));

      final semantics = tester.getSemantics(find.byType(CarDiscoveryCard));
      expect(semantics.label, contains('Toyota Camry'));
      expect(semantics.label, contains('Sedan'));
      expect(semantics.label, contains('Automatic'));
      expect(semantics.label, contains('5 seats'));
      expect(semantics.label, contains('2 bags'));
      expect(semantics.label, contains('AC'));
      expect(semantics.label, contains('Price 1200 EGP'));
    });

    testWidgets('long car name ellipsizes in scrim', (tester) async {
      await tester.pumpWidget(_wrap(CarDiscoveryCard(item: _makeItem(
        imageUrl: null,
        title: 'Very Long Car Name That Should Be Truncated',
        metadata: {'type': 'Sedan'},
      ))));

      expect(find.byType(CarDiscoveryCard), findsOneWidget);
    });

    testWidgets('dark mode renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: CarDiscoveryCard(item: _makeItem(imageUrl: null, metadata: {'type': 'Sedan'}))),
      ));

      expect(find.byType(CarDiscoveryCard), findsOneWidget);
    });

    testWidgets('RTL layout renders without overflow', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: CarDiscoveryCard(item: _makeItem(imageUrl: null, metadata: {'type': 'Sedan'}))),
      ));

      expect(find.byType(CarDiscoveryCard), findsOneWidget);
    });
  });
}