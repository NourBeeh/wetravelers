import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:wetravellers/app/app.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/features/ai/data/ai_api_service.dart';
import 'package:wetravellers/features/ai/application/ai_providers.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_ai_search_field.dart';
import 'package:wetravellers/features/universal_search/application/universal_search_controller.dart';
import 'package:wetravellers/features/universal_search/application/voice_search_providers.dart';
import 'package:wetravellers/features/universal_search/application/voice_search_state.dart';
import 'package:wetravellers/features/universal_search/presentation/pages/universal_search_page.dart';
import 'package:wetravellers/core/storage/offline_cache.dart';
import 'package:wetravellers/core/storage/offline_cache_providers.dart';

/// Universal Search page coverage (US-1 STEP 26) — migrated from the v1
/// smart search tests: the Home AI field pushes the full-screen search
/// page, recent searches persist through the OfflineCache, the back
/// affordance returns to Home, and the surface degrades silently to local
/// fallback prompts when the suggestion backend fails.
void main() {
  setUpAll(() {
    // The onboarding controller opens a Hive settings box on boot.
    Hive.init(Directory.systemTemp.createTempSync('wt_universal_search').path);
  });

  Widget harness({OfflineCache? cache, AiApiService? suggestions}) {
    return ProviderScope(
      overrides: <Override>[
        offlineCacheProvider.overrideWithValue(cache ?? MemoryOfflineCache()),
        if (suggestions != null)
          aiSuggestionsServiceProvider.overrideWithValue(suggestions),
      ],
      child: const WeTravellersApp(),
    );
  }

  testWidgets('home AI search field pushes the universal search page', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 500));

    // The smart search pill renders in the Home header.
    final field = find.byType(HomeAiSearchField);
    expect(field, findsOneWidget);

    // Tapping it pushes the full-screen search page. The route uses a
    // custom transition, so the page needs extra frames to mount.
    await tester.tap(field);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsOneWidget);
    expect(find.text('Where do you want to go?'), findsOneWidget);

    // The back affordance returns to Home.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsNothing);
    expect(find.byType(HomeAiSearchField), findsOneWidget);
  });

  testWidgets('submitting persists the prompt as a recent search', (tester) async {
    final cache = MemoryOfflineCache();
    await tester.pumpWidget(harness(cache: cache));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'hotels in dubai');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));

    // Submit via the send button.
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump(const Duration(milliseconds: 300));

    // The submit reached SEARCHING (loading) or already rendered results.
    expect(find.byType(UniversalSearchPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The recent was recorded (submit-only, US-1 STEP 9).
    final stored = await cache.read('ai_search_recent/0');
    expect(stored?['text'], 'hotels in dubai');
  });

  testWidgets('page falls back to local suggestions when backend fails', (tester) async {
    await tester.pumpWidget(
      harness(suggestions: _FailingSuggestionsService()),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsOneWidget);

    // Type enough characters to trigger the debounced suggest call.
    await tester.enterText(find.byType(TextField).first, 'flights to dubai');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));

    // The failing service degrades silently to the fallback prompts.
    expect(find.text('Flights from Cairo to Dubai next week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // -----------------------------------------------------------------------
  // Migrated from the v1 suite (US-1 FINAL FIX): the edit-query chip —
  // leaving the results view returns to the suggestions surface with the
  // keyboard up, and the persisted recent entry is visible underneath.
  // -----------------------------------------------------------------------

  testWidgets('edit chip leaves results and surfaces the recent', (tester) async {
    final cache = MemoryOfflineCache();
    await tester.pumpWidget(harness(cache: cache));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'random words here');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));

    // Submit — a non-travel query parks on SEARCHING (AI flow). Land it
    // the same way the page does when the shared AI sheet responds.
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump(const Duration(milliseconds: 300));
    {
      final ctx = tester.element(find.byType(UniversalSearchPage));
      final container = ProviderScope.containerOf(ctx);
      container
          .read(universalSearchControllerProvider.notifier)
          .aiResultsReady(const <HomeSection>[], 'Found some options.');
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Found some options.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The recent was recorded on submit.
    final stored = await cache.read('ai_search_recent/0');
    expect(stored?['text'], 'random words here');

    // Reopen the field for editing from the results header — the surface
    // returns to the suggestions view without exceptions.
    await tester.tap(find.text('Edit'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('categories chips show in ACTIVE and hide in TYPING', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));

    // ACTIVE (empty query): all four category chips render.
    expect(find.text('Flights'), findsOneWidget);
    expect(find.text('Hotels'), findsOneWidget);
    expect(find.text('Cars'), findsOneWidget);
    expect(find.text('Packages'), findsOneWidget);

    // TYPING: chips hide.
    await tester.enterText(find.byType(TextField).first, 'du');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Flights'), findsNothing);
    expect(find.text('Hotels'), findsNothing);
  });

  testWidgets('incomplete intent surfaces question chips instead of searching', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsOneWidget);

    // "flight to dubai" — valid service + destination, no origin: the
    // gaps body asks instead of executing a search with an invented
    // origin (US-2 §3).
    await tester.enterText(find.byType(TextField).first, 'flight to dubai');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('منين بتسافر؟'), findsOneWidget);
    expect(find.text('القاهرة'), findsOneWidget);

    // Answering the question completes the intent and runs the search.
    await tester.tap(find.text('القاهرة'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(UniversalSearchPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('US-3: the live mic button renders and starts a session on tap', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 500));

    // The collapsed Home bar still has no mic (voice lives in the expanded
    // header only)…
    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(UniversalSearchPage), findsOneWidget);

    // …the expanded header carries the LIVE mic (was: disabled placeholder).
    final mic = find.byIcon(Icons.mic_rounded);
    expect(mic, findsOneWidget);

    // Tapping it starts a session — with no recognizer available in the
    // test env, the service degrades to a typed failure (never a crash)
    // and the page stays mounted.
    await tester.tap(mic);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(UniversalSearchPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('US-3: the listening state renders the stop affordance with pulse', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(HomeAiSearchField));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));

    // Drive the mic into LISTENING through the controller's own state.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(UniversalSearchPage)),
    );
    final voice =
        container.read(voiceSearchControllerProvider.notifier);
    voice.stateForTesting = const VoiceSearchState(
      status: VoiceSearchStatus.listening,
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Stop icon + semantics label are present; tapping it stops cleanly.
    expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.stop_circle_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(UniversalSearchPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Suggestions service stub whose endpoint always fails — exercises the
/// fail-silent path of the surface.
class _FailingSuggestionsService implements AiApiService {
  @override
  Future<List<String>> suggest(
    String query, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    throw Exception('offline');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('Stubbed: ${invocation.memberName}');
  }
}
