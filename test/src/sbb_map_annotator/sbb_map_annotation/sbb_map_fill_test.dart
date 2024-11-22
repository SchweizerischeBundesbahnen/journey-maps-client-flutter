import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

import 'sbb_map_annotation_fixture.dart';

void main() {
  group('SBBMapFill', () {
    group('toGeoJson', () {
      test('should return minimal geoJson', () {
        // setup
        final sut = createFillFixture();
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {"id": sut.id, "draggable": sut.draggable, "sbbAnnotationType": "SBBMapFill"},
          "geometry": {
            "type": "Polygon",
            "coordinates":
                sut.coords.map((e) => e.map((LatLng latLng) => [latLng.longitude, latLng.latitude]).toList()).toList(),
          }
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });

      test('should return geoJson with properties from style', () {
        // setup
        const style = SBBMapFillStyle(fillOpacity: 0.5);
        final sut = createFillFixture(style: style);
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {
            "id": sut.id,
            "draggable": sut.draggable,
            "fillOpacity": style.fillOpacity,
            "sbbAnnotationType": "SBBMapFill",
          },
          "geometry": {
            "type": "Polygon",
            "coordinates":
                sut.coords.map((e) => e.map((LatLng latLng) => [latLng.longitude, latLng.latitude]).toList()).toList(),
          }
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });
    });

    group('copyWith', () {
      test('should return same if no values given', () {
        // setup
        final sut = createFillFixture();

        // act + expect
        expect(sut.copyWith(), equals(sut));
      });

      test('should be different object from copyWith', () {
        // setup
        final sut = createFillFixture();

        // act
        final result = sut.copyWith(coords: [
          [const LatLng(0, 0), const LatLng(0, 1), const LatLng(1, 1), const LatLng(1, 0)]
        ]);

        // act + expect
        expect(identical(sut, result), equals(false));
      });

      test('should have same id from copyWith', () {
        // setup
        final sut = createFillFixture();

        // act
        final result = sut.copyWith();

        // act + expect
        expect(result.id, equals(sut.id));
      });

      test('should have same hashCode and equality from copyWith', () {
        // setup
        final sut = createFillFixture();

        // act
        final result = sut.copyWith();

        // act + expect
        expect(result, equals(sut));
        expect(result.hashCode, equals(sut.hashCode));
      });

      test('should return src with addon properties from copy', () {
        // setup
        final sut = createFillFixture();
        final fakeData = {'key': 'new value'};

        // act
        final result = sut.copyWith(data: fakeData);

        // expect
        expect(result.id, equals(sut.id));
        expect(result.data, equals(fakeData));
      });

      test('should override src properties from copy but not in src', () {
        // setup
        final sut = createFillFixture();
        final newCoords = [
          [const LatLng(12.0, 22.0), const LatLng(13.0, 23.0)]
        ];

        // act
        final result = sut.copyWith(coords: newCoords);

        // expect
        expect(result.coords, equals(newCoords));
        expect(sut.coords, isNot(equals(newCoords)));
      });
    });

    group('id', () {
      test('should not be same for different instances', () {
        // setup
        final sut1 = createFillFixture();
        final sut2 = createFillFixture();

        // expect
        expect(sut1.id, isNot(equals(sut2.id)));
      });
    });

    group('annotationFilter', () {
      test('annotationFilter should be correct', () {
        // setup
        final sut = createFillFixture();

        // expect
        expect(
          sut.annotationFilter,
          equals(
            createAnnotationFilter(sut.runtimeType.toString()),
          ),
        );
      });
    });
  });

  group('SBBMapFillStyle', () {
    test('should create a default SBBMapFillStyle instance', () {
      const style = SBBMapFillStyle();

      // Default values tests
      expect(style.fillOpacity, isNull);
      expect(style.fillColor, isNull);
      expect(style.fillOutlineColor, isNull);
      expect(style.fillPattern, isNull);
    });

    test('should use provided values', () {
      const style = SBBMapFillStyle(
        fillOpacity: 0.5,
        fillColor: Colors.blue,
        fillOutlineColor: Colors.green,
        fillPattern: 'pattern-image',
      );

      // Provided values tests
      expect(style.fillOpacity, 0.5);
      expect(style.fillColor, Colors.blue);
      expect(style.fillOutlineColor, Colors.green);
      expect(style.fillPattern, 'pattern-image');
    });

    test('copyWith should override properties', () {
      var style = const SBBMapFillStyle(fillOpacity: 0.5);
      style = style.copyWith(const SBBMapFillStyle(fillOpacity: 0.8));

      expect(style.fillOpacity, 0.8);
    });

    test('toJson should convert instance to json', () {
      const style = SBBMapFillStyle(
        fillOpacity: 0.5,
        fillColor: Colors.blue,
        fillOutlineColor: Colors.green,
        fillPattern: 'pattern-image',
      );

      final json = style.toJson();

      expect(json['fillOpacity'], 0.5);
      expect(
        json['fillColor'],
        Colors.blue.toHexStringRGB(),
      );
      expect(
        json['fillOutlineColor'],
        Colors.green.toHexStringRGB(),
      );
      expect(json['fillPattern'], 'pattern-image');
    });

    test('equality and hashCode', () {
      const style1 = SBBMapFillStyle(fillOpacity: 0.5);
      const style2 = SBBMapFillStyle(fillOpacity: 0.5);
      const style3 = SBBMapFillStyle(fillOpacity: 0.8);

      expect(style1, equals(style2));
      expect(style1, isNot(equals(style3)));
      expect(style1.hashCode, equals(style2.hashCode));
      expect(style1.hashCode, isNot(equals(style3.hashCode)));
    });
  });
}
