import 'package:flutter/material.dart';

/// Central colour palette for WeTravellers.
///
/// Light mode uses bright white surfaces with soft, elevated cards and light
/// borders. Dark mode uses near-black surfaces with subtle borders.
///
/// This is a design primitive. Consumers should reference these tokens and
/// let [AppTheme] map them onto the active [ThemeData] and [ColorScheme].
@immutable
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------
  static const Color brand = Color(0xFF0071E3);
  static const Color onBrand = Colors.white;
  static const Color brandContainer = Color(0xFFE8F1FD);
  static const Color onBrandContainer = Color(0xFF00397A);

  // ---------------------------------------------------------------------------
  // Semantic / feedback
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color danger = Color(0xFFFF3B30);
  static const Color info = Color(0xFF32ADE6);

  // ---------------------------------------------------------------------------
  // Light surfaces
  // ---------------------------------------------------------------------------
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceSecondaryLight = Color(0xFFF2F2F4);
  static const Color outlineLight = Color(0xFFE4E4E8);
  static const Color dividerLight = Color(0xFFD9DADD);
  static const Color overlayLight = Color(0x14000000); // scrim / focused overlay

  // Light text
  static const Color textPrimaryLight = Color(0xFF1D1D1F);
  static const Color textSecondaryLight = Color(0xFF5F5F63);
  static const Color textTertiaryLight = Color(0xFF8E8E93);
  static const Color textOnSurfaceLight = Color(0xFFF5F5F7);

  // ---------------------------------------------------------------------------
  // Dark surfaces
  // ---------------------------------------------------------------------------
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceSecondaryDark = Color(0xFF26262A);
  static const Color outlineDark = Color(0xFF3A3A3C);
  static const Color dividerDark = Color(0xFF2C2C2E);
  static const Color overlayDark = Color(0x59FFFFFF); // scrim / focused overlay

  // Dark text
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFFAEAEB2);
  static const Color textTertiaryDark = Color(0xFF636366);
  static const Color textOnSurfaceDark = Color(0xFF1D1D1F);
}