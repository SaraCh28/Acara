import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../services/checkout_service.dart';
import '../../../services/event_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/bookmark_service.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventByIdProvider(eventId));

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Sorry, we couldn\'t find this event details.'),
              TextButton(
                onPressed: () => _goBack(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentUser = ref.watch(currentUserProvider);
    // Watching the state directly to ensure the widget rebuilds when bookmarks change
    final bookmarks = ref.watch(userBookmarksProvider);
    final isBookmarked = currentUser != null && 
        ref.read(userBookmarksProvider.notifier).isBookmarked(
              currentUser.id,
              event.id,
              alternateEventIds: event.lookupIds.skip(1),
            );

    return Scaffold(
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image with Overlay
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              AppColors.backgroundLight, // Blends into the background at the bottom
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Custom Back & Action Buttons Top
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: AppConstants.paddingMedium,
                        right: AppConstants.paddingMedium,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _GlassButton(
                              icon: Icons.arrow_back,
                              onTap: () => _goBack(context),
                            ),
                            _GlassButton(
                              icon: isBookmarked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isBookmarked
                                  ? Colors.red
                                  : Colors.white,
                              onTap: () {
                                if (currentUser != null) {
                                  ref
                                      .read(userBookmarksProvider.notifier)
                                      .toggleBookmark(
                                        currentUser.id,
                                        event.id,
                                        alternateEventIds:
                                            event.lookupIds.skip(1),
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please log in to bookmark events')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Info Content
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),

                          // Row: Date & Time, Location Summary
                          _InfoTile(
                            icon: Icons.calendar_month,
                            title: DateFormat('d MMMM yyyy').format(event.date),
                            subtitle: '${event.startTime} - ${event.endTime}',
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          _InfoTile(
                            icon: Icons.location_on,
                            title: event.venue,
                            subtitle: '${event.city}, ${event.country}',
                          ),

                          const SizedBox(height: AppConstants.paddingLarge),

                          // Organizer Profile Stub
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  event.organizerName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.organizerName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  Text(
                                    'Organizer',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Follow'),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.paddingLarge),

                          // Description
                          Text(
                            'About Event',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            event.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),

                          const SizedBox(height: 100), // padding for bottom bar
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Action Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '\$${event.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppConstants.paddingLarge),
                    Expanded(
                      child: AppButton(
                        label: 'Buy Ticket',
                        onPressed: () {
                          ref.read(checkoutEventProvider.notifier).setEvent(event);
                          context.pushNamed(
                            'booking',
                            pathParameters: {'id': event.id},
                            extra: event,
                          );
                        },
                        variant: AppButtonVariant.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}

// Helper widget for frosted glass back buttons
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// Helper widget for Date/Location rows
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 16),
            ),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
