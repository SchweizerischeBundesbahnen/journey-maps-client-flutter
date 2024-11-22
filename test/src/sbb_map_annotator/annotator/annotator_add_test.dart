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

  group('SBBMapAnnotator AddAnnotation Unit Tests', () {
    setUp(() async {
      mockController = MockMapLibreMapController();
      sut = SBBMapAnnotatorImpl(controller: mockController);
      reset(mockController);
    });

    group('multiple calls', () {
      /// the addAnnotation method (single) is just a special case
      /// we split the behavior into calling multiple times and calling a single time

      test('subsequent annotations should not add GeoJsonSource', () async {
        // act
        await sut.addAnnotations([AnnotatorFixture.simpleSymbol()]);
        await sut.addAnnotations([AnnotatorFixture.simpleSymbol()]);
        await sut.addAnnotations([AnnotatorFixture.simpleRokasIcon()]);

        // verify
        verify(
          mockController.addGeoJsonSource(AnnotatorFixture.kSourceId, any),
        ).called(1);
      });

      test('second annotation of same type should not add new layer', () async {
        // setup
        final symbol = AnnotatorFixture.simpleSymbol();

        // act
        await sut.addAnnotations([symbol]);
        await sut.addAnnotations([AnnotatorFixture.simpleSymbol()]);

        // verify
        verify(
          mockController.addLayer(
            AnnotatorFixture.kSourceId,
            AnnotatorFixture.kSymbolIdentifier,
            argThat(isA<SymbolLayerProperties>()),
            filter: symbol.annotationFilter,
          ),
        ).called(1);
      });

      test('annotation of different type should add new layer', () async {
        // setup
        final symbol = AnnotatorFixture.simpleSymbol();
        final rokasIcon = AnnotatorFixture.simpleRokasIcon();

        // act
        await sut.addAnnotations([symbol]);
        await sut.addAnnotations([rokasIcon]);

        // verify
        verify(
          mockController.addLayer(
            AnnotatorFixture.kSourceId,
            argThat(anyOf([AnnotatorFixture.kRokasIconIdentifier, AnnotatorFixture.kSymbolIdentifier])),
            argThat(isA<SymbolLayerProperties>()),
            filter: anyNamed('filter'),
          ),
        ).called(2);
      });

      test('adding same annotation twice should quietly fail', () async {
        // setup
        final annotation = AnnotatorFixture.simpleSymbol();
        await sut.addAnnotations([annotation]);
        reset(mockController);

        // act
        await sut.addAnnotations([annotation]);

        // verify
        verifyNoMoreInteractions(mockController);
      });
    });

    group('single call', () {
      /// the error cases are covered here
      test('first annotation should add new GeoJsonSource', () async {
        // act
        await sut.addAnnotations([AnnotatorFixture.simpleSymbol()]);

        // verify
        verify(
          mockController.addGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([]),
          ),
        ).called(1);
      });
      test('subsequent annotations should not add GeoJsonSource', () async {
        // act
        await sut.addAnnotations([
          AnnotatorFixture.simpleSymbol(),
          AnnotatorFixture.simpleSymbol(),
        ]);

        // verify
        verify(
          mockController.addGeoJsonSource(AnnotatorFixture.kSourceId, any),
        ).called(1);
      });

      test('error from addGeoJsonSource should throw AnnotationException', () async {
        // when
        when(mockController.addGeoJsonSource(any, any))
            .thenAnswer((_) => Future.error(PlatformException(code: 'fakeCode')));

        // act + expect
        await expectLater(
            sut.addAnnotations([AnnotatorFixture.simpleSymbol()]), throwsA(const TypeMatcher<AnnotationException>()));
      });

      test('first annotation should add new layer', () async {
        // setup
        final symbol = AnnotatorFixture.simpleSymbol();

        // act
        await sut.addAnnotations([symbol]);

        // verify
        verify(
          mockController.addLayer(
            AnnotatorFixture.kSourceId,
            AnnotatorFixture.kSymbolIdentifier,
            argThat(isA<SymbolLayerProperties>()),
            filter: symbol.annotationFilter,
          ),
        ).called(1);
      });

      test('second annotation of same type should not add new layer', () async {
        // setup
        final symbol = AnnotatorFixture.simpleSymbol();
        // act
        await sut.addAnnotations([
          symbol,
          AnnotatorFixture.simpleSymbol(),
        ]);

        // verify
        verify(
          mockController.addLayer(
            AnnotatorFixture.kSourceId,
            AnnotatorFixture.kSymbolIdentifier,
            argThat(isA<SymbolLayerProperties>()),
            filter: symbol.annotationFilter,
          ),
        ).called(1);
      });

      test('annotation of different type should add new layer', () async {
        // setup
        final symbol = AnnotatorFixture.simpleSymbol();
        final rokasIcon = AnnotatorFixture.simpleRokasIcon();
        // act
        await sut.addAnnotations([symbol, rokasIcon]);

        // verify
        verify(
          mockController.addLayer(
            AnnotatorFixture.kSourceId,
            argThat(anyOf([AnnotatorFixture.kRokasIconIdentifier, AnnotatorFixture.kSymbolIdentifier])),
            argThat(isA<SymbolLayerProperties>()),
            filter: argThat(
                anyOf([
                  symbol.annotationFilter,
                  rokasIcon.annotationFilter,
                ]),
                named: 'filter'),
          ),
        ).called(2);
      });

      test('error from addLayer should throw AnnotationException', () async {
        // when
        when(mockController.addLayer(any, any, any, filter: anyNamed('filter')))
            .thenAnswer((_) => Future.error(PlatformException(code: 'fakeCode')));

        // act + expect
        await expectLater(
            sut.addAnnotations([AnnotatorFixture.simpleSymbol()]), throwsA(const TypeMatcher<AnnotationException>()));
      });

      test('adding new annotaton should call setGeoJson', () async {
        final annotation = AnnotatorFixture.simpleSymbol();

        // act
        await sut.addAnnotations([annotation]);

        // verify
        verify(
          mockController.setGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([annotation.toGeoJson()]),
          ),
        ).called(1);
      });

      test('error from setGeoJson should throw AnnotationException', () async {
        // when
        when(mockController.setGeoJsonSource(any, any))
            .thenAnswer((_) => Future.error(PlatformException(code: 'fakeCode')));

        // act + expect
        await expectLater(
            sut.addAnnotations([AnnotatorFixture.simpleSymbol()]), throwsA(const TypeMatcher<AnnotationException>()));
      });

      test('adding same annotation twice should quietly fail', () async {
        // setup
        final annotation = AnnotatorFixture.simpleSymbol();

        // act
        await sut.addAnnotations([annotation, annotation]);

        // verify
        // add GeoJsonSource
        verify(
          mockController.addGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([]),
          ),
        ).called(1);
        // layer
        verify(
          mockController.addLayer(
            AnnotatorFixture.kSourceId,
            AnnotatorFixture.kSymbolIdentifier,
            argThat(isA<SymbolLayerProperties>()),
            filter: anyNamed('filter'),
          ),
        ).called(1);
        // set GeoJsonSource
        verify(
          mockController.setGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([annotation.toGeoJson()]),
          ),
        ).called(1);
      });

      test('adding new and known annotation should not update known', () async {
        // setup
        final a = AnnotatorFixture.simpleSymbol();
        final b = AnnotatorFixture.simpleSymbol();
        await sut.addAnnotations([a]);
        final aWithChanges = a.copyWith(coords: AnnotatorFixture.fakeCoords + const LatLng(2, 2));
        reset(mockController);

        // act
        await sut.addAnnotations([aWithChanges, b]);

        // verify
        // set GeoJsonSource
        verify(
          mockController.setGeoJsonSource(
            AnnotatorFixture.kSourceId,
            buildFeatureCollection([a.toGeoJson(), b.toGeoJson()]),
          ),
        ).called(1);
      });
    });
  });
}
