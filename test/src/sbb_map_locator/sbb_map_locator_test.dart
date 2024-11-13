import 'dart:ui';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/geolocator_facade.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator_impl.dart';
import 'package:test/test.dart';

import '../../util/mock_callback_function.dart';
@GenerateNiceMocks([MockSpec<MapLibreMapController>(), MockSpec<GeolocatorFacade>()])
import 'sbb_map_locator_test.mocks.dart';

void main() {
  group('Unit Test SBBMapLocator', () {
    const LatLng bernStation = LatLng(46.948, 7.439);

    late SBBMapLocatorImpl sut;
    late ListenableMockMapLibreMapController mockController;
    late MockGeolocatorFacade mockGeolocator;
    MockCallbackFunction listener = MockCallbackFunction();

    setUp(() {
      mockController = ListenableMockMapLibreMapController();
      mockGeolocator = MockGeolocatorFacade();
      sut = SBBMapLocatorImpl(
        Future.value(mockController),
        mockGeolocator,
      );
      sut.addListener(listener.call);
    });

    tearDown(() {
      reset(mockController);
      sut.removeListener(listener.call);
      reset(listener);
    });

    group('myLocation has not been enabled', () {
      test('isTracking should be false', () {
        // act + expect
        expect(sut.isTracking, false);
        verifyNever(listener());
      });

      test('isLocationEnabled should be false', () {
        // act + expect
        expect(sut.isLocationEnabled, false);
        verifyNever(listener());
      });

      test('lastKnownPosition should return null', () {
        // act
        final result = sut.lastKnownLocation;
        // expect
        expect(result, null);
        verifyNever(listener());
      });
      test('lastKnownPosition should return null even after falsly updated', () {
        sut.updateDeviceLocation(bernStation);
        // act
        final result = sut.lastKnownLocation;
        // expect
        expect(result, null);
        verifyNever(listener());
      });
      test('should not call dismissTracking when cameraMoving if not tracking', () async {
        // arrange
        when(mockController.isCameraMoving).thenReturn(true);
        // act
        mockController.notifyListeners();
        await Future.delayed(const Duration(milliseconds: 50));
        // expect
        expect(sut.isTracking, false);
        verifyNever(listener());
        verifyNever(mockController.updateMyLocationTrackingMode(any));
      });
      test('dismissTracking should do nothing if not tracking', () async {
        // act
        await sut.dismissTracking();
        // expect
        verifyNever(listener());
        verifyNever(mockController.updateMyLocationTrackingMode(any));
      });
    });
    group('enable my Location', () {
      group('Good weather tests', () {
        void expectSutNotTrackingAndNeverCalled() {
          expect(sut.isTracking, false);
          expect(sut.isLocationEnabled, false);
          expect(sut.lastKnownLocation, null);
          verifyNever(listener());
        }

        test('should enable myLocation if permission already granted', () async {
          // arrange mocks
          when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.always));
          when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(true));
          when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());

          expectSutNotTrackingAndNeverCalled();

          // act
          await sut.trackDeviceLocation();

          // expect
          expect(sut.isLocationEnabled, true);
          expect(sut.isTracking, true);
          verify(listener()).called(1);
        });

        test('should enable myLocation if permission is granted by the user', () async {
          // arrange mocks
          when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.denied));
          when(mockGeolocator.requestPermission()).thenAnswer((_) => Future.value(LocationPermission.always));
          when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(true));
          when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());

          expectSutNotTrackingAndNeverCalled();

          // act
          await sut.trackDeviceLocation();

          // expect
          expect(sut.isLocationEnabled, true);
          expect(sut.isTracking, true);
          verify(listener()).called(1);
        });
        test('should not notify listeners twice if already tracking', () async {
          // arrange mocks
          when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.denied));
          when(mockGeolocator.requestPermission()).thenAnswer((_) => Future.value(LocationPermission.always));
          when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(true));
          when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());

          expectSutNotTrackingAndNeverCalled();

          // act
          await sut.trackDeviceLocation();
          await sut.trackDeviceLocation();

          // expect
          expect(sut.isLocationEnabled, true);
          expect(sut.isTracking, true);
          verify(listener()).called(1);
        });
      });
      group('Bad weather tests', () {
        test('should not enable myLocation if permission is denied', () async {
          // arrange mocks
          when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.denied));
          when(mockGeolocator.requestPermission()).thenAnswer((_) => Future.value(LocationPermission.denied));
          when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(true));
          when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());

          // act
          await sut.trackDeviceLocation();

          // expect
          expect(sut.isLocationEnabled, false);
          expect(sut.isTracking, false);
          verifyNever(listener());
          verifyNever(mockController.updateMyLocationTrackingMode(any));
        });
        test('should not enable myLocation if permission is deniedForever', () async {
          // arrange mocks
          when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.deniedForever));
          when(mockGeolocator.requestPermission()).thenAnswer((_) => Future.value(LocationPermission.denied));
          when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(true));
          when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());

          // act
          await sut.trackDeviceLocation();

          // expect
          expect(sut.isLocationEnabled, false);
          expect(sut.isTracking, false);
          verifyNever(listener());
          verifyNever(mockController.updateMyLocationTrackingMode(any));
        });
        test('should not enable myLocation if location Service not available', () async {
          // arrange mocks
          when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(false));
          when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());

          // act
          await sut.trackDeviceLocation();

          // expect
          expect(sut.isLocationEnabled, false);
          expect(sut.isTracking, false);
          verifyNever(listener());
          verifyNever(mockController.updateMyLocationTrackingMode(any));
          verifyNever(mockGeolocator.checkPermission());
          verifyNever(mockGeolocator.requestPermission());
        });
      });
    });
    group('myLocation already enabled', () {
      setUp(() async {
        when(mockController.updateMyLocationTrackingMode(any)).thenAnswer((_) => Future.value());
        when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.always));
        when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) => Future.value(true));
        await sut.trackDeviceLocation();
        verify(listener()).called(1);
      });
      test('isTracking and isLocationEnabled should be true', () {
        // act + expect
        expect(sut.isTracking, true);
        expect(sut.isLocationEnabled, true);
        verifyNever(listener()); // no new listener call since setUp
      });
      test('lastKnownPosition should return the last known position', () {
        // arrange
        sut.updateDeviceLocation(bernStation);
        // act
        final result = sut.lastKnownLocation;
        // expect
        expect(result, bernStation);
        verify(listener()).called(1);
      });
      test('lastKnownPosition should notify only if position changes', () {
        // arrange
        sut.updateDeviceLocation(bernStation);
        sut.updateDeviceLocation(bernStation);
        // act
        final result = sut.lastKnownLocation;
        // expect
        expect(result, bernStation);
        verify(listener()).called(1);
      });
      test('isTracking should return false after tracking is dismissed', () async {
        // act
        await sut.dismissTracking();
        // expect
        expect(sut.isTracking, false);
        expect(sut.isLocationEnabled, true);
        verify(listener()).called(1);
        verify(mockController.updateMyLocationTrackingMode(
          MyLocationTrackingMode.none,
        )).called(1);
      });
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
