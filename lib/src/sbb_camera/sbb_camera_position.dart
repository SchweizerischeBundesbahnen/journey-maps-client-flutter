import 'package:maplibre_gl/maplibre_gl.dart';

/// The view point from which the world is shown in the map view.
/// Aggregates the camera's [target] geographical location, its [zoom] level, and [bearing].
///
/// SBB Maps are always shown in 2D, so the tilt angle from Maplibre's camera position is always 0.0.
class SBBCameraPosition {
  const SBBCameraPosition({
    required this.target,
    this.bearing = 0.0,
    this.zoom = 0.0,
  });

  /// Center of switzerland with low level zoom.
  ///
  /// see https://en.wikipedia.org/wiki/Geographical_centre_of_Switzerland
  static const SBBCameraPosition highLevelCH = SBBCameraPosition(
    target: LatLng(46.8182, 8.2275),
    bearing: 0.0,
    zoom: 5.0,
  );

  /// The camera's bearing in degrees, measured clockwise from north.
  ///
  /// A bearing of 0.0, the default, means the camera points north.
  /// A bearing of 90.0 means the camera points east.
  final double bearing;

  /// The geographical location that the camera is pointing at.
  ///
  /// The target is always at the center of the map.
  final LatLng target;

  /// The zoom level of the camera.
  ///
  /// Larger zoom levels correspond to the camera being placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final SBBCameraPosition typedOther = other as SBBCameraPosition;
    return bearing == typedOther.bearing && target == typedOther.target && zoom == typedOther.zoom;
  }

  @override
  int get hashCode => Object.hash(bearing, target, zoom);

  @override
  String toString() => 'SBBCameraPosition(bearing: $bearing, target: $target, zoom: $zoom)';

  CameraPosition toMaplibre() => CameraPosition(
        bearing: bearing,
        target: target,
        zoom: zoom,
      );
}
