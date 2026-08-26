import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_radius.dart';

/// A reusable frosted-glass surface used for on-image overlays (favorite
/// toggle, translucent badge/rating/feature pills placed over a photo).
///
/// Centralises the BackdropFilter + translucent-tint + hairline-border recipe
/// so feature cards never re-implement glassmorphism themselves. Blur/tint are
/// brightness-aware by default (translucent white in light, translucent white
/// on black in dark) but can be overridden per instance.
class CardGlass extends StatelessWidget {
  const CardGlass({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.blur = 12,
    this.tint,
    this.borderColor,
    this.borderWidth = 1,
    this.alignment,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  /// Backdrop blur radius in logical pixels.
  final double blur;

  /// Base layer tint; defaults to a brightness-aware white.
  final Color? tint;

  /// Hairline border colour; defaults to a brightness-aware white.
  final Color? borderColor;
  final double borderWidth;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);
    final effectiveTint = tint ??
        (isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.55));
    final effectiveBorder = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.45));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          alignment: alignment,
          decoration: BoxDecoration(
            color: effectiveTint,
            borderRadius: radius,
            border: Border.all(color: effectiveBorder, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}
