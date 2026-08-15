import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/core/network/http_api_client.dart';

import 'ai_api_service.dart';

/// [AiAssistantService] wired to the real NestJS endpoint (`POST /ai/query`).
///
/// The controller and the UI only ever see [AiAssistantService]; switching
/// backends (or the platform base URL) never touches them. The local mock
/// implementation (`MockAiAssistantService`) is kept in the codebase but is no
/// longer injected.
final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  return AiApiService(HttpApiClient());
});