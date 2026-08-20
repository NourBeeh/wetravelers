import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/core/network/api_client.dart';
import 'package:wetravellers/features/ai/domain/ai_query_context.dart';
import 'package:wetravellers/features/ai/domain/ai_response.dart';

import 'mock_ai_response_data.dart';

/// Temporary, fully local implementation of [AiAssistantService].
///
/// `query` — the method the assistant workflow uses — delegates to the
/// existing [MockAiResponseSource]. The legacy content-generation methods
/// return harmless placeholders until a real backend lands. No network.
class MockAiAssistantService implements AiAssistantService {
  const MockAiAssistantService({
    MockAiResponseSource source = const MockAiResponseSource(),
  }) : _source = source;

  final MockAiResponseSource _source;

  @override
  Future<AiResponse> query(String prompt, {RequestToken? token, Duration? timeout, AiQueryContext? context}) => _source.generate(prompt);

  @override
  Future<String> generateContent({required String prompt}) async {
    final response = await _source.generate(prompt);
    return response.text ?? '';
  }

  @override
  Future<String> generateDescription({
    required String offerId,
    required String type,
  }) async {
    return 'Mock description for $type "offerId".';
  }

  @override
  Future<List<String>> recommend({required String context}) async {
    return buildMockAiResponse()
        .sections
        .map((section) => section.title)
        .toList();
  }

  @override
  Future<List<String>> compareOffers({required List<String> offerIds}) async {
    return offerIds.map((id) => 'Mock comparison summary for $id.').toList();
  }

  @override
  Future<String> generateOfferSummary({required String offerId}) async {
    return 'Mock summary for offer $offerId.';
  }
}