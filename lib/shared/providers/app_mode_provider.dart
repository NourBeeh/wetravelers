import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application-wide operating mode.
///
/// - [AppMode.ai]: the AI assistant surface is the primary experience.
/// - [AppMode.normal]: classic app with the floating radial control panel.
enum AppMode { ai, normal }

/// Reactive app-wide operating mode.
///
/// Defaults to [AppMode.ai]. The shell binds the floating radial control panel
/// to [AppMode.normal]; the single circular AI/Normal toggle lands in a later
/// phase, so this phase only wires the state.
final appModeProvider = StateProvider<AppMode>((ref) {
  return AppMode.ai;
});