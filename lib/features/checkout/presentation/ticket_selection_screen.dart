import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/event_service.dart';
import '../../../services/checkout_service.dart';
import '../../../models/checkout_draft_model.dart';
import 'package:intl/intl.dart';

class TicketSelectionScreen extends ConsumerStatefulWidget {
  final String eventId;
  const TicketSelectionScreen({super.key, required this.eventId});

  @override
  ConsumerState<TicketSelectionScreen> createState() =>
      _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends ConsumerState<TicketSelectionScreen> {
  int _vipCount = 0;
  int _regularCount = 1;

  @override
  Widget build(BuildContext context) {
    final event = ref
        .watch(eventsProvider)
        .firstWhere((e) => e.id == widget.eventId);

    final total = (_vipCount * 100) + (_regularCount * event.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Tickets')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('d MMM yyyy').format(event.date)} • ${event.venue}, ${event.city}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                _buildTicketRow(
                  title: 'VIP Ticket',
                  price: 100.0,
                  count: _vipCount,
                  onIncrement: () => setState(() => _vipCount++),
                  onDecrement: () => setState(() {
                    if (_vipCount > 0) _vipCount--;
                  }),
                ),
                const Divider(height: 32),
                _buildTicketRow(
                  title: 'Regular Ticket',
                  price: event.price,
                  count: _regularCount,
                  onIncrement: () => setState(() => _regularCount++),
                  onDecrement: () => setState(() {
                    if (_regularCount > 0) _regularCount--;
                  }),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: (_vipCount + _regularCount) > 0
                        ? () {
                            // Save the draft before navigating
                            final draft = CheckoutDraftModel(
                              eventId: widget.eventId,
                              regularCount: _regularCount,
                              vipCount: _vipCount,
                              regularPrice: event.price,
                              vipPrice: 100.0,
                            );
                            ref
                                .read(checkoutDraftProvider.notifier)
                                .saveDraft(draft);
                            context.push(
                              '/contact_info/${widget.eventId}',
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow({
    required String title,
    required double price,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline),
              color: count > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(
              width: 30,
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
