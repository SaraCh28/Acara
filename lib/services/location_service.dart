import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Result of a location lookup – coordinates plus resolved city/country.
class LocationResult {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String countryCode;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.countryCode,
  });
}

class LocationService {
  /// Requests permission (if needed) then returns the device's current GPS
  /// position, followed by a reverse-geocode call to Nominatim to get the
  /// city/country name.
  Future<LocationResult> requestPermissionAndGetLocation() async {
    // --- Permission check ---
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // --- Get GPS position ---
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // --- Reverse geocode ---
    final placeInfo = await reverseGeocode(position.latitude, position.longitude);

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      city: placeInfo.$1,
      country: placeInfo.$2,
      countryCode: placeInfo.$3,
    );
  }

  /// Uses OpenStreetMap Nominatim to search for cities by name.
  Future<List<LocationResult>> searchCities(String query) async {
    if (query.length < 3) return [];

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1&featuretype=city',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'AcaraApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((item) {
          final address = item['address'] as Map<String, dynamic>? ?? {};
          final city = (address['city'] as String?) ??
              (address['town'] as String?) ??
              (address['village'] as String?) ??
              (address['municipality'] as String?) ??
              (address['state'] as String?) ??
              item['display_name'].split(',').first;
          final country = (address['country'] as String?) ?? 'Unknown';
          final countryCode = (address['country_code'] as String?)?.toUpperCase() ?? 'PK';
          
          return LocationResult(
            latitude: double.parse(item['lat']),
            longitude: double.parse(item['lon']),
            city: city,
            country: country,
            countryCode: countryCode,
          );
        }).toList();
      }
    } catch (_) {
      // Return empty list on error
    }
    return [];
  }

  /// Uses OpenStreetMap Nominatim to convert coordinates to city/country.
  Future<(String city, String country, String countryCode)> reverseGeocode(
    double lat,
    double lng,
  ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'AcaraApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        final city = (address['city'] as String?) ??
            (address['town'] as String?) ??
            (address['village'] as String?) ??
            (address['state'] as String?) ??
            'Unknown';
        final country = (address['country'] as String?) ?? 'Unknown';
        final countryCode = (address['country_code'] as String?)?.toUpperCase() ?? 'PK';
        return (city, country, countryCode);
      }
    } catch (_) {
      // Fall through to default
    }
    return ('Unknown', 'Unknown', 'PK');
  }

  /// Returns (lat, lng) for a well-known city name (for manual selection).
  static (double lat, double lng)? coordsForCity(String city) {
    return _cityCoords[city.toLowerCase()];
  }

  static const _cityCoords = <String, (double, double)>{
    'jakarta': (-6.2088, 106.8456),
    'bandung': (-6.9175, 107.6191),
    'surabaya': (-7.2575, 112.7521),
    'bali': (-8.4095, 115.1889),
    'singapore': (1.3521, 103.8198),
    'kuala lumpur': (3.1390, 101.6869),
    'lahore': (31.5497, 74.3436),
    'london': (51.5074, -0.1278),
    'dubai': (25.2048, 55.2708),
    'new york': (40.7128, -74.0060),
    'karachi': (24.8607, 67.0011),
    'islamabad': (33.6844, 73.0479),
  };
}
