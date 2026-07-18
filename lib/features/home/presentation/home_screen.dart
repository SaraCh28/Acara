import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: AppColors.backgroundLight,
      body: eventsAsync.when(
        data: (allEvents) => _HomeScreenContent(user: user, allEvents: allEvents),
        loading: () => const _HomeLoadingState(),
        error: (err, stack) => _HomeErrorState(error: err.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai_assistant'),
        backgroundColor: AppColors.trueCobalt,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        label: const Text(
          'Ask AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ).animate().scale(delay: 1.seconds, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }
}

class _HomeScreenContent extends ConsumerWidget {
  const _HomeScreenContent({this.user, required this.allEvents});
  final UserModel? user;
  final List<EventModel> allEvents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = [...allEvents]..sort((a, b) => b.attendeeCount.compareTo(a.attendeeCount));
    final nearYou = [...allEvents]..sort((a, b) => _distanceForUser(user, a).compareTo(_distanceForUser(user, b)));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero Header ─────────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.trueCobalt,
          elevation: 0,
          leadingWidth: 0,
          leading: const SizedBox.shrink(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _buildSearchBar(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Premium Gradient Background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.trueCobalt,
                        Color(0xFF00154D),
                      ],
                    ),
                  ),
                ),
                // Abstract decorative circles for "illustration" feel
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pinkMist.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.coolSky.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Header Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Location',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => context.push('/city_selection'),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, color: AppColors.pinkMist, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        user?.city ?? 'Set City',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white10,
                                backgroundImage: user?.profileImageUrl != null ? AssetImage(user!.profileImageUrl!) : null,
                                child: user?.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Hello, ${user?.name.split(' ').first ?? 'Friend'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        const Text(
                          'Let’s find some amazing events.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        const SizedBox(height: 40), // Space for floating search
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Trending Vertical Cards ────────────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Trending Right Now',
                onAction: () => context.push('/search'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 380,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: trending.take(5).length,
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: trending[index],
                      isHorizontal: false,
                      onTap: () => context.push('/event/${trending[index].id}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Events Near You ────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Discovered Near You',
                  onAction: () => context.push('/explore'),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nearYou.take(4).length,
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: nearYou[index],
                      onTap: () => context.push('/event/${nearYou[index].id}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Hero(
      tag: 'search_bar',
      child: Material(
        elevation: 8,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push('/search'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.trueCobalt, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Search amazing events...',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.tune_rounded, color: AppColors.trueCobalt, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onAction});
  final String title;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.trueCobalt,
              letterSpacing: -0.5,
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: const Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.trueCobalt,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.trueCobalt),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(height: 280, borderRadius: BorderRadius.zero),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerLoader(height: 56, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerLoader(height: 24, width: 200),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 380,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: ShimmerLoader(width: 280, height: 380, borderRadius: BorderRadius.all(Radius.circular(24))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.error});
  final String error;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

double _distanceForUser(UserModel? user, EventModel event) {
  if (user?.latitude == null || user?.longitude == null) return 0;
  return LocationUtils.distanceInKm(
    startLatitude: user!.latitude!,
    startLongitude: user.longitude!,
    endLatitude: event.latitude,
    endLongitude: event.longitude,
  );
}
