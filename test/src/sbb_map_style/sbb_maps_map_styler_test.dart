import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/api_key_missing_exception.dart';

void main() {
  group('Unit Test SBBMapsMapStyler', () {
    test('whenFull_shouldReturnCustomMapStylerWithAllStyleIds', () {
      // act
      final actual = SBBMapsMapStyler.full(apiKey: 'key');

      // expect
      expect(actual, isA<SBBCustomMapStyler>());
      expect(actual.getStyleIds().contains('sbbmaps_aerial'), equals(true));
      expect(actual.getStyleIds().contains('sbbmaps_bright'), equals(true));
    });

    test('whenFull_shouldReturnInBrightMode', () {
      // act
      final actual = SBBMapsMapStyler.full(apiKey: 'key');

      // expect
      expect(actual, isA<SBBCustomMapStyler>());
      expect(actual.isDarkMode, equals(false));
    });

    test('whenFull_shouldReturnStyleUriInBrightMode', () {
      // arrange
      const expectedUri =
          'https://journey-maps-tiles.geocdn.sbb.ch'
          '/styles/sbbmaps_bright/style.json?api_key=key';

      // act
      final actual = SBBMapsMapStyler.full(apiKey: 'key');

      // expect
      expect(actual, isA<SBBCustomMapStyler>());
      expect(actual.currentStyleURI, equals(expectedUri));
    });

    test('whenFullAndIsDarkMode_shouldReturnStyleUriInDarkMode', () {
      // arrange
      const expectedUri =
          'https://journey-maps-tiles.geocdn.sbb.ch'
          '/styles/sbbmaps_dark/style.json?api_key=key';

      // act
      final actual = SBBMapsMapStyler.full(apiKey: 'key', isDarkMode: true);

      // expect
      expect(actual, isA<SBBCustomMapStyler>());
      expect(actual.currentStyleURI, equals(expectedUri));
    });

    test('whenNoAerial_shouldNotHaveAerial', () {
      // act
      final actual = SBBMapsMapStyler.noAerial(apiKey: 'key');

      // expect
      expect(actual, isA<SBBCustomMapStyler>());
      expect(actual.getStyleIds().contains('sbbmaps_aerial'), equals(false));
    });

    test('whenNoApiKey_shouldThrowApiKeyMissingException', () {
      // act + expect
      expect(() => SBBMapsMapStyler.full(), throwsA(const TypeMatcher<ApiKeyMissing>()));
    });

    test('whenUseIntegrationDataIsTrue_uriShouldBeIntPointing', () {
      // arrange
      const expectedUri =
          'https://journey-maps-tiles.geocdn-int.sbb.ch'
          '/styles/sbbmaps_bright/style.json?api_key=key';

      // act
      final actual = SBBMapsMapStyler.full(apiKey: 'key', useIntegrationData: true);

      // expect
      expect(actual, isA<SBBCustomMapStyler>());
      expect(actual.currentStyleURI, equals(expectedUri));
    });
  });
}
