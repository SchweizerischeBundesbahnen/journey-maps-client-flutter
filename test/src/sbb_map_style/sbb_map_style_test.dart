import 'package:test/test.dart';

import 'sbb_map_style.fixture.dart';

void main() {
  group('Unit Test SBBMapStyle', () {
    group('fromURL styles', () {
      test('should return the correct uri without apiKey', () {
        // act
        final resultBright = brightOnlyWithoutApiKey.uri(isDarkStyle: false);
        final resultBrightFromDark = fullWithoutApiKey.uri(isDarkStyle: false);

        final resultDarkFromBright = brightOnlyWithoutApiKey.uri(isDarkStyle: true);
        final resultDark = fullWithoutApiKey.uri(isDarkStyle: true);
        // assert
        expect(resultBright, brightStyleURL);
        expect(resultBrightFromDark, brightStyleURL);
        expect(resultDark, darkStyleURL);
        expect(resultDarkFromBright, brightStyleURL);
      });
      test('should return the correct uri with api key', () {
        // act
        final resultBright = brightOnlyWithApiKey.uri(isDarkStyle: false);
        final resultBrightFromDark = fullWithApiKey.uri(isDarkStyle: false);

        final resultDarkFromBright = brightOnlyWithApiKey.uri(isDarkStyle: true);
        final resultDark = fullWithApiKey.uri(isDarkStyle: true);
        // assert
        expect(resultBright, '$brightStyleURL?api_key=$apiKey');
        expect(resultBrightFromDark, '$brightStyleURL?api_key=$apiKey');
        expect(resultDark, '$darkStyleURL?api_key=$apiKey');
        expect(resultDarkFromBright, '$brightStyleURL?api_key=$apiKey');
      });
    });
  });
}
