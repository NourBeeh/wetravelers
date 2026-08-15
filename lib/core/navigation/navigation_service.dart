import 'package:flutter/material.dart';

abstract interface class NavigationService {
  void goTo(String route);
  void goBack();
  bool canGoBack();
}

class SimpleNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  SimpleNavigationService(this.navigatorKey);

  @override
  void goTo(String route) {
    navigatorKey.currentState?.pushNamed(route);
  }

  @override
  void goBack() {
    if (canGoBack()) {
      navigatorKey.currentState?.pop();
    }
  }

  @override
  bool canGoBack() => navigatorKey.currentState?.canPop() ?? false;
}