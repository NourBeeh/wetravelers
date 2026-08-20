import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/core/network/api_client.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/network/api_error.dart';
import 'package:wetravellers/features/ai/application/ai_mock_providers.dart';
import 'package:wetravellers/features/ai/application/ai_state.dart';
import 'package:wetravellers/features/ai/data/mock_ai_assistant_service.dart';
import 'package:wetravellers/features/ai/data/mock_ai_response_provider.dart';
import 'package:wetravellers/features/ai/domain/ai_item.dart';
import 'package:wetravellers/features/ai/domain/ai_response.dart';
import 'package:wetravellers/features/ai/domain/ai_section.dart';
import 'package:wetravellers/features/ai/domain/ai_query_context.dart';
import 'package:wetravellers/features/ai/presentation/widgets/ai_bottom_sheet.dart';

class _FakeAiService implements AiAssistantService {
  _FakeAiService({this.response, this.error});

  final AiResponse? response;
  final Object? error;

  @override
  Future<String> generateContent({required String prompt}) async =>
      response?.text ?? '';

  @override
  Future<String> generateDescription({
    required String offerId,
    required String type,
  }) async => 'Generated description';

  @override
  Future<List<String>> recommend({required String context}) async => const [];

  @override
  Future<List<String>> compareOffers({required List<String> offerIds}) async =>
      const [];

  @override
  Future<String> generateOfferSummary({required String offerId}) async =>
      'Summary';

  @override
  Future<AiResponse> query(String prompt, {RequestToken? token, Duration? timeout, AiQueryContext? context}) async {
    if (error != null) {
      throw error!;
    }
    return response ?? const AiResponse();
  }
}

class _FallbackService extends MockAiAssistantService {
  _FallbackService({this.response, this.error});

  final AiResponse? response;
  final Object? error;

  @override
  Future<AiResponse> query(String prompt, {RequestToken? token, Duration? timeout, AiQueryContext? context}) async {
    if (error != null) {
      throw error!;
    }
    return response ?? const AiResponse();
  }
}

void main() {
  testWidgets('AI bottom sheet renders success state', (tester) async {
    final fakeService = _FakeAiService(
      response: AiResponse(
        text: 'Two great stays',
        sections: [
          AiSection(
            id: 'recommended',
            title: 'Recommended stays',
            items: [
              AiItem(
                id: 'hotel-1',
                type: HomeCardType.hotel,
                title: 'Seaside Hotel',
                price: 129,
                currency: 'USD',
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(fakeService),
          aiMockAssistantServiceProvider.overrideWithValue(
            _FallbackService(response: fakeService.response),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AiBottomSheetContent(prompt: 'find hotels in Rome'),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Recommended stays'), findsOneWidget);
    expect(find.text('Seaside Hotel'), findsOneWidget);
  });

  testWidgets('AI bottom sheet shows a sanitized error state', (tester) async {
    final fakeService = _FakeAiService(
      error: const ApiNetworkError(message: 'SocketException: boom:3000'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(fakeService),
          aiMockAssistantServiceProvider.overrideWithValue(
            _FallbackService(error: fakeService.error),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AiBottomSheetContent(prompt: 'find hotels in Rome'),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(
      find.text('No connection. Check your internet and try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('SocketException'), findsNothing);
  });

  testWidgets('AI bottom sheet cancellation stops stale updates', (tester) async {
    final completer = Completer<AiResponse>();
    final fakeService = _FakeAiService();
    final delayedService = _DelayedAiService(completer);
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(delayedService),
          aiMockAssistantServiceProvider.overrideWithValue(
            _FallbackService(response: fakeService.response),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context, listen: false);
            return const MaterialApp(
              home: Scaffold(
                body: AiBottomSheetContent(prompt: 'find hotels in Rome'),
              ),
            );
          },
        ),
      ),
    );

    final controller = container.read(aiSheetControllerProvider((prompt: 'find hotels in Rome', context: null)).notifier);
    controller.cancel();
    completer.complete(
      AiResponse(
        text: 'Late result',
        sections: [
          AiSection(
            id: 'late-section',
            title: 'Late section',
            items: const [],
          ),
        ],
      ),
    );

    await tester.pump();
    expect(controller.state.status, AiStatus.idle);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class _DelayedAiService implements AiAssistantService {
  _DelayedAiService(this._completer);

  final Completer<AiResponse> _completer;

  @override
  Future<String> generateContent({required String prompt}) async => '';

  @override
  Future<String> generateDescription({
    required String offerId,
    required String type,
  }) async => '';

  @override
  Future<List<String>> recommend({required String context}) async => const [];

  @override
  Future<List<String>> compareOffers({required List<String> offerIds}) async =>
      const [];

  @override
  Future<String> generateOfferSummary({required String offerId}) async => '';

  @override
  Future<AiResponse> query(String prompt, {RequestToken? token, Duration? timeout, AiQueryContext? context}) => _completer.future;
}