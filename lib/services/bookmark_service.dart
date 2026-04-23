import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bookmark_model.dart';
import 'auth_service.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

// A provider holding the list of user bookmarks
final userBookmarksProvider =
    NotifierProvider<UserBookmarksNotifier, List<BookmarkModel>>(() {
  return UserBookmarksNotifier();
});

class UserBookmarksNotifier extends Notifier<List<BookmarkModel>> {
  final _supabase = Supabase.instance.client;

  @override
  List<BookmarkModel> build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      // We can't do async build easily in Notifier, but we can initialize
      // and then fetch. For simplicity, we'll listen to the user provider
      // and fetch when it changes.
      _fetchBookmarks(user.id);
    }
    return [];
  }

  Future<void> _fetchBookmarks(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId);
      
      state = data.map((json) => BookmarkModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching bookmarks: $e');
    }
  }

  Future<void> toggleBookmark(String userId, String eventId) async {
    final isBookmarkedCurrently = isBookmarked(userId, eventId);

    try {
      if (isBookmarkedCurrently) {
        // Remove bookmark from Supabase
        await _supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('event_id', eventId);

        // Update local state
        state = state.where((b) => b.eventId != eventId).toList();
      } else {
        // Add bookmark to Supabase
        final response = await _supabase.from('bookmarks').insert({
          'user_id': userId,
          'event_id': eventId,
        }).select().single();

        // Update local state
        final newBookmark = BookmarkModel.fromJson(response);
        state = [...state, newBookmark];
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      rethrow;
    }
  }

  bool isBookmarked(String userId, String eventId) {
    return state.any(
      (bookmark) => bookmark.userId == userId && bookmark.eventId == eventId,
    );
  }
}

class BookmarkService {
  // Service logic can go here
}
