import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isSmallPhone => screenWidth < 360;
  bool get isLargePhone => screenWidth >= 430;
  bool get isTablet => screenWidth >= 600;

  double scale(
    double value, {
    double baseWidth = 390,
    double minScale = 0.85,
    double maxScale = 1.22,
  }) {
    final factor = (screenWidth / baseWidth).clamp(minScale, maxScale);
    return value * factor;
  }

  double fs(double size) => scale(size, minScale: 0.9, maxScale: 1.15);

  EdgeInsets pagePadding({double horizontal = 16, double vertical = 12}) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal),
      vertical: scale(vertical),
    );
  }
}
