import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkout_draft_model.dart';
import '../models/event_model.dart';

final checkoutDraftProvider =
    NotifierProvider<CheckoutDraftNotifier, CheckoutDraftModel?>(
      CheckoutDraftNotifier.new,
    );

final checkoutEventProvider =
    NotifierProvider<CheckoutEventNotifier, EventModel?>(
      CheckoutEventNotifier.new,
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

class CheckoutEventNotifier extends Notifier<EventModel?> {
  @override
  EventModel? build() => null;

  void setEvent(EventModel event) {
    state = event;
  }

  void clear() {
    state = null;
  }
}

