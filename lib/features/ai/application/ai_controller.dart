import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/ai/ai_assistant_service.dart';

import '../domain/ai_home_mapper.dart';
import 'ai_state.dart';

/// Bridges [AiState] to the AI response pipeline.
///
/// Same `StateNotifier` style used across the app: immutable state +
/// explicit transitions. Depends only on the [AiAssistantService] abstraction
/// and the shared boundary mapper — it never touches mock/HTTP specifics.
class AiController extends StateNotifier<AiState> {
  AiController({
    required AiAssistantService service,
    required AiHomeMapper mapper,
  })  : _service = service,
        _mapper = mapper,
        super(const AiState());

  final AiAssistantService _service;
  final AiHomeMapper _mapper;

  /// Runs [prompt] through the assistant service, maps the result into
  /// renderable home sections and publishes a new [AiState].
  Future<void> submit(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = AiState(
      status: AiStatus.loading,
      currentPrompt: trimmed,
    );

    try {
      final response = await _service.query(trimmed);
      final sections = _mapper.toHomeSections(response);
      final text = response.text;

      if (sections.isEmpty && (text == null || text.trim().isEmpty)) {
        state = AiState(
          status: AiStatus.empty,
          currentPrompt: trimmed,
        );
      } else {
        state = AiState(
          status: AiStatus.success,
          currentPrompt: trimmed,
          responseText: text,
          sections: sections,
        );
      }
    } catch (error) {
      state = AiState(
        status: AiStatus.error,
        currentPrompt: trimmed,
        errorMessage: error.toString(),
      );
    }
  }

  /// Re-runs the last prompt (used by the error-state retry action).
  Future<void> retry() => submit(state.currentPrompt);

  /// Returns the controller to its pristine idle state.
  void reset() => state = const AiState();
}