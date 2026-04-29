import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C4CF1);
  static const Color primaryLight = Color(0xFF9078F4);
  static const Color primaryDark = Color(0xFF5436C8);
  static const Color secondary = Color(0xFF4D8DFF);
  static const Color secondaryLight = Color(0xFF7BA7FF);
  static const Color accent = Color(0xFFFF4FD8);
  static const Color accentLight = Color(0xFFFF7FEA);

  // Additional gradient colors
  static const Color gradientStart = Color(0xFF6C4CF1);
  static const Color gradientEnd = Color(0xFF4D8DFF);
  static const Color accentGradientStart = Color(0xFFFF4FD8);
  static const Color accentGradientEnd = Color(0xFF6C4CF1);

  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surface = surfaceWhite;
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceDarkAlt = Color(0xFF334155);

  // Glass Morphism Colors
  static const Color glassLight = Color(0x80FFFFFF); // Translucent white
  static const Color glassDark = Color(0x80000000); // Translucent black

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);

  // Semantic Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFB8C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color info = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFF42A5F5);

  // Dark Theme Colors
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkInputBackground = Color(0xFF0F172A);

  // Utility
  static const Color transparent = Color(0x00000000);
  static const Color divider = Color(0xFFE0E0E0);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentGradientStart, accentGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleBlueGradient = LinearGradient(
    colors: [Color(0xFF6C4CF1), Color(0xFF4D8DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFFF4FD8), Color(0xFF6C4CF1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF4D8DFF), Color(0xFF7BA7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF4FD8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
