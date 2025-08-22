import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotations/sbb_map_annotation.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:test/test.dart';

import '../../../util/mock_callback_function.dart';
import 'annotator.fixture.dart';

import 'annotator_test.mocks.dart';

void main() {
  late SBBMapAnnotatorImpl sut;
  late MockMapLibreMapController mockController;
  late List<OnFeatureInteractionCallback> mockCallbackList;
  late MockCallbackSymbolFunction mockCallback;

  group('SBBMapAnnotator OnTap Unit Tests', () {
    group('initialization test', () {
      test('should register callback delegator to controller on init', () {
        // setup
        mockController = MockMapLibreMapController();
        mockCallbackList = <OnFeatureInteractionCallback>[];
        when(mockController.onFeatureTapped).thenReturn(mockCallbackList);

        // act
        sut = SBBMapAnnotatorImpl(controller: mockController);

        // verify
        verify(mockController.onFeatureTapped.add).called(1);
        expect(mockCallbackList.length, equals(1));
      });
    });

    group('further test', () {
      setUp(() {
        mockController = MockMapLibreMapController();
        mockCallbackList = <OnFeatureInteractionCallback>[];
        mockCallback = MockCallbackSymbolFunction();
        when(mockController.onFeatureTapped).thenReturn(mockCallbackList);
        sut = SBBMapAnnotatorImpl(controller: mockController);
        reset(mockController);
        reset(mockCallback);
        when(mockController.onFeatureTapped).thenReturn(mockCallbackList);
      });

      test('should not make further registers in controller when callback registered', () {
        // act
        sut.onSymbolTapped(mockCallback.call);

        // verify + expect
        verifyZeroInteractions(mockController);
      });

      test('callback should be registered in mockCallbackList', () {
        // act
        sut.onSymbolTapped(mockCallback.call);

        // verify + expect
        expect(mockCallbackList.isNotEmpty, equals(true), reason: 'Callback should be registered.');
      });

      test('should not call callback when unknown annotation', () {
        // setup
        sut.onSymbolTapped(mockCallback.call);
        final unregisteredAnnotation = AnnotatorFixture.simpleSymbol();

        // act
        _callAllWithAnnotation(mockCallbackList, unregisteredAnnotation);

        // verify
        verifyNever(mockCallback(unregisteredAnnotation));
      });

      test('should call callback when known annotation', () async {
        // setup
        sut.onSymbolTapped(mockCallback.call);
        final registeredA = AnnotatorFixture.simpleSymbol();
        await sut.addAnnotation(registeredA);

        // act
        _callAllWithAnnotation(mockCallbackList, registeredA);
        // verify
        verify(mockCallback(registeredA)).called(1);
      });
    });

    test('should not call callback any more after null passed', () async {
      // setup
      sut.onSymbolTapped(mockCallback.call);
      final registeredA = AnnotatorFixture.simpleSymbol();
      await sut.addAnnotation(registeredA);
      sut.onSymbolTapped(null);

      // act
      _callAllWithAnnotation(mockCallbackList, registeredA);

      // verify
      verifyNever(mockCallback(registeredA));
    });

    test('should be able to call both when two callbacks registered', () async {
      // setup
      final rokasIconCallback = MockCallbackRokasIconFunction();
      sut.onSymbolTapped(mockCallback.call);
      sut.onRokasIconTapped(rokasIconCallback.call);
      final registeredS = AnnotatorFixture.simpleSymbol();
      final registeredI = AnnotatorFixture.simpleRokasIcon();
      await sut.addAnnotations([registeredI, registeredS]);

      // act
      _callAllWithAnnotation(mockCallbackList, registeredS);
      _callAllWithAnnotation(mockCallbackList, registeredI);

      // verify + expect
      verifyInOrder([mockCallback(registeredS), rokasIconCallback(registeredI)]);
    });
  });
}

void _callAllWithAnnotation(List<OnFeatureInteractionCallback> mockCallbackList, SBBMapAnnotation registeredA) {
  for (final callback in mockCallbackList) {
    callback.call(
      registeredA.id,
      AnnotatorFixture.fakePoint,
      AnnotatorFixture.fakeCoords,
      AnnotatorFixture.fakeLayerId,
    );
  }
}
