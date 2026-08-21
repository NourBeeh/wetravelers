import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/command_bar/command_bar.dart';
import '../core/navigation/app_route.dart';
import '../features/ai/domain/ai_query_context.dart';
import '../features/ai/domain/search_intent_parser.dart';
import '../features/ai/presentation/pages/ai_visual_shell_page.dart';
import '../features/ai/presentation/widgets/ai_bottom_sheet.dart';
import '../shared/providers/app_mode_provider.dart';

/// The unified application shell.
///
/// Features a fixed top header with app name, notifications and profile.
/// A persistent bottom bar with AI input + navigation toggle that opens a
/// list of all primary destinations. Merges the previous floating/radial
/// navigation into a single toggleable list, eliminating competing UIs.
class WeTravellersShell extends ConsumerStatefulWidget {
  const WeTravellersShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WeTravellersShell> createState() => _WeTravellersShellState();
}

class _WeTravellersShellState extends ConsumerState<WeTravellersShell> with SingleTickerProviderStateMixin {
  late final AnimationController _navController;
  bool _navOpen = false;

  // Primary navigation destinations as specified in requirements
  static const List<AppRoute> _navDestinations = <AppRoute>[
    AppRoute.home,
    AppRoute.flights,
    AppRoute.hotels,
    AppRoute.cars,
    // Tour programs (packages) - dedicated route
    AppRoute.packages,
    // Transfer - dedicated route
    AppRoute.transfers,
  ];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _toggleNav() {
    setState(() {
      _navOpen = !_navOpen;
      if (_navOpen) {
        _navController.forward();
      } else {
        _navController.reverse();
      }
    });
  }

  void _navigateTo(AppRoute route) {
    _navController.reverse();
    setState(() => _navOpen = false);
    context.go(route.path);
  }

  @override
  Widget build(BuildContext context) {
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
          // Main page content with padding for header and bottom bar
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              bottom: 80 + MediaQuery.of(context).padding.bottom,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // App name/logo on the left
                        Text(
                          'WeTravellers',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        // Notifications icon
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () => context.go(AppRoute.notifications.path),
                          tooltip: 'Notifications',
                        ),
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
          // Toggleable navigation list (merged floating/radial nav)
          if (appMode == AppMode.normal && _navOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleNav,
                child: Container(
                  color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.4),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedBuilder(
                      animation: _navController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - _navController.value) * 200),
                          child: Opacity(
                            opacity: _navController.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 80 + MediaQuery.of(context).padding.bottom,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _navDestinations.map((route) {
                            final isSelected = route == currentRoute;
                            return ListTile(
                              leading: Icon(
                                route.iconFor(selected: isSelected),
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              title: Text(
                                route.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              onTap: () => _navigateTo(route),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // AI mode covers the routed surface with the living AI shell. The
          // routed page stays mounted underneath so switching back is lossless.
          if (appMode == AppMode.ai)
            const Positioned.fill(child: AiVisualShellPage()),
        ],
      ),
      // Persistent bottom bar with AI input and nav toggle - Scaffold.bottomNavigationBar
      bottomNavigationBar: appMode == AppMode.normal
          ? SafeArea(
              child: Material(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        // Navigation toggle button
                        IconButton(
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 250),
                            turns: _navOpen ? 0.125 : 0, // 45 degrees when open
                            child: const Icon(Icons.menu),
                          ),
                          onPressed: _toggleNav,
                          tooltip: 'Toggle navigation',
                        ),
                        const SizedBox(width: 8),
                        // AI Command bar - gets bounded width via Expanded
                        Expanded(
                          child: CommandBar(
                            onSubmitted: (text) {
                              // Parse search intent from natural language query
                              final parsedIntent = SearchIntentParser.parse(text);

                              if (parsedIntent.isValid) {
                                // Navigate to the appropriate search page with parsed parameters
                                if (parsedIntent.service == 'flight') {
                                  context.go(AppRoute.flights.path, extra: {
                                    'origin': parsedIntent.origin,
                                    'destination': parsedIntent.destination,
                                    'departureDate': parsedIntent.date,
                                  });
                                } else if (parsedIntent.service == 'hotel') {
                                  context.go(AppRoute.hotels.path, extra: {
                                    'city': parsedIntent.destination ?? parsedIntent.origin,
                                    'checkIn': parsedIntent.date,
                                    'checkOut': parsedIntent.returnDate,
                                  });
                                } else if (parsedIntent.service == 'car') {
                                  context.go(AppRoute.cars.path, extra: {
                                    'pickupLocation': parsedIntent.origin,
                                    'dropoffLocation': parsedIntent.destination,
                                    'pickupDate': parsedIntent.date,
                                  });
                                }
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
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}