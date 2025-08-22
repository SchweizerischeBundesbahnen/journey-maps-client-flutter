import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class SBBMapFloorControllerImpl with ChangeNotifier implements SBBMapFloorController {
  static const _levelsFeaturePropertyName = 'floor_liststring';
  static const _servicePointSourceId = 'service_points';
  static const _servicePointLayerId = 'rokas_service_points';

  SBBMapFloorControllerImpl(this._controller);

  final Future<MapLibreMapController> _controller;
  List<int> _availableFloors = [];
  int? _currentFloor;
  final Logger _logger = Logger();

  @override
  List<int> get availableFloors => _availableFloors;

  @override
  int? get currentFloor => _currentFloor;

  @override
  Future<void> switchFloor(int? floor) async {
    if (floor != null && !_availableFloors.contains(floor)) return;
    await _selectFloor(floor: floor ?? 0);
    _notifyListenersIfChanged(currentFloor: floor);
  }

  /// Only called by [SBBMap] to update available floors
  /// when the map camera is idle.
  ///
  /// If the current floor is not available anymore,
  /// this will also reset it to null.
  Future<void> updateAvailableFloors() async {
    final features = await _queryFeaturesWithFloorsFromSource();
    final updatedFloors = _extractUniqueSortedFloors(features);

    int? updatedFloor = _currentFloor;
    if (_currentFloorShouldBeReset(updatedFloors)) {
      _selectFloor(floor: 0);
      updatedFloor = null;
    }
    _notifyListenersIfChanged(currentFloor: updatedFloor, availableFloors: updatedFloors);
  }

  Future<List<dynamic>> _queryFeaturesWithFloorsFromSource() async {
    return await _controller.then(
      (controller) => controller.querySourceFeatures(_servicePointSourceId, _servicePointLayerId, null),
    );
  }

  List<int> _extractUniqueSortedFloors(List<dynamic> features) {
    final floors = features.map((feature) => _extractFloors(feature['properties']));
    final flatFloors = _flattenFloors(floors);
    return _sortUniqueFloors(flatFloors);
  }

  List<int> _extractFloors(dynamic properties) {
    if (properties == null || properties[_levelsFeaturePropertyName] == null) {
      return [];
    }
    return (properties[_levelsFeaturePropertyName] as String).split(',').map((e) => int.parse(e)).toList();
  }

  List<int> _flattenFloors(Iterable<List<int>> floors) {
    return floors.expand((element) => element).toList();
  }

  List<int> _sortUniqueFloors(List<int> flatFloors) {
    final uniqueFloors = flatFloors.toSet().toList();
    uniqueFloors.sort((a, b) => b.compareTo(a));
    return uniqueFloors;
  }

  bool _currentFloorShouldBeReset(List<int> updatedFloors) =>
      _currentFloor != null && !updatedFloors.contains(_currentFloor);

  void _notifyListenersIfChanged({required int? currentFloor, List<int>? availableFloors}) {
    final previousAvailableFloors = _availableFloors;
    final previousFloor = _currentFloor;

    _availableFloors = availableFloors ?? _availableFloors;
    _currentFloor = currentFloor;

    if (!listEquals(_availableFloors, previousAvailableFloors) || previousFloor != _currentFloor) {
      notifyListeners();
    }
  }

  Future<void> _selectFloor({required int floor}) async {
    return await _controller.then((controller) async {
      final knownLayerIds = (await controller.getLayerIds()).where((id) => (id as String).endsWith('-lvl'));
      for (final layerId in knownLayerIds) {
        try {
          final oldFilter = await _tryGettingOldFilter(controller, layerId);
          if (oldFilter == null) continue;
          final newFilter = _calculateLayerFilter(oldFilter, floor);
          final oldFilterString = jsonEncode(oldFilter);
          final newFilterString = jsonEncode(newFilter);
          if (oldFilterString != newFilterString) {
            _logger.d(
              "Updating Filter on Layer: $layerId\n"
              "OLD Filter $oldFilterString\n"
              "NEW Filter $newFilterString",
            );
            controller.setFilter(layerId, newFilter);
          }
        } catch (e) {
          _logger.e('Failed to set new layer filter on layer=$layerId');
        }
      }
      controller.setLayerVisibility("rokas_background_mask", floor < 0);
    });
  }

  Future<dynamic> _tryGettingOldFilter(MapLibreMapController controller, layerId) async {
    try {
      final result = await controller.getFilter(layerId);
      return result;
    } catch (e) {
      _logger.i('Failed to get layer filter on layer: $layerId\nSkipping layer.');
      return null;
    }
  }

  List<dynamic>? _calculateLayerFilter(List<dynamic>? oldFilter, int level) {
    if (oldFilter == null || oldFilter.isEmpty) {
      return oldFilter;
    }

    final newFilter = [oldFilter[0]];
    bool floorFound = false;
    oldFilter.slice(1).forEach((item) {
      if (item is String && _isFloorFilter(item)) {
        // "floor" in "rokas_indoor" and "geojson_walk" layers
        floorFound = true;
        newFilter.add(item);
      } else if (item is List) {
        bool levelFound = false;
        final newInnerPart = [item[0]];
        item.slice(1).forEach((innerPart) {
          final innerPartString = jsonEncode(innerPart);
          if (_isCaseLvlFilter(innerPartString)) {
            levelFound = true;
            newInnerPart.add(innerPart);
          } else if (_isFloorFilter(innerPartString)) {
            levelFound = true;
            // when filter: ['==', ['get','floor'], 0]
            floorFound = true;
            newInnerPart.add(innerPart);
          } else if (levelFound) {
            levelFound = false;
            newInnerPart.add(level);
          } else {
            newInnerPart.add(innerPart);
          }
        });
        newFilter.add(newInnerPart);
      } else if (floorFound) {
        floorFound = false;
        newFilter.add(level);
      } else {
        newFilter.add(item);
      }
    });

    return newFilter;
  }

  bool _isCaseLvlFilter(String innerPartString) {
    if (Platform.isIOS) {
      return innerPartString.startsWith('["case",["==",["has","level"],true],["get","level"]');
    } else {
      return innerPartString.startsWith('["case",["has","level"],["get","level"]');
    }
  }

  bool _isFloorFilter(String innerPartString) {
    return innerPartString.contains('floor');
  }
}
