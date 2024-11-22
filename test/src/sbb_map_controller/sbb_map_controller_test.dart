import 'dart:ui';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_controller/sbb_map_controller_impl.dart';
import 'package:test/test.dart';

import '../../util/mock_callback_function.dart';
@GenerateNiceMocks([MockSpec<MapLibreMapController>()])
import 'sbb_map_controller_test.mocks.dart';

void main() {
  group('Unit Test SBBMapController', () {
    late SBBMapController sut;
    late ListenableMockMapLibreMapController mockMLController;
    MockCallbackFunction listener = MockCallbackFunction();

    setUp(() {
      mockMLController = ListenableMockMapLibreMapController();
      sut = SBBMapControllerImpl(maplibreMapController: mockMLController);
      sut.addListener(listener.call);
    });

    tearDown(() {
      reset(mockMLController);
      sut.removeListener(listener.call);
      reset(listener);
    });

    group('listener notification', () {
      test('should not call listeners if isCameraMoving has not changed', () {
        // arrange
        when(mockMLController.isCameraMoving).thenReturn(false);

        // act
        mockMLController.notifyListeners();

        // expect
        verifyNever(listener());
      });

      test('should call listeners if isCameraMoving has changed', () {
        // arrange
        when(mockMLController.isCameraMoving).thenReturn(true);

        // act
        mockMLController.notifyListeners();

        // expect
        verify(listener()).called(1);
      });

      test('should not call listeners if cameraPosition has not changed', () {
        // arrange
        when(mockMLController.cameraPosition).thenReturn(null);

        // act
        mockMLController.notifyListeners();

        // expect
        verifyNever(listener());
      });

      test('should call listeners if cameraPosition has changed', () {
        // arrange
        const origin = CameraPosition(target: LatLng(0, 0));
        when(mockMLController.cameraPosition).thenReturn(origin);

        // act
        mockMLController.notifyListeners();

        // expect
        verify(listener()).called(1);
      });
    });
    test('getFilter should call mapLibre controller one to one', () {
      // arrange
      const fakeLayerId = 'fakeLayerId';
      when(mockMLController.getFilter(fakeLayerId)).thenAnswer((_) => Future.value([]));

      // act
      sut.getFilter(fakeLayerId);

      // expect
      verify(mockMLController.getFilter(fakeLayerId)).called(1);
    });

    test('setFilter should call mapLibre controller one to one', () {
      // arrange
      const fakeLayerId = 'fakeLayerId';
      when(mockMLController.setFilter(fakeLayerId, [])).thenAnswer((_) => Future.value());

      // act
      sut.setFilter(fakeLayerId, []);

      // expect
      verify(mockMLController.setFilter(fakeLayerId, [])).called(1);
    });

    test('setLayerVisibility should call mapLibre controller one to one', () {
      // arrange
      const fakeLayerId = 'fakeLayerId';
      when(mockMLController.setLayerVisibility(fakeLayerId, true)).thenAnswer((_) => Future.value());

      // act
      sut.setLayerVisibility(fakeLayerId, true);

      // expect
      verify(mockMLController.setLayerVisibility(fakeLayerId, true)).called(1);
    });

    test('animateCameraMove should call mapLibre controller one to one', () {
      // arrange
      final cameraUpdate = SBBCameraUpdate.bearingTo(0.0);
      final mlCameraUpdate = cameraUpdate.toMaplibre();
      when(mockMLController.animateCamera(mlCameraUpdate)).thenAnswer((_) => Future.value());

      // act
      sut.animateCameraMove(cameraUpdate: cameraUpdate);

      // expect
      verify(mockMLController.animateCamera(mlCameraUpdate)).called(1);
    });

    test('querySourceFeatures should call mapLibre controller one to one', () {
      // arrange
      const sourceId = 'someSourceId';
      when(mockMLController.querySourceFeatures(sourceId, null, null)).thenAnswer((_) => Future.value([]));

      // act
      sut.querySourceFeatures(sourceId);

      // expect
      verify(mockMLController.querySourceFeatures(sourceId, null, null)).called(1);
    });
  });
}

class ListenableMockMapLibreMapController extends MockMapLibreMapController {
  final List<VoidCallback> _listeners = [];

  @override
  void addListener(VoidCallback? listener) {
    if (listener != null) {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(VoidCallback? listener) {
    _listeners.remove(listener);
  }

  @override
  void notifyListeners() {
    for (final listener in _listeners) {
      listener.call();
    }
  }
}
