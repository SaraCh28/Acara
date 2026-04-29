import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';

class EventApiService {
  final _supabase = Supabase.instance.client;

  Future<List<EventModel>> fetchEvents({
    String? city,
    String? country,
    double? lat,
    double? lng,
    String? keyword,
    String? classificationName,
    int size = 20,
  }) async {
    try {
      // Call Supabase Edge Function 'get-events'
      final response = await _supabase.functions.invoke(
        'get-events',
        body: {
          'city': city,
          'country': country,
          'lat': lat,
          'lng': lng,
          'keyword': keyword,
          'category': classificationName,
        },
      );

      final dynamic rawData = response.data;
      if (rawData is Map && rawData.containsKey('error')) {
        final msg = rawData['details'] ?? rawData['error'];
        throw Exception('Backend Error: $msg');
      }

      if (rawData == null || rawData is! List) {
        print('Backend returned unexpected data format: $rawData');
        return [];
      }
      
      final List<dynamic> data = rawData;
      return data
          .map((json) => EventModel.fromJson(_normalizeJson(json as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      print('Error calling get-events function: $e');
      return [];
    }
  }

  Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    // Ensure all required fields for EventModel.fromJson are present
    // EventModel.fromJson expects 'id', 'title', 'description', etc.
    final sourceId = json['sourceId'] ?? json['organizerId'] ?? 'ticketmaster';
    final sourceName = json['sourceName'] ?? json['organizerName'] ?? 'Ticketmaster';
    return {
      'id': json['id'] ?? '',
      'legacyId': json['legacyId'] ?? json['sourceEventId'] ?? json['id'] ?? '',
      'sourceId': sourceId,
      'sourceName': sourceName,
      'title': json['title'] ?? 'Unknown Event',
      'description': json['description'] ?? 'No description available.',
      'category': json['category'] ?? 'General',
      'date': json['date'] ?? DateTime.now().toIso8601String(),
      'startTime': json['startTime'] ?? '00:00',
      'endTime': json['endTime'] ?? '23:59',
      'latitude': (json['latitude'] as num?)?.toDouble() ?? 0.0,
      'longitude': (json['longitude'] as num?)?.toDouble() ?? 0.0,
      'venue': json['venue'] ?? 'TBA',
      'city': json['city'] ?? 'TBA',
      'country': json['country'] ?? 'TBA',
      'price': (json['price'] as num?)?.toDouble() ?? 0.0,
      'imageUrl': json['imageUrl'] ?? '',
      'organizerId': json['organizerId'] ?? sourceId,
      'organizerName': json['organizerName'] ?? sourceName,
      'attendeeCount': (json['attendeeCount'] as num?)?.toInt() ?? 0,
      'created_at': json['created_at'] ?? DateTime.now().toIso8601String(),
    };
  }
}

final eventApiServiceProvider = Provider<EventApiService>((ref) => EventApiService());
