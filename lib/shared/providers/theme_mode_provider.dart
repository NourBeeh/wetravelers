import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive app-wide theme mode (light / dark / system).
///
/// Foundation only — actual persistence of the preference lands later.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Temporarily forced to light — dark theme has not had a design pass yet;
  // revisit when dark mode is explicitly scoped.
  return ThemeMode.light;
});