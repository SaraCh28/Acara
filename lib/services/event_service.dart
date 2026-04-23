import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'events_notifier.dart';

/// Legacy service, now mostly replaced by [EventApiService] and [EventsNotifier].
/// We keep it for basic provider delegation if needed.
class EventService {
  // Mock data removed in favor of real Ticketmaster API
}

final eventServiceProvider = Provider((ref) => EventService());

/// Simple provider that returns all currently fetched events.
final eventsProvider = Provider<List<EventModel>>((ref) {
  return ref.watch(eventsNotifierProvider).maybeWhen(
        data: (events) => events,
        orElse: () => [],
      );
});

/// Legacy city filter provider.
final cityEventsProvider = Provider.family<List<EventModel>, String>((ref, city) {
  final allEvents = ref.watch(eventsProvider);
  return allEvents
      .where((e) => e.city.toLowerCase() == city.toLowerCase())
      .toList();
});

/// Legacy city + interest filter provider.
final locationInterestEventsProvider =
    Provider.family<List<EventModel>, ({String city, List<String> interests})>(
  (ref, args) {
    final all = ref.watch(eventsProvider);
    return all.where((e) {
      final matchCity = e.city.toLowerCase() == args.city.toLowerCase();
      final matchInterest = args.interests.isEmpty ||
          args.interests
              .map((i) => i.toLowerCase())
              .contains(e.category.toLowerCase());
      return matchCity && matchInterest;
    }).toList();
  },
);

