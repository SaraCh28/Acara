import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/modern_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_input.dart';
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
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isAdminMode = false;

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
        if (_isAdminMode) {
          if (user.isAdmin) {
            context.go('/admin');
          } else {
             // Use the standard logout method which clears both Supabase and Riverpod state
             await ref.read(currentUserProvider.notifier).logout();

             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Access Denied: This account is not an admin.')),
             );
          }
        } else {
          // Normal user flow
          if (user.name == 'User' || user.name == user.email.split('@').first) {
            context.go('/name_selection');
          } else {
            context.go('/home');
          }
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
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                    fontSize: 18,
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3),
                const SizedBox(height: 60),
                // Form Card (refactored to use AppCard and AppInput)
                AppCard(
                  color: Colors.white.withAlpha((0.95 * 255).round()),
                  radius: 28,
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(_isAdminMode ? 'Admin Portal' : 'Welcome Back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)).animate(delay: 200.ms).fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        Text(_isAdminMode ? 'Authorized personnel only' : 'Sign in to continue', style: Theme.of(context).textTheme.bodyMedium).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                        const SizedBox(height: 24),
                        // Mode Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isAdminMode = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isAdminMode ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'User',
                                        style: TextStyle(
                                          color: !_isAdminMode ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isAdminMode = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isAdminMode ? AppColors.secondary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Admin',
                                        style: TextStyle(
                                          color: _isAdminMode ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppInput(controller: _emailController, hintText: 'Email address', prefixIcon: const Icon(Icons.email_outlined)).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        AppInput(controller: _passwordController, hintText: 'Password', obscureText: _obscurePassword, prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        const SizedBox(height: 12),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot_password'), child: Text('Forgot password?', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary))).animate(delay: 600.ms).fadeIn(duration: 500.ms)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false)),
                            const SizedBox(width: 8),
                            const Text('Remember me'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ModernButton(text: 'Login', onPressed: _login, isLoading: _isLoading, isPrimary: true).animate(delay: 700.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3),
                const SizedBox(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha((0.8 * 255).round()))), TextButton(onPressed: () => context.push('/signup'), child: Text('Sign up', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)))]).animate(delay: 1200.ms).fadeIn(duration: 500.ms),
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
            color: AppColors.textSecondary.withAlpha(((_isHovered ? 0.4 : 0.2) * 255).round()),
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.textSecondary.withAlpha((0.1 * 255).round()),
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
