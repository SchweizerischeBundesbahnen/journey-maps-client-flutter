import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// A SBBMapController is also a [ChangeNotifier].
/// Subscribers (change listeners) are notified upon changes to any of
///
/// * the configuration options of the underlying [MapLibreMap] widget
/// * the [symbols], [lines], [circles] or [fills] properties
/// (i.e. the collection of [Symbol]s, [Line]s, [Circle]s and [Fill]s
/// added to this map via the "simple way" (see above))
/// * the [isCameraMoving] property
/// * the [cameraPosition] property
///
/// Listeners are notified after changes have been applied on the platform side.
abstract class SBBMapController with ChangeNotifier {
  /// Returns the current filter of a layer of the style.
  ///
  /// The [layerId] must be the id of a layer in the current style.
  Future<dynamic> getFilter(String layerId) async {}

  /// Sets the filter of a layer of the style.
  ///
  /// The [layerId] must be the id of a layer in the current style.
  /// The [filter] must be a valid filter for the layer.
  Future<void> setFilter(String layerId, dynamic filter) async {}

  /// Sets the visibility of the specified layer.
  ///
  /// The [layerId] must be the id of a layer in the current style.
  /// The [visible] must be a boolean value.
  Future<void> setLayerVisibility(String layerId, bool visible) async {}

  /// Queries the data received from the specified source with [sourceId].
  ///
  /// The [sourceId] must be the id of a source in the current style.
  /// If specified, the [sourceLayerId] must be in the source.
  Future<List<dynamic>> querySourceFeatures(String sourceId, {String? sourceLayerId, List<Object>? filter});

  /// Animates the movement of the camera from the
  /// current position to the position defined in [cameraUpdate].
  ///
  /// The animation smoothly moves the camera from
  /// the current position to the new position over time.
  ///
  /// Note: This currently always returns immediately with a value of null on iOS.
  Future<bool?> animateCameraMove({
    required SBBCameraUpdate cameraUpdate,
    Duration duration = const Duration(milliseconds: 500),
  });

  /// True if the map camera is currently moving.
  bool get isCameraMoving;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if [SBBMap.trackCameraPosition] is false.
  SBBCameraPosition? get cameraPosition;
}
