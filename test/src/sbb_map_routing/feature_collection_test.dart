import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/feature_collection.dart';

import 'feature_collection.fixture.dart';

void main() {
  group('FeatureCollection', () {
    test('fromGeoJSON should convert JSON to FeatureCollection object', () {
      final result = FeatureCollection.fromGeoJSON(featureCollectionFixtureGeneralJSON);

      expect(result, isA<FeatureCollection>());
      expect(result, equals(featureCollectionFixtureGeneral));
    });

    test('toAnnotation should convert feature object to annotation object', () {
      final resultCircle = featureCollectionFixtureGeneral.features[0].toAnnotation();
      final resultLine = featureCollectionFixtureGeneral.features[1].toAnnotation();
      final resultFill = featureCollectionFixtureGeneral.features[2].toAnnotation();

      expect(resultCircle, isA<SBBMapCircle>());
      expect(resultLine, isA<SBBMapLine>());
      expect(resultFill, isA<SBBMapFill>());
    });
  });
}
