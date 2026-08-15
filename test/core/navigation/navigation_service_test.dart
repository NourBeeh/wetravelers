import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetravellers/core/navigation/navigation_service.dart';

void main() {
  test('SimpleNavigationService can be instantiated', () {
    final service = SimpleNavigationService(GlobalKey());
    expect(service, isA<SimpleNavigationService>());
  });
}
