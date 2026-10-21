import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide MapCreatedCallback;
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_controller/sbb_map_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/permission_handler_facade.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/controller/sbb_rokas_poi_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller_impl.dart';

/// The part of an [SBBMap]'s configuration that the [SBBMapSession] acts on.
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

/// The Map Session of one [SBBMap]: from map created to disposed, across every
/// style load in between.
///
/// Owns the controllers, receives the map events and decides what happens on
/// each one. Every event method returns a future that completes once the
/// session has finished handling that event.
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

    _mapLocator = mapLocator ?? SBBMapLocatorImpl(_mlController.future, PermissionHandlerFacade());
    _mapLocator.addListener(notifyListeners);

    _floorController = floorController ?? SBBMapFloorControllerImpl(_mlController.future);
    _floorController.addListener(notifyListeners);

    _routingController =
        routingController ??
        SBBRoutingControllerImpl(
          annotator: _mapAnnotator.future,
          controller: _mlController.future,
          floorController: _floorController,
        );
    _routingController.addListener(notifyListeners);

    _poiController =
        poiController ??
        SBBRokasPOIControllerImpl(
          controller: _mlController.future,
          onPoiSelected: config.poiSettings.onPoiSelected,
          onPoiDeselected: config.poiSettings.onPoiDeselected,
          isDarkMode: () => mapStyler.isDarkMode,
        );
  }

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

  final Completer<MapLibreMapController> _mlController = Completer<MapLibreMapController>();
  final Completer<SBBMapController> _controller = Completer<SBBMapController>();
  final Completer<SBBMapAnnotatorImpl> _mapAnnotator = Completer<SBBMapAnnotatorImpl>();
  SBBMapAnnotatorImpl? _annotator;
  late final SBBMapLocatorImpl _mapLocator;
  late final SBBMapFloorControllerImpl _floorController;
  late final SBBRoutingControllerImpl _routingController;
  late final SBBRokasPOIControllerImpl _poiController;

  /// The styler given in the config, or a default one owned by this session.
  SBBMapStyler get mapStyler => _config.mapStyler ?? (_defaultMapStyler ??= _createDefaultMapStyler());

  SBBMapLocator get mapLocator => _mapLocator;

  SBBMapFloorController get floorController => _floorController;

  /// Whether the "My Location" layer is currently enabled on the map.
  bool get isLocationEnabled => _mapLocator.isLocationEnabled;

  bool get _isDisposed => _lifecycle == _Lifecycle.disposed;

  bool get _acceptsInput => _lifecycle == _Lifecycle.ready;

  /// Replaces the configuration, e.g. when the [SBBMap] widget is rebuilt.
  ///
  /// A swapped [SBBMapStyler] is followed from now on, and its style is set on
  /// the map if it differs from the previous styler's.
  Future<void> update(SBBMapSessionConfig config) async {
    final oldConfig = _config;
    _config = config;
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

    if (previousStyleURI != currentStyler.currentStyleURI) {
      final controller = await _mlController.future;
      await controller.setStyle(currentStyler.currentStyleURI);
    }
  }

  Future<void> onMapCreated(MapLibreMapController controller) async {
    if (_isDisposed) return;
    final sbbMapController = SBBMapControllerImpl(maplibreMapController: controller, mapLocator: _mapLocator);

    _mlController.complete(controller);
    _controller.complete(sbbMapController);

    _config.onMapCreated?.call(sbbMapController);
  }

  Future<void> onStyleLoaded() async {
    if (_isDisposed) return;
    if (_lifecycle == _Lifecycle.awaitingMap) {
      // First-load workaround (#185): the map first loads MapLibre's default
      // style, so the real style is set here and its load is the first one.
      final controller = await _mlController.future;
      await controller.setStyle(mapStyler.currentStyleURI);
      if (_lifecycle == _Lifecycle.awaitingMap) _lifecycle = _Lifecycle.reloading;
      notifyListeners();
      return;
    }

    _lifecycle = _Lifecycle.ready;
    notifyListeners();

    if (_config.initialCameraPosition == null && _isFirstStyleLoad) {
      await _moveCameraToSwitzerland();
    }

    if (_config.isMyLocationEnabled && _isFirstStyleLoad) {
      _config.onMapLocatorAvailable?.call(_mapLocator);
    }
    if (_config.isFloorSwitchingEnabled && _config.onFloorControllerAvailable != null && _isFirstStyleLoad) {
      _config.onFloorControllerAvailable!(_floorController);
    }

    _poiController.synchronizeWithNewStyle();
    if (_config.poiSettings.onPoiControllerAvailable != null && _isFirstStyleLoad) {
      _config.poiSettings.onPoiControllerAvailable!(_poiController);
    }

    _completeAnnotatorIfNecessary();
    if (_config.onMapAnnotatorAvailable != null) {
      _mapAnnotator.future.then((a) => a.onStyleChanged());
      if (_isFirstStyleLoad) {
        _config.onMapAnnotatorAvailable!(await _mapAnnotator.future);
      }
    }

    if (_config.onRoutingControllerAvailable != null && _isFirstStyleLoad) {
      _config.onRoutingControllerAvailable!(_routingController);
    }

    _config.onStyleLoaded?.call();
    _isFirstStyleLoad = false;
  }

  Future<void> onMapClick(Point<double> point, LatLng coordinates) async {
    if (_isDisposed) return;
    if (_acceptsInput && _config.poiSettings.onPoiSelected != null) {
      _poiController.toggleSelectedPointOfInterest(point);
    }
    if (_acceptsInput && _config.onMapClick != null) {
      _config.onMapClick!(point, coordinates);
    }
  }

  Future<void> onMapLongClick(Point<double> point, LatLng coordinates) async {
    if (_isDisposed) return;
    if (_acceptsInput && _config.onMapLongClick != null) {
      _config.onMapLongClick!(point, coordinates);
    }
  }

  Future<void> onCameraIdle() async {
    if (_isDisposed) return;
    if (_acceptsInput) await _floorController.updateAvailableFloors();
  }

  Future<void> onCameraTrackingDismissed() async {
    if (_isDisposed) return;
    if (_acceptsInput) await _mapLocator.dismissTracking();
  }

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

  void _reactToStyleChange() {
    _mlController.future.then((c) {
      c.setStyle(mapStyler.currentStyleURI);
      if (_lifecycle == _Lifecycle.ready) _lifecycle = _Lifecycle.reloading;
      notifyListeners();
    });
  }

  Future<void> _moveCameraToSwitzerland() => _controller.future.then(
    (c) => c.animateCameraMove(cameraUpdate: _switzerlandBounds, duration: const Duration(milliseconds: 50)),
  );

  void _completeAnnotatorIfNecessary() {
    if (!_mapAnnotator.isCompleted) {
      _mlController.future.then((c) {
        if (_isDisposed) return;
        _mapAnnotator.complete(_annotator = _createAnnotator(c));
      });
    }
  }
}
