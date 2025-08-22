import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:test/test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'annotator.fixture.dart';

import 'annotator_test.mocks.dart';

void main() {
  late SBBMapAnnotatorImpl sut;
  late MockMapLibreMapController mockController;

  group('SBBMapAnnotator dispose Unit Tests', () {
    group('disposal of delegate to annotation callback ', () {
      test('should remove callback delegator to controller on dispose', () async {
        // setup
        mockController = MockMapLibreMapController();
        final mockCallbackList = List<OnFeatureInteractionCallback>.empty(growable: true);
        when(mockController.onFeatureTapped).thenReturn(mockCallbackList);
        sut = SBBMapAnnotatorImpl(controller: mockController);
        reset(mockController);
        when(mockController.onFeatureTapped).thenReturn(mockCallbackList);

        // act
        await sut.dispose();

        // verify
        verify(mockController.onFeatureTapped).called(1);
        expect(mockCallbackList.isEmpty, equals(true), reason: 'Expected callback list to be empty.');
      });
    });

    group('disposal of geoJson resources', () {
      setUp(() async {
        mockController = MockMapLibreMapController();
        sut = SBBMapAnnotatorImpl(controller: mockController);
        reset(mockController);
      });

      test('should remove geoJsonSource if symbol added', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());

        // act
        await sut.dispose();

        // verify
        verify(mockController.removeSource(AnnotatorFixture.kSourceId)).called(1);
      });

      test('should remove single layer if single symbol added', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());

        // act
        await sut.dispose();

        // verify
        verify(mockController.removeLayer(AnnotatorFixture.kRokasIconIdentifier)).called(1);
      });

      test('should remove first layer, then source if symbol', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());

        // act
        await sut.dispose();

        // verify
        verifyInOrder([
          mockController.removeLayer(AnnotatorFixture.kRokasIconIdentifier),
          mockController.removeSource(AnnotatorFixture.kSourceId),
        ]);
      });

      test('should remove all layers if multiple annotation types', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());
        await sut.addAnnotation(AnnotatorFixture.simpleSymbol());

        // act
        await sut.dispose();

        // verify
        verify(
          mockController.removeLayer(
            argThat(anyOf([AnnotatorFixture.kRokasIconIdentifier, AnnotatorFixture.kSymbolIdentifier])),
          ),
        ).called(2);
      });
    });
  });
}
