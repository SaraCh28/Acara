import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/event_service.dart';
import '../../../services/checkout_service.dart';
import '../../../models/checkout_draft_model.dart';
import 'package:intl/intl.dart';
import '../../../models/event_model.dart';

class TicketSelectionScreen extends ConsumerStatefulWidget {
  final String eventId;
  final EventModel? initialEvent;
  const TicketSelectionScreen({super.key, required this.eventId, this.initialEvent});

  @override
  ConsumerState<TicketSelectionScreen> createState() =>
      _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends ConsumerState<TicketSelectionScreen> {
  int _vipCount = 0;
  int _regularCount = 1;
  EventModel? _resolvedEvent;

  @override
  void initState() {
    super.initState();
    _resolvedEvent = widget.initialEvent ?? ref.read(eventByIdProvider(widget.eventId)) ?? ref.read(checkoutEventProvider);

    if (_resolvedEvent != null && ref.read(checkoutEventProvider) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(checkoutEventProvider.notifier).setEvent(_resolvedEvent!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutEvent = ref.watch(checkoutEventProvider);
    final event = _resolvedEvent ?? widget.initialEvent ?? checkoutEvent ?? ref.watch(eventByIdProvider(widget.eventId));

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Tickets')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'We could not load this event.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please go back and try opening the event again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_resolvedEvent == null) {
      _resolvedEvent = event;
    }

    final total = (_vipCount * 100) + (_regularCount * event.price);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Select Tickets')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 12),
                  Text(
                    'Choose your tickets below',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildTicketRow(
              title: 'VIP Ticket',
              price: 100.0,
              count: _vipCount,
              onIncrement: () => setState(() => _vipCount++),
              onDecrement: () => setState(() {
                if (_vipCount > 0) _vipCount--;
              }),
            ),
            const SizedBox(height: 16),
            _buildTicketRow(
              title: 'Regular Ticket',
              price: event.price,
              count: _regularCount,
              onIncrement: () => setState(() => _regularCount++),
              onDecrement: () => setState(() {
                if (_regularCount > 0) _regularCount--;
              }),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (_vipCount + _regularCount) > 0
                        ? () {
                            final draft = CheckoutDraftModel(
                              eventId: widget.eventId,
                              regularCount: _regularCount,
                              vipCount: _vipCount,
                              regularPrice: event.price,
                              vipPrice: 100.0,
                            );
                            ref.read(checkoutDraftProvider.notifier).saveDraft(draft);
                            ref.read(checkoutEventProvider.notifier).setEvent(event);
                            context.pushNamed(
                              'contact_info',
                              pathParameters: {'id': widget.eventId},
                              extra: event,
                            );
                          }
                        : null,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
