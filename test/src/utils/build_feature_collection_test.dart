import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:test/test.dart';

void main() {
  group('Unit Test Build Feature Collection', () {
    sut(List<Map<String, dynamic>> p0) => buildFeatureCollection(p0);
    test('should return empty features if empty list given', () {
      // setup
      final expected = {"type": "FeatureCollection", "features": []};

      // act + expect
      expect(sut([]), equals(expected));
    });

    test('should return full features if list given', () {
      // setup
      final expected = {
        "type": "FeatureCollection",
        "features": [
          {'hello': 'world'},
          {'foo': 'bar'},
        ],
      };

      // act + expect
      expect(
        sut([
          {'hello': 'world'},
          {'foo': 'bar'},
        ]),
        equals(expected),
      );
    });
  });
}
