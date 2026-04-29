import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'events_notifier.dart';

/// A global cache that keeps track of all [EventModel]s fetched during this session.
/// This ensures that bookmarked events remain visible even if the user changes cities.
class EventsCacheNotifier extends Notifier<Map<String, EventModel>> {
  @override
  Map<String, EventModel> build() {
    // Watch for new events and add them to the cache
    ref.listen(eventsNotifierProvider, (previous, next) {
      if (next is AsyncData<List<EventModel>>) {
        addEvents(next.value);
      }
    });
    
    return {};
  }

  void addEvents(List<EventModel> events) {
    final updated = Map<String, EventModel>.from(state);
    for (final event in events) {
      for (final key in event.lookupIds) {
        updated[key] = event;
      }
    }
    state = updated;
  }

  void addEvent(EventModel event) {
    state = {
      ...state,
      for (final key in event.lookupIds) key: event,
    };
  }
}

final eventsCacheProvider = NotifierProvider<EventsCacheNotifier, Map<String, EventModel>>(
  EventsCacheNotifier.new,
);

/// A derived provider that returns a list of all events in the cache.
final allKnownEventsProvider = Provider<List<EventModel>>((ref) {
  final seen = <String>{};
  final events = <EventModel>[];

  for (final event in ref.watch(eventsCacheProvider).values) {
    if (seen.add(event.id)) {
      events.add(event);
    }
  }

  return events;
});
