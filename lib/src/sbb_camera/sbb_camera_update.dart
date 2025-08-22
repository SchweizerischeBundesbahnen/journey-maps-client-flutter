import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
class SBBCameraUpdate {
  SBBCameraUpdate._(this._cameraUpdate);

  /// Returns a [SBBCameraUpdate] that moves the camera to the specified position.
  static SBBCameraUpdate newCameraPosition(SBBCameraPosition cameraPosition) {
    return SBBCameraUpdate._(CameraUpdate.newCameraPosition(cameraPosition.toMaplibre()));
  }

  /// Returns a [SBBCameraUpdate] that moves the camera target to the specified
  /// geographical location.
  static SBBCameraUpdate newLatLng(LatLng latLng) {
    return SBBCameraUpdate._(CameraUpdate.newLatLng(latLng));
  }

  /// Returns a [SBBCameraUpdate] that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [left], [top], [right] and [bottom] padding
  /// insets the bounding box from the map view's edges.
  /// The camera's new tilt and bearing will both be 0.0.
  static SBBCameraUpdate newLatLngBounds(
    LatLngBounds bounds, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return SBBCameraUpdate._(CameraUpdate.newLatLngBounds(bounds, left: left, top: top, right: right, bottom: bottom));
  }

  /// Returns a [SBBCameraUpdate] that moves the camera target to the specified
  /// geographical location and zoom level.
  static SBBCameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    return SBBCameraUpdate._(CameraUpdate.newLatLngZoom(latLng, zoom));
  }

  /// Returns a [SBBCameraUpdate] that moves the camera target the specified screen
  /// distance.
  ///
  /// For a camera with bearing 0.0 (pointing north), scrolling by 50,75 moves
  /// the camera's target to a geographical location that is 50 to the east and
  /// 75 to the south of the current location, measured in screen coordinates.
  static SBBCameraUpdate scrollBy(double dx, double dy) {
    return SBBCameraUpdate._(CameraUpdate.scrollBy(dx, dy));
  }

  /// Returns a [SBBCameraUpdate] that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static SBBCameraUpdate zoomIn() {
    return SBBCameraUpdate._(CameraUpdate.zoomIn());
  }

  /// Returns a [SBBCameraUpdate] that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static SBBCameraUpdate zoomOut() {
    return SBBCameraUpdate._(CameraUpdate.zoomOut());
  }

  /// Returns a [SBBCameraUpdate] that sets the camera zoom level.
  static SBBCameraUpdate zoomTo(double zoom) {
    return SBBCameraUpdate._(CameraUpdate.zoomTo(zoom));
  }

  /// Returns a [SBBCameraUpdate] that sets the camera bearing.
  static SBBCameraUpdate bearingTo(double bearing) {
    return SBBCameraUpdate._(CameraUpdate.bearingTo(bearing));
  }

  /// Used by the [SBBMap] to adapt to the maplibre interface.
  CameraUpdate toMaplibre() => _cameraUpdate;

  final CameraUpdate _cameraUpdate;
}
