import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ai_home_mapper.dart';
import '../data/mock_ai_response_provider.dart';
import 'ai_controller.dart';
import 'ai_state.dart';

/// Single shared instance of the boundary mapper.
final aiHomeMapperProvider = Provider<AiHomeMapper>((ref) {
  return const AiHomeMapper();
});

/// Exposes the reactive [AiState] produced by [AiController].
///
/// The controller is wired to the real HTTP `AiAssistantService`; pointing it
/// elsewhere (another backend, a mock in tests) happens only at the provider
/// level, leaving the controller, mapper and UI untouched.
final aiControllerProvider =
    StateNotifierProvider<AiController, AiState>((ref) {
  return AiController(
    service: ref.watch(aiAssistantServiceProvider),
    mapper: ref.watch(aiHomeMapperProvider),
  );
});