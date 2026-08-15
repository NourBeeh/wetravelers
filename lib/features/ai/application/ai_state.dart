import 'package:flutter/foundation.dart';

import 'package:wetravellers/core/domain/models/home/home_section.dart';

/// Lifecycle status of an AI interaction.
enum AiStatus { idle, loading, success, empty, error }

/// Immutable AI assistant state.
///
/// Mirrors the `StateNotifier` state shapes used by Home/Search/Auth:
/// a `status` gate plus the data that each phase needs.
@immutable
class AiState {
  const AiState({
    this.status = AiStatus.idle,
    this.currentPrompt = '',
    this.responseText,
    this.sections = const [],
    this.errorMessage,
  });

  final AiStatus status;

  /// The most recent submitted prompt (empty until the first submit).
  final String currentPrompt;

  /// Natural-language content of the latest response.
  final String? responseText;

  /// Mapped renderable home sections for the latest response.
  final List<HomeSection> sections;

  final String? errorMessage;

  AiState copyWith({
    AiStatus? status,
    String? currentPrompt,
    String? responseText,
    List<HomeSection>? sections,
    String? errorMessage,
  }) {
    return AiState(
      status: status ?? this.status,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      responseText: responseText ?? this.responseText,
      sections: sections ?? this.sections,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}