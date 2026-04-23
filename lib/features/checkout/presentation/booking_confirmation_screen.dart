import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/booking_service.dart';
import '../../../services/event_service.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;
  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(userBookingsProvider);
    final booking = allBookings.cast<dynamic?>().firstWhere(
      (b) => b?.id == bookingId,
      orElse: () => null,
    );

    if (booking == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Booking not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allEvents = ref.watch(eventsProvider);
    final event = allEvents.cast<dynamic?>().firstWhere(
      (e) => e?.id == booking.eventId,
      orElse: () => null,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Booking Successful!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your ticket has been booked successfully.\nYou can view it in your profile or click below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),

              const SizedBox(height: 32),

              if (event != null)
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (booking.vipTicketCount > 0)
                        Text(
                          'VIP: ${booking.vipTicketCount}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (booking.regularTicketCount > 0)
                        Text(
                          'Regular: ${booking.regularTicketCount}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const Divider(),
                      Text(
                        'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  context.push('/view_ticket/$bookingId');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('View Ticket'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
