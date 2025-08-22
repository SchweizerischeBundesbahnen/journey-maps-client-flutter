import 'dart:math';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('SBBMapProperties Unit tests', () {
    // Test defaults
    test('default values', () {
      const mapProperties = SBBMapProperties();
      expect(mapProperties.compassEnabled, isTrue);
      expect(mapProperties.compassViewPosition, CompassViewPosition.topLeft);
      expect(mapProperties.compassViewMargins, isNull);
      expect(mapProperties.rotateGesturesEnabled, isTrue);
      expect(mapProperties.scrollGesturesEnabled, isTrue);
      expect(mapProperties.doubleClickZoomEnabled, isTrue);
      expect(mapProperties.zoomGesturesEnabled, isTrue);
    });

    // Test copyWith
    test('copyWith with all new values', () {
      const original = SBBMapProperties();
      final copied = original.copyWith(
        compassEnabled: false,
        compassViewPosition: CompassViewPosition.bottomRight,
        compassViewMargins: const Point(10, 10),
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        doubleClickZoomEnabled: false,
        zoomGesturesEnabled: false,
      );

      expect(copied.compassEnabled, isFalse);
      expect(copied.compassViewPosition, CompassViewPosition.bottomRight);
      expect(copied.compassViewMargins, const Point(10, 10));
      expect(copied.rotateGesturesEnabled, isFalse);
      expect(copied.scrollGesturesEnabled, isFalse);
      expect(copied.doubleClickZoomEnabled, isFalse);
      expect(copied.zoomGesturesEnabled, isFalse);
    });

    test('copyWith with no new values', () {
      const original = SBBMapProperties();
      final copied = original.copyWith();
      expect(copied.compassEnabled, isTrue);
      expect(copied.compassViewPosition, CompassViewPosition.topLeft);
      expect(copied.compassViewMargins, isNull);
      expect(copied.rotateGesturesEnabled, isTrue);
      expect(copied.scrollGesturesEnabled, isTrue);
      expect(copied.doubleClickZoomEnabled, isTrue);
      expect(copied.zoomGesturesEnabled, isTrue);
    });

    // Test equality and hashcode
    test('equality and hashCode', () {
      const properties1 = SBBMapProperties(compassViewMargins: Point(5, 5));
      const properties2 = SBBMapProperties(compassViewMargins: Point(5, 5));
      const properties3 = SBBMapProperties(compassViewMargins: Point(10, 10));

      expect(properties1, equals(properties2));
      expect(properties1.hashCode, equals(properties2.hashCode));
      expect(properties1, isNot(equals(properties3)));
      expect(properties1.hashCode, isNot(equals(properties3.hashCode)));
    });
  });
}
