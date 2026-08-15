import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/core/network/api_client.dart';
import 'package:wetravellers/features/ai/domain/ai_response.dart';

/// Real HTTP implementation of [AiAssistantService].
///
/// Talks to the WeTravellers NestJS BFF endpoint `POST /ai/query` through the
/// shared [ApiClient] — timeouts, non-2xx, malformed JSON and connectivity
/// failures are already mapped by the client into [ApiResult] failures, so
/// this service never crashes; it simply rethrows the failure for the
/// controller to surface. The normalized backend payload is parsed straight
/// into the exact Flutter contract via [AiResponse.fromMap].
class AiApiService implements AiAssistantService {
  AiApiService(this._client);

  final ApiClient _client;

  static const String _queryPath = '/ai/query';

  @override
  Future<AiResponse> query(String prompt) async {
    final result = await _client.post<Map<String, dynamic>>(
      _queryPath,
      body: <String, dynamic>{'prompt': prompt},
    );

    final map = result.when(
      success: (data) => data,
      failure: (error) => throw error,
    );
    return AiResponse.fromMap(map);
  }

  @override
  Future<String> generateContent({required String prompt}) async {
    final response = await query(prompt);
    return response.text ?? '';
  }

  @override
  Future<String> generateDescription({
    required String offerId,
    required String type,
  }) {
    throw UnimplementedError(
      'generateDescription is not implemented by the HTTP AI service.',
    );
  }

  @override
  Future<List<String>> recommend({required String context}) {
    throw UnimplementedError(
      'recommend is not implemented by the HTTP AI service.',
    );
  }

  @override
  Future<List<String>> compareOffers({required List<String> offerIds}) {
    throw UnimplementedError(
      'compareOffers is not implemented by the HTTP AI service.',
    );
  }

  @override
  Future<String> generateOfferSummary({required String offerId}) {
    throw UnimplementedError(
      'generateOfferSummary is not implemented by the HTTP AI service.',
    );
  }
}