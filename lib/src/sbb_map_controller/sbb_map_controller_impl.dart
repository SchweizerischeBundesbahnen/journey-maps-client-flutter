import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class SBBMapControllerImpl with ChangeNotifier implements SBBMapController {
  SBBMapControllerImpl({required MapLibreMapController maplibreMapController})
    : _maplibreMapController = maplibreMapController,
      _isCameraMoving = maplibreMapController.isCameraMoving {
    _maplibreMapController.addListener(_notifyListenersIfStateChanged);
  }

  final MapLibreMapController _maplibreMapController;
  bool _isCameraMoving;
  SBBCameraPosition? _cameraPosition;

  @override
  void dispose() {
    _maplibreMapController.removeListener(_notifyListenersIfStateChanged);
    super.dispose();
    _maplibreMapController.dispose();
  }

  @override
  Future getFilter(String layerId) {
    return _maplibreMapController.getFilter(layerId);
  }

  @override
  Future<void> setFilter(String layerId, dynamic filter) {
    return _maplibreMapController.setFilter(layerId, filter);
  }

  @override
  Future<void> setLayerVisibility(String layerId, bool visible) {
    return _maplibreMapController.setLayerVisibility(layerId, visible);
  }

  @override
  Future<List<dynamic>> querySourceFeatures(String sourceId, {String? sourceLayerId, List<Object>? filter}) {
    return _maplibreMapController.querySourceFeatures(sourceId, sourceLayerId, filter);
  }

  @override
  bool get isCameraMoving => _isCameraMoving;

  @override
  SBBCameraPosition? get cameraPosition => _cameraPosition;

  @override
  Future<bool?> animateCameraMove({required SBBCameraUpdate cameraUpdate, Duration? duration}) {
    return _maplibreMapController.animateCamera(cameraUpdate.toMaplibre(), duration: duration);
  }

  void _notifyListenersIfStateChanged() {
    final camMoving = _maplibreMapController.isCameraMoving;
    final camPos = _maplibreMapController.cameraPosition?.toSBBCameraPosition();
    if (camMoving == _isCameraMoving && camPos == _cameraPosition) return;

    if (camMoving != _isCameraMoving) _isCameraMoving = camMoving;
    if (camPos != _cameraPosition) _cameraPosition = camPos;

    notifyListeners();
  }
}

extension on CameraPosition {
  SBBCameraPosition toSBBCameraPosition() => SBBCameraPosition(target: target, bearing: bearing, zoom: zoom);
}
