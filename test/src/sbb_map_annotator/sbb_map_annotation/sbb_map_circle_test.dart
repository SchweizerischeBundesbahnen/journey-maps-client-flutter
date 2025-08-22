import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

import 'sbb_map_annotation_fixture.dart';

void main() {
  group('SBBMapCircle Unit Test', () {
    group('toGeoJson', () {
      test('should return minimal geoJson', () {
        // setup
        final sut = createCircleFixture();
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {"id": sut.id, "draggable": false, "sbbAnnotationType": "SBBMapCircle"},
          "geometry": {"type": "Point", "coordinates": fakeCenter.toGeoJsonCoordinates()},
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });

      test('should return geoJson with properties from style', () {
        // setup
        const double radius = 15.0;
        final sut = createCircleFixture(style: const SBBMapCircleStyle(radius: radius));
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {"id": sut.id, "draggable": false, "circleRadius": radius, "sbbAnnotationType": "SBBMapCircle"},
          "geometry": {"type": "Point", "coordinates": fakeCenter.toGeoJsonCoordinates()},
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });
    });

    group('copyWith', () {
      test('should return same if no values given', () {
        // setup
        final sut = createCircleFixture();

        //act + expect
        expect(sut.copyWith(), equals(sut));
      });

      test('should be different object from copyWith', () {
        // setup
        final sut = createCircleFixture();

        // act
        final result = sut.copyWith(center: const LatLng(0, 0));

        //act + expect
        expect(identical(sut, result), equals(false));
      });

      test('should have same id from copyWith', () {
        // setup
        final sut = createCircleFixture();

        // act
        final result = sut.copyWith(center: const LatLng(0, 0));

        //act + expect
        expect(result.id, equals(sut.id));
      });

      test('should return src with addon properties from copy', () {
        // setup
        final sut = createCircleFixture();

        //act
        final result = sut.copyWith(data: fakeData);

        // expect
        expect(result.id, equals(sut.id));
        expect(result.data, equals(fakeData));
      });

      test('should override src properties from copy but not in src', () {
        // setup
        final sut = createCircleFixture();
        const LatLng newCenter = LatLng(12.0, 22.0);

        // act
        final result = sut.copyWith(center: newCenter);

        // expect
        expect(result.center, equals(newCenter));
        expect(sut.center, equals(fakeCenter));
      });
    });

    group('id', () {
      test('should not be same for different instances', () {
        // setup
        final sut1 = createCircleFixture();
        final sut2 = createCircleFixture();

        // expect
        expect(sut1.id, isNot(equals(sut2.id)));
      });
    });

    group('annotationFilter', () {
      test('annotationFilter should be correct', () {
        // setup
        final sut = createCircleFixture();

        // expect
        expect(sut.annotationFilter, equals(createAnnotationFilter(sut.runtimeType.toString())));
      });
    });
  });

  group('SBBMapCircleStyle Unit tests', () {
    // Test data
    const double testRadius = 10.0;
    const Color testFillColor = Colors.red;
    const double testFillOpacity = 0.5;
    const double testFillBlur = 1.0;
    const Color testStrokeColor = Colors.blue;
    const double testStrokeOpacity = 0.75;
    const double testStrokeWidth = 2.0;

    // Test default constructor
    test('default values', () {
      const style = SBBMapCircleStyle();
      expect(style.radius, isNull);
      expect(style.fillColor, isNull);
      expect(style.fillOpacity, isNull);
      expect(style.fillBlur, isNull);
      expect(style.strokeColor, isNull);
      expect(style.strokeOpacity, isNull);
      expect(style.strokeWidth, isNull);
    });

    // Test copyWith
    test('copyWith', () {
      const original = SBBMapCircleStyle();
      final copied = original.copyWith(
        const SBBMapCircleStyle(
          radius: testRadius,
          fillColor: testFillColor,
          fillOpacity: testFillOpacity,
          fillBlur: testFillBlur,
          strokeColor: testStrokeColor,
          strokeOpacity: testStrokeOpacity,
          strokeWidth: testStrokeWidth,
        ),
      );

      expect(copied.radius, testRadius);
      expect(copied.fillColor, testFillColor);
      expect(copied.fillOpacity, testFillOpacity);
      expect(copied.fillBlur, testFillBlur);
      expect(copied.strokeColor, testStrokeColor);
      expect(copied.strokeOpacity, testStrokeOpacity);
      expect(copied.strokeWidth, testStrokeWidth);
    });

    // Test toJson
    test('toJson', () {
      const style = SBBMapCircleStyle(
        radius: testRadius,
        fillColor: testFillColor,
        fillOpacity: testFillOpacity,
        fillBlur: testFillBlur,
        strokeColor: testStrokeColor,
        strokeOpacity: testStrokeOpacity,
        strokeWidth: testStrokeWidth,
      );

      final json = style.toJson();
      expect(json['circleRadius'], testRadius);
      expect(json['circleColor'], testFillColor.toHexStringRGB());
      expect(json['circleOpacity'], testFillOpacity);
      expect(json['circleBlur'], testFillBlur);
      expect(json['circleStrokeColor'], testStrokeColor.toHexStringRGB());
      expect(json['circleStrokeOpacity'], testStrokeOpacity);
      expect(json['circleStrokeWidth'], testStrokeWidth);
    });

    // Test equality and hashCode
    test('equality and hashCode', () {
      const style1 = SBBMapCircleStyle(radius: testRadius, fillColor: testFillColor);
      const style2 = SBBMapCircleStyle(radius: testRadius, fillColor: testFillColor);
      const style3 = SBBMapCircleStyle(
        radius: testRadius,
        fillColor: Colors.green, // Different color
      );

      expect(style1 == style2, isTrue);
      expect(style1.hashCode, style2.hashCode);
      expect(style1 == style3, isFalse);
      expect(style1.hashCode, isNot(style3.hashCode));
    });
  });
}
