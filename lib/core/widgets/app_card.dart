import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final bool elevated;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.elevated = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius ?? DesignTokens.radiusMedium),
        boxShadow: elevated ? DesignTokens.softShadow : null,
      ),
      padding: padding ?? EdgeInsets.all(DesignTokens.m),
      child: child,
    );
  }
}


