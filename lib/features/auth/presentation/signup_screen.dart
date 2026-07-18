import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/app_card.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

   Future<void> _signup() async {
     if (!_formKey.currentState!.validate()) return;

     setState(() => _isLoading = true);
     try {
       final user = await ref.read(authServiceProvider).signUp(
             _emailController.text.trim(),
             _passwordController.text,
           );
      ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) context.go('/name_selection');
    } on AuthException catch (error) {
      if (mounted) {
        final msg = error.message.toLowerCase();
        if (msg.contains('already registered') || msg.contains('already in use') || msg.contains('already exists') || msg.contains('user already')) {
          _showAlreadyRegisteredDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
        }
      }
    } catch (error) {
      if (mounted) {
        final msg = error.toString().toLowerCase();
        if (msg.contains('already registered') || msg.contains('already in use') || msg.contains('already exists') || msg.contains('user already')) {
          _showAlreadyRegisteredDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: $error')));
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
           'An account with the email "${_emailController.text.trim()}" already exists. Would you like to log in instead?',
         ),
         actions: [
           TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
           AppButton(
             label: 'Go to Login',
             onPressed: () {
               Navigator.of(ctx).pop();
               context.go('/login');
             },
             variant: AppButtonVariant.primary,
           ),
         ],
       ),
     );
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
                  'Join Acara',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5),
                const SizedBox(height: 8),
                Text(
                  'Create your account today',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                    fontSize: 18,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 600.ms).slideY(begin: -0.3),
                const SizedBox(height: 40),

                // Form Card
                AppCard(
                  color: Colors.white.withAlpha((0.95 * 255).round()),
                  radius: 28,
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text('Create Account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Sign up to discover amazing events', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 24),

                        // Email Field
                        AppInput(controller: _emailController, hintText: 'Email address', prefixIcon: const Icon(Icons.email_outlined)),
                        const SizedBox(height: 16),

                        // Password Field
                        AppInput(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        AppInput(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: _obscureConfirm,
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                        ),
                        const SizedBox(height: 24),

                        AppButton(label: 'Create Account', onPressed: _signup, loading: _isLoading, variant: AppButtonVariant.primary),
                      ],
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 24),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha((0.8 * 255).round()))),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text('Log in', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ).animate(delay: 1000.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
