import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_provider.dart';
import '../../shared/widgets/placeholder_page.dart';
import '../../core/navigation/app_route.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search/presentation/pages/flight_search_page.dart';
import '../../features/search/presentation/pages/hotel_search_page.dart';
import '../../features/search/presentation/pages/car_search_page.dart';
import '../shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Phase 15C: real authentication arrives in a later phase. Until then the
/// auth repository is a local stub, so a mandatory login redirect would lock
/// unauthenticated users out of the app. The login route stays registered and
/// this flag re-enables the redirect once real identity work lands.
const bool _authRedirectEnabled = false;

final goRouterProvider = Provider<GoRouter>((ref) {
  final authUser = ref.watch(authUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (!_authRedirectEnabled) {
        return null;
      }
      final isLoggedIn = authUser != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return WeTravellersShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'search'),
          ),
          GoRoute(
            path: '/flights',
            name: 'flights',
            builder: (context, state) => const FlightSearchPage(),
          ),
          GoRoute(
            path: '/hotels',
            name: 'hotels',
            builder: (context, state) => const HotelSearchPage(),
          ),
          GoRoute(
            path: '/cars',
            name: 'cars',
            builder: (context, state) => const CarSearchPage(),
          ),
          GoRoute(
            path: '/packages',
            name: 'packages',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'packages'),
          ),
          GoRoute(
            path: '/transfers',
            name: 'transfers',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'transfers'),
          ),
          GoRoute(
            path: '/groups',
            name: 'groups',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'groups'),
          ),
          GoRoute(
            path: '/bag',
            name: 'bag',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'bag'),
          ),
          GoRoute(
            path: '/ai',
            name: 'ai',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'ai'),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'notifications'),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'profile'),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'settings'),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const PlaceholderPageScaffold(routeName: 'login'),
          ),
        ],
      ),
    ],
  );
});

class PlaceholderPageScaffold extends StatelessWidget {
  const PlaceholderPageScaffold({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final path = routeName == 'home' ? '/' : '/$routeName';
    final route = AppRoute.values.firstWhere(
      (r) => r.path == path,
      orElse: () => AppRoute.home,
    );
    return PlaceholderPage(route: route);
  }
}