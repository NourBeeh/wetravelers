import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/app/widgets/app_bottom_nav.dart';

/// The unified application shell.
///
/// A seamless surface: pages render edge-to-edge with their own merged
/// headers (no fixed top bar), and the attached bottom navigation bar hosts
/// the five primary destinations — Home, Search, AI (centre), Groups,
/// Explore. The AI centre button pushes the full-screen assistant route.
class WeTravellersShell extends StatelessWidget {
  const WeTravellersShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        current: _destinationFor(navigationShell.currentIndex),
        onSelect: (destination) => _goBranch(destination),
        onAiPressed: () => context.push('/ai-chat'),
      ),
    );
  }

  /// Maps the active branch index onto the highlighted tab.
  ///
  /// The router hosts four branches (Home, Search, Groups, Explore) — the
  /// AI centre button is a pushed route, not a branch.
  AppBottomNavDestination _destinationFor(int index) {
    return switch (index) {
      1 => AppBottomNavDestination.search,
      2 => AppBottomNavDestination.groups,
      3 => AppBottomNavDestination.explore,
      _ => AppBottomNavDestination.home,
    };
  }

  void _goBranch(AppBottomNavDestination destination) {
    final index = switch (destination) {
      AppBottomNavDestination.home => 0,
      AppBottomNavDestination.search => 1,
      AppBottomNavDestination.groups => 2,
      AppBottomNavDestination.explore => 3,
      AppBottomNavDestination.ai => 2, // unreachable — AI is a pushed route
    };
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
