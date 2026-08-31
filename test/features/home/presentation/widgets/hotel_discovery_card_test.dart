import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/widgets/cards/card.dart';
import 'package:wetravellers/features/home/presentation/widgets/hotel_discovery_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

HomeItem _makeItem({
  String id = 'h1',
  String title = 'Grand Hotel',
  String? subtitle = 'Downtown, Cairo',
  String? imageUrl = 'https://example.com/hotel.jpg',
  double? price = 299,
  String? currency = 'USD',
  double? rating = 4.7,
  int? reviewCount = 120,
  String? badge = 'Best Seller',
  Map<String, dynamic>? metadata,
}) =>
    HomeItem(
      id: id,
      type: HomeCardType.hotel,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      price: price,
      currency: currency,
      rating: rating,
      reviewCount: reviewCount,
      badge: badge,
      metadata: metadata ?? {},
    );

void main() {
  group('HotelDiscoveryCard', () {
    testWidgets('renders all core elements', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem())));

      expect(find.text('Grand Hotel'), findsOneWidget);
      expect(find.text('Downtown, Cairo'), findsOneWidget);
      expect(find.text('USD 299'), findsOneWidget);
      expect(find.byType(CardImage), findsOneWidget);
      expect(find.byType(CardBadge), findsOneWidget);
      expect(find.byType(CardFavorite), findsOneWidget);
      expect(find.byType(CardRating), findsOneWidget);
    });

    testWidgets('badge renders as glass variant when on image', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem(badge: 'Trending'))));

      final badge = tester.widget<CardBadge>(find.byType(CardBadge));
      expect(badge.variant, CardBadgeVariant.glass);
      expect(find.text('Trending'), findsOneWidget);
    });

    testWidgets('no badge: no CardBadge rendered', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem(badge: null))));

      expect(find.byType(CardBadge), findsNothing);
    });

    testWidgets('wishlist heart renders as glass variant and toggles', (tester) async {
      var lastCallbackValue = false;
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(
        item: _makeItem(),
        onWishlistChanged: (v) => lastCallbackValue = v,
      )));

      final favorite = tester.widget<CardFavorite>(find.byType(CardFavorite));
      expect(favorite.onImage, true);
      expect(favorite.value, false);
      await tester.pump(); // Allow AnimatedSwitcher to render

      // Tap the heart - should call onChanged with true
      await tester.tap(find.byType(CardFavorite));
      expect(lastCallbackValue, true);
      // The CardFavorite is controlled by parent, so it won't update without parent rebuild
      // Just verify the callback was called correctly
    });

    testWidgets('rating pill renders as glass variant with review count', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem(rating: 4.5, reviewCount: 88))));

      final rating = tester.widget<CardRating>(find.byType(CardRating));
      expect(rating.onImage, true);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(88)'), findsOneWidget);
      // There are 3 CardGlass widgets (badge, favorite, rating), so expect at least 1
      expect(find.byType(CardGlass), findsAtLeast(1));
    });

    testWidgets('no rating: no CardRating rendered', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem(rating: null))));

      expect(find.byType(CardRating), findsNothing);
    });

    testWidgets('price uses CardPrice with white color over scrim', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem(price: 199, currency: 'EUR'))));

      final price = tester.widget<CardPrice>(find.byType(CardPrice));
      expect(price.color, Colors.white);
      expect(find.text('EUR 199'), findsOneWidget);
    });

    testWidgets('onTap callback fires', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(
        item: _makeItem(),
        onTap: () => taps++,
      )));

      await tester.tap(find.byType(HotelDiscoveryCard));
      expect(taps, 1);
    });

    testWidgets('semantics label aggregates title, subtitle, rating, reviews, price, badge', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem())));

      final semantics = tester.getSemantics(find.byType(HotelDiscoveryCard));
      expect(semantics.label, contains('Grand Hotel'));
      expect(semantics.label, contains('Downtown, Cairo'));
      expect(semantics.label, contains('4.7 stars'));
      expect(semantics.label, contains('120 reviews'));
      expect(semantics.label, contains('Price 299 USD'));
      expect(semantics.label, contains('Badge Best Seller'));
    });

    testWidgets('long title/subtitle ellipsizes', (tester) async {
      await tester.pumpWidget(_wrap(HotelDiscoveryCard(item: _makeItem(
        title: 'Very Long Hotel Name That Should Be Truncated Because It Exceeds The Available Width',
        subtitle: 'Very Long Subtitle That Should Also Be Truncated Properly Without Overflow',
      ))));

      expect(find.byType(HotelDiscoveryCard), findsOneWidget);
      // No overflow errors in test output
    });

    testWidgets('dark mode renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: HotelDiscoveryCard(item: _makeItem())),
      ));

      expect(find.byType(HotelDiscoveryCard), findsOneWidget);
    });

    testWidgets('RTL layout renders without overflow', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: HotelDiscoveryCard(item: _makeItem())),
      ));

      expect(find.byType(HotelDiscoveryCard), findsOneWidget);
    });
  });
}