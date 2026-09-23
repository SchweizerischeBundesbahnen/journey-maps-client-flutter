import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_style_container.dart';

/// Mounts [child] in the same widget tree [SBBMap] builds around its UI
/// controls.
///
/// A map UI control reads its controllers from the [SBBMapUiContainer] and its
/// colors from the theme extensions the [SBBMapStyleContainer] injects, so a
/// widget test has to mount both. Every map UI widget test should reach the
/// control through this helper rather than rebuilding that scaffolding.
///
/// [styler] and [locator] default to inert stand-ins; pass your own where the
/// control under test reads them. [theme] is the host application's theme, the
/// one a consumer would supply.
Widget mapUiHarness({
  required Widget child,
  required SBBMapFloorController floorController,
  SBBMapStyler? styler,
  SBBMapLocator? locator,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme,
    home: SBBMapStyleContainer(
      child: SBBMapUiContainer(
        mapStyler: styler ?? FakeMapStyler(),
        mapLocator: locator ?? FakeMapLocator(),
        mapFloorController: floorController,
        child: Center(child: child),
      ),
    ),
  );
}

/// An inert stand-in for [SBBMapStyler]; only [isDarkMode] and the style ids
/// are read by the map UI controls.
class FakeMapStyler extends ChangeNotifier implements SBBMapStyler {
  FakeMapStyler({this.isDarkMode = false, List<String> styleIds = const <String>['bright', 'dark']})
    : _styleIds = styleIds;

  final List<String> _styleIds;

  @override
  bool isDarkMode;

  @override
  bool get isAerialStyle => false;

  @override
  String get currentStyleURI => 'fake://style';

  @override
  List<String> getStyleIds() => _styleIds;

  @override
  void switchStyle(String styleId) {}

  @override
  void toggleAerialStyle() {}

  @override
  void toggleDarkMode() {}
}

/// An inert stand-in for [SBBMapLocator].
class FakeMapLocator extends ChangeNotifier implements SBBMapLocator {
  @override
  LatLng? get lastKnownLocation => null;

  @override
  bool get isTracking => false;

  @override
  bool get isLocationEnabled => false;

  @override
  Future<void> trackDeviceLocation() async {}

  @override
  void dismissTracking() {}
}
