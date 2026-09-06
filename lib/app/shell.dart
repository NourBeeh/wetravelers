import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/app/widgets/app_bottom_nav.dart';

/// The unified application shell.
///
/// A seamless surface: pages render edge-to-edge with their own merged
/// headers (no fixed top bar) and a floating bottom navigation pill hosts
/// the four primary destinations — Home, Search, Groups, Explore. The pill
/// hovers above the content so feeds scroll underneath it.
///
/// Branch sub-pages that own their bottom edge (booking flow sticky CTAs,
/// search forms, bag, profile…) hide the pill: [location] is the live router
/// URI, and only the four tab roots keep the floating bar.
class WeTravellersShell extends StatelessWidget {
  const WeTravellersShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;

  /// Live router location of the current route, used to decide whether the
  /// floating nav pill should hover over the page.
  final Uri location;

  /// Tab-root paths that keep the floating navigation pill.
  static const Set<String> _tabRoots = <String>{
    '/',
    '/search',
    '/groups',
    '/explore',
  };

  @override
  Widget build(BuildContext context) {
    final showNav = _tabRoots.contains(location.path);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: navigationShell),
          if (showNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(
                current: _destinationFor(navigationShell.currentIndex),
                onSelect: (destination) => _goBranch(destination),
              ),
            ),
        ],
      ),
    );
  }

  /// Maps the active branch index onto the highlighted tab.
  ///
  /// The router hosts four branches (Home, Search, Groups, Explore).
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
    };
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
