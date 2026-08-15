import 'package:flutter/material.dart';

/// Elevation tokens producing soft, diffused shadows similar to iOS surfaces.
@immutable
abstract final class AppElevation {
  static const double none = 0;
  static const double sm = 1;
  static const double md = 3;
  static const double lg = 8;
  static const double xl = 16;

  /// Builds a shadow list for [color] background. `level` maps 0..2 to soft
  /// (sm/md/lg) presets; dedicated calls below are preferred over this.
  static List<BoxShadow> shadow({
    required Color background,
    double level = AppElevation.md,
  }) {
    double alpha;
    switch (level) {
      case AppElevation.sm:
        alpha = 0.05;
      case AppElevation.md:
        alpha = 0.10;
      case AppElevation.lg:
        alpha = 0.16;
      default:
        alpha = 0.10;
    }
    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: alpha),
        blurRadius: level * 2.0,
        offset: Offset(0, level * 0.6),
      ),
    ];
  }
}