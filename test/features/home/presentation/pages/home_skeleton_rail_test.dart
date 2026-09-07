import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/network/api_result.dart';
import 'package:wetravellers/core/repositories/contracts/home_repository.dart';
import 'package:wetravellers/features/home/presentation/home_controller.dart';
import 'package:wetravellers/features/home/presentation/pages/home_page.dart';
import 'package:wetravellers/features/home/providers/home_providers.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

/// H1 — Nuitee-only Home loading rail tests.
///
/// The Home controller is overridden into the EXACT Nuitee-only loading
/// state: feed legitimately empty (developmentPreview with no sections) and
/// recommended hotels still in flight. The skeleton rail must mirror the
/// real carousel geometry (title + 220px rail + cards) with zero fake travel
/// data, and the pull-to-refresh must be gone.
void main() {
  Widget host() => ProviderScope(
        overrides: [
          homeControllerProvider.overrideWith((ref) => _PreviewController()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: HomePage()),
        ),
      );

  testWidgets('skeleton rail renders the fixed real title', (tester) async {
    await tester.pumpWidget(host());
    // In the empty-feed loading state ONLY the skeleton rail's fixed title
    // renders (the real rail has no hotels to show yet).
    expect(find.text('Recommended for You'), findsOneWidget);
  });

  testWidgets('skeleton rail shows while Nuitee hotels are absent',
      (tester) async {
    await tester.pumpWidget(host());

    // Three skeleton hotel cards render (placeholder rail width).
    expect(find.byType(Card), findsAtLeast(3));
    // No pull-to-refresh remains anywhere on the Home surface (H1).
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('skeleton rail carries NO fake travel data', (tester) async {
    await tester.pumpWidget(host());

    // Hotel-shaped TEXT that would indicate seeded/fake CONTENT must not
    // exist while loading — only shimmer geometry. (NAV note: the Home nav
    // buttons legitimately carry 'Flights'/'Hotels'/... — those are
    // navigation, not data, so the assertions target full content strings.)
    expect(find.text('Grand Palm Hotel'), findsNothing);
    expect(find.text('Real Hotel'), findsNothing);
    expect(find.text('Grand Cairo'), findsNothing);
    expect(find.textContaining('Paris'), findsNothing);
    expect(find.textContaining('Cairo'), findsNothing);
    expect(find.textContaining('USD'), findsNothing);
    expect(find.textContaining('\$'), findsNothing);
  });
}

/// Controller pinned to the Nuitee-only loading state: empty feed published
/// as developmentPreview, sections empty, no hotels yet. The repository
/// returns inert empty results for the async startup paths (the real startup
/// behavior is covered by home_controller_test.dart).
class _PreviewController extends HomeController {
  _PreviewController() : super(_InertRepo(), liveValidation: null) {
    state = const HomeState(
      status: HomeStatus.developmentPreview,
      sections: [],
    );
  }
}

/// Inert repository: every call succeeds with empty/null — nothing can
/// throw or override the pinned state asynchronously.
class _InertRepo implements HomeRepository {
  @override
  Future<ApiResult<List<HomeSection>>> getHomeSections() async =>
      const ApiResult.success([]);

  @override
  Future<ApiResult<List<HomeItem>>> getRecommendedHotels({int limit = 6}) async =>
      const ApiResult.success([]);

  @override
  Future<ApiResult<void>> refresh() async => const ApiResult.success(null);

  @override
  Future<List<HomeSection>?> readHomeSnapshot({required String audience}) async => null;

  @override
  Future<void> clearHomeSnapshot({required String audience}) async {}

  @override
  Future<void> saveHomeSnapshot(
    List<HomeSection> sections, {
    required String audience,
  }) async {}
}
