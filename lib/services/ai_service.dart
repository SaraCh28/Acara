import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'events_notifier.dart';

class AiService {
  final Ref _ref;

  AiService(this._ref);

  Future<String> getAiResponse(String message) async {
    final events = _ref.read(eventsNotifierProvider).value ?? [];

    // LOCAL SMART AI LOGIC (Simulated Backend)
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final query = message.toLowerCase();
    
    // 1. RECOMMENDATION LOGIC
    if (query.contains('recommend') || query.contains('suggest') || query.contains('should i go')) {
      if (events.isNotEmpty) {
        final event = events.first;
        return "Based on your refined preferences, I highly recommend the \"${event.title}\" in ${event.city}. It's a premier ${event.category} gathering on ${event.date.month}/${event.date.day}. Would you like the full itinerary?";
      }
      return "I'm analyzing the current social landscape... We have several elite gatherings in various cities. Which city are you currently in?";
    }
    
    // 2. SEARCH LOGIC
    if (query.contains('free')) {
      final freeEvents = events.where((e) => e.price == 0).toList();
      if (freeEvents.isNotEmpty) {
        return "We have ${freeEvents.length} complimentary experiences available, including \"${freeEvents.first.title}\". A rare opportunity for exceptional networking.";
      }
      return "Currently, all curated experiences require a reservation fee, ensuring the highest quality of attendance.";
    }

    if (query.contains('price') || query.contains('cost') || query.contains('expensive')) {
       final expensive = events.where((e) => e.price > 100).toList();
       if (expensive.isNotEmpty) {
         return "The most exclusive reservation currently available is \"${expensive.first.title}\" at \$${expensive.first.price}. It promises an unparalleled experience.";
       }
       return "Reservations for our current selection range from \$20 to \$80.";
    }

    // 3. POLICY/FAQ
    if (query.contains('refund') || query.contains('cancel')) {
      return "Acara maintains a strict 48-hour cancellation policy for all premier reservations. You can manage your bookings directly in the Profile section.";
    }

    if (query.contains('ticket') || query.contains('my booking')) {
      return "All your verified credentials and digital tickets are securely archived in your 'My Bookings' section. They include unique QR verification for seamless entry.";
    }

    // 4. FALLBACK
    return "I am your Acara Concierge. I can assist you in discovering exclusive events, explaining our reservation policies, or managing your digital credentials. How may I serve you?";
  }
}

final aiServiceProvider = Provider((ref) => AiService(ref));
