import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/event_service.dart';
import '../../../services/booking_service.dart';
import 'package:intl/intl.dart';

class ViewTicketScreen extends ConsumerWidget {
  final String bookingId;
  const ViewTicketScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(userBookingsProvider);
    final booking = allBookings.cast<dynamic>().firstWhere(
      (b) => b?.id == bookingId,
      orElse: () => null,
    );

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Ticket')),
        body: const Center(child: Text('Ticket not found')),
      );
    }

    final allEvents = ref.watch(eventsProvider);
    final event = allEvents.cast<dynamic>().firstWhere(
      (e) => e?.id == booking.eventId,
      orElse: () => null,
    );

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Ticket')),
        body: const Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('My Ticket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Event Info section
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Hero(
                            tag: 'event_image_${event.id}',
                            child: Image.network(
                              event.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 180,
                                color: AppColors.border,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            text: DateFormat('EEEE, d MMMM yyyy').format(event.date),
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.access_time_outlined,
                            text: DateFormat('HH:mm').format(event.date),
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            text: '${event.venue}, ${event.city}',
                          ),
                        ],
                      ),
                    ),

                    // Dashed line divider with semi-circle cutouts
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: List.generate(
                            30,
                            (index) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  height: 1.5,
                                  color: AppColors.border,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -15,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -15,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom QR Section
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        children: [
                          QrImageView(
                            data: booking.ticketCode,
                            version: QrVersions.auto,
                            size: 180,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            booking.ticketCode,
                            style: const TextStyle(
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scan this QR code at the event entrance',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _TicketInfoColumn(
                                  label: 'TYPE',
                                  value: booking.vipTicketCount > 0 ? 'VIP' : 'REGULAR',
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: AppColors.border,
                                ),
                                _TicketInfoColumn(
                                  label: 'QUANTITY',
                                  value: '${booking.ticketCount} Tix',
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: AppColors.border,
                                ),
                                _TicketInfoColumn(
                                  label: 'STATUS',
                                  value: booking.status.toUpperCase(),
                                  color: booking.status == 'confirmed'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.event),
                      label: const Text('Add to Calendar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _TicketInfoColumn({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
