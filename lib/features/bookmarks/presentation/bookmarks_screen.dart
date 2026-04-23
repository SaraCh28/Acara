import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/bookmark_model.dart';
import '../../../services/event_service.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/event_card.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final bookmarkedEvents = ref
        .watch(userBookmarksProvider)
        .where((bookmark) => user != null && bookmark.userId == user.id)
        .toList();
    final eventsById = {
      for (final event in ref.watch(eventsProvider)) event.id: event,
    };

    final upcomingEvents = bookmarkedEvents.where((bookmark) {
      final event = eventsById[bookmark.eventId];
      return event != null && event.date.isAfter(DateTime.now());
    }).toList();
    final pastEvents = bookmarkedEvents.where((bookmark) {
      final event = eventsById[bookmark.eventId];
      return event != null && !event.date.isAfter(DateTime.now());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(upcomingEvents),
          _buildEventsList(pastEvents),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<BookmarkModel> bookmarks) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved events',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final allEvents = ref.watch(eventsProvider);
    final grouped = <String, List<BookmarkModel>>{};

    for (final bookmark in bookmarks) {
      final event = allEvents
          .where((item) => item.id == bookmark.eventId)
          .firstOrNull;
      if (event == null) {
        continue;
      }
      final key = '${event.date.year}-${event.date.month}-${event.date.day}';
      grouped.putIfAbsent(key, () => []).add(bookmark);
    }

    final keys = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final sectionBookmarks = grouped[key]!;
        final firstEvent = allEvents.firstWhere(
          (event) => event.id == sectionBookmarks.first.eventId,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${firstEvent.date.day}/${firstEvent.date.month}/${firstEvent.date.year}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...sectionBookmarks.map((bookmark) {
              final event = allEvents.firstWhere(
                (item) => item.id == bookmark.eventId,
              );
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.paddingMedium,
                ),
                child: Dismissible(
                  key: ValueKey(bookmark.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser != null) {
                      ref
                          .read(userBookmarksProvider.notifier)
                          .toggleBookmark(currentUser.id, event.id);
                    }
                  },
                  child: EventCard(
                    event: event,
                    onTap: () => context.push('/event/${event.id}'),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
