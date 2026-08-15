import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../navigation/app_route.dart';

/// Exact display geometry of a single navigation destination.
class NavigationItemPosition {
  const NavigationItemPosition({
    required this.center,
    required this.stagger,
  });

  /// Item centre in overlay/canvas coordinates.
  final Offset center;

  /// Normalised 0..1 delay used to stagger entrance animations.
  final double stagger;
}

/// A strategy for placing floating-navigation destinations.
///
/// This is the extension point for the future drag/re-order capability: any
/// [NavigationLayout] can reposition/reflow the same [AppRoute] list.
abstract class NavigationLayout {
  const NavigationLayout();

  List<NavigationItemPosition> positionsFor({
    required List<AppRoute> items,
    required Size canvas,
    required Offset anchor,
  });
}

/// Places destinations around the upper semicircle above the trigger button.
///
/// Bottom-anchored so the whole menu stays within a comfortable thumb arc
/// (one-handed use). Overflows are collapsed and can be paged later.
class RadialNavigationLayout extends NavigationLayout {
  const RadialNavigationLayout({
    this.maxRadius = 150,
    this.minRadius = 88,
    this.itemDiameter = 64,
    this.safeMargin = 12,
  });

  final double maxRadius;
  final double minRadius;
  final double itemDiameter;
  final double safeMargin;

  @override
  List<NavigationItemPosition> positionsFor({
    required List<AppRoute> items,
    required Size canvas,
    required Offset anchor,
  }) {
    // Positions are returned for every supplied item so callers can map them
    // back to routes by index. The layout clamps spacing/radius internally.
    final count = items.length;
    if (count == 0) {
      return const <NavigationItemPosition>[];
    }

    // Available radial room above the anchor.
    final aboveRoom = anchor.dy - safeMargin - (itemDiameter / 2);
    final horizontalRoom =
        (canvas.width / 2) - safeMargin - (itemDiameter / 2);
    // Shrink for dense menus so outer items stay near the centre.
    final densityShrink = 1.0 + (math.max(count - 6, 0) * 0.12);
    final radius = (math.min(aboveRoom, horizontalRoom) / densityShrink)
        .clamp(minRadius, maxRadius);

    // Upper semicircle from right (0°) through top (90°) to left (180°).
    const startAngle = 0.0;
    const endAngle = math.pi;
    final step = (endAngle - startAngle) / math.max(count - 1, 1);

    return List<NavigationItemPosition>.generate(count, (i) {
      final angle = startAngle + step * i;
      final dx = math.cos(angle) * radius;
      final dy = -math.sin(angle) * radius;
      final center = Offset(anchor.dx + dx, anchor.dy + dy);
      return NavigationItemPosition(
        center: center,
        stagger: i / math.max(count - 1, 1),
      );
    });
  }
}