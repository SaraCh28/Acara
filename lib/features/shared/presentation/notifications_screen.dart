import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/event_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final events = ref.watch(eventsProvider);
    final bookings = ref
        .watch(userBookingsProvider)
        .where((booking) => user != null && booking.userId == user.id)
        .toList();

    final items = <_NotificationItem>[
      if (user?.interests.isNotEmpty ?? false)
        _NotificationItem(
          title: 'New events match your interests',
          subtitle:
              'We found ${events.where((event) => user!.interests.contains(event.category)).length} events across ${user!.interests.take(3).join(', ')}.',
          icon: Icons.auto_awesome,
          color: AppColors.primary,
        ),
      if (bookings.isNotEmpty)
        _NotificationItem(
          title: 'Upcoming booking reminder',
          subtitle: 'Your next booked event is ready in the Tickets tab.',
          icon: Icons.confirmation_number_outlined,
          color: AppColors.secondary,
        ),
      _NotificationItem(
        title: 'Trending near ${user?.city ?? 'you'}',
        subtitle:
            'Popular music, food, and tech events are filling up this week.',
        icon: Icons.local_fire_department_outlined,
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: items.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: item.color.withValues(alpha: 0.12),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
