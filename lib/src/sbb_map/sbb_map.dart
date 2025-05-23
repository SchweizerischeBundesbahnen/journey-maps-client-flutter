// coverage:ignore-file

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_controller/sbb_map_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/geolocator_facade.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/controller/sbb_rokas_poi_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller_impl.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_default_ui/sbb_map_default_ui.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_style_container.dart';

typedef MapCreatedCallback = void Function(SBBMapController controller);
typedef OnMapLocatorAvailable = void Function(SBBMapLocator locator);
typedef OnMapAnnotatorAvailable = void Function(SBBMapAnnotator annotator);
typedef OnFloorControllerAvailable = void Function(SBBMapFloorController floorController);
typedef OnRoutingControllerAvailable = void Function(SBBRoutingController routingController);

class SBBMap extends StatefulWidget {
  SBBMap({
    super.key,
    this.initialCameraPosition,
    SBBMapStyler? mapStyler,
    this.onMapCreated,
    this.onStyleLoaded,
    this.onMapClick,
    this.onMapLongClick,
    this.trackCameraPosition = false,
    this.isMyLocationEnabled = false,
    this.onMapLocatorAvailable,
    this.isFloorSwitchingEnabled = true,
    this.onFloorControllerAvailable,
    this.onRoutingControllerAvailable,
    this.builder,
    this.properties = const SBBMapProperties(),
    this.dragEnabled = true,
    this.poiSettings = const SBBMapPOISettings(),
    this.onMapAnnotatorAvailable,
  }) : mapStyler = mapStyler ?? SBBRokasMapStyler.full();

  /// The optional initial [SBBCameraPosition] of the map.
  ///
  /// This defines the viewport of the map when it is first displayed.
  ///
  /// If null the map will move to a camera that fits a bounding box around Switzerland.
  final SBBCameraPosition? initialCameraPosition;

  /// The [SBBMapStyler] that will control the styling of the map.
  ///
  /// If not given, the [SBBRokasMapStyler] `full` will be used. This styler will
  /// try to read the [JOURNEY_MAPS_TILES_API_KEY], for legacy reasons the
  /// [JOURNEY_MAPS_API_KEY] from the environment variables.
  /// If both are not set, an [APIKeyMissing] exception will be thrown during Runtime.
  ///
  /// The style switcher button will only be shown if the given [SBBMapStyler] has more
  /// than one style. Use the [SBBRokasMapStyler.noAerial] to hide the style switcher
  /// when using the default ROKAS styles.
  final SBBMapStyler mapStyler;

  /// Callback method for when the map is created.
  ///
  /// May be used to receive the [SBBMapController] instance of the map.
  /// This is called when the map is ready to be interacted with.
  final MapCreatedCallback? onMapCreated;

  /// True if the "My Location" layer should be shown on the map.
  ///
  /// This layer includes a
  ///
  /// * location indicator at the current device location,
  /// * a MyLocation button (IconButton arrow compass small)
  ///
  /// Behavior:
  ///
  /// * button event *without* location permissions
  /// triggers a prompt asking for permissions
  /// * button event *with* location permissions enables the following behavior:
  ///     * tracking mode, meaning the camera will follow the device location
  ///     * the MyLocation icon will be blue
  ///     * as soon as the user pans the map, tracking mode will be disabled
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On **Android** add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. Please see details here
  /// https://developer.android.com/develop/sensors-and-location/location/permissions
  /// * On **iOS** add at minimum a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. Please refer here https://pub.dev/packages/geolocator#usage.
  final bool isMyLocationEnabled;

  /// Callback for once the map locator is available.
  ///
  /// This is only called if [isMyLocationEnabled] is set to [true].
  ///
  /// This is called after the map is ready to be interacted with (style loaded for the first time).
  /// May be used to receive the [SBBMapLocator] instance of the map, which
  /// notifies its listeners when the device location changes or tracking is dismissed.
  final OnMapLocatorAvailable? onMapLocatorAvailable;

  /// Whether the default floor switching behavior should be exposed.
  ///
  /// If true, the floor controller will be available via the [onFloorControllerAvailable]
  /// to programmatically switch floors. In the default UI, the [SBBMapFloorSelector]
  /// will be shown.
  final bool isFloorSwitchingEnabled;

  /// Callback for once the floor controller is available.
  ///
  /// This is only called if [isFloorSwitchingEnabled] is set to [true].
  ///
  /// This is called after the map is ready to be interacted with (style loaded for the first time).
  /// May be used to receive the [SBBMapFloorController] instance of the map, which
  /// notifies its listeners when the current floor or available floors change.
  final OnFloorControllerAvailable? onFloorControllerAvailable;

  /// Callback for once the routing controller is available.
  ///
  /// This is called after the map is ready to be interacted with (style loaded for the first time).
  /// May be used to receive the [SBBRoutingController] instance of the map, which
  /// notifies its listeners when the current routing or available routing change.
  final OnRoutingControllerAvailable? onRoutingControllerAvailable;

  /// Callback for once the map style has been successfully loaded.
  ///
  /// Interactions with the map should happen after this callback has been called.
  final VoidCallback? onStyleLoaded;

  /// Callback for when the map is clicked. The [Point] and the [LatLng] of the
  /// click are passed to the callback.
  ///
  /// * The point is the relative position on the screen with the origin
  ///   at the top right corner.
  /// * The latLng is the geo-coordinate in WGS84.
  final OnMapClickCallback? onMapClick;

  /// Callback for when the map is **long** clicked. The [Point] and the [LatLng] of the
  /// click are passed to the callback.
  ///
  /// * The point is the relative position on the screen with the origin
  ///   at the top right corner.
  /// * The latLng is the geo-coordinate in WGS84.
  final OnMapClickCallback? onMapLongClick;

  /// Whether user updates to the camera position should be tracked.
  ///
  /// If this is set to true and the user pans/zooms/rotates the map,
  /// [SBBMapController] (which is a [ChangeNotifier]) will notify its listeners
  /// updating its [SBBMapController.cameraPosition].
  ///
  /// Default is false.
  final bool trackCameraPosition;

  /// Builder to create custom UI controls on top of [SBBMap] in a [Stack].
  ///
  /// This is only called after the map is ready to be interacted with (every style loaded).
  ///
  /// Within this builder's [BuildContext], the following SBBMap UI Controls
  /// can be used and will work
  /// * [SBBMapMyLocationButton].
  /// * [SBBMapFloorSwitcher].
  /// * [SBBMapStyleSwitcherButton].
  ///
  /// If null, the above mentioned UI controls are built with
  /// [Alignment.topRight] and the SBB design specification spacings.
  final WidgetBuilder? builder;

  /// Allows customizing some of the properties of the map.
  ///
  /// If not given, the default properties of [SBBMapProperties] are used.
  final SBBMapProperties properties;

  /// True if drag functionality should be enabled.
  ///
  /// Disable to avoid performance issues that from the drag event listeners.
  /// Biggest impact in android
  final bool dragEnabled;

  /// Allows setting the POI configuration of the map.
  ///
  /// POIs will only work if the map style supports them.
  /// The [SBBRokasMapStyler] supports POIs.
  ///
  /// If not given, the default properties of [SBBMapPOISettings] are used.
  /// This will hide POIs and not watch the POI feature layer.
  final SBBMapPOISettings poiSettings;

  /// Callback for once the [SBBMapAnnotator] is available.
  ///
  ///
  /// This is called after the map is ready to be interacted with (style loaded for the first time).
  /// May be used to add [SBBMapAnnotation]s to the map, allowing
  /// to add custom icons and symbols.
  final OnMapAnnotatorAvailable? onMapAnnotatorAvailable;

  @override
  State<SBBMap> createState() => _SBBMapState();
}

class _SBBMapState extends State<SBBMap> {
  bool _isFirstTimeStyleLoaded = true;
  bool _isStyleLoaded = false;
  final Completer<SBBMapController> _controller = Completer<SBBMapControllerImpl>();
  final Completer<MapLibreMapController> _mlController = Completer<MapLibreMapController>();
  late SBBMapFloorControllerImpl _floorController;
  late SBBRoutingControllerImpl _routingController;
  late SBBMapLocatorImpl _mapLocator;
  late SBBRokasPOIControllerImpl _poiController;
  final Completer<SBBMapAnnotatorImpl> _mapAnnotator = Completer();

  @override
  void initState() {
    super.initState();
    widget.mapStyler.addListener(_setStyleLoadedFalse);

    _mapLocator = SBBMapLocatorImpl(
      _mlController.future,
      GeolocatorFacade(),
    );
    _mapLocator.addListener(_setState);

    _floorController = SBBMapFloorControllerImpl(_mlController.future);
    _floorController.addListener(_setState);

    _routingController = SBBRoutingControllerImpl(
        annotator: _mapAnnotator.future, controller: _mlController.future, floorController: _floorController);
    _routingController.addListener(_setState);

    _poiController = SBBRokasPOIControllerImpl(
      controller: _mlController.future,
      onPoiSelected: widget.poiSettings.onPoiSelected,
      onPoiDeselected: widget.poiSettings.onPoiDeselected,
    );
  }

  void _setStyleLoadedFalse() {
    setState(() {
      _isStyleLoaded = false;
    });
  }

  @override
  void didUpdateWidget(covariant SBBMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapStyler != widget.mapStyler) {
      oldWidget.mapStyler.removeListener(_setStyleLoadedFalse);
      widget.mapStyler.addListener(_setStyleLoadedFalse);
      oldWidget.mapStyler.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mapLocator.removeListener(_setState);
    _floorController.removeListener(_setState);
    _routingController.removeListener(_setState);
    widget.mapStyler.removeListener(_setStyleLoadedFalse);
    if (_mapAnnotator.isCompleted) {
      _mapAnnotator.future.then((a) => a.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          styleString: widget.mapStyler.currentStyleURI,
          initialCameraPosition:
              widget.initialCameraPosition?.toMaplibre() ?? SBBCameraPosition.highLevelCH.toMaplibre(),
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoadedCallback,
          onMapClick: (point, coords) {
            if (_isStyleLoaded && widget.poiSettings.onPoiSelected != null) {
              _poiController.toggleSelectedPointOfInterest(point);
            }
            if (_isStyleLoaded && widget.onMapClick != null) {
              widget.onMapClick!.call(point, coords);
            }
          },
          onMapLongClick: widget.onMapLongClick,
          myLocationEnabled: _mapLocator.isLocationEnabled,
          onUserLocationUpdated: (location) => _mapLocator.updateDeviceLocation(location.position),
          trackCameraPosition: widget.trackCameraPosition,
          onCameraTrackingDismissed: () {
            if (_isStyleLoaded) _mapLocator.dismissTracking();
          },
          onCameraIdle: () {
            if (_isStyleLoaded) _floorController.updateAvailableFloors();
          },
          compassEnabled: widget.properties.compassEnabled,
          compassViewMargins: widget.properties.compassViewMargins,
          compassViewPosition: widget.properties.compassViewPosition,
          rotateGesturesEnabled: widget.properties.rotateGesturesEnabled,
          scrollGesturesEnabled: widget.properties.scrollGesturesEnabled,
          doubleClickZoomEnabled: widget.properties.doubleClickZoomEnabled,
          zoomGesturesEnabled: widget.properties.zoomGesturesEnabled,
          dragEnabled: widget.dragEnabled,
        ),
        _buildUserControls(),
      ],
    );
  }

  _onMapCreated(MapLibreMapController controller) {
    SBBMapController sbbMapController = SBBMapControllerImpl(
      maplibreMapController: controller,
    );

    _mlController.complete(controller);
    _controller.complete(sbbMapController);

    if (widget.onMapCreated != null) {
      widget.onMapCreated!(sbbMapController);
    }
  }

  _buildUserControls() {
    return SBBMapStyleContainer(
      child: SBBMapUiContainer(
        mapStyler: widget.mapStyler,
        mapLocator: _mapLocator,
        mapFloorController: _floorController,
        child: Builder(
          builder: widget.builder ??
              (context) => SBBMapDefaultUI(
                    locationEnabled: widget.isMyLocationEnabled,
                    isFloorSwitchingEnabled: widget.isFloorSwitchingEnabled,
                  ),
        ),
      ),
    );
  }

  void _onStyleLoadedCallback() async {
    setState(() {
      _isStyleLoaded = true;
    });

    if (widget.initialCameraPosition == null && _isFirstTimeStyleLoaded) {
      await _delayedMoveToCHBounds();
    }

    if (widget.isMyLocationEnabled && _isFirstTimeStyleLoaded) {
      if (widget.onMapLocatorAvailable != null) {
        widget.onMapLocatorAvailable!(_mapLocator);
      }
    }
    if (widget.isFloorSwitchingEnabled && widget.onFloorControllerAvailable != null && _isFirstTimeStyleLoaded) {
      widget.onFloorControllerAvailable!(_floorController);
    }

    _poiController.synchronizeWithNewStyle();
    if (widget.poiSettings.onPoiControllerAvailable != null) {
      widget.poiSettings.onPoiControllerAvailable!(_poiController);
    }

    _completeAnnotatorIfNecessary();
    if (widget.onMapAnnotatorAvailable != null) {
      _mapAnnotator.future.then((a) => a.onStyleChanged());
      if (_isFirstTimeStyleLoaded) {
        widget.onMapAnnotatorAvailable!(await _mapAnnotator.future);
      }
    }

    if (widget.onRoutingControllerAvailable != null && _isFirstTimeStyleLoaded) {
      widget.onRoutingControllerAvailable!(_routingController);
    }

    if (widget.onStyleLoaded != null) {
      widget.onStyleLoaded!();
    }
    _isFirstTimeStyleLoaded = false;
  }

  Future<void> _delayedMoveToCHBounds() {
    return Future.delayed(const Duration(milliseconds: 10)).then(
      (_) => _controller.future.then(
        (c) => c.animateCameraMove(
          cameraUpdate: _getSwitzerlandLatLngBounds(),
          duration: Durations.short1,
        ),
      ),
    );
  }

  SBBCameraUpdate _getSwitzerlandLatLngBounds() {
    return SBBCameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: const LatLng(45.7769477403, 5.93960949059),
        northeast: const LatLng(47.8308275417, 10.6427014502),
      ),
    );
  }

  void _completeAnnotatorIfNecessary() {
    if (!_mapAnnotator.isCompleted) {
      _mlController.future.then((c) {
        _mapAnnotator.complete(SBBMapAnnotatorImpl(controller: c));
      });
    }
  }

  void _setState() => setState(() {});
}
