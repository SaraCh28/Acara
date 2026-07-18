import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _SourceBadge(
                        label: event.sourceBadgeLabel,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, 
                               size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('EEE, d MMM').format(event.date)} • ${event.startTime}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, 
                               size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${event.venue}, ${event.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event.price == 0
                                ? 'FREE'
                                : '\$${event.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _distanceLabel(currentUser, event),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: isBookmarked ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                  shape: const CircleBorder(),
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
                      size: 22,
                      color: isBookmarked ? AppColors.accent : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: event.imageUrl,
              width: 280,
              height: 380,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Header Info Badges
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white.withValues(alpha: 0.2),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('d').format(event.date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              DateFormat('MMM').format(event.date).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _SourceBadge(label: event.sourceBadgeLabel),
                ],
              ),
            ),
            // Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.coolSky, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event.venue}, ${event.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.coolSky,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.price == 0 ? 'FREE' : '\$${event.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.trueCobalt,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _distanceLabel(currentUser, event),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bookmark Toggle
            Positioned(
              bottom: 120,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: GestureDetector(
                    onTap: currentUser == null
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        isBookmarked ? Icons.favorite : Icons.favorite_border,
                        color: isBookmarked ? AppColors.accent : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Tap area
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 8 : 12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 8 : 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
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
