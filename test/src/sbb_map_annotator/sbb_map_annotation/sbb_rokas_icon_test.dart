import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotations/sbb_map_annotation.dart';
import 'package:test/test.dart';

import 'sbb_map_annotation_fixture.dart';

void main() {
  group('SBBRokasIcon Unit Test', () {
    group('toGeoSource', () {
      test('should return minimal geoJson', () {
        // setup
        final sut = simpleRokasIconFixture;
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {
            "id": sut.id,
            "iconImage": fakeRokasIconURI,
            "draggable": false,
            "sbbAnnotationType": "SBBRokasIcon",
          },
          "geometry": {"type": "Point", "coordinates": fakeCoords.toGeoJsonCoordinates()}
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });
    });

    group('id', () {
      test('should return different ids even if object have same properties (empty)', () {
        // setup
        final a = SBBRokasIcon(symbolURI: fakeRokasIconURI, coords: fakeCoords);
        final b = SBBRokasIcon(symbolURI: fakeRokasIconURI, coords: fakeCoords);

        // act + expect
        expect(identical(a, b), false);
        expect(a.id, isNot(equals(b.id)));
      });
    });

    group('annotationFilter', () {
      test('annotationFilter should be correct', () {
        // setup
        final sut = simpleRokasIconFixture;

        // expect
        expect(
          sut.annotationFilter,
          equals(
            createAnnotationFilter(sut.runtimeType.toString()),
          ),
        );
      });
    });

    group('copyWith', () {
      test('should return same if no values given', () {
        // setup
        final sut = simpleRokasIconFixture;
        //act + expect
        expect(sut.copyWith(), equals(sut));
      });

      test('should return different object even if no properties given', () {
        // setup
        final sut = simpleRokasIconFixture;
        //act + expect
        expect(identical(sut.copyWith(), sut), false);
      });

      test('should return same id even if properties change', () {
        // setup
        final sut = simpleRokasIconFixture;
        //act + expect
        expect(sut.copyWith(draggable: true).id, equals(sut.id));
      });

      test('should return src with addon properties from copy', () {
        // setup
        final sut = simpleRokasIconFixture;
        final someData = {'hello': 'data'};

        //act + expect
        expect(sut.copyWith(data: someData).data, equals(someData));
      });

      test('should override src properties from copy', () {
        // setup
        final sut = simpleRokasIconFixture;
        const newCoords = LatLng(12.0, 22.0);

        //act + expect
        expect(sut.copyWith(coords: newCoords).coords, equals(newCoords));
      });
    });
  });
}
