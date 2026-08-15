import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_route.dart';
import '../../shared/widgets/placeholder_page.dart';

/// The currently active navigation destination.
///
/// Drives both the shell body and the highlighted item in the floating
/// navigation. Foundation state; later phases may move to deep-link routing.
final currentRouteProvider = StateProvider<AppRoute>((ref) {
  return AppRoute.home;
});

/// Reactive route (screen area) for a destination.
final activePageProvider = Provider<Widget>((ref) {
  final route = ref.watch(currentRouteProvider);
  return PlaceholderPage(route: route);
});

/// Routing foundation.
///
/// Phase 1 builds a reactive shell: the destination within [currentRouteProvider]
/// is swapped into the body and the floating menu highlights it. [buildRoute]
/// already models the per-destination Router path so a Navigator-2.0 / deep-link
/// upgrade can reuse these mappings later without touching consumers.
abstract final class AppRouter {
  /// Material page transition for a destination.
  static Route<dynamic> buildRoute(AppRoute route) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: route.path),
      builder: (context) => PlaceholderPage(route: route),
    );
  }

  /// Maps every [AppRoute] to its page builder (extension point for push).
  static Map<AppRoute, Widget Function()> buildPages() => <AppRoute, Widget Function()>{
        for (final route in AppRoute.values)
          route: () => PlaceholderPage(route: route),
      };

  /// Makes [route] the active destination.
  static void go(WidgetRef ref, AppRoute route) {
    ref.read(currentRouteProvider.notifier).state = route;
  }
}