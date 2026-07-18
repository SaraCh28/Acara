import 'package:flutter_test/flutter_test.dart';
import 'package:acara/core/utils/location_utils.dart';

void main() {
  group('LocationUtils Tests', () {
    test('calculate distance between two coordinates', () {
      // London to Paris (~344km)
      final distance = LocationUtils.distanceInKm(
        startLatitude: 51.5074,
        startLongitude: -0.1278,
        endLatitude: 48.8566,
        endLongitude: 2.3522,
      );
      
      expect(distance, closeTo(343.4, 1.0));
    });

    test('format distance correctly for meters', () {
      expect(LocationUtils.formatDistance(0.5), '500 m');
      expect(LocationUtils.formatDistance(0.01), '10 m');
    });

    test('format distance correctly for kilometers', () {
      expect(LocationUtils.formatDistance(1.5), '1.5 km');
      expect(LocationUtils.formatDistance(120.45), '120.5 km');
    });
  });
}
