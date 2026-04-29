import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/modern_app_bar.dart';
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
      appBar: ModernAppBar(
        title: 'Acara',
        gradient: AppColors.primaryGradient,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => context.push('/notifications'),
          )
              .animate()
              .fadeIn(duration: 400.ms),
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingMedium),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: (user?.profileImageUrl != null)
                    ? AssetImage(user!.profileImageUrl!)
                    : null,
                child: user?.profileImageUrl == null
                    ? Text(
                        user?.name.isNotEmpty == true
                            ? user!.name.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scaleXY(begin: 0.8),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (allEvents) => _buildContent(context, ref, user, allEvents),
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoader(
                height: 80,
                margin: const EdgeInsets.all(AppConstants.paddingLarge),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge),
                child: ShimmerLoader(height: 56, borderRadius:
                    BorderRadius.circular(16)),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Padding(
                padding: const EdgeInsets.only(left: AppConstants.paddingLarge),
                child: SizedBox(
                  height: 320,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (_, i) => Padding(
                      padding:
                          const EdgeInsets.only(right: 12),
                      child: ShimmerLoader(
                        width: 260,
                        height: 300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Error: $err',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(eventsNotifierProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai_assistant'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserModel? user,
      List<EventModel> allEvents) {
    final now = DateTime.now();
    final nextMonday = DateTime(now.year, now.month, now.day + (8 - now.weekday));
    final eventsByCategory = ref.watch(eventsByCategoryProvider);

    // Filter Logic
    final nearYou = [...allEvents]
      ..sort((a, b) =>
          _distanceForUser(user, a).compareTo(_distanceForUser(user, b)));

    final trending = [...allEvents]
      ..sort((a, b) => b.attendeeCount.compareTo(a.attendeeCount));

    final thisWeekend = allEvents.where((e) => e.date.isAfter(now) && e.date.isBefore(nextMonday)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final freeEvents = allEvents.where((e) => e.price == 0).toList();

    final recommended = allEvents
        .where((e) => user?.interests.contains(e.category) ?? false)
        .toList();

    final categories = eventsByCategory.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, user),

          // Search Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/search'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search events, venues...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: AppConstants.paddingLarge),

          // Near You Section
          _SectionHeader(
            title: user?.city != null
                ? 'Events in ${user!.city}'
                : 'Events Near You',
            actionLabel: 'Explore',
            onTap: () => context.push('/search'),
          ),
          _buildHorizontalList(nearYou, context),

          // This Weekend Section
          if (thisWeekend.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _SectionHeader(
              title: 'This Weekend 🎉',
              actionLabel: 'See all',
              onTap: () => context.push('/search'),
            ),
            _buildHorizontalList(thisWeekend, context),
          ],

          // Recommended Section
          if (recommended.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _SectionHeader(
              title: 'Matches Your Interests',
              actionLabel: 'More',
              onTap: () => context.push('/search'),
            ),
            _buildHorizontalList(recommended, context),
          ],

          // Free Events Section
          if (freeEvents.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _SectionHeader(
              title: 'Free Events 🎁',
              actionLabel: 'Explore',
              onTap: () => context.push('/search'),
            ),
            _buildHorizontalList(freeEvents, context),
          ],

          // Trending Section (Vertical)
          const SizedBox(height: AppConstants.paddingLarge),
          _SectionHeader(
            title: 'Trending Right Now 🔥',
            actionLabel: 'See all',
            onTap: () => context.push('/search'),
          ),
          ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trending.take(3).length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = trending[index];
              return EventCard(
                event: event,
                onTap: () => context.push('/event/${event.id}'),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100))
                  .slideX(begin: 0.1);
            },
          ),

          // Categories Grid
          const SizedBox(height: AppConstants.paddingLarge),
          _SectionHeader(
            title: 'Browse Categories',
            actionLabel: '',
            onTap: () {},
          ),
          _buildCategoriesGrid(categories, context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLarge,
          AppConstants.paddingMedium,
          AppConstants.paddingLarge,
          AppConstants.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey ${user?.name.split(' ').first ?? ''} 👋',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.2),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => context.push('/city_selection'),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Consumer(
                              builder: (context, ref, child) {
                                final prefs =
                                    ref.watch(appPreferencesProvider);
                                final locationText = prefs.selectedCity != null
                                    ? '${prefs.selectedCity}, ${prefs.selectedCountry}'
                                    : user?.city != null
                                        ? '${user?.city}, ${user?.country}'
                                        : 'Set your location';
                                return Expanded(
                                  child: Text(
                                    locationText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                           color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white70, size: 18),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideX(begin: -0.2),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: user?.profileImageUrl != null
                        ? AssetImage(user!.profileImageUrl!)
                        : null,
                    child: user?.profileImageUrl == null
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scaleXY(begin: 0.8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<EventModel> events, BuildContext context) {
    if (events.isEmpty) {
      return const _EmptySection(message: 'No events found in this category yet.');
    }
    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        scrollDirection: Axis.horizontal,
        itemCount: events.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final event = events[index];
          return SizedBox(
            width: 260,
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
    final categoryGradients = [
      AppColors.primaryGradient,
      AppColors.accentGradient,
      AppColors.skyGradient,
      AppColors.sunsetGradient,
      AppColors.purpleBlueGradient,
      AppColors.pinkPurpleGradient,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final gradientIndex = index % categoryGradients.length;
          final gradient = categoryGradients[gradientIndex];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/category/${Uri.encodeComponent(category)}'),
              borderRadius: BorderRadius.circular(18),
              splashColor: Colors.white.withValues(alpha: 0.1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Blur overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: 400.ms)
              .scaleXY(begin: 0.9);
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
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              overflow: TextOverflow.ellipsis,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.1),
          ),
          if (actionLabel.isNotEmpty)
            TextButton(
              onPressed: onTap,
              child: Text(
                actionLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
