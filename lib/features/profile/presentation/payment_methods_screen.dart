import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/payment_service.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethods = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        children: [
          ...paymentMethods.map(
            (method) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.paddingMedium,
              ),
              child: _buildCardItem(
                context,
                method: method,
                onRemove: () {
                  ref
                      .read(paymentMethodsProvider.notifier)
                      .removeCard(method.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Card removed')));
                },
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add card feature coming soon')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Card'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context, {
    required dynamic method,
    required VoidCallback onRemove,
  }) {
    final colors = {
      'Visa': const Color(0xFF1A1F71),
      'Mastercard': const Color(0xFFEB001B),
      'Amex': const Color(0xFF006FCF),
    };

    final color = colors[method.brand] ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method.brand,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton(
                color: Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: onRemove,
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            '**** **** **** ${method.last4}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Card Holder',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    method.holderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Expires',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    method.expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
