import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/checkout_service.dart';
import '../../../services/auth_service.dart';

class ContactInfoScreen extends ConsumerStatefulWidget {
  final String eventId;
  const ContactInfoScreen({super.key, required this.eventId});

  @override
  ConsumerState<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends ConsumerState<ContactInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    final draft = ref.read(checkoutDraftProvider);

    _nameController = TextEditingController(text: draft?.bookerName ?? user?.name ?? '');
    _emailController = TextEditingController(text: draft?.bookerEmail ?? user?.email ?? '');
    _phoneController = TextEditingController(text: draft?.bookerPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final draft = ref.read(checkoutDraftProvider);
      if (draft != null) {
        ref.read(checkoutDraftProvider.notifier).saveDraft(
          draft.copyWith(
            bookerName: _nameController.text.trim(),
            bookerEmail: _emailController.text.trim(),
            bookerPhone: _phoneController.text.trim(),
          ),
        );
        context.push('/payment_selection/${widget.eventId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Information')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Where should we send your tickets?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              const Text(
                'The tickets will be sent to the email address below.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+92 300 0000000',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => 
                  value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
