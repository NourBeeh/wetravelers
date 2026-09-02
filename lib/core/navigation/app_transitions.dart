import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/core/theme/app_motion.dart';

/// The unified page-transition language of the app ("fade-through").
///
/// - Push: outgoing page fades + scales down to 96%; incoming page fades in
///   and scales up from 92% with the standard ease-out curve.
/// - Pop: the mirrored sequence.
///
/// Every route in the app uses this single transition so navigation feels
/// like one continuous premium surface.
class FadeThroughTransition extends CustomTransitionPage<void> {
  FadeThroughTransition({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    Duration duration = AppMotion.normal,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: AppMotion.standard,
              reverseCurve: AppMotion.exit,
            );
            return FadeThroughBuilder(
              animation: curved,
              child: child,
            );
          },
        );
}

/// Core fade-through builder shared by [FadeThroughTransition] and any
/// custom usages (dialogs, sheets, hero surfaces).
class FadeThroughBuilder extends StatelessWidget {
  const FadeThroughBuilder({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  static const double _incomingScaleFrom = 0.92;
  static const double _outgoingScaleTo = 0.96;
  static const double _incomingFadePeak = 0.4;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Phase 1 (0 -> 0.4): outgoing content fades to invisible while
        // scaling down. Phase 2 (0.4 -> 1): incoming content fades in while
        // scaling up from 92%. This mirrors the Material fade-through spec.
        final t = animation.value;
        if (t <= _incomingFadePeak) {
          final phase = t / _incomingFadePeak;
          return Opacity(
            opacity: 1 - phase,
            child: Transform.scale(
              scale: 1 - (1 - _outgoingScaleTo) * phase,
              child: child,
            ),
          );
        }
        final phase = (t - _incomingFadePeak) / (1 - _incomingFadePeak);
        return Opacity(
          opacity: phase,
          child: Transform.scale(
            scale: _incomingScaleFrom + (1 - _incomingScaleFrom) * phase,
            child: child,
          ),
        );
      },
    );
  }
}

/// Convenience wrapper: wraps [child] with the unified fade-through
/// transition for go-router page builders.
CustomTransitionPage<void> fadeThroughPage({
  required Widget child,
  Object? arguments,
  String? name,
}) {
  return FadeThroughTransition(
    child: child,
    arguments: arguments,
    name: name,
  );
}
