import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String avatarInitial;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.avatarInitial,
    this.actions,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: avatarUrl != null ? AssetImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        avatarInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: 0.8),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: 0.8),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms),
                ],
              ),
            ),
            if (actions != null)
              Row(
                children: actions!
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.2),
                        ))
                    .toList(),
              ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.2),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final int? delayMs;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.gradient,
    this.onTap,
    this.delayMs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultGradient = AppColors.primaryGradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? defaultGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient?.colors.first ?? AppColors.primary)
                  .withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: delayMs ?? 0))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.textHint.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

