import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'event_api_service.dart';
import 'auth_service.dart';

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
    return EventsQuery(
      city: user?.city,
      country: user?.countryCode ?? 'PK', // Default to PK if unknown
      lat: user?.latitude,
      lng: user?.longitude,
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

/// An AsyncNotifier that fetches events based on the current query.
class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  @override
  Future<List<EventModel>> build() async {
    final query = ref.watch(eventsQueryProvider);
    final apiService = ref.read(eventApiServiceProvider);

    return apiService.fetchEvents(
      city: query.city,
      country: query.country,
      lat: query.lat,
      lng: query.lng,
      keyword: query.keyword,
      classificationName: query.category,
    );
  }

  /// Manually trigger a refresh.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final eventsNotifierProvider =
    AsyncNotifierProvider<EventsNotifier, List<EventModel>>(EventsNotifier.new);
