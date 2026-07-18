import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';

class AdminService {
  final _supabase = Supabase.instance.client;

  Future<List<UserModel>> getAllUsers() async {
    final response = await _supabase.from('profiles').select().order('created_at', ascending: false);
    return (response as List).map((u) => UserModel.fromJson(u)).toList();
  }

  Future<void> createEvent(EventModel event) async {
    // Since we don't have a shared 'events' table for all sources yet, 
    // we'll insert into a new 'custom_events' table or just the local cache for now.
    // However, the best way for a 'Manage Events' feature is to have a dedicated table.
    
    final eventData = {
      'title': event.title,
      'description': event.description,
      'category': event.category,
      'date': event.date.toIso8601String(),
      'start_time': event.startTime,
      'end_time': event.endTime,
      'venue': event.venue,
      'city': event.city,
      'country': event.country,
      'price': event.price,
      'image_url': event.imageUrl,
      'organizer_name': event.organizerName,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'source_id': 'admin',
    };

    await _supabase.from('events').insert(eventData);
  }

  Future<void> deleteUser(String userId) async {
     // This would typically involve auth admin API, but we can delete the profile
     await _supabase.from('profiles').delete().eq('id', userId);
  }
}

final adminServiceProvider = Provider((ref) => AdminService());

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.watch(adminServiceProvider).getAllUsers();
});
