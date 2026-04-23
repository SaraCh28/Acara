import 'package:flutter/material.dart';

class AppColors {
  // COMMON COLORS
  static const Color primary = Color(0xFF7356F1); // Vibrant Indigo
  static const Color accent = Color(0xFFFFD700); // Premium Gold
  static const Color secondary = Color(0xFF2D2D44); // Slate Deep
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF00C853);

  // LUXE DARK PALETTE
  static const Color background = Color(0xFF0F0F1A); // Almost Black - Premium Dark
  static const Color surface = Color(0xFF1E1E2E); // Elevated Surface
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C3);
  static const Color textHint = Color(0xFF676779);
  static const Color border = Color(0xFF2D2D44);
  
  // LUXE LIGHT PALETTE
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF676779);
  static const Color textHintLight = Color(0xFFB0B0C3);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Constants for Glassmorphism
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
}
