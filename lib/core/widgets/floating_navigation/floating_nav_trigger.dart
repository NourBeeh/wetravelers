import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_elevation.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';

/// The main floating trigger button (bottom-centre).
///
/// Morphs to a "close" glyph while the menu is open so its purpose stays
/// unambiguous (good accessibility).
class FloatingNavTrigger extends StatelessWidget {
  const FloatingNavTrigger({
    super.key,
    required this.open,
    required this.onToggle,
    this.heroTag,
  });

  final bool open;
  final VoidCallback onToggle;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = AppSpacing.xxl + AppSpacing.lg; // 64

    return Semantics(
      button: true,
      label: open ? 'Close navigation menu' : 'Open navigation menu',
      toggled: open,
      child: Tooltip(
        message: open ? 'Close menu' : 'Open menu',
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, AppColors.brand.withValues(alpha: 0.85)],
            ),
            boxShadow: AppElevation.shadow(
              background: scheme.primary,
              level: AppElevation.lg,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  open ? Icons.close : Icons.navigation_rounded,
                  key: ValueKey<bool>(open),
                  color: scheme.onPrimary,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}