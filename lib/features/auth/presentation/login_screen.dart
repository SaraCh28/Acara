import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/modern_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref
          .read(authServiceProvider)
          .login(_emailController.text.trim(), _passwordController.text);
      await ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) {
        // If profile has no name, send to name selection first
        if (user.name == 'User' || user.name == user.email.split('@').first) {
          context.go('/name_selection');
        } else {
          context.go('/home');
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        final msg = error.message.toLowerCase();
        String displayMsg = error.message;
        if (msg.contains('email not confirmed') || msg.contains('email_not_confirmed')) {
          displayMsg = 'Please confirm your email first, then try logging in again. '
              'Check your inbox or disable email confirmation in Supabase.';
        } else if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
          displayMsg = 'Incorrect email or password. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMsg),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.primaryGradient,
        backgroundOverlay: const FloatingPattern(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo/Title
                Text(
                  'Acara',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.5),
                const SizedBox(height: 8),
                Text(
                  'Discover Amazing Events',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3),
                const SizedBox(height: 60),
                // Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms),
                        const SizedBox(height: 24),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty || !email.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Enter your password';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot_password'),
                            child: Text(
                              'Forgot password?',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                              .animate(delay: 600.ms)
                              .fadeIn(duration: 500.ms),
                        ),
                        const SizedBox(height: 24),
                        ModernButton(
                          text: 'Login',
                          onPressed: _login,
                          isLoading: _isLoading,
                          isPrimary: true,
                        )
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3),
                const SizedBox(height: 32),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                    ),
                  ],
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 24),
                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google login coming soon'),
                          ),
                        );
                      },
                    )
                        .animate(delay: 900.ms)
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.2),
                    const SizedBox(width: 16),
                    _SocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Apple login coming soon'),
                          ),
                        );
                      },
                    )
                        .animate(delay: 1000.ms)
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: 0.2),
                  ],
                ),
                const SizedBox(height: 24),
                // Demo Credentials Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '📋 Demo Credentials',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'demo@acara.app',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'acara123',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
                    .animate(delay: 1100.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 24),
                // Sign up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(delay: 1200.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(_isHovered ? 0.4 : 0.2),
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: OutlinedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, color: AppColors.primary, size: 22),
          label: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(140, 56),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
