import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/app/shell.dart';
import 'package:wetravellers/app/widgets/app_bottom_nav.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

/// Regression coverage for the tab-index mismatch bug: the router hosts four
/// branches (Home=0, Search=1, Groups=2, Explore=3) and the floating bottom
/// bar renders the same four destinations. Tapping each tab must show the
/// matching page — through the real shell + StatefulShellRoute wiring.
void main() {
  testWidgets('bottom nav tabs land on the correct branches', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => WeTravellersShell(
            navigationShell: navigationShell,
            location: state.uri,
          ),
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
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('HOME'), findsOneWidget);

    // Four floating tabs in order: Home, Search, Groups, Explore.
    await tester.tap(find.text('Search'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SEARCH'), findsOneWidget);

    await tester.tap(find.text('Groups'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GROUPS'), findsOneWidget);

    // Explore is the last slot.
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('EXPLORE'), findsOneWidget);

    // Home round-trips back correctly.
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('floating pill hides on branch sub-pages', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => WeTravellersShell(
            navigationShell: navigationShell,
            location: state.uri,
          ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/',
                  builder: (_, __) => const _BranchLabel('HOME'),
                  routes: <GoRoute>[
                    GoRoute(
                      path: 'flights',
                      builder: (_, __) => const _BranchLabel('FLIGHTS'),
                    ),
                  ],
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
    await tester.pump(const Duration(milliseconds: 400));

    // The pill is visible on the Home tab root.
    expect(find.byType(AppBottomNav), findsOneWidget);

    // Pushing a branch sub-page hides the floating pill.
    router.push('/flights');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AppBottomNav), findsNothing);
  });

  test('branch/tab mapping helpers stay in sync', () {
    // The shell maps branch indices to tabs; assert the internal contract:
    // four router branches, four destinations, no AI slot.
    expect(AppBottomNavDestination.values.length, 4);
    expect(AppBottomNavDestination.values, containsAll(<AppBottomNavDestination>[
      AppBottomNavDestination.home,
      AppBottomNavDestination.search,
      AppBottomNavDestination.groups,
      AppBottomNavDestination.explore,
    ]));
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
