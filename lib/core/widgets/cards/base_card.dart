import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';

/// The shared layout container for every card in the system.
///
/// Provides the unified surface language: white/surface background,
/// [AppRadius.lg] corners, a subtle shadow, and pressed / disabled / loading
/// states. Content is passed through [child]; compose the other card
/// components inside it.
///
/// Responsive: horizontal padding tightens slightly on very narrow screens.
class BaseCard extends StatefulWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.loading = false,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.margin = EdgeInsets.zero,
    this.semanticsLabel,
  });

  final Widget child;

  /// When null the card is display-only (no ink/pressed state).
  final VoidCallback? onTap;

  /// False renders the card at reduced opacity and swallows taps.
  final bool enabled;
  final bool loading;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry margin;

  /// Accessible label; the card is also flagged `button` when interactive.
  final String? semanticsLabel;

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && !widget.loading && widget.onTap != null;

  void _setPressed(bool value) {
    if (!_interactive) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: widget.semanticsLabel,
      button: _interactive,
      enabled: widget.enabled,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: tighten horizontal padding on very narrow screens.
          final basePadding =
              widget.padding ?? const EdgeInsets.all(AppSpacing.lg);
          final effectivePadding =
              constraints.maxWidth < 360 && basePadding is EdgeInsets
                  ? basePadding.copyWith(
                      left: AppSpacing.md, right: AppSpacing.md)
                  : basePadding;

          return Padding(
            padding: widget.margin,
            child: Opacity(
              opacity: widget.enabled ? 1 : 0.55,
              child: AnimatedScale(
                scale: _pressed ? 0.98 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTapDown: (_) => _setPressed(true),
                  onTapUp: (_) => _setPressed(false),
                  onTapCancel: () => _setPressed(false),
                  onTap: _interactive ? widget.onTap : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? scheme.surface,
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: widget.borderColor ??
                            scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          // Brightness-aware so cards stay legible in dark mode.
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(AppRadius.lg),
                      child: Stack(
                        children: [
                          Padding(
                            padding: effectivePadding,
                            child: widget.child,
                          ),
                          if (widget.loading)
                            Positioned.fill(
                              child: ColoredBox(
                                color: scheme.surface.withValues(alpha: 0.6),
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
