import 'dart:math';

class LocationUtils {
  static double distanceInKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _degreesToRadians(endLatitude - startLatitude);
    final longitudeDelta = _degreesToRadians(endLongitude - startLongitude);

    final first =
        sin(latitudeDelta / 2) * sin(latitudeDelta / 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(longitudeDelta / 2) *
            sin(longitudeDelta / 2);
    final second = 2 * atan2(sqrt(first), sqrt(1 - first));
    return earthRadiusKm * second;
  }

  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  static double _degreesToRadians(double value) {
    return value * pi / 180;
  }
}
