import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/app/shell.dart';
import 'package:wetravellers/app/widgets/app_bottom_nav.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

/// Regression coverage for the tab-index mismatch bug: the router hosts four
/// branches (Home=0, Search=1, Groups=2, Explore=3) while the bottom bar
/// renders five slots with AI in the centre. Tapping Groups must show the
/// Groups page and tapping Explore must show the Explore page — through the
/// real shell + StatefulShellRoute wiring.
void main() {
  testWidgets('bottom nav tabs land on the correct branches', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              WeTravellersShell(navigationShell: navigationShell),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/',
                  builder: (_, __) => const _BranchLabel('HOME'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/search',
                  builder: (_, __) => const _BranchLabel('SEARCH'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/groups',
                  builder: (_, __) => const _BranchLabel('GROUPS'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/explore',
                  builder: (_, __) => const _BranchLabel('EXPLORE'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    // The AI centre button pulses forever — pumpAndSettle would time out,
    // so pump fixed frames instead.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('HOME'), findsOneWidget);

    // Groups is the 4th slot of the five-slot bar.
    await tester.tap(find.text('Groups'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GROUPS'), findsOneWidget);

    // Explore is the 5th slot.
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('EXPLORE'), findsOneWidget);

    // Home round-trips back correctly.
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('branch/tab mapping helpers stay in sync', (tester) async {
    // The shell maps branch indices to tabs; assert the internal contract:
    // four router branches, AI is not one of them.
    expect(AppBottomNavDestination.values.length, 5);
    // AI sits in the centre slot.
    expect(AppBottomNavDestination.values[2], AppBottomNavDestination.ai);
  });
}

class _BranchLabel extends StatelessWidget {
  const _BranchLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(label, textDirection: TextDirection.ltr),
      );
}
