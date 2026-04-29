import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'event_api_service.dart';
import 'auth_service.dart';
import 'app_preferences_service.dart';

/// Represents the parameters for an event search query.
class EventsQuery {
  final String? city;
  final String? country;
  final double? lat;
  final double? lng;
  final String? keyword;
  final String? category;

  const EventsQuery({
    this.city,
    this.country,
    this.lat,
    this.lng,
    this.keyword,
    this.category,
  });

  EventsQuery copyWith({
    String? city,
    String? country,
    double? lat,
    double? lng,
    String? keyword,
    String? category,
    bool clearCity = false,
    bool clearCoords = false,
  }) {
    return EventsQuery(
      city: clearCity ? null : (city ?? this.city),
      country: country ?? this.country,
      lat: clearCoords ? null : (lat ?? this.lat),
      lng: clearCoords ? null : (lng ?? this.lng),
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventsQuery &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          country == other.country &&
          lat == other.lat &&
          lng == other.lng &&
          keyword == other.keyword &&
          category == other.category;

  @override
  int get hashCode =>
      city.hashCode ^
      country.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      keyword.hashCode ^
      category.hashCode;
}

/// A notifier that holds the current search query.
class EventsQueryNotifier extends Notifier<EventsQuery> {
  @override
  EventsQuery build() {
    final user = ref.watch(currentUserProvider);
    final prefs = ref.watch(appPreferencesProvider);
    
    return EventsQuery(
      city: prefs.selectedCity ?? user?.city,
      country: prefs.selectedCountryCode ?? user?.countryCode,
      lat: prefs.latitude ?? user?.latitude,
      lng: prefs.longitude ?? user?.longitude,
    );
  }

  void updateQuery(EventsQuery query) {
    state = query;
  }

  void updateParameters({
    String? city,
    String? country,
    double? lat,
    double? lng,
    String? keyword,
    String? category,
    bool clearCity = false,
    bool clearCoords = false,
  }) {
    state = state.copyWith(
      city: city,
      country: country,
      lat: lat,
      lng: lng,
      keyword: keyword,
      category: category,
      clearCity: clearCity,
      clearCoords: clearCoords,
    );
  }
}

final eventsQueryProvider = NotifierProvider<EventsQueryNotifier, EventsQuery>(EventsQueryNotifier.new);

String normalizeCategoryLabel(String category) {
  return EventModel.normalizeCategory(category);
}

Map<String, List<EventModel>> groupEventsByCategory(Iterable<EventModel> events) {
  final grouped = <String, List<EventModel>>{};

  for (final event in events) {
    final key = normalizeCategoryLabel(event.category);
    grouped.putIfAbsent(key, () => []).add(event);
  }

  for (final entry in grouped.entries) {
    entry.value.sort((first, second) => first.date.compareTo(second.date));
  }

  return grouped;
}

int _sourcePriority(String sourceId) {
  switch (sourceId.toLowerCase()) {
    case 'ticketmaster':
      return 0;
    case 'eventbrite':
      return 1;
    case 'seatgeek':
      return 2;
    case 'local':
      return 3;
    case 'google_places':
      return 4;
    default:
      return 5;
  }
}

List<EventModel> dedupeEventsByLocation(Iterable<EventModel> events) {
  final deduped = <String, EventModel>{};

  for (final event in events) {
    final key = event.locationFingerprint;
    final existing = deduped[key];
    if (existing == null) {
      deduped[key] = event;
      continue;
    }

    final existingPriority = _sourcePriority(existing.sourceId);
    final incomingPriority = _sourcePriority(event.sourceId);
    final shouldReplace = incomingPriority < existingPriority ||
        (incomingPriority == existingPriority && event.attendeeCount > existing.attendeeCount);

    if (shouldReplace) {
      deduped[key] = event;
    }
  }

  final eventsList = deduped.values.toList();
  eventsList.sort((first, second) => first.date.compareTo(second.date));
  return eventsList;
}

final eventsByCategoryProvider = Provider<Map<String, List<EventModel>>>((ref) {
  final events = ref.watch(eventsNotifierProvider).value ?? const <EventModel>[];
  return groupEventsByCategory(dedupeEventsByLocation(events));
});

final eventCategoriesProvider = Provider<List<String>>((ref) {
  final categories = ref.watch(eventsByCategoryProvider).keys.toList()..sort();
  return categories;
});

/// An AsyncNotifier that fetches events based on the current query.
class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  // A session-wide cache of all events encountered so far
  static final Map<String, EventModel> _allEventsCache = {};

  static EventModel? getEvent(String id) => _allEventsCache[id];

  @override
  Future<List<EventModel>> build() async {
    final query = ref.watch(eventsQueryProvider);
    final apiService = ref.read(eventApiServiceProvider);

    final results = await apiService.fetchEvents(
      city: query.city,
      country: query.country,
      lat: query.lat,
      lng: query.lng,
      keyword: query.keyword,
      classificationName: query.category,
    );

    // Update session cache
    for (var event in results) {
      for (final key in event.lookupIds) {
        _allEventsCache[key] = event;
      }
    }

    return results;
  }

  /// Manually trigger a refresh.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final eventsNotifierProvider =
    AsyncNotifierProvider<EventsNotifier, List<EventModel>>(EventsNotifier.new);
