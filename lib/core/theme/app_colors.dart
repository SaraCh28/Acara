import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette (User Provided)
  static const Color black = Color(0xFF000807);
  static const Color coolSky = Color(0xFF65AFFF);
  static const Color trueCobalt = Color(0xFF002987);
  static const Color pinkMist = Color(0xFFEDA2C0);
  static const Color ghostWhite = Color(0xFFFBF9FF);
  static const Color background = Color(0xFFFDFFFC);

  // Primary Colors
  static const Color primary = trueCobalt; // Navy Blue for main app color
  static const Color primaryLight = Color(0xFF33539F);
  static const Color primaryDark = Color(0xFF001D60);
  
  static const Color secondary = coolSky; // Cool sky as second accent
  static const Color secondaryLight = Color(0xFF8DC4FF);
  
  static const Color accent = pinkMist; // Pink mist for small little accents
  static const Color accentLight = Color(0xFFF1BED3);

  // Additional gradient colors
  static const Color gradientStart = trueCobalt;
  static const Color gradientEnd = coolSky;
  static const Color accentGradientStart = pinkMist;
  static const Color accentGradientEnd = trueCobalt;

  // Background & Surface
  static const Color backgroundLight = background;
  static const Color backgroundDark = black;
  static const Color surfaceWhite = ghostWhite;
  static const Color surface = surfaceWhite;
  static const Color surfaceDark = Color(0xFF0A1211); // Tinted dark surface
  static const Color surfaceDarkAlt = Color(0xFF152220);

  // Glass Morphism Colors
  static const Color glassLight = Color(0x80FBF9FF); // Translucent ghost white
  static const Color glassDark = Color(0x80000807); // Translucent black

  // Text Colors
  static const Color textPrimary = black;
  static const Color textSecondary = Color(0xFF4A5554); // Dark charcoal grey for subtext
  static const Color textHint = Color(0xFF7A8685);
  static const Color textLight = Colors.white;
  static const Color textDark = black;

  // Semantic Colors
  static const Color border = Color(0xFFE0E5E4);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color info = coolSky;
  static const Color infoLight = Color(0xFF8DC4FF);

  // Dark Theme Colors
  static const Color darkCardBackground = Color(0xFF152220);
  static const Color darkInputBackground = Color(0xFF0A1211);

  // Utility
  static const Color transparent = Color(0x00000000);
  static const Color divider = Color(0xFFE0E5E4);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [trueCobalt, coolSky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [pinkMist, trueCobalt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navySkyGradient = LinearGradient(
    colors: [trueCobalt, coolSky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkNavyGradient = LinearGradient(
    colors: [pinkMist, trueCobalt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyMistGradient = LinearGradient(
    colors: [coolSky, pinkMist],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), pinkMist],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
