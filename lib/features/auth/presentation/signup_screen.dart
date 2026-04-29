import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/modern_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../services/auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signUp(
            _emailController.text.trim(),
            _passwordController.text,
          );
      ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) {
        context.go('/name_selection');
      }
    } on AuthException catch (error) {
      if (mounted) {
        final msg = error.message.toLowerCase();
        // Email already exists — guide user to login instead
        if (msg.contains('already registered') ||
            msg.contains('already in use') ||
            msg.contains('already exists') ||
            msg.contains('user already')) {
          _showAlreadyRegisteredDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message)),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        final msg = error.toString().toLowerCase();
        if (msg.contains('already registered') ||
            msg.contains('already in use') ||
            msg.contains('already exists') ||
            msg.contains('user already')) {
          _showAlreadyRegisteredDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: $error')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAlreadyRegisteredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account Already Exists'),
        content: Text(
          'An account with the email "${_emailController.text.trim()}" already exists. '
          'Would you like to log in instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.accentGradient,
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
                  'Join Acara',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.5),
                const SizedBox(height: 8),
                Text(
                  'Create your account today',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3),
                const SizedBox(height: 40),
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
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to discover amazing events',
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
                            if ((value ?? '').length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 24),
                        ModernButton(
                          text: 'Create Account',
                          onPressed: _signup,
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
                const SizedBox(height: 24),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text(
                        'Log in',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 500.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
