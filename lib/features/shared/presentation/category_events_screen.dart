import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/event_service.dart';
import '../../../widgets/event_card.dart';

class CategoryEventsScreen extends ConsumerWidget {
  const CategoryEventsScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events =
        ref
            .watch(eventsProvider)
            .where(
              (event) => event.category.toLowerCase() == category.toLowerCase(),
            )
            .toList()
          ..sort((first, second) => first.date.compareTo(second.date));

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: events.isEmpty
          ? Center(
              child: Text(
                'No events found in $category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.paddingMedium,
                  ),
                  child: EventCard(
                    event: event,
                    isHorizontal: true,
                    onTap: () => context.push('/event/${event.id}'),
                  ),
                );
              },
            ),
    );
  }
}
