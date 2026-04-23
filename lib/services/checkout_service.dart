import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkout_draft_model.dart';

final checkoutDraftProvider =
    NotifierProvider<CheckoutDraftNotifier, CheckoutDraftModel?>(
      CheckoutDraftNotifier.new,
    );

class CheckoutDraftNotifier extends Notifier<CheckoutDraftModel?> {
  @override
  CheckoutDraftModel? build() {
    return null;
  }

  void saveDraft(CheckoutDraftModel draft) {
    state = draft;
  }

  void clear() {
    state = null;
  }
}
