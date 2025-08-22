import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('SBBCameraPosition Unit tests', () {
    // Test data
    const LatLng testTarget = LatLng(47.3769, 8.5417); // Coordinates for Zurich, for example
    const double testBearing = 45.0;
    const double testZoom = 15.0;

    test('default values', () {
      const position = SBBCameraPosition(target: testTarget);
      expect(position.bearing, 0.0);
      expect(position.zoom, 0.0);
    });

    test('initialization with parameters', () {
      const position = SBBCameraPosition(target: testTarget, bearing: testBearing, zoom: testZoom);
      expect(position.bearing, testBearing);
      expect(position.target, testTarget);
      expect(position.zoom, testZoom);
    });

    test('equality operator', () {
      const position1 = SBBCameraPosition(target: testTarget, bearing: testBearing, zoom: testZoom);
      const position2 = SBBCameraPosition(target: testTarget, bearing: testBearing, zoom: testZoom);
      const position3 = SBBCameraPosition(
        target: LatLng(0.0, 0.0), // Different target
      );

      expect(position1 == position2, isTrue);
      expect(position1 == position3, isFalse);
    });

    test('hashCode', () {
      const position = SBBCameraPosition(target: testTarget, bearing: testBearing, zoom: testZoom);
      final expectedHashCode = Object.hash(testBearing, testTarget, testZoom);
      expect(position.hashCode, expectedHashCode);
    });

    test('toString', () {
      const position = SBBCameraPosition(target: testTarget, bearing: testBearing, zoom: testZoom);
      final stringRepresentation = 'SBBCameraPosition(bearing: $testBearing, target: $testTarget, zoom: $testZoom)';
      expect(position.toString(), stringRepresentation);
    });

    test('toMaplibre conversion', () {
      const position = SBBCameraPosition(target: testTarget, bearing: testBearing, zoom: testZoom);
      final maplibrePosition = position.toMaplibre();
      expect(maplibrePosition.bearing, testBearing);
      expect(maplibrePosition.target, testTarget);
      expect(maplibrePosition.zoom, testZoom);
    });
  });
}
