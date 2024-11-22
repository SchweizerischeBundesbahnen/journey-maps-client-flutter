import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('Unit Test SBBCustomMapStyler', () {
    group('initalization', () {
      test('full should return custom map styler with all styles', () {
        // act
        final actual = SBBRokasMapStyler.full(apiKey: 'key');

        // expect
        expect(actual, isA<SBBCustomMapStyler>());
        expect(actual.isDarkMode, equals(false));
      });

      test('aerial should return custom map styler without aerial', () {
        // act
        final actual = SBBRokasMapStyler.noAerial(apiKey: 'key');

        // expect
        expect(actual, isA<SBBCustomMapStyler>());
        expect(actual.getStyleIds().contains('aerial_sbb_ki_v2'), equals(false));
      });
    });
  });
}
