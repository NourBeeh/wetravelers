import 'package:flutter/widgets.dart';
import '../../core/theme/app_breakpoints.dart';

/// Build-context / layout helpers.
extension WidgetContextExtension on BuildContext {
  /// Total width of the current layout.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Total height of the current layout.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// True when this layout is phone-width (compact).
  bool get isCompact => screenWidth < AppBreakpoints.compact;

  /// True when this layout is a tablet.
  bool get isMedium =>
      screenWidth >= AppBreakpoints.compact && screenWidth < AppBreakpoints.medium;

  /// True when this layout is a wide/desktop surface.
  bool get isExpanded => screenWidth >= AppBreakpoints.expanded;

  /// Safe top inset (status bar / notch).
  double get safeTop => MediaQuery.paddingOf(this).top;

  /// Safe bottom inset (home indicator / gesture bar).
  double get safeBottom => MediaQuery.paddingOf(this).bottom;
}