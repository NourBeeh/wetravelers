import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/app/router/go_router_config.dart';

void main() {
  test('GoRouter provider builds without error', () {
    final container = ProviderContainer();
    final router = container.read(goRouterProvider);
    expect(router, isA<GoRouter>());
  });
}
