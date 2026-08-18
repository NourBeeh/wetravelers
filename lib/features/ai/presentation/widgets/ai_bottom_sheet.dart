import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/ai/ai_assistant_service.dart';
import 'package:wetravellers/features/ai/application/ai_mock_providers.dart';
import 'package:wetravellers/features/ai/application/ai_providers.dart';
import 'package:wetravellers/features/ai/data/mock_ai_response_provider.dart';
import 'package:wetravellers/features/ai/domain/ai_response.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_section.dart';
import 'package:wetravellers/core/network/user_facing_message.dart';

/// Shows a draggable AI bottom sheet over the current surface.
Future<void> showAiBottomSheet(BuildContext context, String prompt) async {
  final container = ProviderScope.containerOf(context);
  final AiAssistantService primary = container.read(aiAssistantServiceProvider);
  final AiAssistantService fallback = container.read(aiMockAssistantServiceProvider);
  final mapper = container.read(aiHomeMapperProvider);

  Future<AiResponse> callPrimaryThenFallback(String p) async {
    try {
      return await primary.query(p);
    } catch (e) {
      // Try fallback mock service for UI continuity
      try {
        return await fallback.query(p);
      } catch (e2) {
        // rethrow original for visibility to the UI
        throw e;
      }
    }
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<AiResponse>(
              future: callPrimaryThenFallback(prompt) as Future<AiResponse>,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final msg = userFacingMessage(snapshot.error ?? 'unknown', subject: 'AI assistant');
                  return Center(child: Text(msg));
                }
                final response = snapshot.data;
                if (response == null || response.sections.isEmpty) {
                  return const Center(child: Text('No suggestions right now. Try a different prompt.'));
                }
                final sections = mapper.toHomeSections(response);
                return ListView.builder(
                  controller: scrollController,
                  itemCount: sections.length,
                  itemBuilder: (context, index) => HomeSectionWidget(section: sections[index]),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}
