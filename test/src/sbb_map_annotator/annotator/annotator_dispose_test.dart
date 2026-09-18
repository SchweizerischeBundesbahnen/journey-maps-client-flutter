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
        sut.dispose();

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

      // The source and the layers belong to the style of the platform view, which
      // is already torn down when SBBMap disposes the annotator. Reaching into it
      // raised a MissingPluginException on iOS and threw on Android.
      // See https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/235
      test('should not remove the geoJsonSource if symbol added', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());

        // act
        sut.dispose();

        // verify
        verifyNever(mockController.removeSource(any));
      });

      test('should not remove the layer if single symbol added', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());

        // act
        sut.dispose();

        // verify
        verifyNever(mockController.removeLayer(any));
      });

      test('should not remove any layer if multiple annotation types', () async {
        // setup
        await sut.addAnnotation(AnnotatorFixture.simpleRokasIcon());
        await sut.addAnnotation(AnnotatorFixture.simpleSymbol());

        // act
        sut.dispose();

        // verify
        verifyNever(mockController.removeLayer(any));
        verifyNever(mockController.removeSource(any));
      });
    });
  });
}
