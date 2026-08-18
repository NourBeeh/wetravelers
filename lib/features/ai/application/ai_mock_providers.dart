import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_ai_assistant_service.dart';

/// Provider for a mock, local-only AiAssistantService used by UI prototypes.
final aiMockAssistantServiceProvider = Provider.autoDispose((ref) => const MockAiAssistantService());
