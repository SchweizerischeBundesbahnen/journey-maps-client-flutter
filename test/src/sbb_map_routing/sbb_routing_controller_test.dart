import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller_impl.dart';

import '../../util/mock_callback_function.dart';
import 'feature_collection.fixture.dart';
import 'sbb_routing_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MapLibreMapController>(), MockSpec<SBBMapAnnotator>(), MockSpec<SBBMapFloorController>()])
void main() {
  late SBBRoutingControllerImpl sut;
  late MockMapLibreMapController mockMapLibreController;
  late MockSBBMapAnnotator mockAnnotator;
  late ListenableMockSBBMapFloorController mockFloorController;
  final listener = MockCallbackFunction();

  group('Unit Test SBBRoutingController', () {
    setUp(
      () => {
        mockMapLibreController = MockMapLibreMapController(),
        mockAnnotator = MockSBBMapAnnotator(),
        mockFloorController = ListenableMockSBBMapFloorController(),
        sut = SBBRoutingControllerImpl(
          controller: Future.value(mockMapLibreController),
          annotator: Future.value(mockAnnotator),
          floorController: mockFloorController,
        ),
        reset(mockMapLibreController),
        reset(listener),
      },
    );

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
          featureCollectionFixtureGeneral.bbox[1] - latMargin,
          featureCollectionFixtureGeneral.bbox[0] - lngMargin,
        ),
        northeast: LatLng(
          featureCollectionFixtureGeneral.bbox[3] + latMargin,
          featureCollectionFixtureGeneral.bbox[2] + lngMargin,
        ),
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
          featureCollectionFixtureGeneral.bbox[1] - latMargin,
          featureCollectionFixtureGeneral.bbox[0] - lngMargin,
        ),
        northeast: LatLng(
          featureCollectionFixtureGeneral.bbox[3] + latMargin,
          featureCollectionFixtureGeneral.bbox[2] + lngMargin,
        ),
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

  group('SBBRoutingController with the real annotator', () {
    late List<Map<String, dynamic>> sentSourceData;

    List<dynamic> featuresOf(Map<String, dynamic> sourceData) => sourceData['features'] as List<dynamic>;

    Future<void> changeFloor(int floor) async {
      when(mockFloorController.currentFloor).thenReturn(floor);
      mockFloorController.notifyListeners();
      await pumpEventQueue();
    }

    setUp(() {
      mockMapLibreController = MockMapLibreMapController();
      mockFloorController = ListenableMockSBBMapFloorController();
      sentSourceData = [];
      when(mockMapLibreController.onFeatureTapped).thenReturn(<OnFeatureInteractionCallback>[]);
      when(mockMapLibreController.setGeoJsonSource(any, any)).thenAnswer((invocation) async {
        sentSourceData.add(invocation.positionalArguments[1] as Map<String, dynamic>);
      });
      sut = SBBRoutingControllerImpl(
        controller: Future.value(mockMapLibreController),
        annotator: Future.value(SBBMapAnnotatorImpl(controller: mockMapLibreController)),
        floorController: mockFloorController,
      );
    });

    test('floor changes replace the route instead of adding copies of it', () async {
      await sut.routeFromFeatureCollection(featureCollectionFixtureGeneral);
      final routeFeatureCount = featureCollectionFixtureGeneral.features.length;
      expect(featuresOf(sentSourceData.last), hasLength(routeFeatureCount));

      for (final floor in [1, 0, 2, -1]) {
        await changeFloor(floor);

        expect(
          featuresOf(sentSourceData.last),
          hasLength(routeFeatureCount),
          reason: 'after switching to floor $floor',
        );
      }
    });
  });

  group('SBBRoutingController route annotations', () {
    setUp(() {
      mockAnnotator = MockSBBMapAnnotator();
      mockFloorController = ListenableMockSBBMapFloorController();
      sut = SBBRoutingControllerImpl(
        controller: Future.value(MockMapLibreMapController()),
        annotator: Future.value(mockAnnotator),
        floorController: mockFloorController,
      );
    });

    test('keep their ids when iterated more than once', () async {
      await sut.routeFromFeatureCollection(featureCollectionFixtureGeneral);

      final annotations =
          verify(mockAnnotator.addAnnotations(captureAny)).captured.single as Iterable<SBBMapAnnotation>;

      final idsOfFirstPass = annotations.map((a) => a.id).toList();

      expect(annotations.map((a) => a.id), orderedEquals(idsOfFirstPass));
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
