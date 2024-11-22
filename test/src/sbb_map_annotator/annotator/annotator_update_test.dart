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

  group('SBBMapAnnotator Update Unit Tests', () {
    setUp(() async {
      mockController = MockMapLibreMapController();
      sut = SBBMapAnnotatorImpl(controller: mockController);
      reset(mockController);
    });
    group('single calls', () {
      /// the updateAnnotation method (single) is just a special case
      /// we split the behavior into calling multiple times and calling a single time
      test('updating an unknown annotation should quietly fail', () async {
        // act
        await sut.updateAnnotations([AnnotatorFixture.simpleSymbol()]);

        // verify
        verifyZeroInteractions(mockController);
      });

      test('updating should call setGeoJson with updated features', () async {
        // setup
        final original = AnnotatorFixture.simpleSymbol();
        final update = original.copyWith(coords: const LatLng(2.0, 3.0));
        await sut.addAnnotation(original);
        reset(mockController);

        // act
        await sut.updateAnnotations([update]);

        // verify
        verify(
          mockController.setGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([update.toGeoJson()]),
          ),
        ).called(1);
      });
    });

    group('single calls', () {
      // error testing is done here
      test('error from setGeoJson should throw AnnotationException', () async {
        // setup
        final a = AnnotatorFixture.simpleSymbol();
        await sut.addAnnotation(a);
        when(mockController.setGeoJsonSource(any, any))
            .thenAnswer((_) => Future.error(PlatformException(code: 'fakeCode')));

        // act + expect
        await expectLater(
          sut.updateAnnotations([a]),
          throwsA(const TypeMatcher<AnnotationException>()),
        );
      });

      test('updating an unknown annotation should quietly fail', () async {
        // act
        await sut.updateAnnotations([
          AnnotatorFixture.simpleSymbol(),
          AnnotatorFixture.simpleSymbol(),
        ]);

        // verify
        verifyZeroInteractions(mockController);
      });

      test('updating two annotations should call setGeoJson with updated features', () async {
        // setup
        final original = AnnotatorFixture.simpleSymbol();
        final secondOriginal = AnnotatorFixture.simpleSymbol();
        final update = original.copyWith(coords: const LatLng(2.0, 3.0));
        final secondUpdate = secondOriginal.copyWith(coords: const LatLng(2.0, 3.0));
        await sut.addAnnotations([original, secondOriginal]);
        reset(mockController);

        // act
        await sut.updateAnnotations([update, secondUpdate]);

        // verify
        verify(
          mockController.setGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([
              update.toGeoJson(),
              secondUpdate.toGeoJson(),
            ]),
          ),
        ).called(1);
      });

      test('updating known and unknown annotation should call setGeoJson with updated feature only', () async {
        // setup
        final original = AnnotatorFixture.simpleSymbol();
        final secondOriginal = AnnotatorFixture.simpleSymbol();
        final update = original.copyWith(coords: const LatLng(2.0, 3.0));
        await sut.addAnnotation(original);
        reset(mockController);

        // act
        await sut.updateAnnotations([update, secondOriginal]);

        // verify
        verify(
          mockController.setGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([
              update.toGeoJson(),
            ]),
          ),
        ).called(1);
      });
    });

    /// test what happens if style of map changes and [SBBMap] triggers this function
    group('onStyleChanged', () {
      test('should not do anything when no symbols and no images', () {
        // act
        sut.onStyleChanged();

        // verify
        verifyZeroInteractions(mockController);
      });

      test('should add geoJsonSource back to map if has annotations', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());
        reset(mockController);

        // act
        await sut.onStyleChanged();

        // verify
        verify(mockController.addGeoJsonSource(AnnotatorFixture.kSourceId, buildFeatureCollection([]))).called(1);
      });

      test('should add layer back to map if has annotation', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());
        reset(mockController);

        // act
        await sut.onStyleChanged();

        // verify
        verify(mockController.addLayer(
          AnnotatorFixture.kSourceId,
          AnnotatorFixture.kRokasIconIdentifier,
          argThat(isA<SymbolLayerProperties>()),
          filter: AnnotatorFixture.simpleRokasIcon().annotationFilter,
        )).called(1);
      });

      test('should add all layers back to map if has multiple type annotations', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());
        await sut.addAnnotation(AnnotatorFixture.simpleSymbol());
        reset(mockController);

        // act
        await sut.onStyleChanged();

        // verify
        verify(mockController.addLayer(
          AnnotatorFixture.kSourceId,
          argThat(anyOf([AnnotatorFixture.kRokasIconIdentifier, AnnotatorFixture.kSymbolIdentifier])),
          argThat(isA<SymbolLayerProperties>()),
          filter: anyNamed('filter'),
        )).called(2);
      });

      test('should add features back to map if has annotation', () async {
        // setup
        final a = AnnotatorFixture.simpleRokasIcon();
        await sut.addAnnotation(a);
        reset(mockController);

        // act
        await sut.onStyleChanged();

        // verify
        verify(mockController.setGeoJsonSource(
          AnnotatorFixture.kSourceId,
          buildFeatureCollection([a.toGeoJson()]),
        )).called(1);
      });

      test('should add all features back to map if has multiple annotation', () async {
        // setup
        final a = AnnotatorFixture.simpleRokasIcon();
        final b = AnnotatorFixture.simpleSymbol();
        await sut.addAnnotation(a);
        await sut.addAnnotation(b);
        reset(mockController);

        // act
        await sut.onStyleChanged();

        // verify
        verify(mockController.setGeoJsonSource(
          AnnotatorFixture.kSourceId,
          buildFeatureCollection([a.toGeoJson(), b.toGeoJson()]),
        )).called(1);
      });

      test('should add image back if has images', () async {
        // setup
        await sut.addImage(
          imageId: AnnotatorFixture.fakeImageName,
          imageBytes: AnnotatorFixture.fakeImage,
        );
        reset(mockController);

        // act
        await sut.onStyleChanged();

        // verify
        verify(mockController.addImage(
          AnnotatorFixture.fakeImageName,
          AnnotatorFixture.fakeImage,
        )).called(1);
      });
    });
  });
}
