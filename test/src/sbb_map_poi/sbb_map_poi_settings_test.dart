import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('Unit Test SBBMapPOISettings', () {
    onPoiControllerAvailable1(controller) {}
    onPoiSelected1(poi) {}
    onPoiDeselected1() {}
    onPoiControllerAvailable2(controller) {}
    onPoiSelected2(poi) {}
    onPoiDeselected2() {}

    test('equality_whenAllPropertyValuesEqual_shouldBeEqual', () {
      final settings1 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      final settings2 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      expect(settings1, equals(settings2));
    });

    test('equality_whenDifferentProperties_shouldNotBeEqual', () {
      final settings1 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      final settings2 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable2,
        onPoiSelected: onPoiSelected2,
        onPoiDeselected: onPoiDeselected2,
        isPointOfInterestVisible: false,
      );

      expect(settings1, isNot(equals(settings2)));
    });

    test('equality_whenComparingWithSelf_shouldBeEqual', () {
      final settings = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      expect(settings, equals(settings));
    });

    test('equality_whenComparingWithNull_shouldNotBeEqual', () {
      final settings = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      expect(settings, isNot(equals(null)));
    });

    test('hashCode_whenAllPropertyValuesEqual_shouldBeEqual', () {
      final settings1 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      final settings2 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('hashCode_whenPropertyValuesDifferent_shouldNotBeEqual', () {
      final settings1 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable1,
        onPoiSelected: onPoiSelected1,
        onPoiDeselected: onPoiDeselected1,
        isPointOfInterestVisible: true,
      );

      final settings2 = SBBMapPOISettings(
        onPoiControllerAvailable: onPoiControllerAvailable2,
        onPoiSelected: onPoiSelected2,
        onPoiDeselected: onPoiDeselected2,
        isPointOfInterestVisible: false,
      );

      expect(settings1.hashCode, isNot(equals(settings2.hashCode)));
    });
  });
}
