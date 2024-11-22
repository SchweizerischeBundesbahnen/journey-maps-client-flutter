import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('SBBCameraUpdate tests', () {
    // Test data
    const LatLng testLatLng = LatLng(47.3769, 8.5417); // Coordinates for Zurich, for example
    const double testZoom = 15.0;
    const double testBearing = 45.0;
    LatLngBounds testBounds = LatLngBounds(
      southwest: const LatLng(47.0, 8.0),
      northeast: const LatLng(48.0, 9.0),
    );
    const double testPadding = 10.0;

    test('newCameraPosition creates correct CameraUpdate', () {
      const cameraPosition = SBBCameraPosition(target: testLatLng);
      final sbbCameraUpdate = SBBCameraUpdate.newCameraPosition(cameraPosition);

      const cameraMlPosition = CameraPosition(target: testLatLng);
      final cameraMlUpdate = CameraUpdate.newCameraPosition(cameraMlPosition);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('newLatLng creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.newLatLng(testLatLng);

      final cameraMlUpdate = CameraUpdate.newLatLng(testLatLng);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('newLatLngBounds creates correct CameraUpdate with default padding', () {
      final sbbCameraUpdate = SBBCameraUpdate.newLatLngBounds(testBounds);

      final cameraMlUpdate = CameraUpdate.newLatLngBounds(testBounds);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('newLatLngBounds creates correct CameraUpdate with custom padding', () {
      final sbbCameraUpdate = SBBCameraUpdate.newLatLngBounds(
        testBounds,
        left: testPadding,
        top: testPadding,
        right: testPadding,
        bottom: testPadding,
      );

      final cameraMlUpdate = CameraUpdate.newLatLngBounds(
        testBounds,
        left: testPadding,
        top: testPadding,
        right: testPadding,
        bottom: testPadding,
      );
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('newLatLngZoom creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.newLatLngZoom(testLatLng, testZoom);

      final cameraMlUpdate = CameraUpdate.newLatLngZoom(testLatLng, testZoom);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('scrollBy creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.scrollBy(50.0, 75.0);

      final cameraMlUpdate = CameraUpdate.scrollBy(50.0, 75.0);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('zoomIn creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.zoomIn();

      final cameraMlUpdate = CameraUpdate.zoomIn();
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('zoomOut creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.zoomOut();

      final cameraMlUpdate = CameraUpdate.zoomOut();
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('zoomTo creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.zoomTo(testZoom);

      final cameraMlUpdate = CameraUpdate.zoomTo(testZoom);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });

    test('bearingTo creates correct CameraUpdate', () {
      final sbbCameraUpdate = SBBCameraUpdate.bearingTo(testBearing);

      final cameraMlUpdate = CameraUpdate.bearingTo(testBearing);
      expect(sbbCameraUpdate.toMaplibre(), isA<CameraUpdate>());
      expect(
        sbbCameraUpdate.toMaplibre().toJson(),
        equals(cameraMlUpdate.toJson()),
      );
    });
  });
}
