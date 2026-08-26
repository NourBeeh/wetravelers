import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/app/shell.dart';
import 'package:wetravellers/core/storage/offline_cache_providers.dart';
import 'package:wetravellers/core/storage/offline_cache.dart';
import 'package:wetravellers/features/ai/presentation/pages/ai_chat_page.dart';
import 'package:wetravellers/features/ai/presentation/widgets/ai_bubble_icon.dart';

void main() {
  /// Pumps a minimal router (shell + blank home + chat route) so the bubble's
  /// push('/ai-chat') navigation is exercised end-to-end WITHOUT dragging in
  /// unrelated Home-page rendering noise (a pre-existing hotel-card overflow
  /// lives there).
  Future<void> pumpHost(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => WeTravellersShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SizedBox()),
          ],
        ),
        GoRoute(
          path: '/ai-chat',
          builder: (context, state) => const AiChatPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offlineCacheProvider.overrideWithValue(MemoryOfflineCache()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // The shell's pulse animation loops forever — fixed pumps instead of
    // pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> tapBubble(WidgetTester tester) async {
    final bubble = tester.getCenter(
      find.byKey(const ValueKey('ai-bubble-circle')),
    );
    await tester.tapAt(bubble);
  }

  testWidgets(
    'collapsed launcher shows a 52px pulsing bubble without exceptions',
    (tester) async {
      await pumpHost(tester);

      final bubbleSize =
          tester.getSize(find.byKey(const ValueKey('ai-bubble-circle')));
      expect(bubbleSize.width, closeTo(52, 4));
      expect(bubbleSize.height, closeTo(52, 4));
      // Chat page not open yet.
      expect(find.text('Travellers AI'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tapping the bubble pushes the full-screen chat page',
    (tester) async {
      await pumpHost(tester);

      await tapBubble(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Travellers AI'), findsOneWidget);
      expect(find.text('Hi! Ask me about flights, hotels, and more…'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'regression: a long-press (held touch) on the bubble still opens the '
    'chat — no long-press recognizer may win the gesture arena',
    (tester) async {
      await pumpHost(tester);

      final center = tester.getCenter(
        find.byKey(const ValueKey('ai-bubble-circle')),
      );
      final gesture = await tester.startGesture(center);
      // Hold well past the default 500ms long-press timeout.
      await tester.pump(const Duration(milliseconds: 700));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Travellers AI'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'regression: no drag/long-press callbacks remain on the bubble',
    (tester) async {
      await pumpHost(tester);

      final detector = tester.widget<GestureDetector>(
        find.ancestor(
          of: find.byType(AiBubbleIcon),
          matching: find.byType(GestureDetector),
        ).first,
      );
      expect(detector.onLongPressStart, isNull);
      expect(detector.onLongPressMoveUpdate, isNull);
      expect(detector.onLongPressEnd, isNull);
      expect(detector.onTap, isNotNull);
    },
  );

  testWidgets(
    'haptic feedback fires when the bubble opens the chat',
    (tester) async {
      var hapticCalls = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls++;
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await pumpHost(tester);

      await tapBubble(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));
      expect(hapticCalls, greaterThanOrEqualTo(1));
      expect(find.text('Travellers AI'), findsOneWidget);
    },
  );
}
