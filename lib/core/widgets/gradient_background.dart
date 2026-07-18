import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final LinearGradient? gradient;
  final Widget child;
  final Widget? backgroundOverlay;

  const GradientBackground({
    super.key,
    this.gradient,
    required this.child,
    this.backgroundOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          if (backgroundOverlay != null) backgroundOverlay!,
          child,
        ],
      ),
    );
  }
}

// Floating Background Pattern
class FloatingPattern extends StatefulWidget {
  const FloatingPattern({super.key});

  @override
  State<FloatingPattern> createState() => _FloatingPatternState();
}

class _FloatingPatternState extends State<FloatingPattern>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -50 + (50 * _controller.value * 2),
              right: -50,
              child: _buildCircle(120, AppColors.secondary.withOpacity(0.1)),
            ),
            Positioned(
              bottom: -30 + (30 * _controller.value * 2),
              left: -50,
              child: _buildCircle(100, AppColors.accent.withOpacity(0.1)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<LinearGradient>? gradients;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.gradients,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _currentGradientIndex = 0;

  final List<LinearGradient> defaultGradients = [
    AppColors.primaryGradient,
    AppColors.accentGradient,
    AppColors.skyMistGradient,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      if (_controller.value > 0.33 && _controller.value < 0.34) {
        setState(() => _currentGradientIndex = 1);
      } else if (_controller.value > 0.66 && _controller.value < 0.67) {
        setState(() => _currentGradientIndex = 2);
      } else if (_controller.value < 0.01) {
        setState(() => _currentGradientIndex = 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = widget.gradients ?? defaultGradients;

    return Container(
      decoration: BoxDecoration(
        gradient: gradients[_currentGradientIndex],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: FloatingPattern()),
          widget.child,
        ],
      ),
    );
  }
}

