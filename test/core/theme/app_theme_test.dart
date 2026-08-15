import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetravellers/core/theme/app_theme.dart';
import 'package:wetravellers/core/theme/app_colors.dart';

void main() {
  test('Light theme uses bright white surfaces', () {
    final theme = AppTheme.light();
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.surface, AppColors.surfaceLight);
  });

  test('Dark theme uses near-black surfaces', () {
    final theme = AppTheme.dark();
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.surface, AppColors.surfaceDark);
  });
}