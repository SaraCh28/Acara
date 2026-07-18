import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BrandedLogo extends StatelessWidget {
  const BrandedLogo({
    super.key,
    this.size = 92,
    this.showWordmark = true,
    this.wordmarkColor = Colors.white,
    this.tagline,
    this.center = true,
  });

  final double size;
  final bool showWordmark;
  final Color wordmarkColor;
  final String? tagline;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              Container(
                width: size * 0.78,
                height: size * 0.78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.5,
                  ),
                ),
              ),
              Text(
                'A',
                style: GoogleFonts.playwriteNzGuides(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: size * 0.42,
                ),
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.22),
          Text(
            'acara',
            style: GoogleFonts.playwriteNzGuides(
              color: wordmarkColor,
              fontWeight: FontWeight.w400,
              fontSize: size * 0.32,
            ),
          ),
        ],
        if (tagline != null) ...[
          const SizedBox(height: 8),
          Text(
            tagline!,
            style: textTheme.bodyMedium?.copyWith(
              color: wordmarkColor.withValues(alpha: 0.8),
            ),
            textAlign: center ? TextAlign.center : TextAlign.left,
          ),
        ],
      ],
    );
  }
}

