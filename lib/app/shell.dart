import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_route.dart';
import '../shared/providers/app_mode_provider.dart';
import 'widgets/ai_morph_control.dart';

/// The unified application shell.
///
/// Features a fixed top header with app name, notifications and profile,
/// and a persistent floating AI morph control (bubble ⇄ glass input bar).
/// The old bottom bar / nav-toggle overlay was retired in Phase 21A —
/// navigation is covered by Home's quick-links and per-page back buttons.
class WeTravellersShell extends ConsumerStatefulWidget {
  const WeTravellersShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WeTravellersShell> createState() => _WeTravellersShellState();
}

class _WeTravellersShellState extends ConsumerState<WeTravellersShell> {
  /// Root surfaces that read as top-level destinations — no back button.
  static const Set<AppRoute> _rootRoutes = <AppRoute>{
    AppRoute.home,
    AppRoute.flights,
    AppRoute.hotels,
    AppRoute.cars,
    AppRoute.packages,
  };

  @override
  Widget build(BuildContext context) {
    final appMode = ref.watch(appModeProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final currentRoute = AppRoute.values.firstWhere(
      (r) => r.path == location,
      orElse: () => AppRoute.home,
    );
    // /booking/review has no AppRoute enum entry (enum paths are single-segment),
    // so fall back to an explicit title instead of the misleading 'Home'.
    // Home shows the brand name; all other routes show their page label.
    final isBookingReview = location == '/booking/review';
    final headerTitle = location == '/'
        ? 'Travellers'
        : isBookingReview
            ? 'Review Booking'
            : currentRoute.label;
    // Non-root routes (and /booking/review) get a leading back button.
    final showBack = isBookingReview || !_rootRoutes.contains(currentRoute);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Main page content with padding for the fixed header
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            child: widget.child,
          ),
          // Fixed top header
          if (appMode == AppMode.normal)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                // No boxShadow — header blends into the page as one surface.
                color: Theme.of(context).colorScheme.surface,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Leading back button on non-root surfaces only
                        if (showBack)
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back',
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go('/'),
                          ),
                        // Current page name replaces the brand name
                        Text(
                          headerTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        // Profile icon
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          onPressed: () => context.go(AppRoute.profile.path),
                          tooltip: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Persistent AI quick-access control — fills the shell and manages
          // its own bubble / scrim / chat-window layers internally.
          const Positioned.fill(child: AiMorphControl()),
        ],
      ),
    );
  }
}