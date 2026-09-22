import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/sbb_map_poi.dart';
import 'sbb_rokas_poi_controller.fixture.dart';

void main() {
  group('RokasPOI', () {
    test('fromGeoJSON should convert JSON to RokasPOI object', () {
      // Act
      final result = RokasPOI.fromGeoJSON(mobilityBikesharingPoiGeoJSONFixture);

      // Assert
      expect(result, isA<RokasPOI>());
      expect(result, mobilityBikesharingPoiFixture);
    });
  });
}
