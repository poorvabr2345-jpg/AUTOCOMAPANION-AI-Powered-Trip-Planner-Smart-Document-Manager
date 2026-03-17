import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double desktopMaxWidth = 1200;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Check if current screen is web (desktop or large tablet)
  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
  }

  /// Get responsive grid count
  static int getGridCrossAxisCount(BuildContext context, {int mobileCount = 1, int tabletCount = 2, int desktopCount = 3}) {
    if (isMobile(context)) return mobileCount;
    if (isTablet(context)) return tabletCount;
    return desktopCount;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {required double mobile, required double tablet, required double desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(BuildContext context, {required T mobile, required T tablet, required T desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive constraint width for centered content
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 700;
    } else {
      return 1200;
    }
  }

  /// Build responsive layout with different widgets for mobile/tablet/desktop
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
