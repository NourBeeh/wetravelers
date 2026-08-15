import 'package:flutter/material.dart';

import '../../navigation/app_route.dart';
import '../../theme/app_motion.dart';
import 'floating_nav_destination.dart';
import 'floating_nav_trigger.dart';
import 'navigation_layout.dart';

/// Floating, bottom-anchored navigation overlay.
///
/// A single trigger opens a radially arranged set of destinations around an
/// upper semicircle — reachable with one hand, with premium staggered motion
/// and full accessibility semantics.
///
/// [destinations] drives ordering and is the seam where a future drag/re-order
/// controller will live (positions are index-aligned to it).
class FloatingNavigation extends StatefulWidget {
  const FloatingNavigation({
    super.key,
    this.destinations = AppRoute.primaryDestinations,
    required this.currentRoute,
    required this.onDestinationSelected,
    this.layout = const RadialNavigationLayout(),
  });

  final List<AppRoute> destinations;
  final AppRoute currentRoute;
  final ValueChanged<AppRoute> onDestinationSelected;
  final NavigationLayout layout;

  @override
  State<FloatingNavigation> createState() => _FloatingNavigationState();
}

class _FloatingNavigationState extends State<FloatingNavigation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool get _open =>
      _controller.status == AnimationStatus.forward ||
      _controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
      reverseDuration: AppMotion.fast,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _select(AppRoute route) {
    _controller.reverse();
    widget.onDestinationSelected(route);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvas = constraints.biggest;
        final anchor = Offset(
          canvas.width / 2,
          canvas.height - MediaQuery.paddingOf(context).bottom - 48,
        );
        final positions = widget.layout.positionsFor(
          items: widget.destinations,
          canvas: canvas,
          anchor: anchor,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // Dismissible scrim while open.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final scrim = Theme.of(context).colorScheme.scrim;
                return IgnorePointer(
                  ignoring: !_open,
                  child: GestureDetector(
                    onTap: () => _controller.reverse(),
                    child: ColoredBox(
                      color: scrim.withValues(alpha: 0.28 * _controller.value),
                    ),
                  ),
                );
              },
            ),

            // Index-aligned destinations placed on the arc.
            for (var i = 0; i < positions.length; i++) _buildDestination(i, positions[i]),

            // Trigger pinned to the bottom centre.
            Positioned(
              left: anchor.dx - 32,
              top: anchor.dy - 32,
              width: 64,
              height: 64,
              child: FloatingNavTrigger(open: _open, onToggle: _toggle),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestination(int index, NavigationItemPosition pos) {
    final route = widget.destinations[index];
    const itemSize = 72.0;
    return AnimatedBuilder(
      animation: _controller,
      child: FloatingNavDestinationItem(
        route: route,
        selected: route == widget.currentRoute,
        onTap: () => _select(route),
      ),
      builder: (context, child) {
        final t = _controller.value;
        final shown = Curves.easeOutBack.transform(
          ((t - pos.stagger * 0.4) / 0.6).clamp(0.0, 1.0),
        );
        return Positioned(
          left: pos.center.dx - itemSize / 2,
          top: pos.center.dy - itemSize / 2,
          width: itemSize,
          height: itemSize,
          child: IgnorePointer(
            ignoring: !_open,
            child: Opacity(
              opacity: shown.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.4 + 0.6 * shown, child: child),
            ),
          ),
        );
      },
    );
  }
}