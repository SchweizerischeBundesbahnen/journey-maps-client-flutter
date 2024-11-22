import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/feature_collection.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';

@visibleForTesting
const marginFraction = 0.1;

class SBBRoutingControllerImpl with ChangeNotifier implements SBBRoutingController {
  SBBRoutingControllerImpl({
    required Future<SBBMapAnnotator> annotator,
    required Future<MapLibreMapController> controller,
    required SBBMapFloorController floorController,
  })  : _annotator = annotator,
        _controller = controller,
        _floorController = floorController {
    _floorController.addListener(_floorControllerListener);
  }

  final Future<SBBMapAnnotator> _annotator;
  final SBBMapFloorController _floorController;
  final Future<MapLibreMapController> _controller;

  List<SBBMapAnnotation> _currentShownAnnotations = [];
  FeatureCollection? _featureCollection;
  bool _isFeatureCollectionSet = false;

  @override
  Future<void> routeFromFeatureCollection(FeatureCollection featureCollection) async {
    _setFeatureCollection(featureCollection);
    await _init();
  }

  @override
  Future<void> routeFromGeoJSON(Map<String, dynamic> json) async {
    _setFeatureCollection(FeatureCollection.fromGeoJSON(json));
    await _init();
  }

  void _setFeatureCollection(FeatureCollection featureCollection) {
    _featureCollection = featureCollection;
    _isFeatureCollectionSet = true;
  }

  void _floorControllerListener() {
    if (_isFeatureCollectionSet) {
      _onUpdateFloor(_floorController.currentFloor ?? 0);
    }
  }

  Future<void> _init() async {
    if (_isFeatureCollectionSet) {
      final annotations = _getAnnotations(_featureCollection!);
      await _updateAnnotations(annotations);
      await _moveCamera(_featureCollection!);
    }
  }

  Future<void> _onUpdateFloor(int currentFloor) async {
    if (_isFeatureCollectionSet) {
      final restyledAnnotations = _getAnnotations(_featureCollection!, currentFloor: currentFloor);

      await _updateAnnotations(restyledAnnotations);
    }
  }

  Iterable<SBBMapAnnotation> _getAnnotations(FeatureCollection featureCollection, {int currentFloor = 0}) {
    return featureCollection.features.map((f) {
      var annotation = f.toAnnotation();
      if (annotation is SBBMapLine) {
        annotation = annotation.copyWith(
          style: SBBMapLineStyle(
            lineColor: f.properties['floor'] == currentFloor ? SBBMapColors.sky : SBBMapColors.smoke,
            lineWidth: 5,
          ),
        );
      }
      return annotation;
    });
  }

  Future<void> _updateAnnotations(Iterable<SBBMapAnnotation> annotations) async {
    await _removeAnnotationsIfNecessary();
    await _addAnnotations(annotations);
  }

  Future<void> _removeAnnotationsIfNecessary() async {
    if (_currentShownAnnotations.isNotEmpty) {
      await _annotator.then((a) async {
        await a.removeAnnotations(_currentShownAnnotations);
        _currentShownAnnotations = [];
      });
    }
  }

  Future<void> _addAnnotations(Iterable<SBBMapAnnotation> annotations) async {
    await _annotator.then((a) async {
      await a.addAnnotations(annotations);
      _currentShownAnnotations = annotations.toList();
    });
  }

  Future<void> _moveCamera(FeatureCollection featureCollection) async {
    final cameraUpdate = _calculateCameraUpdateWithMargin(featureCollection.bbox);

    await _controller.then((controller) {
      controller.moveCamera(cameraUpdate);
    });
  }

  CameraUpdate _calculateCameraUpdateWithMargin(List<double> boundingBox) {
    double latDiff = boundingBox[3] - boundingBox[1];
    double lngDiff = boundingBox[2] - boundingBox[0];

    double latMargin = latDiff * marginFraction;
    double lngMargin = lngDiff * marginFraction;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(boundingBox[1] - latMargin, boundingBox[0] - lngMargin),
      northeast: LatLng(boundingBox[3] + latMargin, boundingBox[2] + lngMargin),
    );

    return CameraUpdate.newLatLngBounds(bounds);
  }

  @override
  void dispose() {
    _floorController.removeListener(_floorControllerListener);
    super.dispose();
  }
}
