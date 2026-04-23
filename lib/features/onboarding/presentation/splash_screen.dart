import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_preferences_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _bootstrap();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await ref.read(appPreferencesProvider.notifier).restore();
    await ref.read(paymentMethodsProvider.notifier).restore();
    final user = await ref.read(currentUserProvider.notifier).restoreSession();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) {
      return;
    }

    if (user == null) {
      context.go('/onboarding');
      return;
    }

    context.go(resolvePostAuthRoute(user));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.backgroundLight,
              ],
            ),
          ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.event_available, size: 80, color: AppColors.accent),
                ),
                const SizedBox(height: 32),
                Text(
                  'ACARA',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.textPrimaryLight,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 2,
                  width: 40,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 24),
                Text(
                  'EXCEPTIONAL EXPERIENCES',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    letterSpacing: 4,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
