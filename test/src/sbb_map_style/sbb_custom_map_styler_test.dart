import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:test/test.dart';

import '../../util/mock_callback_function.dart';
import 'sbb_map_style.fixture.dart';

void main() {
  group('Unit Test SBBCustomMapStyler', () {
    late SBBCustomMapStyler sut;
    final spyListener = MockCallbackFunction();

    group('Single Style', () {
      setUp(() {
        sut = SBBCustomMapStyler(styles: [fullWithApiKey]);
        sut.addListener(spyListener.call);
      });
      tearDown(() {
        reset(spyListener);
      });

      test('getStyleIds should return correct style id', () {
        // act
        final result = sut.getStyleIds();
        // assert
        expect(result, [fullWithApiKey.id]);
        verifyNever(spyListener());
      });

      test('currentStyleURI should return styleURI of first style', () {
        // act
        final result = sut.currentStyleURI;
        // assert
        expect(result, fullWithApiKey.uri());
        verifyNever(spyListener());
      });

      test('currentStyleURI should return darkStyleURI after toggling dark mode', () {
        // act
        sut.toggleDarkMode();
        final result = sut.currentStyleURI;
        // assert
        expect(result, fullWithApiKey.uri(isDarkStyle: true));
        verify(spyListener()).called(1);
      });

      test('currentStyleURI of styler with only bright style should return brightStyle after toggling dark mode', () {
        // arrange sut with bright only style
        sut = SBBCustomMapStyler(styles: [brightOnlyWithApiKey]);
        sut.addListener(spyListener.call);
        // act
        sut.toggleDarkMode();
        final result = sut.currentStyleURI;
        // assert
        expect(result, brightOnlyWithApiKey.uri(isDarkStyle: true));
        verify(spyListener()).called(1);
      });

      test('isDarkMode should return correctly when toggling', () {
        // act
        sut.toggleDarkMode();
        final shouldBeTrue = sut.isDarkMode;
        sut.toggleDarkMode();
        final shouldBeFalse = sut.isDarkMode;
        // assert
        expect(shouldBeTrue, true);
        expect(shouldBeFalse, false);
        verify(spyListener()).called(2);
      });

      test('switchStyle should not notify listeners if unknown style (quietly fails)', () {
        // act
        sut.switchStyle('unknown');
        // assert
        verifyNever(spyListener());
      });

      test('switchStyle should not notify listeners if style same as current', () {
        // act
        sut.switchStyle(fullWithApiKey.id);
        // assert
        verifyNever(spyListener());
      });
    });

    group('Two Styles', () {
      setUp(() {
        sut = SBBCustomMapStyler(styles: [fullWithApiKey, aerialWithApiKey]);
        sut.addListener(spyListener.call);
      });
      tearDown(() {
        reset(spyListener);
      });

      test('getStyleIds should return correct style ids', () {
        // act
        final result = sut.getStyleIds();
        // assert
        expect(result, [fullWithApiKey.id, aerialWithApiKey.id]);
        verifyNever(spyListener());
      });

      test('currentStyleURI should return styleURI of first style', () {
        // act
        final result = sut.currentStyleURI;
        // assert
        expect(result, fullWithApiKey.uri());
        verifyNever(spyListener());
      });

      test('initialStyle set to second should return styleURI of second style', () {
        // arrange sut with initial style set to second style
        sut = SBBCustomMapStyler(styles: [fullWithApiKey, aerialWithApiKey], initialStyleId: aerialWithApiKey.id);
        // act
        final result = sut.currentStyleURI;
        // assert
        expect(result, aerialWithApiKey.uri());
        verifyNever(spyListener());
      });

      test('switchStyle should switch styles and notify listeners', () {
        // act
        sut.switchStyle(aerialWithApiKey.id);
        final result = sut.currentStyleURI;
        // assert
        expect(result, aerialWithApiKey.uri());
        verify(spyListener()).called(1);
      });
    });

    group('Styler with aerial style', () {
      setUp(() {
        sut = SBBCustomMapStyler(styles: [fullWithApiKey], aerialStyle: aerialWithApiKey);
        sut.addListener(spyListener.call);
      });
      tearDown(() {
        reset(spyListener);
      });

      test('getStyleIds should return correct style ids', () {
        // act
        final result = sut.getStyleIds();
        // assert
        expect(result, [fullWithApiKey.id, aerialWithApiKey.id]);
        verifyNever(spyListener());
      });

      test('currentStyleURI should return styleURI of first style', () {
        // act
        final result = sut.currentStyleURI;
        // assert
        expect(result, fullWithApiKey.uri());
        verifyNever(spyListener());
      });

      test('toggleAerialStyle should switch to aerial style', () {
        // act
        sut.toggleAerialStyle();
        final result = sut.currentStyleURI;
        // assert
        expect(result, aerialWithApiKey.uri());
        verify(spyListener()).called(1);
      });

      test('toggleAerialStyle should switch back to previous style', () {
        // act
        sut.toggleAerialStyle();
        sut.toggleAerialStyle();
        final result = sut.currentStyleURI;
        // assert
        expect(result, fullWithApiKey.uri());
        verify(spyListener()).called(2);
      });

      test('switchStyle to aerial should toggle aerial', () {
        // act
        sut.switchStyle(aerialWithApiKey.id);
        final result = sut.currentStyleURI;
        final shouldBeTrue = sut.isAerialStyle;
        // assert
        expect(result, aerialWithApiKey.uri());
        expect(shouldBeTrue, true);
        verify(spyListener()).called(1);
      });

      test('switchStyle from aerial should toggle aerial', () {
        // act
        sut.toggleAerialStyle();
        sut.switchStyle(fullWithApiKey.id);
        final result = sut.currentStyleURI;
        final shouldBeFalse = sut.isAerialStyle;
        // assert
        expect(result, fullWithApiKey.uri());
        expect(shouldBeFalse, false);
        verify(spyListener()).called(2);
      });
    });
  });
}
