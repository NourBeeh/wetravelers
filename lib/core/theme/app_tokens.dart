import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'app_colors.dart';
import 'app_elevation.dart';
import 'app_motion.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Aggregates every design token set in a single, brightness-aware bundle.
///
/// A single [AppTokens] instance is produced per [Brightness] by [AppTokens.forBrightness]
/// and consumed by [AppTheme] when building [ThemeData].
@immutable
class AppTokens {
  const AppTokens._({
    required this.brightness,
    required this.colors,
    required this.typography,
  });

  factory AppTokens.forBrightness(Brightness brightness) {
    return AppTokens._(
      brightness: brightness,
      colors: brightness == Brightness.dark ? const _DarkPalette() : const _LightPalette(),
      typography: AppTypography.forBrightness(brightness),
    );
  }

  final Brightness brightness;
  final AppColorPalette colors;
  final AppTypography typography;

  // Non-color token sets are brightness-independent.
  static const AppSpacingToken spacing = AppSpacingToken();
  static const AppRadiusToken radius = AppRadiusToken();
  static const AppElevationToken elevation = AppElevationToken();
  static const AppMotionToken motion = AppMotionToken();
  static const AppBreakpointsToken breakpoints = AppBreakpointsToken();
}

/// Value-object wrappers so tokens can be accessed uniformly from [AppTokens].
@immutable
class AppColorPalette {
  const AppColorPalette({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.outline,
    required this.divider,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnSurface,
  });

  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color outline;
  final Color divider;
  final Color overlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnSurface;
}

/// Immutable palette repositories.
@immutable
class _LightPalette extends AppColorPalette {
  const _LightPalette()
      : super(
          background: AppColors.backgroundLight,
          surface: AppColors.surfaceLight,
          surfaceSecondary: AppColors.surfaceSecondaryLight,
          outline: AppColors.outlineLight,
          divider: AppColors.dividerLight,
          overlay: AppColors.overlayLight,
          textPrimary: AppColors.textPrimaryLight,
          textSecondary: AppColors.textSecondaryLight,
          textTertiary: AppColors.textTertiaryLight,
          textOnSurface: AppColors.textOnSurfaceLight,
        );
}

@immutable
class _DarkPalette extends AppColorPalette {
  const _DarkPalette()
      : super(
          background: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          surfaceSecondary: AppColors.surfaceSecondaryDark,
          outline: AppColors.outlineDark,
          divider: AppColors.dividerDark,
          overlay: AppColors.overlayDark,
          textPrimary: AppColors.textPrimaryDark,
          textSecondary: AppColors.textSecondaryDark,
          textTertiary: AppColors.textTertiaryDark,
          textOnSurface: AppColors.textOnSurfaceDark,
        );
}

/// Non-color token sets (concrete, const).
@immutable
class AppSpacingToken {
  const AppSpacingToken();
  double get xxs => AppSpacing.xxs;
  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
  double get xxxl => AppSpacing.xxxl;
}

@immutable
class AppRadiusToken {
  const AppRadiusToken();
  double get xs => AppRadius.xs;
  double get sm => AppRadius.sm;
  double get md => AppRadius.md;
  double get lg => AppRadius.lg;
  double get xl => AppRadius.xl;
  double get pill => AppRadius.pill;
}

@immutable
class AppElevationToken {
  const AppElevationToken();
  double get none => AppElevation.none;
  double get sm => AppElevation.sm;
  double get md => AppElevation.md;
  double get lg => AppElevation.lg;
  double get xl => AppElevation.xl;
}

@immutable
class AppMotionToken {
  const AppMotionToken();
  Duration get fast => AppMotion.fast;
  Duration get normal => AppMotion.normal;
  Duration get slow => AppMotion.slow;
  Curve get standard => AppMotion.standard;
  Curve get emphasized => AppMotion.emphasized;
  Curve get exit => AppMotion.exit;
}

@immutable
class AppBreakpointsToken {
  const AppBreakpointsToken();
  double get compact => AppBreakpoints.compact;
  double get medium => AppBreakpoints.medium;
  double get expanded => AppBreakpoints.expanded;
}