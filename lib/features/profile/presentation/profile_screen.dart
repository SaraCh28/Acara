import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/bookmark_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bookingCount = ref
        .watch(userBookingsProvider)
        .where((booking) => booking.userId == user?.id)
        .length;
    final bookmarkCount = ref
        .watch(userBookmarksProvider)
        .where((bookmark) => bookmark.userId == user?.id)
        .length;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MEMBERSHIP'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.surface,
                          backgroundImage: user.profileImageUrl != null
                              ? AssetImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? const Icon(Icons.person, size: 54, color: Colors.white24)
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: GestureDetector(
                          onTap: () => context.push('/name_selection'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textHint,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                   Expanded(child: _StatCard(label: 'EXPERIENCES', value: '$bookingCount')),
                   const SizedBox(width: 16),
                   Expanded(child: _StatCard(label: 'WISHLIST', value: '$bookmarkCount')),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // MENU ITEMS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      title: 'My Reservations',
                      onTap: () => context.push('/profile/bookings'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.interests_outlined,
                      title: 'Tailored Preferences',
                      onTap: () => context.push('/interests'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.security_outlined,
                      title: 'Security & Access',
                      onTap: () => context.push('/profile/settings'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                isCenter: true,
                textColor: Colors.redAccent.withValues(alpha: 0.8),
                onTap: () async {
                  await ref.read(currentUserProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: Colors.white10, indent: 60);

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isCenter = false,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textColor ?? AppColors.accent, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      trailing: isCenter ? null : const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 14),
      onTap: onTap,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white38,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
