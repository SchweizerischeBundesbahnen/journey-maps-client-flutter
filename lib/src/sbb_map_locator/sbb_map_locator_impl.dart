import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/geolocator_facade.dart';

class SBBMapLocatorImpl with ChangeNotifier implements SBBMapLocator {
  SBBMapLocatorImpl(this._mapController, this._geolocator);

  final Future<MapLibreMapController> _mapController;
  final GeolocatorFacade _geolocator;

  bool _isTracking = false;
  bool _isLocationEnabled = false;
  LatLng? _lastKnownLocation;

  @override
  bool get isLocationEnabled => _isLocationEnabled;

  @override
  bool get isTracking => _isTracking;

  @override
  LatLng? get lastKnownLocation => _lastKnownLocation;

  @override
  Future<void> trackDeviceLocation() async {
    LocationPermission locationPermission = await _requestLocationPermission();
    if (_canEnableTracking(locationPermission)) return _enableTrackingMode();
  }

  @override
  Future<void> dismissTracking() async {
    if (!isTracking) {
      return;
    }

    await _mapController.then((controller) {
      return controller
          .updateMyLocationTrackingMode(MyLocationTrackingMode.none)
          .then((_) => _notifyListeners(isTracking: false));
    });
  }

  /// Only called by [SBBMap] when the user location is updated.
  void updateDeviceLocation(LatLng location) {
    if (_isLocationEnabled) _notifyListeners(lastKnownLocation: location);
  }

  Future<LocationPermission> _requestLocationPermission() async {
    if (!await _geolocator.isLocationServiceEnabled()) {
      final logger = Logger();
      logger.w('SBBMap: Location Service not enabled.');
      return LocationPermission.denied;
    }
    LocationPermission status = await _geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      return await _geolocator.requestPermission();
    }
    return status;
  }

  bool _canEnableTracking(LocationPermission permission) {
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<void> _enableTrackingMode() async {
    await _mapController.then((controller) {
      return controller
          .updateMyLocationTrackingMode(MyLocationTrackingMode.tracking)
          .then((_) => _notifyListeners(isTracking: true, enableMyLocation: true));
    });
  }

  void _dismissTracking() {
    _mapController.then((controller) {
      if (isTracking && controller.isCameraMoving) {
        dismissTracking();
      }
    });
  }

  void _notifyListeners({bool? isTracking, bool? enableMyLocation, LatLng? lastKnownLocation}) {
    final bool prevIsLocEnabled = _isLocationEnabled;
    final bool prevIsTracking = _isTracking;
    final LatLng? prevLastKnownLocation = _lastKnownLocation;

    _isLocationEnabled = enableMyLocation ?? _isLocationEnabled;
    _isTracking = isTracking ?? _isTracking;
    _lastKnownLocation = lastKnownLocation ?? _lastKnownLocation;

    if (prevIsLocEnabled != _isLocationEnabled ||
        prevIsTracking != _isTracking ||
        prevLastKnownLocation != _lastKnownLocation) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mapController.then((controller) {
      controller.removeListener(_dismissTracking);
    });
    super.dispose();
  }
}
