import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/app_preferences_service.dart';

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
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/name_selection'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.paddingLarge),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.profileImageUrl != null
                        ? AssetImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Bookings', value: '$bookingCount'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Saved', value: '$bookmarkCount'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interests',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests.isEmpty
                          ? [const Text('No interests selected yet')]
                          : user.interests
                                .map((interest) => Chip(label: Text(interest)))
                                .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.city == null
                          ? 'Not set'
                          : '${user.city}, ${user.country}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: 'My Bookings',
                    onTap: () => context.push('/profile/bookings'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    onTap: () => context.push('/profile/payments'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_border,
                    title: 'Interests & Preferences',
                    onTap: () => context.push('/interests'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => context.push('/profile/settings'),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final prefs = ref.watch(appPreferencesProvider);
                      return SwitchListTile(
                        value: prefs.isDarkMode,
                        onChanged: (value) => ref.read(appPreferencesProvider.notifier).toggleDarkMode(),
                        title: const Text('Dark Mode'),
                        secondary: Icon(
                          prefs.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () async {
                      await ref.read(currentUserProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
