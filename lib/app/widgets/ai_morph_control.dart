import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/ai/presentation/widgets/ai_bubble_icon.dart';

/// Persistent AI launcher bubble pinned to the bottom-right corner of the
/// app shell. A single tap pushes the full-screen [AiChatPage] route
/// (`/ai-chat`); the bubble disappears naturally while that route is on top
/// and returns when it pops.
///
/// No drag/long-press recognizers are registered, so a tap — however long it
/// is held — can never lose the gesture arena.
class AiMorphControl extends ConsumerStatefulWidget {
  const AiMorphControl({super.key});

  @override
  ConsumerState<AiMorphControl> createState() => _AiMorphControlState();
}

class _AiMorphControlState extends ConsumerState<AiMorphControl>
    with SingleTickerProviderStateMixin {
  static const double _bubbleSize = 52;
  static const double _bubbleBottomOffset = 76;

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openChat() {
    HapticFeedback.lightImpact();
    context.push('/ai-chat');
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(
          right: AppSpacing.lg,
          bottom: _bubbleBottomOffset,
        ),
        child: GestureDetector(
          onTap: _openChat,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) {
              final p = _pulse.value;
              return Transform.scale(
                scale: 1.0 + p * 0.06,
                child: Container(
                  key: const ValueKey('ai-bubble-circle'),
                  width: _bubbleSize,
                  height: _bubbleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0057B3), AppColors.brand],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.brand.withValues(alpha: 0.25 + p * 0.2),
                        blurRadius: 12 + p * 8,
                        spreadRadius: 1 + p * 2,
                      ),
                    ],
                  ),
                  child: const AiBubbleIcon(size: 26),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
