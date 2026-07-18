import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.height = 56,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: DesignTokens.motionShort);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctl.forward();
  void _onTapUp(_) => _ctl.reverse();
  void _onTapCancel() => _ctl.reverse();

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.loading;

    Color bgColor;
    BoxBorder? border;
    Gradient? gradient;
    Color foreground;

    switch (widget.variant) {
      case AppButtonVariant.secondary:
        bgColor = AppColors.surfaceWhite;
        border = Border.all(color: AppColors.primary.withAlpha((0.14 * 255).round()), width: 1.5);
        foreground = AppColors.primary;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        foreground = AppColors.primary;
        break;
      default:
        bgColor = AppColors.primary;
        gradient = AppColors.primaryGradient;
        foreground = Colors.white;
    }

    return GestureDetector(
      onTapDown: enabled ? _onTapDown : null,
      onTapUp: enabled ? _onTapUp : null,
      onTapCancel: enabled ? _onTapCancel : null,
      onTap: widget.loading || !enabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: DesignTokens.motionShort,
        curve: DesignTokens.motionCurve,
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: gradient == null ? bgColor : null,
          gradient: gradient,
          border: border,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          boxShadow: widget.variant == AppButtonVariant.primary && enabled
              ? DesignTokens.elevatedSoft
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedOpacity(
            duration: DesignTokens.motionShort,
            opacity: enabled ? 1.0 : 0.6,
            child: Center(
              child: widget.loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: GoogleFonts.dmSans(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}


