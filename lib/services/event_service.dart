import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'event_api_service.dart';
import 'events_notifier.dart';

/// Legacy service, now mostly replaced by [EventApiService] and [EventsNotifier].
/// We keep it for basic provider delegation if needed.
class EventService {
  // Mock data removed in favor of real Ticketmaster API
}

final eventServiceProvider = Provider((ref) => EventService());

/// Simple provider that returns all currently fetched events.
final eventsProvider = Provider<List<EventModel>>((ref) {
  final asyncEvents = ref.watch(eventsNotifierProvider);
  return asyncEvents.value ?? [];
});

/// Returns a specific event by ID, searching the current list and the session cache.
final eventByIdProvider = Provider.family<EventModel?, String>((ref, id) {
  final allEvents = ref.watch(eventsProvider);
  
  // Search in allEvents
  for (final e in allEvents) {
    if (e.id == id || e.legacyId == id || e.lookupIds.contains(id)) {
      return e;
    }
  }
  
  // Fallback to session cache in EventsNotifier
  return EventsNotifier.getEvent(id);
});

/// Fetches a specific event by ID from the API if not found in local state.
final asyncEventByIdProvider = FutureProvider.family<EventModel?, String>((ref, id) async {
  // Check local first
  final local = ref.read(eventByIdProvider(id));
  if (local != null) return local;

  // Fetch from API using the ID as keyword
  final api = ref.read(eventApiServiceProvider);
  final results = await api.fetchEvents(keyword: id);
  
  if (results.isNotEmpty) {
    // Aggregator might return multiple, we look for the best match
    for (final e in results) {
      if (e.id == id || e.legacyId == id || e.lookupIds.contains(id)) {
         return e;
      }
    }
    return results.first;
  }
  
  return null;
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
              .contains(EventModel.normalizeCategory(e.category).toLowerCase());
      return matchCity && matchInterest;
    }).toList();
  },
);

