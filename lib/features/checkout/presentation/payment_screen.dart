import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/checkout_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/event_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String eventId;
  const PaymentScreen({super.key, required this.eventId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedPaymentMethodId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(checkoutDraftProvider);
    final paymentMethods = ref.watch(paymentMethodsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final event = ref
        .watch(eventsProvider)
        .firstWhere((e) => e.id == widget.eventId);

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(
          child: Text('No draft found. Please select tickets again.'),
        ),
      );
    }

    // Set default selection if not already set
    if (_selectedPaymentMethodId == null && paymentMethods.isNotEmpty) {
      _selectedPaymentMethodId = paymentMethods.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.paddingMedium),

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
                  if (draft.vipCount > 0)
                    Text(
                      'VIP Tickets: ${draft.vipCount} x \$${draft.vipPrice.toStringAsFixed(2)} = \$${(draft.vipCount * draft.vipPrice).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  if (draft.regularCount > 0)
                    Text(
                      'Regular Tickets: ${draft.regularCount} x \$${draft.regularPrice.toStringAsFixed(2)} = \$${(draft.regularCount * draft.regularPrice).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${draft.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  final isSelected = _selectedPaymentMethodId == method.id;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingMedium,
                    ),
                    child: _buildPaymentOption(
                      context,
                      method: method,
                      isSelected: isSelected,
                      onTap: () =>
                          setState(() => _selectedPaymentMethodId = method.id),
                    ),
                  );
                },
              ),
            ),

            OutlinedButton.icon(
              onPressed: () {
                // Show add card dialog or navigate to add card screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add card feature coming soon')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Card'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: _selectedPaymentMethodId != null && !_isLoading
                  ? () => _processPayment(ref, currentUser?.id)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(WidgetRef ref, String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final draft = ref.read(checkoutDraftProvider);
      if (draft == null) return;

      // Create the booking
      final booking = await ref
          .read(userBookingsProvider.notifier)
          .bookEvent(
            userId: userId,
            eventId: draft.eventId,
            regularTicketCount: draft.regularCount,
            vipTicketCount: draft.vipCount,
            totalPrice: draft.totalPrice,
            paymentMethodId: _selectedPaymentMethodId!,
            bookerName: draft.bookerName ?? '',
            bookerEmail: draft.bookerEmail ?? '',
            bookerPhone: draft.bookerPhone ?? '',
          );

      // Clear the draft
      ref.read(checkoutDraftProvider.notifier).clear();

      if (mounted) {
        // Navigate to confirmation with booking ID
        context.go('/booking_confirmation/${booking.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required dynamic method,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: AppColors.primary),
        title: Text('${method.brand} ending in ${method.last4}'),
        subtitle: Text('Expires ${method.expiry}'),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
