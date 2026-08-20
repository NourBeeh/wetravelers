import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_elevation.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Builds the central [ThemeData] for WeTravellers.
///
/// Produces a bright, soft-edged Light theme and a near-black Dark theme,
/// both mapped from the shared [AppTokens] so visual identity stays coherent.
@immutable
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final tokens = AppTokens.forBrightness(brightness);
    final palette = tokens.colors;
    final isDark = brightness == Brightness.dark;
    final typography = AppTypography.forBrightness(brightness);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.brand,
      onPrimary: AppColors.onBrand,
      primaryContainer: AppColors.brandContainer,
      onPrimaryContainer: AppColors.onBrandContainer,
      secondary: AppColors.brand,
      onSecondary: AppColors.onBrand,
      secondaryContainer: palette.surfaceSecondary,
      onSecondaryContainer: palette.textPrimary,
      tertiary: AppColors.info,
      onTertiary: AppColors.onBrand,
      error: AppColors.danger,
      onError: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.surfaceSecondary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.outline,
      outlineVariant: palette.divider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: palette.textPrimary,
      onInverseSurface: palette.surface,
      inversePrimary: AppColors.brandContainer,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: tokens.typography.buildTextTheme(),
      scaffoldBackgroundColor: palette.background,
    );

    final shadowSm = AppElevation.shadow(background: palette.surface, level: AppElevation.sm);

    return base.copyWith(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: AppElevation.md,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: BorderSide(color: palette.outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: AppElevation.none,
        scrolledUnderElevation: shadowSm.first.blurRadius,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: typography.bodyLargeMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: palette.outline),
        ),
        hintStyle: typography.bodyMedium.copyWith(color: palette.textTertiary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: AppColors.brandContainer,
        elevation: AppElevation.none,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}