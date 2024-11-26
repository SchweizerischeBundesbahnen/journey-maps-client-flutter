import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('Unit Test SBBRokasMapStyler', () {
    group('initalization', () {
      test('whenFull_shouldReturnCustomMapStylerWithAllStyleIds', () {
        // act
        final actual = SBBRokasMapStyler.full(apiKey: 'key');

        // expect
        expect(actual, isA<SBBCustomMapStyler>());
        expect(actual.getStyleIds().contains('journey_maps_aerial_v1'), equals(true));
        expect(actual.getStyleIds().contains('journey_maps_bright_v1'), equals(true));
      });

      test('whenFull_shouldReturnInBrightMode', () {
        // act
        final actual = SBBRokasMapStyler.full(apiKey: 'key');

        // expect
        expect(actual, isA<SBBCustomMapStyler>());
        expect(actual.isDarkMode, equals(false));
      });

      test('whenFull_shouldReturnStyleUriInBrightMode', () {
        // arrange
        const expectedUri = 'https://journey-maps-tiles.geocdn.sbb.ch'
            '/styles/journey_maps_bright_v1/style.json?api_key=key';

        // act
        final actual = SBBRokasMapStyler.full(apiKey: 'key');

        // expect
        expect(actual, isA<SBBCustomMapStyler>());
        expect(actual.currentStyleURI, equals(expectedUri));
      });

      test('whenNoAerial_shouldNotHaveAerial', () {
        // act
        final actual = SBBRokasMapStyler.noAerial(apiKey: 'key');

        // expect
        expect(actual, isA<SBBCustomMapStyler>());
        expect(actual.getStyleIds().contains('journey_maps_aerial_v1'), equals(false));
      });
    });
  });
}
