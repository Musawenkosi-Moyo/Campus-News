import 'package:flutter/material.dart';

class AppColors {
  // Primary color (HSL 220, 80%, 55%)
  static const Color primary = Color.fromARGB(255, 70, 130, 255);
  static const Color primaryVariant = Color.fromARGB(255, 55, 115, 230);

  // Secondary color
  static const Color secondary = Color.fromARGB(255, 255, 165, 0); // orange
  static const Color secondaryVariant = Color.fromARGB(255, 230, 145, 0);

  // Background / surface
  static const Color background = Color.fromARGB(255, 18, 18, 18); // dark background for dark mode
  static const Color surface = Color.fromARGB(255, 28, 28, 30);

  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.white70;
  static const Color onSurface = Colors.white70;

  // Error
  static const Color error = Colors.redAccent;
}
