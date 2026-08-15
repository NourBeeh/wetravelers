import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Motion tokens driving the premium, smooth animations (opening of the
/// floating navigation, sheet transitions, etc.).
@immutable
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);

  /// Curves for entering/leaving elements.
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve exit = Curves.fastOutSlowIn;

  /// Convenience builders.
  static Duration durationFor(double distance) =>
      Duration(milliseconds: (120 + distance * 18).clamp(150, 420).round());

  static Color scrimColor(Brightness brightness) =>
      brightness == Brightness.dark ? AppColors.overlayDark : AppColors.overlayLight;
}