import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

import 'sbb_map_annotation_fixture.dart';

void main() {
  group('SBBMapLine', () {
    group('toGeoJson', () {
      test('should return minimal geoJson', () {
        // setup
        final sut = createLineFixture();
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {"id": sut.id, "draggable": sut.draggable, "sbbAnnotationType": "SBBMapLine"},
          "geometry": {"type": "LineString", "coordinates": sut.vertices.map((n) => n.toGeoJsonCoordinates()).toList()},
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });

      test('should return geoJson with properties from style', () {
        // setup
        const style = SBBMapLineStyle(lineWidth: 2.0);
        final sut = createLineFixture(style: style);
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {
            "id": sut.id,
            "draggable": sut.draggable,
            "lineWidth": style.lineWidth,
            "sbbAnnotationType": "SBBMapLine",
          },
          "geometry": {"type": "LineString", "coordinates": sut.vertices.map((n) => n.toGeoJsonCoordinates()).toList()},
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });
    });

    group('copyWith', () {
      test('should return same if no values given', () {
        // setup
        final sut = createLineFixture();

        // act + expect
        expect(sut.copyWith(), equals(sut));
      });

      test('should be different object from copyWith', () {
        // setup
        final sut = createLineFixture();

        // act
        final result = sut.copyWith(nodes: [const LatLng(0, 0)]);

        // act + expect
        expect(identical(sut, result), equals(false));
      });

      test('should have same id from copyWith', () {
        // setup
        final sut = createLineFixture();

        // act
        final result = sut.copyWith(nodes: [const LatLng(0, 0)]);

        // act + expect
        expect(result.id, equals(sut.id));
      });

      test('should return src with addon properties from copy', () {
        // setup
        final sut = createLineFixture();
        final fakeData = {'key': 'new value'};

        // act
        final result = sut.copyWith(data: fakeData);

        // expect
        expect(result.id, equals(sut.id));
        expect(result.data, equals(fakeData));
      });

      test('should override src properties from copy but not in src', () {
        // setup
        final sut = createLineFixture();
        final newVertices = [const LatLng(12.0, 22.0)];

        // act
        final result = sut.copyWith(nodes: newVertices);

        // expect
        expect(result.vertices, equals(newVertices));
        expect(sut.vertices, isNot(equals(newVertices)));
      });
    });

    group('id', () {
      test('should not be same for different instances', () {
        // setup
        final sut1 = createLineFixture();
        final sut2 = createLineFixture();

        // expect
        expect(sut1.id, isNot(equals(sut2.id)));
      });
    });
    group('annotationFilter', () {
      test('annotationFilter should be correct', () {
        // setup
        final sut = createLineFixture();

        // expect
        expect(sut.annotationFilter, equals(createAnnotationFilter(sut.runtimeType.toString())));
      });
    });
  });

  group('SBBMapLineStyle', () {
    test('should create a default SBBMapLineStyle instance', () {
      const style = SBBMapLineStyle();

      // Default values tests
      expect(style.lineJoin, isNull);
      expect(style.lineOpacity, isNull);
      expect(style.lineColor, isNull);
      expect(style.lineWidth, isNull);
      expect(style.lineGapWidth, isNull);
      expect(style.lineOffset, isNull);
      expect(style.lineBlur, isNull);
      expect(style.lineDasharray, isNull);
      expect(style.linePattern, isNull);
    });

    test('should use provided values', () {
      const style = SBBMapLineStyle(
        lineJoin: 'bevel',
        lineOpacity: 0.5,
        lineColor: Colors.blue,
        lineWidth: 2.0,
        lineGapWidth: 1.0,
        lineOffset: 3.0,
        lineBlur: 0.1,
        lineDasharray: [5.0, 2.0],
        linePattern: 'pattern',
      );

      // Provided values tests
      expect(style.lineJoin, 'bevel');
      expect(style.lineOpacity, 0.5);
      expect(style.lineColor, Colors.blue);
      expect(style.lineWidth, 2.0);
      expect(style.lineGapWidth, 1.0);
      expect(style.lineOffset, 3.0);
      expect(style.lineBlur, 0.1);
      expect(style.lineDasharray, [5.0, 2.0]);
      expect(style.linePattern, 'pattern');
    });

    test('copyWith should override properties', () {
      var style = const SBBMapLineStyle(lineWidth: 2.0);
      style = style.copyWith(const SBBMapLineStyle(lineWidth: 3.0));

      expect(style.lineWidth, 3.0);
    });

    test('toJson should convert instance to json', () {
      const style = SBBMapLineStyle(
        lineJoin: 'bevel',
        lineOpacity: 0.5,
        lineColor: Colors.blue,
        lineWidth: 2.0,
        lineGapWidth: 1.0,
        lineOffset: 3.0,
        lineBlur: 0.1,
        lineDasharray: [5.0, 2.0],
        linePattern: 'pattern',
      );

      final json = style.toJson();

      expect(json['lineJoin'], 'bevel');
      expect(json['lineOpacity'], 0.5);
      expect(json['lineColor'], Colors.blue.toHexStringRGB());
      expect(json['lineWidth'], 2.0);
      expect(json['lineGapWidth'], 1.0);
      expect(json['lineOffset'], 3.0);
      expect(json['lineBlur'], 0.1);
      expect(json['lineDasharray'], '[5.0, 2.0]');
      expect(json['linePattern'], 'pattern');
    });

    test('equality and hashCode', () {
      const style1 = SBBMapLineStyle(lineWidth: 2.0);
      const style2 = SBBMapLineStyle(lineWidth: 2.0);
      const style3 = SBBMapLineStyle(lineWidth: 3.0);

      expect(style1, equals(style2));
      expect(style1, isNot(equals(style3)));
      expect(style1.hashCode, equals(style2.hashCode));
      expect(style1.hashCode, isNot(equals(style3.hashCode)));
    });
  });
}
