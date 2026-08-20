import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/floating_navigation/floating_navigation.dart';
import '../core/widgets/command_bar/command_bar.dart';
import '../core/navigation/app_route.dart';
import '../features/ai/domain/ai_query_context.dart';
import '../features/ai/presentation/pages/ai_visual_shell_page.dart';
import '../features/ai/presentation/widgets/ai_bottom_sheet.dart';
import '../shared/providers/app_mode_provider.dart';

/// The application shell.
///
/// Holds the active page (driven by [currentRouteProvider]) and overlays the
/// floating navigation while the app is in [AppMode.normal]. There is
/// intentionally no persistent top/bottom bar, following the Phase 1
/// floating-navigation direction. In [AppMode.ai] the routed surface is
/// covered by the AI visual shell and the radial panel is suppressed — the
/// AI surface becomes the primary experience.
class WeTravellersShell extends ConsumerWidget {
  const WeTravellersShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentRoute = AppRoute.values.firstWhere(
      (r) => r.path == location,
      orElse: () => AppRoute.home,
    );
    final appMode = ref.watch(appModeProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          child,
          // Normal mode keeps the familiar radial control panel on top.
          if (appMode == AppMode.normal) ...[
            // Floating radial navigation overlay
            SafeArea(
              top: false,
              left: false,
              right: false,
              child: FloatingNavigation(
                currentRoute: currentRoute,
                onDestinationSelected: (route) {
                  context.go(route.path);
                },
              ),
            ),
            // Persistent bottom command bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CommandBar(
                onSubmitted: (text) {
                  // Basic behaviour: navigate to search page when pressed with simple heuristics
                  if (text.toLowerCase().contains('flight') || text.toLowerCase().contains('flights')) {
                    context.go(AppRoute.flights.path);
                  } else if (text.toLowerCase().contains('hotel') || text.toLowerCase().contains('hotels')) {
                    context.go(AppRoute.hotels.path);
                  } else if (text.toLowerCase().contains('car') || text.toLowerCase().contains('cars')) {
                    context.go(AppRoute.cars.path);
                  } else {
                    // fallback: open AI bottom sheet with the prompt
                    // Uses the mock AI assistant for prototypes; Phase 15A adds context support
                    final queryContext = AiQueryContext.fromAppRoute(currentRoute);
                    showAiBottomSheet(context, text, aiContext: queryContext);
                  }
                },
              ),
            ),
          ],
          // AI mode covers the routed surface with the living AI shell. The
          // routed page stays mounted underneath so switching back is lossless.
          if (appMode == AppMode.ai)
            const Positioned.fill(child: AiVisualShellPage()),
        ],
      ),
    );
  }
}