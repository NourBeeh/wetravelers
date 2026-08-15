import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale for WeTravellers.
///
/// Weights, sizes and letter spacing follow an Apple-quality system while
/// remaining fully adaptive on Android (system font families are used so no
/// bundled font assets are required).
@immutable
class AppTypography {
  const AppTypography._({
    required this.textColor,
    required this.textMutedColor,
  });

  factory AppTypography.forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppTypography._(
      textColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      textMutedColor: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
    );
  }

  final Color textColor;
  final Color textMutedColor;

  // ---------------------------------------------------------------------------
  // Font sizes
  // ---------------------------------------------------------------------------
  static const double fontSizeDisplay = 34;
  static const double fontSizeHeadline = 28;
  static const double fontSizeTitle = 22;
  static const double fontSizeBodyLarge = 17;
  static const double fontSizeBody = 15;
  static const double fontSizeCaption = 13;
  static const double fontSizeLabel = 11;

  // ---------------------------------------------------------------------------
  // Weights
  // ---------------------------------------------------------------------------
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  TextStyle _style({
    required double size,
    required FontWeight weight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color ?? textColor,
      height: height,
      fontFamilyFallback: const <String>['.SF Pro Text', 'Roboto'],
    );
  }

  TextStyle get display => _style(size: fontSizeDisplay, weight: weightBold, height: 1.15);
  TextStyle get headline => _style(size: fontSizeHeadline, weight: weightBold, height: 1.2);
  TextStyle get title => _style(size: fontSizeTitle, weight: weightSemibold, height: 1.25);
  TextStyle get bodyLarge => _style(size: fontSizeBodyLarge, weight: weightRegular, height: 1.4);
  TextStyle get bodyLargeMedium =>
      _style(size: fontSizeBodyLarge, weight: weightSemibold, height: 1.35);
  TextStyle get body => _style(size: fontSizeBody, weight: weightRegular, height: 1.4);
  TextStyle get bodyMedium => _style(size: fontSizeBody, weight: weightMedium, height: 1.35);
  TextStyle get caption => _style(size: fontSizeCaption, weight: weightRegular, height: 1.3);
  TextStyle get captionSemibold =>
      _style(size: fontSizeCaption, weight: weightSemibold, height: 1.3);
  TextStyle get label => _style(
        size: fontSizeLabel,
        weight: weightSemibold,
        color: textMutedColor,
        height: 1.2,
      );

  /// Builds a full [TextTheme] wired to the active palette.
  ///
  /// No [baseStyle] is applied; adjust text styles globally via
  /// [ThemeData.textTheme] or per-widget.
  TextTheme buildTextTheme() {
    return TextTheme(
      displayLarge: display.copyWith(color: textColor),
      displayMedium: headline.copyWith(color: textColor),
      displaySmall: title.copyWith(color: textColor),
      headlineLarge: headline.copyWith(color: textColor),
      headlineMedium: title.copyWith(color: textColor),
      headlineSmall: bodyLarge.copyWith(color: textColor),
      titleLarge: title.copyWith(color: textColor),
      titleMedium: bodyLargeMedium.copyWith(color: textColor),
      titleSmall: bodyMedium.copyWith(color: textColor),
      bodyLarge: bodyLarge.copyWith(color: textColor),
      bodyMedium: body.copyWith(color: textColor),
      bodySmall: caption.copyWith(color: textColor),
      labelLarge: bodyMedium.copyWith(color: textColor),
      labelMedium: captionSemibold.copyWith(color: textMutedColor),
      labelSmall: label.copyWith(color: textMutedColor),
    );
  }
}
