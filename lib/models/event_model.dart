class EventModel {
  final String id;
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

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Event',
      description: json['description'] as String? ?? 'No description available.',
      category: json['category'] as String? ?? 'General',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '23:59',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      venue: json['venue'] as String? ?? 'TBA',
      city: json['city'] as String? ?? 'TBA',
      country: json['country'] as String? ?? 'TBA',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      organizerId: json['organizerId'] as String? ?? 'tm',
      organizerName: json['organizerName'] as String? ?? 'Ticketmaster',
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
