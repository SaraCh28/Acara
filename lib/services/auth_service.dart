import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import 'bookmark_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

final currentUserProvider = NotifierProvider<CurrentUserNotifier, UserModel?>(
  () {
    return CurrentUserNotifier();
  },
);

String resolvePostAuthRoute(UserModel user) {
  if (user.interests.isEmpty) {
    return '/interests';
  }
  if (user.city == null || user.country == null) {
    return '/location_permission';
  }
  return '/home';
}

class CurrentUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    // Initial state is null, then we restore session
    return null;
  }

  Future<UserModel?> restoreSession() async {
    final user = await ref.read(authServiceProvider).restoreSession();
    state = user;
    return user;
  }

  Future<void> setUser(UserModel user) async {
    state = user;
  }

  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
    List<String>? interests,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? countryCode,
  }) async {
    if (state != null) {
      final updatedUser = state!.copyWith(
        name: name,
        profileImageUrl: avatarUrl,
        interests: interests,
        latitude: lat,
        longitude: lng,
        city: city,
        country: country,
        countryCode: countryCode,
      );
      
      await ref.read(authServiceProvider).updateProfile(updatedUser);
      state = updatedUser;
    }
  }

  Future<void> updateLocation(
    double lat,
    double lng,
    String city,
    String country,
    String countryCode,
  ) async {
    await updateProfile(
      lat: lat,
      lng: lng,
      city: city,
      country: country,
      countryCode: countryCode,
    );
  }

  Future<void> logout() async {
    state = null;
    await ref.read(authServiceProvider).signOut();
  }
}

class AuthService {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  AuthService(this._ref);

  Future<void> sendResetLink(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }

  Future<UserModel?> restoreSession() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    
    return _fetchProfile(session.user.id, session.user.email!);
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user == null) {
        throw const AuthException('Login failed: Invalid response from server');
      }

      return _fetchProfile(response.user!.id, response.user!.email!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserModel> signUp(String email, String password, {String? name}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name ?? 'User'},
      );

      if (response.user == null) {
        throw const AuthException('Signup failed: Could not create user account');
      }

      return UserModel(
        id: response.user!.id,
        name: name ?? 'User',
        email: email.trim(),
        joinedAt: DateTime.now(),
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel> _fetchProfile(String id, String email) async {
    Map<String, dynamic>? data;
    int retries = 0;
    
    // Sometimes the Postgres trigger has a tiny delay
    while (retries < 3) {
      try {
        data = await _supabase
            .from('profiles')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null) break;
      } catch (_) {
        // Ignore and retry
      }
      retries++;
      await Future.delayed(Duration(milliseconds: 500 * retries));
    }

    if (data == null) {
      // If profile is missing (e.g. trigger failed during signup), create a default one.
      try {
        final newProfile = {
          'id': id,
          'name': email.split('@').first,
          'avatar_url': 'assets/avatars/avatar_0.png',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        await _supabase.from('profiles').insert(newProfile);
        data = newProfile;
      } catch (e) {
        throw const AuthException('User profile not found and could not be created. Please try again.');
      }
    }
    
    // Fetch bookmarks too
    final List<dynamic> bookmarksData = await _supabase
        .from('bookmarks')
        .select('event_id')
        .eq('user_id', id);
    
    final bookmarks = bookmarksData.map((b) => b['event_id'] as String).toList();

    return UserModel.fromJson({
      ...data,
      'email': email,
      'bookmarkedEventIds': bookmarks,
      'joinedAt': data['created_at'] ?? DateTime.now().toIso8601String(),
      'profileImageUrl': data['avatar_url'], // Map avatar_url to profileImageUrl
    });
  }

  Future<void> updateProfile(UserModel user) async {
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'name': user.name,
      'avatar_url': user.profileImageUrl,
      'interests': user.interests,
      'latitude': user.latitude,
      'longitude': user.longitude,
      'city': user.city,
      'country': user.country,
      'country_code': user.countryCode,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
