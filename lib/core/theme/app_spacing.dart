import 'package:flutter/material.dart';

/// App Spacing, Inset & Dimension Constants
class AppSpacing {
  AppSpacing._();

  // Spacing Units
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double sm = 12.0;
  static const double m = 16.0;
  static const double l = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: m,
    vertical: m,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(m);

  // Border Radii
  static const double radiusXs = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius roundedS = BorderRadius.all(Radius.circular(radiusS));
  static const BorderRadius roundedM = BorderRadius.all(Radius.circular(radiusM));
  static const BorderRadius roundedL = BorderRadius.all(Radius.circular(radiusL));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXl = 48.0;

  // Heights
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
}
