import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/floating_navigation/floating_navigation.dart';
import '../core/navigation/app_route.dart';
import '../features/ai/presentation/pages/ai_visual_shell_page.dart';
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
          if (appMode == AppMode.normal)
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
          // AI mode covers the routed surface with the living AI shell. The
          // routed page stays mounted underneath so switching back is lossless.
          if (appMode == AppMode.ai)
            const Positioned.fill(child: AiVisualShellPage()),
        ],
      ),
    );
  }
}