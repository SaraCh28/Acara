import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/location_utils.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';

class EventCard extends ConsumerWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isHorizontal = true,
  });

  final EventModel event;
  final bool isHorizontal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isHorizontal) {
      return _HorizontalEventCard(event: event, onTap: onTap);
    }
    return _VerticalEventCard(event: event, onTap: onTap);
  }
}

class _HorizontalEventCard extends ConsumerWidget {
  const _HorizontalEventCard({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bookmarks = ref.watch(userBookmarksProvider);
    final isBookmarked =
        currentUser != null &&
        bookmarks.any(
          (bookmark) =>
              bookmark.userId == currentUser.id &&
              event.lookupIds.contains(bookmark.eventId),
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              child: SizedBox(
                width: 110,
                height: 112,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, _, __) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _SourceBadge(
                        label: event.sourceBadgeLabel,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('EEE, d MMM').format(event.date)} • ${event.startTime}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.venue}, ${event.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          event.price == 0
                              ? 'Free'
                              : '\$${event.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          _distanceLabel(currentUser, event),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: currentUser == null
                  ? null
                  : () {
                      ref
                          .read(userBookmarksProvider.notifier)
                                      .toggleBookmark(
                                        currentUser.id,
                                        event.id,
                                        alternateEventIds: event.lookupIds.skip(1),
                                      );
                    },
              icon: Icon(
                isBookmarked ? Icons.favorite : Icons.favorite_border,
                color: isBookmarked ? Colors.redAccent : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalEventCard extends ConsumerWidget {
  const _VerticalEventCard({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bookmarks = ref.watch(userBookmarksProvider);
    final isBookmarked =
        currentUser != null &&
        bookmarks.any(
          (bookmark) =>
              bookmark.userId == currentUser.id &&
              event.lookupIds.contains(bookmark.eventId),
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: SizedBox(
        width: 260,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: 260,
                height: 320,
                fit: BoxFit.cover,
                placeholder: (context, _) => Container(
                  width: 260,
                  height: 320,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, _, __) => Container(
                  width: 260,
                  height: 320,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            Container(
              width: 260,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('d').format(event.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(event.date),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SourceBadge(label: event.sourceBadgeLabel),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                child: IconButton(
                  onPressed: currentUser == null
                      ? null
                      : () {
                          ref
                              .read(userBookmarksProvider.notifier)
                              .toggleBookmark(
                                currentUser.id,
                                event.id,
                                alternateEventIds: event.lookupIds.skip(1),
                              );
                        },
                  icon: Icon(
                    isBookmarked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.venue}, ${event.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        event.price == 0
                            ? 'Free'
                            : '\$${event.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _distanceLabel(currentUser, event),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _distanceLabel(UserModel? user, EventModel event) {
  if (user?.latitude == null || user?.longitude == null) {
    return event.city;
  }

  final distance = LocationUtils.distanceInKm(
    startLatitude: user!.latitude!,
    startLongitude: user.longitude!,
    endLatitude: event.latitude,
    endLongitude: event.longitude,
  );
  return LocationUtils.formatDistance(distance);
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badgeColor = _sourceColor(label);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badgeColor.withValues(alpha: 0.85), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Color _sourceColor(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('ticketmaster')) return const Color(0xFF1E88E5);
  if (normalized.contains('eventbrite')) return const Color(0xFFF6682F);
  if (normalized.contains('seatgeek')) return const Color(0xFF19B36B);
  if (normalized.contains('google')) return const Color(0xFF4285F4);
  if (normalized.contains('local')) return const Color(0xFF8E63FF);
  return Colors.white;
}

