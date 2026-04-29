import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
    this.height,
    this.width,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          width: width,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (isDark ? Colors.black : Colors.white)
                    .withOpacity(isDark ? 0.08 : 0.1),
                (isDark ? Colors.black : Colors.white)
                    .withOpacity(isDark ? 0.05 : 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.white).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return Container(
      margin: margin,
      child: card,
    );
  }
}

