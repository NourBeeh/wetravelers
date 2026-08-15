import 'package:flutter/material.dart';
import '../../navigation/app_route.dart';
import '../../theme/app_spacing.dart';

/// A single destination inside the floating menu.
///
/// Carries an icon, a short label and the canonical accessibility semantics.
class FloatingNavDestinationItem extends StatelessWidget {
  const FloatingNavDestinationItem({
    super.key,
    required this.route,
    required this.selected,
    required this.onTap,
  });

  final AppRoute route;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: route.label,
      child: Tooltip(
        message: route.label,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: selected ? scheme.primary : scheme.surface.withValues(alpha: isDark ? 0.92 : 0.98),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.14),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppSpacing.xxl + AppSpacing.xs, // 56
              height: AppSpacing.xxl + AppSpacing.xs,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    route.iconFor(selected: selected),
                    color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      route.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}