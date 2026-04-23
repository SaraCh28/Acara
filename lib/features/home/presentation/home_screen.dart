import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../../models/event_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/events_notifier.dart';
import '../../../services/app_preferences_service.dart';
import '../../../widgets/event_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final eventsAsync = ref.watch(eventsNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: eventsAsync.when(
        data: (allEvents) => _buildContent(context, ref, user, allEvents),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai_assistant'),
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.auto_awesome, color: AppColors.accent),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserModel? user,
      List<EventModel> allEvents) {
    final now = DateTime.now();
    
    // Sort & Filter
    final recommended = allEvents
        .where((e) => user?.interests.contains(e.category) ?? false)
        .toList();
    final categories = {for (final event in allEvents) event.category}.toList()..sort();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(context, ref, user),
            stretchModes: const [StretchMode.blurBackground],
          ),
          actions: [
            IconButton(
              icon: Icon(
                ref.watch(appPreferencesProvider).isDarkMode 
                    ? Icons.light_mode_outlined 
                    : Icons.dark_mode_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => ref.read(appPreferencesProvider.notifier).toggleDarkMode(),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_none, 
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.push('/notifications'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEARCH BAR - Sleek Luxe
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    readOnly: true,
                    onTap: () => context.push('/search'),
                    decoration: InputDecoration(
                      hintText: 'Discover exceptional events...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.accent, size: 20),
                      fillColor: Theme.of(context).colorScheme.surface,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _SectionHeader(title: 'FOR YOU', actionLabel: 'SEE ALL', onTap: () {}),
                _buildHorizontalList(recommended.isNotEmpty ? recommended : allEvents, context),

                const SizedBox(height: 32),
                _SectionHeader(title: 'CATEGORIES', actionLabel: '', onTap: () {}),
                _buildCategoriesGrid(categories, context),

                const SizedBox(height: 32),
                _SectionHeader(title: 'TRENDING GATHERINGS', actionLabel: 'EXPLORE', onTap: () {}),
                _buildVerticalList(allEvents, context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, UserModel? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/city_selection'),
                  child: Row(
                    children: [
                      const Icon(Icons.place_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        (ref.watch(appPreferencesProvider).selectedCity ?? 'Select Location').toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome Back,',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 2,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name.split(' ').first ?? 'Patron',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: user?.profileImageUrl != null
                    ? AssetImage(user!.profileImageUrl!)
                    : null,
                child: user?.profileImageUrl == null
                    ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalList(List<EventModel> events, BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.take(4).length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () => context.push('/event/${event.id}'),
        );
      },
    );
  }

  Widget _buildHorizontalList(List<EventModel> events, BuildContext context) {
    if (events.isEmpty) {
      return const _EmptySection(message: 'Exploring the horizon for new experiences...');
    }
    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: events.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final event = events[index];
          return SizedBox(
            width: 280,
            child: EventCard(
              event: event,
              isHorizontal: false,
              onTap: () => context.push('/event/${event.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(List<String> categories, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => context.push('/category/$category'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

double _distanceForUser(UserModel? user, EventModel event) {
  if (user?.latitude == null || user?.longitude == null) {
    return event.date.difference(DateTime.now()).inHours.abs().toDouble();
  }
  return LocationUtils.distanceInKm(
    startLatitude: user!.latitude!,
    startLongitude: user.longitude!,
    endLatitude: event.latitude,
    endLongitude: event.longitude,
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Text(
          message, 
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 13),
        ),
      ),
    );
  }
}
