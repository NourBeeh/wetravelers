import 'package:flutter/widgets.dart';

class AdaptiveLayout {
  static bool isCompact(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600;
  }

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 900;
  }

  static bool isTablet(BuildContext context) => isMedium(context) || isLarge(context);

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return width >= 1200 || height >= 900;
  }

  static int adaptiveColumns(BuildContext context) {
    if (isCompact(context)) return 1;
    if (isMedium(context)) return 2;
    return 3;
  }

  static bool shouldUseTwoPane(BuildContext context) {
    return isLarge(context) || isDesktop(context);
  }
}

