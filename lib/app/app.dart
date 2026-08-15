import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../shared/providers/theme_mode_provider.dart';
import 'config/app_config.dart';
import 'router/go_router_config.dart';

/// Root widget for WeTravellers.
///
/// Wires the active design-system theme and mounts the router that hosts the
/// floating navigation shell. Riverpod is provided above this widget in `main.dart`.
class WeTravellersApp extends ConsumerWidget {
  const WeTravellersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}