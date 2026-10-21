// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map/sbb_map_session.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_default_ui/sbb_map_default_ui.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_style_container.dart';

typedef MapCreatedCallback = void Function(SBBMapController controller);
typedef OnMapLocatorAvailable = void Function(SBBMapLocator locator);
typedef OnMapAnnotatorAvailable = void Function(SBBMapAnnotator annotator);
typedef OnFloorControllerAvailable = void Function(SBBMapFloorController floorController);
typedef OnRoutingControllerAvailable = void Function(SBBRoutingController routingController);

class SBBMap extends StatefulWidget {
  const SBBMap({
    super.key,
    this.initialCameraPosition,
    this.mapStyler,
    this.onMapCreated,
    this.onStyleLoaded,
    this.onMapClick,
    this.onMapLongClick,
    this.trackCameraPosition = false,
    this.isMyLocationEnabled = false,
    this.onMapLocatorAvailable,
    this.isFloorSwitchingEnabled = true,
    this.floorSwitcherOrientation = SBBMapFloorSwitcherOrientation.vertical,
    this.onFloorControllerAvailable,
    this.onRoutingControllerAvailable,
    this.builder,
    this.properties = const SBBMapProperties(),
    this.dragEnabled = true,
    this.poiSettings = const SBBMapPOISettings(),
    this.onMapAnnotatorAvailable,
    this.smallControls = false,
  });

  /// The optional initial [SBBCameraPosition] of the map.
  ///
  /// This defines the viewport of the map when it is first displayed.
  ///
  /// If null the map will move to a camera that fits a bounding box around Switzerland.
  final SBBCameraPosition? initialCameraPosition;

  /// The [SBBMapStyler] that will control the styling of the map.
  ///
  /// ignore: deprecated_member_use_from_same_package
  /// If not given, the deprecated [SBBRokasMapStyler] `full` will be used. Its
  /// styles are no longer served after 31.12.2026, so pass a [SBBMapsMapStyler]
  /// instead. The default changes in the next major version.
  ///
  /// Either styler will try to read the [JOURNEY_MAPS_TILES_API_KEY], for legacy
  /// reasons the [JOURNEY_MAPS_API_KEY] from the environment variables.
  /// If both are not set, an [APIKeyMissing] exception will be thrown during Runtime.
  ///
  /// The style switcher button will only be shown if the given [SBBMapStyler] has more
  /// than one style. Use [SBBMapsMapStyler.noAerial] to hide the style switcher.
  final SBBMapStyler? mapStyler;

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
  /// `Info.plist` file. Please refer here https://pub.dev/packages/permission_handler#setup.
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
  /// to programmatically switch floors. In the default UI, the floor switcher
  /// named by [floorSwitcherOrientation] will be shown.
  final bool isFloorSwitchingEnabled;

  /// Which floor switcher the default UI renders.
  ///
  /// [SBBMapFloorSwitcherOrientation.vertical] is the always-expanded column
  /// of floor tiles; [SBBMapFloorSwitcherOrientation.horizontal] is the
  /// collapsible pill, which stays out of the way of the map until a traveller
  /// needs it.
  ///
  /// Crosses with [smallControls] to give four combinations.
  ///
  /// This has no effect when a custom [SBBMap.builder] is provided, because
  /// the builder takes full control of the UI layout.
  ///
  /// Defaults to [SBBMapFloorSwitcherOrientation.vertical]; the default
  /// changes to [SBBMapFloorSwitcherOrientation.horizontal] in 3.0.0.
  final SBBMapFloorSwitcherOrientation floorSwitcherOrientation;

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
  /// * [SBBMapVerticalFloorSwitcher] and [SBBMapHorizontalFloorSwitcher].
  /// * [SBBMapStyleSwitcher].
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
  /// POIs will only work if the map style supports them
  /// (e.g. [SBBMapsMapStyler]).
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

  /// Whether the default UI controls should be rendered in their compact
  /// **32 × 32 px** small variant.
  ///
  /// When `true` the following widgets replace their standard counterparts in
  /// the default UI:
  ///
  /// * [SBBMapStyleSwitcherSmall] instead of [SBBMapStyleSwitcher]
  /// * [SBBMapMyLocationButtonSmall] instead of [SBBMapMyLocationButton]
  /// * the compact variant of whichever floor switcher
  ///   [floorSwitcherOrientation] names — 32 px wide when vertical, 32 px high
  ///   when horizontal.
  ///
  /// This has no effect when a custom [SBBMap.builder] is provided, because
  /// the builder takes full control of the UI layout.
  ///
  /// Defaults to `false`.
  final bool smallControls;

  @override
  State<SBBMap> createState() => _SBBMapState();
}

class _SBBMapState extends State<SBBMap> {
  late final SBBMapSession _session;

  @override
  void initState() {
    super.initState();
    _session = SBBMapSession(config: _sessionConfig());
    _session.addListener(_setState);
  }

  @override
  void didUpdateWidget(covariant SBBMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _session.update(_sessionConfig());
  }

  @override
  void dispose() {
    _session.removeListener(_setState);
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          initialCameraPosition:
              widget.initialCameraPosition?.toMaplibre() ?? SBBCameraPosition.highLevelCH.toMaplibre(),
          onMapCreated: _session.onMapCreated,
          onStyleLoadedCallback: _session.onStyleLoaded,
          onMapClick: _session.onMapClick,
          onMapLongClick: _session.onMapLongClick,
          myLocationEnabled: _session.isLocationEnabled,
          onUserLocationUpdated: _session.onUserLocationUpdated,
          trackCameraPosition: widget.trackCameraPosition,
          onCameraTrackingDismissed: _session.onCameraTrackingDismissed,
          onCameraIdle: _session.onCameraIdle,
          compassEnabled: widget.properties.compassEnabled,
          compassViewMargins: widget.properties.compassViewMargins,
          compassViewPosition: widget.properties.compassViewPosition,
          rotateGesturesEnabled: widget.properties.rotateGesturesEnabled,
          scrollGesturesEnabled: widget.properties.scrollGesturesEnabled,
          doubleClickZoomEnabled: widget.properties.doubleClickZoomEnabled,
          zoomGesturesEnabled: widget.properties.zoomGesturesEnabled,
          dragEnabled: widget.dragEnabled,
        ),
        _sbbMapUserControls(),
      ],
    );
  }

  SBBMapSessionConfig _sessionConfig() => SBBMapSessionConfig(
    mapStyler: widget.mapStyler,
    initialCameraPosition: widget.initialCameraPosition,
    isMyLocationEnabled: widget.isMyLocationEnabled,
    isFloorSwitchingEnabled: widget.isFloorSwitchingEnabled,
    poiSettings: widget.poiSettings,
    onMapCreated: widget.onMapCreated,
    onStyleLoaded: widget.onStyleLoaded,
    onMapClick: widget.onMapClick,
    onMapLongClick: widget.onMapLongClick,
    onMapLocatorAvailable: widget.onMapLocatorAvailable,
    onFloorControllerAvailable: widget.onFloorControllerAvailable,
    onRoutingControllerAvailable: widget.onRoutingControllerAvailable,
    onMapAnnotatorAvailable: widget.onMapAnnotatorAvailable,
  );

  SBBMapStyleContainer _sbbMapUserControls() => SBBMapStyleContainer(
    child: SBBMapUiContainer(
      mapStyler: _session.mapStyler,
      mapLocator: _session.mapLocator,
      mapFloorController: _session.floorController,
      child: Builder(
        builder:
            widget.builder ??
            (context) => SBBMapDefaultUI(
              locationEnabled: widget.isMyLocationEnabled,
              isFloorSwitchingEnabled: widget.isFloorSwitchingEnabled,
              floorSwitcherOrientation: widget.floorSwitcherOrientation,
              smallControls: widget.smallControls,
            ),
      ),
    ),
  );

  void _setState() => setState(() {});
}
