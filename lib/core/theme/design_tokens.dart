import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized design tokens: spacing, radii, shadows, motion curves.
class DesignTokens {
  // Spacing (8px grid)
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;

  // Border radius scale
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // Card elevation / shadows (soft)
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.textSecondary.withAlpha((0.08 * 255).round()),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedSoft = [
    BoxShadow(
      color: AppColors.textSecondary.withAlpha((0.12 * 255).round()),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  // Motion curves and durations
  static const Duration motionShort = Duration(milliseconds: 160);
  static const Duration motionMedium = Duration(milliseconds: 260);
  static const Curve motionCurve = Curves.easeInOutCubic;

  // Opacity tokens
  static const double glassOpacity = 0.08;
}


