import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application-wide operating mode.
///
/// - [AppMode.ai]: the AI assistant surface is the primary experience.
/// - [AppMode.normal]: classic app with the floating radial control panel.
enum AppMode { ai, normal }

/// Reactive app-wide operating mode.
///
/// Defaults to [AppMode.normal]. Full-screen AI takeover was retired in
/// Phase 20 in favor of a persistent bubble + bounded bottom sheet that
/// never covers navigation.
final appModeProvider = StateProvider<AppMode>((ref) {
  return AppMode.normal;
});