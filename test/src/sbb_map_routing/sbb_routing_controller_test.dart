import 'dart:ui';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller_impl.dart';
import 'package:test/test.dart';

import '../../util/mock_callback_function.dart';
import 'feature_collection.fixture.dart';
import 'sbb_routing_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MapLibreMapController>(),
  MockSpec<SBBMapAnnotator>(),
  MockSpec<SBBMapFloorController>(),
])
void main() {
  late SBBRoutingControllerImpl sut;
  late MockMapLibreMapController mockMapLibreController;
  late MockSBBMapAnnotator mockAnnotator;
  late ListenableMockSBBMapFloorController mockFloorController;
  final listener = MockCallbackFunction();

  group('Unit Test SBBRoutingController', () {
    setUp(() => {
          mockMapLibreController = MockMapLibreMapController(),
          mockAnnotator = MockSBBMapAnnotator(),
          mockFloorController = ListenableMockSBBMapFloorController(),
          sut = SBBRoutingControllerImpl(
              controller: Future.value(mockMapLibreController),
              annotator: Future.value(mockAnnotator),
              floorController: mockFloorController),
          reset(mockMapLibreController),
          reset(listener)
        });

    test('routeFromFeatureCollection calls addAnnotations but not removeAnnotations', () async {
      const featureCollection = featureCollectionFixtureGeneral;

      await sut.routeFromFeatureCollection(featureCollection);

      verifyNever(mockAnnotator.removeAnnotations(captureAny)).called(0);
      verify(mockAnnotator.addAnnotations(captureAny)).called(1);
    });

    test('routeFromFeatureCollection calls moveCamera with the correct CameraUpdate', () async {
      double latDiff = featureCollectionFixtureGeneral.bbox[3] - featureCollectionFixtureGeneral.bbox[1];
      double lngDiff = featureCollectionFixtureGeneral.bbox[2] - featureCollectionFixtureGeneral.bbox[0];

      double latMargin = latDiff * marginFraction;
      double lngMargin = lngDiff * marginFraction;

      LatLngBounds expectedBounds = LatLngBounds(
        southwest: LatLng(
            featureCollectionFixtureGeneral.bbox[1] - latMargin, featureCollectionFixtureGeneral.bbox[0] - lngMargin),
        northeast: LatLng(
            featureCollectionFixtureGeneral.bbox[3] + latMargin, featureCollectionFixtureGeneral.bbox[2] + lngMargin),
      );
      final expectedCameraUpdate = CameraUpdate.newLatLngBounds(expectedBounds);

      await sut.routeFromFeatureCollection(featureCollectionFixtureGeneral);

      final verificationResult = verify(mockMapLibreController.moveCamera(captureAny));
      final captured = verificationResult.captured;
      final actualCameraUpdate = captured.first as CameraUpdate;

      verificationResult.called(1);
      expect(actualCameraUpdate, isNotNull);
      expect(actualCameraUpdate.toJson(), equals(expectedCameraUpdate.toJson()));
    });

    test('routeFromGeoJSON calls addAnnotations but not removeAnnotations', () async {
      await sut.routeFromGeoJSON(featureCollectionFixtureGeneralJSON);

      verifyNever(mockAnnotator.removeAnnotations(captureAny)).called(0);
      verify(mockAnnotator.addAnnotations(captureAny)).called(1);
    });

    test('routeFromGeoJSON calls moveCamera with the correct CameraUpdate', () async {
      double latDiff = featureCollectionFixtureGeneral.bbox[3] - featureCollectionFixtureGeneral.bbox[1];
      double lngDiff = featureCollectionFixtureGeneral.bbox[2] - featureCollectionFixtureGeneral.bbox[0];

      double latMargin = latDiff * marginFraction;
      double lngMargin = lngDiff * marginFraction;

      LatLngBounds expectedBounds = LatLngBounds(
        southwest: LatLng(
            featureCollectionFixtureGeneral.bbox[1] - latMargin, featureCollectionFixtureGeneral.bbox[0] - lngMargin),
        northeast: LatLng(
            featureCollectionFixtureGeneral.bbox[3] + latMargin, featureCollectionFixtureGeneral.bbox[2] + lngMargin),
      );
      final expectedCameraUpdate = CameraUpdate.newLatLngBounds(expectedBounds);

      await sut.routeFromGeoJSON(featureCollectionFixtureGeneralJSON);

      final verificationResult = verify(mockMapLibreController.moveCamera(captureAny));
      final captured = verificationResult.captured;
      final actualCameraUpdate = captured.first as CameraUpdate;

      verificationResult.called(1);
      expect(actualCameraUpdate, isNotNull);
      expect(actualCameraUpdate.toJson(), equals(expectedCameraUpdate.toJson()));
    });

    test('annotations are updated if floor changes', () async {
      const featureCollection = featureCollectionFixtureGeneral;

      when(mockFloorController.currentFloor).thenReturn(0);

      await sut.routeFromFeatureCollection(featureCollection);

      when(mockFloorController.currentFloor).thenReturn(1);
      mockFloorController.notifyListeners();

      await Future.delayed(const Duration(milliseconds: 50));

      verify(mockAnnotator.addAnnotations(any)).called(2);
      verify(mockAnnotator.removeAnnotations(any)).called(1);
    });

    test('annotations are not updated if feature collection is not set', () async {
      when(mockFloorController.currentFloor).thenReturn(0);

      when(mockFloorController.currentFloor).thenReturn(1);
      mockFloorController.notifyListeners();

      await Future.delayed(const Duration(milliseconds: 50));

      verifyNever(mockAnnotator.addAnnotations(any)).called(0);
      verifyNever(mockAnnotator.removeAnnotations(any)).called(0);
    });
  });
}

class ListenableMockSBBMapFloorController extends MockSBBMapFloorController {
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
