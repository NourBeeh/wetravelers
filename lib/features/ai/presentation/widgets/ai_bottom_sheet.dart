import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';
import 'package:wetravellers/core/network/api_client.dart';
import 'package:wetravellers/features/ai/application/ai_mock_providers.dart';
import 'package:wetravellers/features/ai/application/ai_providers.dart';
import 'package:wetravellers/features/ai/application/ai_state.dart';
import 'package:wetravellers/features/ai/data/mock_ai_response_provider.dart';
import 'package:wetravellers/features/ai/domain/ai_home_mapper.dart';
import 'package:wetravellers/features/ai/domain/ai_response.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_section.dart';

class AiSheetController extends StateNotifier<AiState> {
  AiSheetController({
    required this.primary,
    required this.fallback,
    required this.mapper,
  }) : super(const AiState());

  final AiAssistantService primary;
  final AiAssistantService fallback;
  final AiHomeMapper mapper;

  int _requestVersion = 0;
  bool _disposed = false;

  Future<void> load(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final requestVersion = ++_requestVersion;
    state = state.copyWith(
      status: AiStatus.loading,
      currentPrompt: trimmed,
      errorMessage: null,
    );

    try {
      final token = RequestToken();
      final response = await _queryWithFallback(trimmed, token: token)
          .timeout(const Duration(seconds: 30));
      if (_disposed || requestVersion != _requestVersion) {
        return;
      }

      final sections = mapper.toHomeSections(response);
      state = state.copyWith(
        status: sections.isEmpty &&
                (response.text == null || response.text!.trim().isEmpty)
            ? AiStatus.empty
            : AiStatus.success,
        currentPrompt: trimmed,
        responseText: response.text,
        sections: sections,
        errorMessage: null,
      );
    } catch (error) {
      if (_disposed || requestVersion != _requestVersion) {
        return;
      }
      state = state.copyWith(
        status: AiStatus.error,
        currentPrompt: trimmed,
        errorMessage: userFacingMessage(error, subject: 'AI assistant'),
      );
    }
  }

  void cancel() {
    _requestVersion++;
    state = const AiState();
  }

  Future<AiResponse> _queryWithFallback(String prompt, {RequestToken? token, Duration? timeout}) async {
    try {
      return await primary.query(prompt, token: token, timeout: timeout);
    } catch (_) {
      try {
        return await fallback.query(prompt, token: token, timeout: timeout);
      } catch (error) {
        throw error;
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}

final aiSheetControllerProvider =
    StateNotifierProvider.autoDispose.family<AiSheetController, AiState, String>(
  (ref, prompt) {
    final controller = AiSheetController(
      primary: ref.watch(aiAssistantServiceProvider),
      fallback: ref.watch(aiMockAssistantServiceProvider),
      mapper: ref.watch(aiHomeMapperProvider),
    );
    Future.microtask(() => controller.load(prompt));
    return controller;
  },
);

class AiBottomSheetContent extends ConsumerWidget {
  const AiBottomSheetContent({super.key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiSheetControllerProvider(prompt));
    final controller = ref.read(aiSheetControllerProvider(prompt).notifier);

    final children = switch (state.status) {
      AiStatus.loading => const [Center(child: CircularProgressIndicator())],
      AiStatus.error => [Center(child: Text(state.errorMessage ?? 'Something went wrong. Please try again.'))],
      AiStatus.empty => const [Center(child: Text('No suggestions right now. Try a different prompt.'))],
      AiStatus.success => [
          ...state.sections.map(
            (section) => HomeSectionWidget(section: section),
          ),
        ],
      AiStatus.idle => const [Center(child: CircularProgressIndicator())],
    };

    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (state.status == AiStatus.error)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => controller.load(state.currentPrompt),
                  child: const Text('Try again'),
                ),
              ),
            Expanded(
              child: children.length == 1 && children.first is Center
                  ? children.first
                  : ListView(
                      children: children,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a draggable AI bottom sheet over the current surface.
Future<void> showAiBottomSheet(BuildContext context, String prompt) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (sheetContext, scrollController) {
        return Consumer(
          builder: (consumerContext, ref, _) {
            final state = ref.watch(aiSheetControllerProvider(prompt));
            final sections = state.sections;
            final content = Padding(
              padding: const EdgeInsets.all(12.0),
              child: switch (state.status) {
                AiStatus.loading => const Center(child: CircularProgressIndicator()),
                AiStatus.error => Center(
                    child: Text(
                      state.errorMessage ??
                          'Something went wrong. Please try again.',
                    ),
                  ),
                AiStatus.empty => const Center(
                    child: Text('No suggestions right now. Try a different prompt.'),
                  ),
                AiStatus.success => ListView.builder(
                    controller: scrollController,
                    itemCount: sections.length,
                    itemBuilder: (context, index) =>
                        HomeSectionWidget(section: sections[index]),
                  ),
                AiStatus.idle => const Center(child: CircularProgressIndicator()),
              },
            );
            return Material(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: content,
            );
          },
        );
      },
    ),
  );
}
