import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide MapCreatedCallback;
import 'package:sbb_maps_flutter/src/sbb_camera/sbb_camera_position.dart';
import 'package:sbb_maps_flutter/src/sbb_camera/sbb_camera_update.dart';
import 'package:sbb_maps_flutter/src/sbb_map/sbb_map_callbacks.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_controller/sbb_map_controller.dart';
import 'package:sbb_maps_flutter/src/sbb_map_controller/sbb_map_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/permission_handler_facade.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/controller/sbb_rokas_poi_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/sbb_map_poi_settings.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/sbb_map_styler.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/sbb_rokas_map_styler.dart';

/// The part of an `SBBMap`'s configuration that the [SBBMapSession] acts on.
@immutable
class SBBMapSessionConfig {
  const SBBMapSessionConfig({
    this.mapStyler,
    this.initialCameraPosition,
    this.isMyLocationEnabled = false,
    this.isFloorSwitchingEnabled = true,
    this.poiSettings = const SBBMapPOISettings(),
    this.onMapCreated,
    this.onStyleLoaded,
    this.onMapClick,
    this.onMapLongClick,
    this.onMapLocatorAvailable,
    this.onFloorControllerAvailable,
    this.onRoutingControllerAvailable,
    this.onMapAnnotatorAvailable,
  });

  final SBBMapStyler? mapStyler;
  final SBBCameraPosition? initialCameraPosition;
  final bool isMyLocationEnabled;
  final bool isFloorSwitchingEnabled;
  final SBBMapPOISettings poiSettings;
  final MapCreatedCallback? onMapCreated;
  final VoidCallback? onStyleLoaded;
  final OnMapClickCallback? onMapClick;
  final OnMapClickCallback? onMapLongClick;
  final OnMapLocatorAvailable? onMapLocatorAvailable;
  final OnFloorControllerAvailable? onFloorControllerAvailable;
  final OnRoutingControllerAvailable? onRoutingControllerAvailable;
  final OnMapAnnotatorAvailable? onMapAnnotatorAvailable;
}

enum _Lifecycle { awaitingMap, reloading, ready, disposed }

/// The Map Session of one `SBBMap`: from map created to disposed, across every
/// style load in between.
///
/// Owns the controllers, receives the map events and decides what happens on
/// each one. Every event method returns a future that completes once the
/// session has finished handling that event, except for work it starts without
/// waiting for:
///
/// * on a style load, the re-syncs with the new style of the POIs
///   ([SBBRokasPOIControllerImpl.synchronizeWithNewStyle]), the selected floor
///   ([SBBMapFloorControllerImpl.synchronizeWithNewStyle]) and the annotator
///   ([SBBMapAnnotatorImpl.onStyleChanged]), and the annotator's creation on
///   the first load, unless the app asked for the annotator;
/// * on a styler notification, the new style being set on the map;
/// * on a config update with new POI settings, the POI controller applying
///   them to the map ([SBBRokasPOIControllerImpl.updateSelectionCallbacks]).
///
/// Once disposed, the session ignores every event, and the handling of an
/// earlier event neither notifies listeners nor calls the app any more.
///
/// Notifies its listeners whenever the map or its UI controls need to rebuild.
class SBBMapSession with ChangeNotifier {
  /// Creates the session and its collaborators.
  ///
  /// The collaborators default to the production implementations. The
  /// annotator needs the MapLibre controller, so it is created by
  /// [createAnnotator] once the map exists. [createDefaultMapStyler] is used
  /// only while the config gives no [SBBMapSessionConfig.mapStyler].
  SBBMapSession({
    required SBBMapSessionConfig config,
    SBBMapLocatorImpl? mapLocator,
    SBBMapFloorControllerImpl? floorController,
    SBBRoutingControllerImpl? routingController,
    SBBRokasPOIControllerImpl? poiController,
    SBBMapAnnotatorImpl Function(MapLibreMapController controller)? createAnnotator,
    SBBMapStyler Function()? createDefaultMapStyler,
  }) : _config = config,
       _createAnnotator = createAnnotator ?? ((c) => SBBMapAnnotatorImpl(controller: c)),
       // ignore: deprecated_member_use_from_same_package
       _createDefaultMapStyler = createDefaultMapStyler ?? SBBRokasMapStyler.full {
    mapStyler.addListener(_reactToStyleChange);

    _mapLocator = mapLocator ?? SBBMapLocatorImpl(_mapLibreController.future, PermissionHandlerFacade());
    _mapLocator.addListener(notifyListeners);

    _floorController = floorController ?? SBBMapFloorControllerImpl(_mapLibreController.future);
    _floorController.addListener(notifyListeners);

    _routingController =
        routingController ??
        SBBRoutingControllerImpl(
          annotator: _mapAnnotator.future,
          controller: _mapLibreController.future,
          floorController: _floorController,
        );
    _routingController.addListener(notifyListeners);

    _poiController =
        poiController ??
        SBBRokasPOIControllerImpl(
          controller: _mapLibreController.future,
          onPoiSelected: config.poiSettings.onPoiSelected,
          onPoiDeselected: config.poiSettings.onPoiDeselected,
          isDarkMode: () => mapStyler.isDarkMode,
        );
  }

  static const Duration _moveToSwitzerlandDuration = Duration(milliseconds: 50);

  static final SBBCameraUpdate _switzerlandBounds = SBBCameraUpdate.newLatLngBounds(
    LatLngBounds(
      southwest: const LatLng(45.7769477403, 5.93960949059),
      northeast: const LatLng(47.8308275417, 10.6427014502),
    ),
  );

  SBBMapSessionConfig _config;
  final SBBMapAnnotatorImpl Function(MapLibreMapController controller) _createAnnotator;
  final SBBMapStyler Function() _createDefaultMapStyler;
  SBBMapStyler? _defaultMapStyler;

  _Lifecycle _lifecycle = _Lifecycle.awaitingMap;
  bool _isFirstStyleLoad = true;

  final Completer<MapLibreMapController> _mapLibreController = Completer<MapLibreMapController>();
  final Completer<SBBMapController> _sbbMapController = Completer<SBBMapController>();
  final Completer<SBBMapAnnotatorImpl> _mapAnnotator = Completer<SBBMapAnnotatorImpl>();
  SBBMapAnnotatorImpl? _annotator;
  late final SBBMapLocatorImpl _mapLocator;
  late final SBBMapFloorControllerImpl _floorController;
  late final SBBRoutingControllerImpl _routingController;
  late final SBBRokasPOIControllerImpl _poiController;

  /// The styler given in the config, or a default one owned by this session.
  SBBMapStyler get mapStyler => _config.mapStyler ?? (_defaultMapStyler ??= _createDefaultMapStyler());

  /// The locator of the device position and the "My Location" tracking.
  SBBMapLocator get mapLocator => _mapLocator;

  /// The controller of the floor shown on the map.
  SBBMapFloorController get floorController => _floorController;

  /// Whether the "My Location" layer is currently enabled on the map.
  bool get isLocationEnabled => _mapLocator.isLocationEnabled;

  bool get _isDisposed => _lifecycle == _Lifecycle.disposed;

  /// False once disposed, so input events are ignored then too.
  bool get _acceptsInput => _lifecycle == _Lifecycle.ready;

  /// Replaces the configuration, e.g. when the `SBBMap` widget is rebuilt.
  ///
  /// New [SBBMapSessionConfig.poiSettings] are handed to the POI controller,
  /// whose selection and deselection callbacks follow them from now on.
  ///
  /// A swapped [SBBMapStyler] is followed from now on, and its style is set on
  /// the map if it differs from the previous styler's. Input is then ignored
  /// until that style has loaded.
  Future<void> update(SBBMapSessionConfig config) async {
    final oldConfig = _config;
    _config = config;
    if (oldConfig.poiSettings != config.poiSettings) {
      unawaited(
        _poiController.updateSelectionCallbacks(
          onPoiSelected: config.poiSettings.onPoiSelected,
          onPoiDeselected: config.poiSettings.onPoiDeselected,
        ),
      );
    }
    if (identical(oldConfig.mapStyler, config.mapStyler)) return;

    final previousStyler = oldConfig.mapStyler ?? _defaultMapStyler!;
    final previousStyleURI = previousStyler.currentStyleURI;
    previousStyler.removeListener(_reactToStyleChange);

    if (config.mapStyler != null && _defaultMapStyler != null) {
      _defaultMapStyler!.dispose();
      _defaultMapStyler = null;
    }

    final currentStyler = mapStyler;
    currentStyler.addListener(_reactToStyleChange);

    if (previousStyleURI != currentStyler.currentStyleURI) await _reloadStyle();
  }

  /// Handles the map being created: hands the [SBBMapController] to the app.
  Future<void> onMapCreated(MapLibreMapController controller) async {
    if (_isDisposed) return;
    final sbbMapController = SBBMapControllerImpl(maplibreMapController: controller, mapLocator: _mapLocator);

    _mapLibreController.complete(controller);
    _sbbMapController.complete(sbbMapController);

    _config.onMapCreated?.call(sbbMapController);
  }

  /// Handles a style load: makes the map accept input, hands the controllers
  /// to the app on the first real load, and re-syncs POIs, the selected floor
  /// and annotations.
  Future<void> onStyleLoaded() async {
    if (_isDisposed) return;
    if (_lifecycle == _Lifecycle.awaitingMap) {
      // The map first loads MapLibre's default style, so the real style is set
      // here and its load is the first one.
      final controller = await _mapLibreController.future;
      await controller.setStyle(mapStyler.currentStyleURI);
      if (_isDisposed) return;
      if (_lifecycle == _Lifecycle.awaitingMap) _lifecycle = _Lifecycle.reloading;
      notifyListeners();
      return;
    }

    _lifecycle = _Lifecycle.ready;
    notifyListeners();

    // Claimed before any await, so a style load arriving meanwhile is not
    // taken for the first one.
    final isFirstStyleLoad = _isFirstStyleLoad;
    _isFirstStyleLoad = false;

    if (isFirstStyleLoad && _config.initialCameraPosition == null) await _moveCameraToSwitzerland();
    if (_isDisposed) return;

    // First-load work is interleaved with every-load work, so it is not one
    // block.
    if (isFirstStyleLoad) {
      if (_config.isMyLocationEnabled) _config.onMapLocatorAvailable?.call(_mapLocator);
      if (_config.isFloorSwitchingEnabled) _config.onFloorControllerAvailable?.call(_floorController);
    }

    _poiController.synchronizeWithNewStyle();
    _floorController.synchronizeWithNewStyle();
    if (isFirstStyleLoad) _config.poiSettings.onPoiControllerAvailable?.call(_poiController);

    _completeAnnotatorIfNecessary();
    _mapAnnotator.future.then((a) => a.onStyleChanged());
    final onMapAnnotatorAvailable = _config.onMapAnnotatorAvailable;
    if (isFirstStyleLoad && onMapAnnotatorAvailable != null) {
      final annotator = await _mapAnnotator.future;
      if (_isDisposed) return;
      onMapAnnotatorAvailable(annotator);
    }

    if (isFirstStyleLoad) _config.onRoutingControllerAvailable?.call(_routingController);

    _config.onStyleLoaded?.call();
  }

  /// Handles a click: toggles POI selection and forwards it to the app.
  Future<void> onMapClick(Point<double> point, LatLng coordinates) async {
    if (_acceptsInput && _config.poiSettings.onPoiSelected != null) {
      _poiController.toggleSelectedPointOfInterest(point);
    }
    if (_acceptsInput) _config.onMapClick?.call(point, coordinates);
  }

  /// Handles a long click: forwards it to the app.
  Future<void> onMapLongClick(Point<double> point, LatLng coordinates) async {
    if (_acceptsInput) _config.onMapLongClick?.call(point, coordinates);
  }

  /// Handles the camera coming to rest: updates the available floors.
  Future<void> onCameraIdle() async {
    if (_acceptsInput) await _floorController.updateAvailableFloors();
  }

  /// Handles the user panning away from the device location: stops tracking.
  Future<void> onCameraTrackingDismissed() async {
    if (_acceptsInput) await _mapLocator.dismissTracking();
  }

  /// Handles a new device location: passes it to the [mapLocator].
  Future<void> onUserLocationUpdated(UserLocation location) async {
    if (_isDisposed) return;
    _mapLocator.updateDeviceLocation(location.position);
  }

  /// Releases everything the session created. A styler given in the config is
  /// left to its owner.
  @override
  void dispose() {
    _lifecycle = _Lifecycle.disposed;
    _mapLocator.removeListener(notifyListeners);
    _floorController.removeListener(notifyListeners);
    _routingController.removeListener(notifyListeners);

    mapStyler.removeListener(_reactToStyleChange);
    _defaultMapStyler?.dispose();
    _annotator?.dispose();
    _mapLocator.dispose();
    _routingController.dispose();
    _floorController.dispose();
    _poiController.dispose();
    super.dispose();
  }

  void _reactToStyleChange() => _reloadStyle();

  /// Sets the current styler's style on the map. Once the map is ready, input
  /// is ignored until that style has loaded.
  Future<void> _reloadStyle() async {
    final controller = await _mapLibreController.future;
    if (_isDisposed) return;
    final setStyle = controller.setStyle(mapStyler.currentStyleURI);
    if (_lifecycle == _Lifecycle.ready) _lifecycle = _Lifecycle.reloading;
    notifyListeners();
    await setStyle;
  }

  Future<void> _moveCameraToSwitzerland() => _sbbMapController.future.then(
    (c) => c.animateCameraMove(cameraUpdate: _switzerlandBounds, duration: _moveToSwitzerlandDuration),
  );

  void _completeAnnotatorIfNecessary() {
    if (!_mapAnnotator.isCompleted) {
      _mapLibreController.future.then((c) {
        if (_isDisposed) return;
        _mapAnnotator.complete(_annotator = _createAnnotator(c));
      });
    }
  }
}
