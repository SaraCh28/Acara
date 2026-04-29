class EventModel {
  final String id;
  final String legacyId;
  final String sourceId;
  final String sourceName;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double latitude;
  final double longitude;
  final String venue;
  final String city;
  final String country;
  final double price;
  final String imageUrl;
  final String organizerId;
  final String organizerName;
  final String? organizerImageUrl;
  final int attendeeCount;
  final DateTime createdAt;

  EventModel({
    required this.id,
    this.legacyId = '',
    required this.sourceId,
    required this.sourceName,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    required this.venue,
    required this.city,
    required this.country,
    required this.price,
    required this.imageUrl,
    required this.organizerId,
    required this.organizerName,
    this.organizerImageUrl,
    required this.attendeeCount,
    required this.createdAt,
  });

  List<String> get lookupIds => [
        id,
        if (legacyId.isNotEmpty && legacyId != id) legacyId,
      ];

  String get sourceBadgeLabel {
    final label = sourceName.trim();
    return label.isNotEmpty ? label : sourceId;
  }

  String get categoryKey => normalizeCategory(category);

  String get locationFingerprint {
    final normalizedTitle = title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedVenue = venue.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedCity = city.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedCountry = country.trim().toUpperCase();
    final normalizedDate = DateTime(date.year, date.month, date.day).toIso8601String().split('T').first;
    final normalizedTime = startTime.trim().isNotEmpty ? startTime.trim() : '00:00:00';
    final latKey = latitude.abs() < 0.000001 ? '0.000' : latitude.toStringAsFixed(3);
    final lngKey = longitude.abs() < 0.000001 ? '0.000' : longitude.toStringAsFixed(3);

    return [
      normalizedTitle,
      normalizedVenue,
      normalizedCity,
      normalizedCountry,
      normalizedDate,
      normalizedTime,
      latKey,
      lngKey,
    ].join('|');
  }

  static String normalizeCategory(String category) {
    final cleaned = category
        .replaceAll('_', ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return 'General';

    final lower = cleaned.toLowerCase();
    if (lower.contains('music')) return 'Music';
    if (lower.contains('sport')) return 'Sports';
    if (lower.contains('art') || lower.contains('theatre') || lower.contains('theater')) {
      return 'Arts';
    }
    if (lower.contains('food') || lower.contains('drink')) return 'Food';
    if (lower.contains('tech') || lower.contains('technology')) return 'Technology';
    if (lower.contains('wellness') || lower.contains('health') || lower.contains('fitness')) {
      return 'Wellness';
    }
    if (lower == 'major events' || lower == 'local site' || lower == 'diagnostics') {
      return 'General';
    }

    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final legacyId = json['legacyId'] as String? ?? json['sourceEventId'] as String? ?? id;
    final sourceId = json['sourceId'] as String? ?? json['organizerId'] as String? ?? 'ticketmaster';
    final sourceName = json['sourceName'] as String? ?? json['organizerName'] as String? ?? 'Ticketmaster';

    return EventModel(
      id: id,
      legacyId: legacyId,
      sourceId: sourceId,
      sourceName: sourceName,
      title: json['title'] as String? ?? 'Unknown Event',
      description: json['description'] as String? ?? 'No description available.',
      category: json['category'] as String? ?? 'General',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '23:59',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      venue: json['venue'] as String? ?? 'TBA',
      city: json['city'] as String? ?? 'TBA',
      country: json['country'] as String? ?? 'TBA',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      organizerId: json['organizerId'] as String? ?? sourceId,
      organizerName: json['organizerName'] as String? ?? sourceName,
      organizerImageUrl: json['organizerImageUrl'] as String?,
      attendeeCount: (json['attendeeCount'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legacyId': legacyId,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'latitude': latitude,
      'longitude': longitude,
      'venue': venue,
      'city': city,
      'country': country,
      'price': price,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerImageUrl': organizerImageUrl,
      'attendeeCount': attendeeCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
