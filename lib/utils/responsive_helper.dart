import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double blockSizeHorizontal(BuildContext context) => screenWidth(context) / 100;
  static double blockSizeVertical(BuildContext context) => screenHeight(context) / 100;
  
  // Common breakpoints
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1200;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;
  
  // Responsive padding
  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }
  
  // Responsive font sizes
  static double getFontSize(BuildContext context, {double? small, double? medium, double? large}) {
    if (isDesktop(context)) {
      return large ?? 16;
    } else if (isTablet(context)) {
      return medium ?? 14;
    }
    return small ?? 12;
  }
  
  // Responsive spacing
  static double getSpacing(BuildContext context, {double? small, double? medium, double? large}) {
    if (isDesktop(context)) {
      return large ?? 24;
    } else if (isTablet(context)) {
      return medium ?? 16;
    }
    return small ?? 8;
  }
  
  // Responsive grid layout
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    }
    return 2;
  }
  
  // Responsive image sizes
  static double getImageSize(BuildContext context, {double? small, double? medium, double? large}) {
    if (isDesktop(context)) {
      return large ?? 200;
    } else if (isTablet(context)) {
      return medium ?? 150;
    }
    return small ?? 100;
  }
} 