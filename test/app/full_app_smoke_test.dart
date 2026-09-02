import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'package:wetravellers/app/app.dart';
import 'package:wetravellers/core/storage/offline_cache.dart';
import 'package:wetravellers/core/storage/offline_cache_providers.dart';
import 'package:wetravellers/app/widgets/app_bottom_nav.dart';

void main() {
  setUpAll(() {
    // The onboarding controller opens a Hive settings box on boot.
    Hive.init(Directory.systemTemp.createTempSync('wt_app_smoke').path);
  });

  testWidgets('full app boots and navigates all tabs without exceptions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          offlineCacheProvider.overrideWithValue(MemoryOfflineCache()),
        ],
        child: const WeTravellersApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Home tab renders
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);

    // Navigate through every tab — looking for runtime exceptions
    await tester.tap(find.text('Search'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Groups'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}
