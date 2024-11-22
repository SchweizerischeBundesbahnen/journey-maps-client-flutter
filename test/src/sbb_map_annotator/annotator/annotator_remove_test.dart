import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:test/test.dart';

import 'annotator.fixture.dart';

import 'annotator_test.mocks.dart';

void main() {
  late SBBMapAnnotatorImpl sut;
  late MockMapLibreMapController mockController;

  group('SBBMapAnnotator Remove Unit Tests', () {
    setUp(() async {
      mockController = MockMapLibreMapController();
      sut = SBBMapAnnotatorImpl(controller: mockController);
      reset(mockController);
    });

    /// remove single annotation is just a special case

    test('removing an unknown annotation should quietly fail', () async {
      // act
      await sut.removeAnnotations([AnnotatorFixture.simpleSymbol()]);

      // verify
      verifyZeroInteractions(mockController);
    });

    test('removing a known annotation should remove the annotation', () async {
      // setup
      final a = AnnotatorFixture.simpleSymbol();
      await sut.addAnnotation(a);
      // act
      await sut.removeAnnotations([a]);

      // verify
      verify(
        mockController.setGeoJsonSource(
          AnnotatorFixture.kSourceId,
          buildFeatureCollection([]),
        ),
      ).called(1);
    });

    test('removing a known annotation should keep all the other annotations', () async {
      // setup
      final a = AnnotatorFixture.simpleSymbol();
      final b = AnnotatorFixture.simpleSymbol();
      final c = AnnotatorFixture.simpleSymbol();
      await sut.addAnnotations([a, b, c]);
      reset(mockController);
      // act
      await sut.removeAnnotations([a, c]);

      // verify
      verify(
        mockController.setGeoJsonSource(
          AnnotatorFixture.kSourceId,
          buildFeatureCollection([b.toGeoJson()]),
        ),
      ).called(1);
    });

    test('error from setGeoJson should throw AnnotationException', () async {
      // setup
      final a = AnnotatorFixture.simpleSymbol();
      await sut.addAnnotation(a);
      when(mockController.setGeoJsonSource(any, any))
          .thenAnswer((_) => Future.error(PlatformException(code: 'fakeCode')));

      // act + expect
      await expectLater(
        sut.removeAnnotations([a]),
        throwsA(const TypeMatcher<AnnotationException>()),
      );
    });
  });
}
