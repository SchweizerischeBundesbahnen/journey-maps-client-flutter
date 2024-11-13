import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

/// This class is used to encapsulate
/// some of the properties of the [SBBMap] widget.
class SBBMapProperties {
  const SBBMapProperties({
    this.compassEnabled = true,
    this.compassViewPosition = CompassViewPosition.topLeft,
    this.compassViewMargins,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.doubleClickZoomEnabled = true,
    this.zoomGesturesEnabled = true,
  });

  /// Sets all properties to false.
  const SBBMapProperties.allDisabled()
      : this(
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          doubleClickZoomEnabled: false,
          zoomGesturesEnabled: false,
        );

  /// Whether the compass of the map should be shown,
  /// once the camera is rotated.
  final bool compassEnabled;

  /// Set the position for the Compass
  final CompassViewPosition compassViewPosition;

  /// Set the layout margins for the Compass
  final Point? compassViewMargins;

  /// Whether the [SBBMap] camera can be rotated.
  final bool rotateGesturesEnabled;

  /// Whether the [SBBMap] camera can be scrolled.
  final bool scrollGesturesEnabled;

  /// Whether the [SBBMap] camera can be double clicked
  /// to zoom in.
  ///
  /// This does not seem to work on Android.
  final bool doubleClickZoomEnabled;

  /// Whether the [SBBMap] camera can zoomed by gestures.
  final bool zoomGesturesEnabled;

  SBBMapProperties copyWith({
    bool? compassEnabled,
    CompassViewPosition? compassViewPosition,
    Point? compassViewMargins,
    bool? rotateGesturesEnabled,
    bool? scrollGesturesEnabled,
    bool? doubleClickZoomEnabled,
    bool? zoomGesturesEnabled,
  }) {
    return SBBMapProperties(
      compassEnabled: compassEnabled ?? this.compassEnabled,
      compassViewPosition: compassViewPosition ?? this.compassViewPosition,
      compassViewMargins: compassViewMargins ?? this.compassViewMargins,
      rotateGesturesEnabled: rotateGesturesEnabled ?? this.rotateGesturesEnabled,
      scrollGesturesEnabled: scrollGesturesEnabled ?? this.scrollGesturesEnabled,
      doubleClickZoomEnabled: doubleClickZoomEnabled ?? this.doubleClickZoomEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled ?? this.zoomGesturesEnabled,
    );
  }

  @override
  int get hashCode {
    return compassEnabled.hashCode ^
        compassViewPosition.hashCode ^
        compassViewMargins.hashCode ^
        rotateGesturesEnabled.hashCode ^
        scrollGesturesEnabled.hashCode ^
        doubleClickZoomEnabled.hashCode ^
        zoomGesturesEnabled.hashCode;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SBBMapProperties &&
          runtimeType == other.runtimeType &&
          compassEnabled == other.compassEnabled &&
          compassViewPosition == other.compassViewPosition &&
          compassViewMargins == other.compassViewMargins &&
          rotateGesturesEnabled == other.rotateGesturesEnabled &&
          scrollGesturesEnabled == other.scrollGesturesEnabled &&
          doubleClickZoomEnabled == other.doubleClickZoomEnabled &&
          zoomGesturesEnabled == other.zoomGesturesEnabled;
}
