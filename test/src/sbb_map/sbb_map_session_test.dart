import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map/sbb_map_session.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/controller/sbb_rokas_poi_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller_impl.dart';

// Spies carry no behaviour: they only record calls, and only methods returning
// futures answer (with a completed future) so the session can await them. If a
// test needs a collaborator to behave, use the real controller over a mocked
// MapLibreMapController instead of stubbing behaviour here (see ADR-0001).
@GenerateNiceMocks([
  MockSpec<MapLibreMapController>(),
  MockSpec<SBBMapLocatorImpl>(),
  MockSpec<SBBMapFloorControllerImpl>(),
  MockSpec<SBBRoutingControllerImpl>(),
  MockSpec<SBBRokasPOIControllerImpl>(),
  MockSpec<SBBMapAnnotatorImpl>(),
  MockSpec<SBBMapStyler>(),
])
import 'sbb_map_session_test.mocks.dart';

const _point = Point<double>(1, 2);
const _latLng = LatLng(46.9, 7.4);

const _brightStyle = SBBMapStyle.fromURL(id: 'bright', brightStyleURL: 'bright_uri', darkStyleURL: 'dark_uri');
const _otherStyle = SBBMapStyle.fromURL(id: 'other', brightStyleURL: 'other_uri');

/// An app callback, as recorded in a test's `calls`.
enum _Call { click, longClick, locator, floor, poi, annotator, routing, styleLoaded }

void main() {
  late MockMapLibreMapController mapLibre;
  late MockSBBMapLocatorImpl locator;
  late MockSBBMapFloorControllerImpl floorController;
  late MockSBBRoutingControllerImpl routingController;
  late MockSBBRokasPOIControllerImpl poiController;
  late MockSBBMapAnnotatorImpl annotator;
  late SBBCustomMapStyler styler;
  late List<_Call> calls;

  setUp(() {
    mapLibre = MockMapLibreMapController();
    locator = MockSBBMapLocatorImpl();
    floorController = MockSBBMapFloorControllerImpl();
    routingController = MockSBBRoutingControllerImpl();
    poiController = MockSBBRokasPOIControllerImpl();
    annotator = MockSBBMapAnnotatorImpl();
    styler = SBBCustomMapStyler(styles: [_brightStyle, _otherStyle]);
    calls = [];
  });

  SBBMapSession createSession(SBBMapSessionConfig config, {SBBMapStyler Function()? createDefaultMapStyler}) =>
      SBBMapSession(
        config: config,
        mapLocator: locator,
        floorController: floorController,
        routingController: routingController,
        poiController: poiController,
        createAnnotator: (_) => annotator,
        createDefaultMapStyler: createDefaultMapStyler,
      );

  /// The first load: the map is created with the styler's style and loads it.
  Future<void> loadFirstStyle(SBBMapSession session) async {
    await session.onMapCreated(mapLibre);
    await session.onStyleLoaded();
  }

  SBBMapSessionConfig recordingConfig({
    SBBMapStyler? mapStyler,
    SBBCameraPosition? initialCameraPosition = .highLevelCH,
    SBBMapPOISettings poiSettings = const SBBMapPOISettings(),
    void Function()? onStyleLoaded,
  }) => SBBMapSessionConfig(
    mapStyler: mapStyler ?? styler,
    initialCameraPosition: initialCameraPosition,
    poiSettings: poiSettings,
    onStyleLoaded: onStyleLoaded,
    onMapClick: (_, _) => calls.add(.click),
    onMapLongClick: (_, _) => calls.add(.longClick),
  );

  Future<void> sendInputEvents(SBBMapSession session) async {
    await session.onMapClick(_point, _latLng);
    await session.onMapLongClick(_point, _latLng);
    await session.onMapIdle();
    await session.onCameraTrackingDismissed();
  }

  group('input gating', () {
    test('inputEvents_whenStyleNotYetLoaded_shouldBeIgnored', () async {
      final session = createSession(recordingConfig());
      await sendInputEvents(session);

      await session.onMapCreated(mapLibre);
      await sendInputEvents(session);

      expect(calls, isEmpty);
      verifyNever(floorController.updateAvailableFloors());
      verifyNever(locator.dismissTracking());
    });

    test('inputEvents_whenStyleLoaded_shouldReachAppAndCollaborators', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);

      await sendInputEvents(session);

      expect(calls, <_Call>[.click, .longClick]);
      verify(floorController.updateAvailableFloors()).called(1);
      verify(locator.dismissTracking()).called(1);
    });

    test('inputEvents_whenReloadingAfterStylerSwitch_shouldBeIgnoredUntilStyleLoaded', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);

      styler.switchStyle('other');
      await pumpEventQueue();
      await sendInputEvents(session);

      expect(calls, isEmpty);
      verifyNever(floorController.updateAvailableFloors());
      verifyNever(locator.dismissTracking());

      await session.onStyleLoaded();
      await sendInputEvents(session);

      expect(calls, <_Call>[.click, .longClick]);
    });

    test('inputEvents_whenReloadingAfterStylerSwappedForDifferentStyle_shouldBeIgnoredUntilStyleLoaded', () async {
      final session = createSession(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: (_) {})));
      await loadFirstStyle(session);

      await session.update(
        recordingConfig(
          mapStyler: SBBCustomMapStyler(styles: [_otherStyle]),
          poiSettings: SBBMapPOISettings(onPoiSelected: (_) {}),
        ),
      );
      await sendInputEvents(session);

      expect(calls, isEmpty);
      verifyNever(poiController.toggleSelectedPointOfInterest(any));
      verifyNever(floorController.updateAvailableFloors());
      verifyNever(locator.dismissTracking());

      await session.onStyleLoaded();
      await sendInputEvents(session);

      expect(calls, <_Call>[.click, .longClick]);
      verify(poiController.toggleSelectedPointOfInterest(_point)).called(1);
      verify(floorController.updateAvailableFloors()).called(1);
      verify(locator.dismissTracking()).called(1);
    });

    test('inputEvents_whenStylerSwappedForSameStyle_shouldReachApp', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);

      await session.update(recordingConfig(mapStyler: SBBCustomMapStyler(styles: [_brightStyle])));
      await sendInputEvents(session);

      expect(calls, <_Call>[.click, .longClick]);
      verify(floorController.updateAvailableFloors()).called(1);
      verify(locator.dismissTracking()).called(1);
    });
  });

  group('map styler', () {
    test('initialStyleURI_whenStylerChangesLater_shouldStayStylersStyleAtCreation', () {
      final session = createSession(recordingConfig());

      styler.toggleDarkMode();
      session.update(recordingConfig(mapStyler: SBBCustomMapStyler(styles: [_otherStyle])));

      expect(session.initialStyleURI, 'bright_uri');
    });

    test('stylerNotification_whenStyleLoaded_shouldSetStylersCurrentStyleOnMap', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      clearInteractions(mapLibre);

      styler.switchStyle('other');
      await pumpEventQueue();
      styler.toggleDarkMode();
      await pumpEventQueue();

      verifyInOrder([mapLibre.setStyle('other_uri'), mapLibre.setStyle('other_uri')]);
      clearInteractions(mapLibre);

      styler.switchStyle('bright');
      await pumpEventQueue();

      verify(mapLibre.setStyle('dark_uri')).called(1);
      session.dispose();
    });

    test('stylerNotification_whenBeforeMapCreated_shouldSetStylersCurrentStyleOnceMapCreated', () async {
      final session = createSession(recordingConfig());

      styler.toggleDarkMode();
      await pumpEventQueue();
      verifyNever(mapLibre.setStyle(any));

      await session.onMapCreated(mapLibre);
      await pumpEventQueue();

      verify(mapLibre.setStyle('dark_uri')).called(1);
    });

    test('update_whenStylerSwappedForDifferentStyle_shouldSetNewStyle', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      clearInteractions(mapLibre);
      final newStyler = SBBCustomMapStyler(styles: [_otherStyle]);

      await session.update(recordingConfig(mapStyler: newStyler));

      verify(mapLibre.setStyle('other_uri')).called(1);
    });

    test('update_whenStylerSwappedForSameStyle_shouldNotSetStyle', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      clearInteractions(mapLibre);
      final newStyler = SBBCustomMapStyler(styles: [_brightStyle]);

      await session.update(recordingConfig(mapStyler: newStyler));

      verifyNever(mapLibre.setStyle(any));
    });

    test('update_whenStylerSwapped_shouldFollowNewStylerOnly', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      final newStyler = SBBCustomMapStyler(styles: [_brightStyle, _otherStyle]);
      await session.update(recordingConfig(mapStyler: newStyler));
      clearInteractions(mapLibre);

      styler.switchStyle('other');
      await pumpEventQueue();
      verifyNever(mapLibre.setStyle(any));

      newStyler.toggleDarkMode();
      await pumpEventQueue();
      verify(mapLibre.setStyle('dark_uri')).called(1);
    });

    test('update_whenSameStyler_shouldNotSetStyle', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      clearInteractions(mapLibre);

      await session.update(recordingConfig());

      verifyNever(mapLibre.setStyle(any));
    });
  });

  group('style loaded', () {
    SBBMapSessionConfig availableCallbacksConfig({
      bool isMyLocationEnabled = true,
      bool isFloorSwitchingEnabled = true,
      SBBCameraPosition? initialCameraPosition = .highLevelCH,
      void Function()? onStyleLoaded,
    }) => SBBMapSessionConfig(
      mapStyler: styler,
      initialCameraPosition: initialCameraPosition,
      isMyLocationEnabled: isMyLocationEnabled,
      isFloorSwitchingEnabled: isFloorSwitchingEnabled,
      poiSettings: SBBMapPOISettings(onPoiControllerAvailable: (_) => calls.add(.poi)),
      onMapLocatorAvailable: (_) => calls.add(.locator),
      onFloorControllerAvailable: (_) => calls.add(.floor),
      onMapAnnotatorAvailable: (_) => calls.add(.annotator),
      onRoutingControllerAvailable: (_) => calls.add(.routing),
      onStyleLoaded: onStyleLoaded,
    );

    Future<void> reloadStyle(SBBMapSession session) async {
      styler.toggleDarkMode();
      await pumpEventQueue();
      await session.onStyleLoaded();
    }

    test('onStyleLoaded_whenFirstLoad_shouldFireAvailableCallbacksInOrder', () async {
      final session = createSession(availableCallbacksConfig());

      await loadFirstStyle(session);

      expect(calls, <_Call>[.locator, .floor, .poi, .annotator, .routing]);
    });

    test('onStyleLoaded_whenFirstLoad_shouldNotSetStyle', () async {
      final session = createSession(availableCallbacksConfig());

      await loadFirstStyle(session);

      verifyNever(mapLibre.setStyle(any));
    });

    test('onStyleLoaded_whenFirstLoad_shouldCallAppOnStyleLoadedOnce', () async {
      var styleLoadedCount = 0;
      final session = createSession(availableCallbacksConfig(onStyleLoaded: () => styleLoadedCount++));

      await loadFirstStyle(session);

      expect(styleLoadedCount, 1);
    });

    test('onStyleLoaded_whenLaterLoad_shouldNotFireAvailableCallbacksAgain', () async {
      final session = createSession(availableCallbacksConfig());
      await loadFirstStyle(session);
      calls.clear();

      await reloadStyle(session);
      await reloadStyle(session);

      expect(calls, isEmpty);
    });

    test('onStyleLoaded_whenStyleLoadsDuringFirstLoad_shouldFireAvailableCallbacksOnce', () async {
      final cameraMove = Completer<bool?>();
      when(mapLibre.animateCamera(any, duration: anyNamed('duration'))).thenAnswer((_) => cameraMove.future);
      var styleLoadedCount = 0;
      final session = createSession(
        availableCallbacksConfig(initialCameraPosition: null, onStyleLoaded: () => styleLoadedCount++),
      );
      await session.onMapCreated(mapLibre);

      final firstLoad = session.onStyleLoaded();
      await pumpEventQueue();
      final secondLoad = session.onStyleLoaded();
      await pumpEventQueue();
      cameraMove.complete(true);
      await Future.wait([firstLoad, secondLoad]);

      expect(calls, <_Call>[.locator, .floor, .poi, .annotator, .routing]);
      expect(styleLoadedCount, 2);
    });

    test('onStyleLoaded_whenFeaturesDisabled_shouldNotFireTheirAvailableCallbacks', () async {
      final session = createSession(
        availableCallbacksConfig(isMyLocationEnabled: false, isFloorSwitchingEnabled: false),
      );

      await loadFirstStyle(session);

      expect(calls, <_Call>[.poi, .annotator, .routing]);
    });

    test('onStyleLoaded_whenAnyLoad_shouldCallAppOnStyleLoaded', () async {
      final session = createSession(
        SBBMapSessionConfig(
          mapStyler: styler,
          initialCameraPosition: .highLevelCH,
          onStyleLoaded: () => calls.add(.styleLoaded),
        ),
      );

      await loadFirstStyle(session);
      await reloadStyle(session);
      await reloadStyle(session);

      expect(calls, <_Call>[.styleLoaded, .styleLoaded, .styleLoaded]);
    });

    test('onStyleLoaded_whenAnyLoad_shouldResyncPoiController', () async {
      final session = createSession(recordingConfig());

      await loadFirstStyle(session);
      await reloadStyle(session);

      verify(poiController.synchronizeWithNewStyle()).called(2);
    });

    test('onStyleLoaded_whenAnyLoad_shouldResyncFloorController', () async {
      final session = createSession(recordingConfig());

      await loadFirstStyle(session);
      await reloadStyle(session);

      verify(floorController.synchronizeWithNewStyle()).called(2);
    });

    test('onStyleLoaded_whenAnyLoadWithoutOnMapAnnotatorAvailable_shouldResyncAnnotator', () async {
      final session = createSession(recordingConfig());

      await loadFirstStyle(session);
      await reloadStyle(session);
      await pumpEventQueue();

      verify(annotator.onStyleChanged()).called(2);
    });

    test('onStyleLoaded_whenNoInitialCameraPosition_shouldMoveCameraToSwitzerlandOnce', () async {
      final session = createSession(recordingConfig(initialCameraPosition: null));

      await loadFirstStyle(session);
      await reloadStyle(session);

      final moves = verify(mapLibre.animateCamera(captureAny, duration: anyNamed('duration')));
      moves.called(1);
      expect(
        (moves.captured.single as CameraUpdate).toJson(),
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: const LatLng(45.7769477403, 5.93960949059),
            northeast: const LatLng(47.8308275417, 10.6427014502),
          ),
        ).toJson(),
      );
    });

    test('onStyleLoaded_whenInitialCameraPosition_shouldNotMoveCamera', () async {
      final session = createSession(recordingConfig());

      await loadFirstStyle(session);

      verifyNever(mapLibre.animateCamera(any, duration: anyNamed('duration')));
    });
  });

  group('poi selection', () {
    test('onMapClick_whenOnPoiSelectedSet_shouldTogglePoiSelection', () async {
      final session = createSession(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: (_) {})));
      await loadFirstStyle(session);

      await session.onMapClick(_point, _latLng);

      verify(poiController.toggleSelectedPointOfInterest(_point)).called(1);
      expect(calls, <_Call>[.click]);
    });

    test('onMapClick_whenOnPoiSelectedNotSet_shouldNotTogglePoiSelection', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);

      await session.onMapClick(_point, _latLng);

      verifyNever(poiController.toggleSelectedPointOfInterest(any));
      expect(calls, <_Call>[.click]);
    });

    test('onMapClick_whenUpdateSetsOnPoiSelected_shouldTogglePoiSelection', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);

      await session.update(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: (_) {})));
      await session.onMapClick(_point, _latLng);

      verify(poiController.toggleSelectedPointOfInterest(_point)).called(1);
    });

    test('onMapClick_whenUpdateUnsetsOnPoiSelected_shouldNotTogglePoiSelection', () async {
      final session = createSession(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: (_) {})));
      await loadFirstStyle(session);

      await session.update(recordingConfig());
      await session.onMapClick(_point, _latLng);

      verifyNever(poiController.toggleSelectedPointOfInterest(any));
    });

    test('update_whenPoiSettingsChange_shouldPassNewSelectionCallbacksToPoiController', () async {
      void onPoiSelected(RokasPOI _) {}
      void onPoiDeselected(RokasPOI _) {}
      final session = createSession(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: (_) {})));
      await loadFirstStyle(session);

      await session.update(
        recordingConfig(
          poiSettings: SBBMapPOISettings(onPoiSelected: onPoiSelected, onPoiDeselected: onPoiDeselected),
        ),
      );

      verify(
        poiController.updateSelectionCallbacks(onPoiSelected: onPoiSelected, onPoiDeselected: onPoiDeselected),
      ).called(1);
    });

    test('update_whenPoiSettingsEqual_shouldNotUpdatePoiController', () async {
      void onPoiSelected(RokasPOI _) {}
      final session = createSession(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: onPoiSelected)));
      await loadFirstStyle(session);

      await session.update(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: onPoiSelected)));

      verifyNever(
        poiController.updateSelectionCallbacks(
          onPoiSelected: anyNamed('onPoiSelected'),
          onPoiDeselected: anyNamed('onPoiDeselected'),
        ),
      );
    });
  });

  group('dispose', () {
    test('dispose_whenStyleLoaded_shouldReleaseEveryCollaboratorAndStopFollowingStyler', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      await pumpEventQueue();
      clearInteractions(mapLibre);

      session.dispose();
      styler.toggleDarkMode();
      await pumpEventQueue();

      verify(locator.dispose()).called(1);
      verify(floorController.dispose()).called(1);
      verify(routingController.dispose()).called(1);
      verify(poiController.dispose()).called(1);
      verify(annotator.dispose()).called(1);
      verifyNever(mapLibre.setStyle(any));
    });

    test('dispose_whenMapCreated_shouldDisposeMapControllerButNotMapLibreController', () async {
      final controllers = <SBBMapController>[];
      final session = createSession(SBBMapSessionConfig(mapStyler: styler, onMapCreated: controllers.add));
      await session.onMapCreated(mapLibre);

      session.dispose();

      expect(() => controllers.single.addListener(() {}), throwsFlutterError);
      verifyNever(mapLibre.dispose());
    });

    test('dispose_whenAppDisposedMapController_shouldNotThrow', () async {
      final controllers = <SBBMapController>[];
      final session = createSession(SBBMapSessionConfig(mapStyler: styler, onMapCreated: controllers.add));
      await session.onMapCreated(mapLibre);
      controllers.single.dispose();

      expect(session.dispose, returnsNormally);
      verifyNever(mapLibre.dispose());
    });

    test('dispose_whenCreated_shouldStopListeningToLocatorFloorAndRoutingControllers', () {
      final session = createSession(recordingConfig());
      final locatorListener = verify(locator.addListener(captureAny)).captured.single;
      final floorListener = verify(floorController.addListener(captureAny)).captured.single;
      final routingListener = verify(routingController.addListener(captureAny)).captured.single;

      session.dispose();

      verify(locator.removeListener(locatorListener)).called(1);
      verify(floorController.removeListener(floorListener)).called(1);
      verify(routingController.removeListener(routingListener)).called(1);
    });

    test('mapEvents_whenDisposed_shouldBeIgnored', () async {
      final session = createSession(recordingConfig(onStyleLoaded: () => calls.add(.styleLoaded)));
      await loadFirstStyle(session);
      calls.clear();
      clearInteractions(poiController);

      session.dispose();
      await session.onStyleLoaded();
      await sendInputEvents(session);

      expect(calls, isEmpty);
      verifyNever(poiController.synchronizeWithNewStyle());
      verifyNever(floorController.updateAvailableFloors());
      verifyNever(locator.dismissTracking());
    });

    test('dispose_whenStylerNotifiesJustBefore_shouldNotSetStyleNorNotifyListeners', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      clearInteractions(mapLibre);
      var notifications = 0;
      session.addListener(() => notifications++);

      styler.toggleDarkMode();
      session.dispose();
      await pumpEventQueue();

      verifyNever(mapLibre.setStyle(any));
      expect(notifications, 0);
    });

    test('dispose_whenStylerSwappedJustBefore_shouldNotSetStyleNorNotifyListeners', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);
      clearInteractions(mapLibre);
      var notifications = 0;
      session.addListener(() => notifications++);

      final update = session.update(recordingConfig(mapStyler: SBBCustomMapStyler(styles: [_otherStyle])));
      session.dispose();
      await update;

      verifyNever(mapLibre.setStyle(any));
      expect(notifications, 0);
    });

    test('dispose_whenFirstStyleLoadMovingCamera_shouldNotCallAppNorCollaborators', () async {
      final cameraMove = Completer<bool?>();
      when(mapLibre.animateCamera(any, duration: anyNamed('duration'))).thenAnswer((_) => cameraMove.future);
      final session = createSession(
        SBBMapSessionConfig(
          mapStyler: styler,
          isMyLocationEnabled: true,
          poiSettings: SBBMapPOISettings(onPoiControllerAvailable: (_) => calls.add(.poi)),
          onMapLocatorAvailable: (_) => calls.add(.locator),
          onFloorControllerAvailable: (_) => calls.add(.floor),
          onMapAnnotatorAvailable: (_) => calls.add(.annotator),
          onRoutingControllerAvailable: (_) => calls.add(.routing),
          onStyleLoaded: () => calls.add(.styleLoaded),
        ),
      );
      await session.onMapCreated(mapLibre);

      unawaited(session.onStyleLoaded());
      await pumpEventQueue();
      session.dispose();
      cameraMove.complete(true);
      await pumpEventQueue();

      expect(calls, isEmpty);
      verifyNever(poiController.synchronizeWithNewStyle());
      verifyNever(floorController.synchronizeWithNewStyle());
      verifyNever(annotator.onStyleChanged());
    });

    test('dispose_whenNoStylerGiven_shouldDisposeDefaultStyler', () {
      final defaultStyler = MockSBBMapStyler();
      final session = createSession(const SBBMapSessionConfig(), createDefaultMapStyler: () => defaultStyler);

      session.dispose();

      verify(defaultStyler.removeListener(any)).called(1);
      verify(defaultStyler.dispose()).called(1);
    });

    test('dispose_whenAppGaveStyler_shouldNotDisposeIt', () {
      final appStyler = MockSBBMapStyler();
      final session = createSession(recordingConfig(mapStyler: appStyler));

      session.dispose();

      verify(appStyler.removeListener(any)).called(1);
      verifyNever(appStyler.dispose());
    });

    test('update_whenDefaultStylerReplacedByAppStyler_shouldDisposeDefaultStylerOnly', () async {
      final defaultStyler = MockSBBMapStyler();
      final session = createSession(const SBBMapSessionConfig(), createDefaultMapStyler: () => defaultStyler);
      await session.onMapCreated(mapLibre);

      await session.update(recordingConfig());
      verify(defaultStyler.dispose()).called(1);

      session.dispose();
      verifyNever(defaultStyler.dispose());

      clearInteractions(mapLibre);
      styler.toggleDarkMode();
      await pumpEventQueue();
      verifyNever(mapLibre.setStyle(any));
    });
  });

  group('map events', () {
    test('onMapCreated_whenCalled_shouldHandMapControllerToApp', () async {
      final controllers = <SBBMapController>[];
      final session = createSession(SBBMapSessionConfig(mapStyler: styler, onMapCreated: controllers.add));

      await session.onMapCreated(mapLibre);

      expect(controllers, hasLength(1));
    });

    test('onMapIdle_afterFirstStyleLoad_shouldUpdateAvailableFloors', () async {
      final session = createSession(recordingConfig());
      await loadFirstStyle(session);

      await session.onMapIdle();

      verify(floorController.updateAvailableFloors()).called(1);
    });

    test('onMapIdle_whenFloorSwitchingDisabled_shouldNotUpdateAvailableFloors', () async {
      final session = createSession(SBBMapSessionConfig(mapStyler: styler, isFloorSwitchingEnabled: false));
      await loadFirstStyle(session);

      await session.onMapIdle();

      verifyNever(floorController.updateAvailableFloors());
    });

    test('onUserLocationUpdated_whenCalled_shouldUpdateDeviceLocation', () async {
      final session = createSession(recordingConfig());

      await session.onUserLocationUpdated(
        UserLocation(
          position: _latLng,
          altitude: null,
          bearing: null,
          speed: null,
          horizontalAccuracy: null,
          verticalAccuracy: null,
          timestamp: DateTime(2026),
          heading: null,
        ),
      );

      verify(locator.updateDeviceLocation(_latLng)).called(1);
    });

    test('getters_whenCreated_shouldExposeOwnedCollaborators', () {
      final session = createSession(recordingConfig());

      expect(session.mapStyler, same(styler));
      expect(session.mapLocator, same(locator));
      expect(session.floorController, same(floorController));
      expect(session.isLocationEnabled, isFalse);
    });
  });

  group('production collaborators', () {
    test('constructor_whenNoCollaboratorsGiven_shouldCreateProductionOnes', () async {
      SBBRokasPOIController? poi;
      final session = SBBMapSession(
        config: recordingConfig(poiSettings: SBBMapPOISettings(onPoiControllerAvailable: (c) => poi = c)),
      );
      await loadFirstStyle(session);
      when(mapLibre.querySourceFeatures(any, any, any)).thenAnswer((_) async => [_poiGeoJson]);

      // Selecting a POI reads the styler's dark mode through the session.
      await poi!.showPointsOfInterest();
      await poi!.selectPointOfInterest(sbbId: 'sbb-id');

      expect(session.mapLocator, isA<SBBMapLocatorImpl>());
      session.dispose();
    });

    test('update_whenPoiSettingsChange_shouldCallNewOnPoiSelectedOnSelection', () async {
      SBBRokasPOIController? poi;
      final selected = <String>[];
      final session = SBBMapSession(
        config: recordingConfig(
          poiSettings: SBBMapPOISettings(
            onPoiControllerAvailable: (c) => poi = c,
            onPoiSelected: (_) => selected.add('old'),
          ),
        ),
      );
      await loadFirstStyle(session);
      when(mapLibre.queryRenderedFeatures(any, any, any)).thenAnswer((_) async => [_poiGeoJson]);
      await poi!.showPointsOfInterest();

      await session.update(recordingConfig(poiSettings: SBBMapPOISettings(onPoiSelected: (_) => selected.add('new'))));
      await session.onMapClick(_point, _latLng);
      await pumpEventQueue();

      expect(selected, ['new']);
      session.dispose();
    });
  });
}

const _poiGeoJson = {
  'id': '1',
  'properties': {
    'sbbId': 'sbb-id',
    'name': 'name',
    'category': 'mobility',
    'subCategory': 'bike_sharing',
    'icon': 'mobility_bikesharing',
    'operator': 'operator',
  },
  'geometry': {
    'type': 'Point',
    'coordinates': [7.4, 46.9],
  },
};
