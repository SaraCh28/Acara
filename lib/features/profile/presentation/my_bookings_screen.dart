import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event_model.dart';
import '../../../services/event_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/auth_service.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
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
    final currentUser = ref.watch(currentUserProvider);
    final allBookings = ref.watch(userBookingsProvider);
    final allEvents = ref.watch(eventsProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: const Center(child: Text('Please log in to view bookings')),
      );
    }

    // Filter bookings for current user
    final userBookings = allBookings
        .where((booking) => booking.userId == currentUser.id)
        .toList();

    // Separate into upcoming and past
    final now = DateTime.now();
    final upcomingBookings = userBookings.where((booking) {
      final event = allEvents.cast<dynamic?>().firstWhere(
        (e) => e?.id == booking.eventId,
        orElse: () => null,
      );
      return event != null && event.date.isAfter(now);
    }).toList();

    final pastBookings = userBookings.where((booking) {
      final event = allEvents.cast<dynamic?>().firstWhere(
        (e) => e?.id == booking.eventId,
        orElse: () => null,
      );
      return event != null && !event.date.isAfter(now);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
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
          _buildBookingList(upcomingBookings, allEvents),
          _buildBookingList(pastBookings, allEvents),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, List<EventModel> events) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No bookings found',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final event = events.cast<dynamic?>().firstWhere(
          (e) => e?.id == booking.eventId,
          orElse: () => null,
        );

        if (event == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(
                    AppConstants.paddingMedium,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.border,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(event.date),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.summaryLabel ??
                            '${booking.ticketCount} tickets',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/view_ticket/${booking.id}'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('/view_ticket/${booking.id}'),
                      child: const Text('View Ticket'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: booking.status == 'confirmed'
                        ? OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Booking'),
                                  content: const Text(
                                    'Are you sure you want to cancel this booking?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Keep'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(userBookingsProvider.notifier)
                                            .cancelBooking(booking.id);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Booking cancelled'),
                                          ),
                                        );
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Cancel'),
                          )
                        : const OutlinedButton(
                            onPressed: null,
                            child: Text('Cancelled'),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
