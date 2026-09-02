import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_motion.dart';
import 'package:wetravellers/core/theme/app_radius.dart';

/// Destination of the attached bottom navigation bar.
enum AppBottomNavDestination {
  home(Icons.home_outlined, Icons.home_rounded),
  search(Icons.search, Icons.search_rounded),
  ai(null, null),
  groups(Icons.groups_outlined, Icons.groups_rounded),
  explore(Icons.explore_outlined, Icons.explore_rounded);

  const AppBottomNavDestination(this.icon, this.selectedIcon);

  final IconData? icon;
  final IconData? selectedIcon;
}

/// The unified attached bottom navigation bar.
///
/// Five slots with the AI assistant as a solid-violet circular button in the
/// centre. Tabs animate with a quiet scale + colour ramp; layout mirrors
/// automatically under RTL.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
    this.onAiPressed,
  });

  /// Currently highlighted destination (AI is highlighted only while its
  /// full-screen route is open).
  final AppBottomNavDestination current;

  /// Fires with the selected tab destination.
  final ValueChanged<AppBottomNavDestination> onSelect;

  /// Separate handler so the AI centre button can push the full-screen
  /// assistant instead of switching tabs.
  final VoidCallback? onAiPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final destination in AppBottomNavDestination.values)
                Expanded(
                  child: destination == AppBottomNavDestination.ai
                      ? _AiCentreButton(
                          active: current == AppBottomNavDestination.ai,
                          onPressed: onAiPressed,
                        )
                      : _NavItem(
                          destination: destination,
                          selected: current == destination,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelect(destination);
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : AppColors.textTertiary;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashFactory: NoSplash.splashFactory,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: AppMotion.fast,
              curve: AppMotion.standard,
              child: Icon(
                (selected ? destination.selectedIcon : destination.icon) ??
                    Icons.error_outline,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppMotion.fast,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1,
                  ),
              child: Text(
                destination.name[0].toUpperCase() + destination.name.substring(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The AI centre button — solid violet circle with a quiet breathing glow.
class _AiCentreButton extends StatefulWidget {
  const _AiCentreButton({required this.active, this.onPressed});

  final bool active;
  final VoidCallback? onPressed;

  @override
  State<_AiCentreButton> createState() => _AiCentreButtonState();
}

class _AiCentreButtonState extends State<_AiCentreButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final glow = 0.16 + _pulse.value * 0.14;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.ai.withValues(alpha: glow),
                  blurRadius: 18 + _pulse.value * 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: AppColors.ai,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _handleTap,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 26,
                      color: Colors.white.withValues(
                        alpha: 0.9 + _pulse.value * 0.1,
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
