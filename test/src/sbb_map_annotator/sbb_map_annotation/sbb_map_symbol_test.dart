import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

import 'sbb_map_annotation_fixture.dart';

void main() {
  group('SBBMapSymbol Unit Test', () {
    group('toGeoSource', () {
      test('should return minimal geoJson', () {
        // setup
        final sut = simpleSymbolFixture;
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {
            "id": sut.id,
            "iconImage": fakeURI,
            "draggable": false,
            "sbbAnnotationType": "SBBMapSymbol",
          },
          "geometry": {"type": "Point", "coordinates": fakeCoords.toGeoJsonCoordinates()}
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });

      test('should return geoJson with properties from style', () {
        // setup
        const iconSize = 2.0;
        const text = 'someText';
        final sut = SBBMapSymbol(
          symbolURI: fakeURI,
          coords: fakeCoords,
          style: const SBBMapSymbolStyle(iconSize: iconSize),
          text: text,
        );
        final expected = {
          "type": "Feature",
          "id": sut.id,
          "properties": {
            "id": sut.id,
            "iconImage": fakeURI,
            "draggable": false,
            "iconSize": iconSize,
            "textField": text,
            "sbbAnnotationType": "SBBMapSymbol",
          },
          "geometry": {"type": "Point", "coordinates": fakeCoords.toGeoJsonCoordinates()}
        };
        // act + expect
        expect(sut.toGeoJson(), equals(expected));
      });
    });

    group('copyWith', () {
      test('should return same if no values given', () {
        // setup
        final sut = simpleSymbolFixture;

        //act + expect
        expect(sut.copyWith(), equals(sut));
      });

      test('should be different object from copyWith', () {
        // setup
        final a = simpleSymbolFixture;

        // act
        final b = a.copyWith(text: 'someText');

        //act + expect
        expect(identical(a, b), equals(false));
      });

      test('should have same id from copyWith', () {
        // setup
        final sut = simpleSymbolFixture;

        // act
        final actual = sut.copyWith(text: 'someText');

        //act + expect
        expect(actual.id, equals(sut.id));
      });

      test('should return src with addon properties from copy', () {
        // setup
        final sut = simpleSymbolFixture;
        const someData = {'some': 'data'};

        //act
        final actual = sut.copyWith(data: someData);

        // expect
        expect(actual.id, equals(sut.id));
        expect(actual.data, equals(someData));
      });

      test('should override src properties from copy but not in src', () {
        // setup
        final sut = simpleSymbolFixture;
        const newCoords = LatLng(12.0, 22.0);

        // act
        final actual = sut.copyWith(coords: newCoords);

        // expect
        expect(actual.coords, equals(newCoords));
        expect(sut.coords, equals(fakeCoords));
      });
    });

    group('id', () {
      test('should be same if simple', () {
        // setup
        final sut = simpleSymbolFixture;
        final other = simpleSymbolFixture;

        // expect
        expect(sut.id, equals(other.id));
      });
      test('should not be same if more annotated', () {
        // setup
        final sut = SBBMapSymbol(
          symbolURI: fakeURI,
          coords: fakeCoords,
          text: 'someText',
          data: {'hello': 'world'},
        );
        final other = SBBMapSymbol(
          symbolURI: fakeURI,
          coords: fakeCoords,
          text: 'someText',
          data: {'hello': 'world'},
        );

        // expect
        expect(sut.id, isNot(equals(other.id)));
      });
    });
    group('annotationFilter', () {
      test('annotationFilter should be correct', () {
        // setup
        final sut = simpleSymbolFixture;

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

  group('SBBMapSymbolStyle Unit Test', () {
    group('toJson', () {
      test('should return empty json', () {
        // setup
        const sut = SBBMapSymbolStyle();

        //act + expect
        expect(sut.toJson(), equals({}));
      });
      test('should return fixed json', () {
        // setup
        const sut = SBBMapSymbolStyle(
            iconOffset: Offset(10.0, 20.0),
            iconAnchor: 'center',
            fontNames: ["Arial", "Helvetica", "Sans-serif"],
            textSize: 16.0);

        const expected = {
          "iconOffset": [10.0, 20.0],
          "iconAnchor": "center",
          "fontNames": ["Arial", "Helvetica", "Sans-serif"],
          "textSize": 16.0,
        };

        // act + expected
        expect(sut.toJson(), equals(expected));
      });
    });

    group('copyWith', () {
      test('should return empty if src and copy are empty', () {
        // setup
        const sut = SBBMapSymbolStyle();
        const other = SBBMapSymbolStyle();

        //act + expect
        expect(sut.copyWith(other), equals(sut));
      });

      test('should return same as src if copy is empty', () {
        // setup
        const sut = SBBMapSymbolStyle(textAnchor: 'center');
        const other = SBBMapSymbolStyle();

        //act + expect
        expect(sut.copyWith(other), equals(sut));
      });

      test('should return src with addon properties from copy', () {
        // setup
        const sut = SBBMapSymbolStyle(textAnchor: 'center');
        const other = SBBMapSymbolStyle(iconAnchor: 'center');

        //act + expect
        expect(
            sut.copyWith(other),
            equals(
              const SBBMapSymbolStyle(textAnchor: 'center', iconAnchor: 'center'),
            ));
      });

      test('should override src properties from copy', () {
        // setup
        const sut = SBBMapSymbolStyle(
          iconAnchor: 'center',
          textColor: Colors.black,
        );
        const other = SBBMapSymbolStyle(iconAnchor: 'topLeft');

        //act + expect
        expect(
            sut.copyWith(other),
            equals(
              const SBBMapSymbolStyle(textColor: Colors.black, iconAnchor: 'topLeft'),
            ));
      });
    });
  });
}
