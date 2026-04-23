import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferencesState>(
      AppPreferencesNotifier.new,
    );

class AppPreferencesState {
  final bool onboardingSeen;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final List<String> searchHistory;
  final String? selectedCity;
  final String? selectedCountry;
  final String? selectedCountryCode;
  final double? latitude;
  final double? longitude;
  final bool useGeoLocation;
  final bool isDarkMode;

  const AppPreferencesState({
    required this.onboardingSeen,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.searchHistory,
    this.selectedCity,
    this.selectedCountry,
    this.selectedCountryCode,
    this.latitude,
    this.longitude,
    this.useGeoLocation = true,
    this.isDarkMode = false,
  });

  const AppPreferencesState.initial()
      : onboardingSeen = false,
        pushNotificationsEnabled = true,
        emailNotificationsEnabled = true,
        selectedCity = null,
        selectedCountry = null,
        selectedCountryCode = null,
        latitude = null,
        longitude = null,
        useGeoLocation = true,
        isDarkMode = false, // Default to Light Luxe
        searchHistory = const [];

  AppPreferencesState copyWith({
    bool? onboardingSeen,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    List<String>? searchHistory,
    String? selectedCity,
    String? selectedCountry,
    String? selectedCountryCode,
    double? latitude,
    double? longitude,
    bool? useGeoLocation,
    bool? isDarkMode,
  }) {
    return AppPreferencesState(
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      searchHistory: searchHistory ?? this.searchHistory,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      useGeoLocation: useGeoLocation ?? this.useGeoLocation,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onboardingSeen': onboardingSeen,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'searchHistory': searchHistory,
      'selectedCity': selectedCity,
      'selectedCountry': selectedCountry,
      'selectedCountryCode': selectedCountryCode,
      'latitude': latitude,
      'longitude': longitude,
      'useGeoLocation': useGeoLocation,
      'isDarkMode': isDarkMode,
    };
  }

  factory AppPreferencesState.fromJson(Map<String, dynamic> json) {
    return AppPreferencesState(
      onboardingSeen: json['onboardingSeen'] as bool? ?? false,
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? true,
      searchHistory: (json['searchHistory'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      selectedCity: json['selectedCity'] as String?,
      selectedCountry: json['selectedCountry'] as String?,
      selectedCountryCode: json['selectedCountryCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      useGeoLocation: json['useGeoLocation'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
    );
  }
}

class AppPreferencesNotifier extends Notifier<AppPreferencesState> {
  static const _storageKey = 'app_preferences';

  @override
  AppPreferencesState build() {
    return const AppPreferencesState.initial();
  }

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    state = AppPreferencesState.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> markOnboardingSeen() async {
    state = state.copyWith(onboardingSeen: true);
    await _persist();
  }

  Future<void> setPushNotifications(bool enabled) async {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    await _persist();
  }

  Future<void> setEmailNotifications(bool enabled) async {
    state = state.copyWith(emailNotificationsEnabled: enabled);
    await _persist();
  }

  Future<void> setManualLocation({
    required String city,
    required String country,
    required String countryCode,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(
      selectedCity: city,
      selectedCountry: country,
      selectedCountryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      useGeoLocation: false,
    );
    await _persist();
  }

  Future<void> setUseGeoLocation(bool use) async {
    state = state.copyWith(useGeoLocation: use);
    await _persist();
  }

  Future<void> addSearchTerm(String term) async {
    final normalized = term.trim();
    if (normalized.isEmpty) {
      return;
    }

    final List<String> next = [
      normalized,
      ...state.searchHistory.where(
        (item) => item.toLowerCase() != normalized.toLowerCase(),
      ),
    ];

    state = state.copyWith(searchHistory: next.take(8).toList());
    await _persist();
  }

  Future<void> clearSearchHistory() async {
    state = state.copyWith(searchHistory: const []);
    await _persist();
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
