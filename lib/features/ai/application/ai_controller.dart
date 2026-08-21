import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/core/network/api_error.dart';
import 'package:wetravellers/core/domain/models/home/home_section.dart';

import '../domain/ai_home_mapper.dart';
import '../domain/ai_query_context.dart';
import 'ai_state.dart';

/// Bridges [AiState] to the AI response pipeline.
///
/// Same `StateNotifier` style used across the app: immutable state +
/// explicit transitions. Depends only on the [AiAssistantService] abstraction
/// and the shared boundary mapper — it never touches mock/HTTP specifics.
class AiController extends StateNotifier<AiState> {
  AiController({
    required this._service,
    required this._mapper,
  }) : super(const AiState());

  final AiAssistantService _service;
  final AiHomeMapper _mapper;

  /// Runs [prompt] through the assistant service, maps the result into
  /// renderable home sections and publishes a new [AiState].
  /// Phase 15B Stage 4: Accepts optional context, auto-builds from home sections if not provided.
  Future<void> submit(String prompt, {
    AiQueryContext? context,
    List<HomeSection> currentHomeSections = const [],
    Map<String, double>? geolocation,
    Map<String, String>? travelDates,
  }) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = AiState(
      status: AiStatus.loading,
      currentPrompt: trimmed,
    );

    // Build context automatically if not provided and we have home sections
    final AiQueryContext finalContext = context ?? _mapper.extractContextFromHomeSections(
      currentHomeSections,
      geolocation: geolocation,
      travelDates: travelDates,
    );

    try {
      final response = await _service.query(trimmed, context: finalContext);
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
        errorMessage: _userFacingMessage(error),
      );
    }
  }

  /// Re-runs the last prompt (used by the error-state retry action).
  Future<void> retry({
    AiQueryContext? context,
    List<HomeSection> currentHomeSections = const [],
    Map<String, double>? geolocation,
    Map<String, String>? travelDates,
  }) => submit(
    state.currentPrompt,
    context: context,
    currentHomeSections: currentHomeSections,
    geolocation: geolocation,
    travelDates: travelDates,
  );

  /// Returns the controller to its pristine idle state.
  void reset() => state = const AiState();

  /// Translates a thrown failure into a message that is safe to display.
  ///
  /// [AiState.errorMessage] is rendered verbatim on the AI surface
  /// (`ai_response_content.dart` → `_AiErrorState`), while `HttpApiClient`
  /// stores the whole HTTP response body in [ApiError.message] and socket
  /// failures carry the host and port. Publishing `error.toString()` therefore
  /// put raw transport, backend and exception text on screen — including the
  /// backend's `AI_API_KEY is missing` configuration notice.
  ///
  /// Reuses the existing [ApiError] hierarchy rather than introducing a new
  /// error type. The switch is exhaustive over the sealed class, so adding a
  /// new [ApiError] subtype fails the build instead of silently leaking again.
  static String _userFacingMessage(Object error) {
    if (error is ApiError) {
      return switch (error) {
        ApiTimeoutError() =>
          'The assistant took too long to respond. Please try again.',
        ApiNetworkError() =>
          'No connection to the assistant. Check your internet and try again.',
        ApiUnauthorizedError() =>
          'Your session has expired. Please sign in and try again.',
        ApiParseError() =>
          'The assistant sent an unexpected reply. Please try again.',
        ApiServerError() =>
          'The assistant is temporarily unavailable. Please try again shortly.',
        ApiClientError() =>
          'That request could not be handled. Please rephrase and try again.',
        ApiRequestCancelledError() => 'Request cancelled.',
        ApiUnknownError() => _genericMessage,
      };
    }
    return _genericMessage;
  }

  static const String _genericMessage =
      'Something went wrong. Please try again.';
}