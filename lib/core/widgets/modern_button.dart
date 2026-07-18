// ModernButton is deprecated in favor of AppButton (new design system).
// This file keeps a thin wrapper to preserve compatibility while encouraging new component usage.
import 'package:flutter/material.dart';
import 'app_button.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double height;
  final IconData? icon;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: AppButton(
        label: text,
        onPressed: onPressed,
        loading: isLoading,
        height: height,
        variant: isPrimary ? AppButtonVariant.primary : AppButtonVariant.secondary,
      ),
    );
  }
}

