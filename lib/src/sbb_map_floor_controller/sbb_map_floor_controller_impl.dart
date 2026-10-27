import 'dart:convert';
import 'dart:io';

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
  /// when the map has finished rendering.
  ///
  /// If the current floor is not available anymore,
  /// this will also reset it to null.
  Future<void> updateAvailableFloors() async {
    final features = await _queryFeaturesWithFloorsFromSource();
    final updatedFloors = _extractUniqueSortedFloors(features);

    int? updatedFloor = _currentFloor;
    if (_currentFloorShouldBeReset(updatedFloors)) {
      await _selectFloor(floor: 0);
      updatedFloor = null;
    }
    _notifyListenersIfChanged(currentFloor: updatedFloor, availableFloors: updatedFloors);
  }

  /// Called by the Map Session after every style load.
  ///
  /// A new style's layers show floor 0, so the [currentFloor] is re-applied to
  /// them. Without a selected floor there is nothing to re-apply.
  Future<void> synchronizeWithNewStyle() async {
    final floor = _currentFloor;
    if (floor != null) await _selectFloor(floor: floor);
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
    return _replaceFloor(oldFilter, level);
  }

  /// Sets [floor] in every Level Filter Idiom clause of [expression]: `all`,
  /// `any` and `none` groups are walked at any depth, and an
  /// `['==', <idiom>, <floor>]` comparison gets [floor] as its third operand.
  /// Every other expression is returned unchanged.
  dynamic _replaceFloor(dynamic expression, int floor) {
    if (expression is! List || expression.isEmpty) return expression;

    final filterOperator = expression.first;
    if (_isBooleanGroup(filterOperator)) {
      return [filterOperator, ...expression.skip(1).map((clause) => _replaceFloor(clause, floor))];
    }
    if (filterOperator == '==' && expression.length == 3 && _isLevelFilterIdiom(expression[1])) {
      return [filterOperator, expression[1], floor];
    }
    return expression;
  }

  /// Whether [filterOperator] combines sub-filters rather than comparing
  /// operands, in which case its children are clauses to walk.
  ///
  /// `rokas-walk-platform-lvl` nests its floor clause inside `any` of `all`,
  /// two levels below the filter root.
  bool _isBooleanGroup(dynamic filterOperator) => const {'all', 'any', 'none'}.contains(filterOperator);

  /// Whether [operand], the left side of an `==` comparison, is a form of the
  /// Level Filter Idiom of the SBB Maps style family:
  ///
  /// * `['get', 'level']`, used by the `level_*` basemap layers,
  /// * `['case', ['has', 'level'], ['get', 'level'], 0]`, used by the
  ///   `journey-pois-*` and `level_label_*` layers,
  /// * `['case', ['has', 'floor'], ['get', 'floor'], 0]`, used by
  ///   `rokas-walk-platform-lvl`.
  bool _isLevelFilterIdiom(dynamic operand) {
    final operandString = jsonEncode(operand);
    return operandString == '["get","level"]' ||
        _isCaseFilter(operandString, property: 'level') ||
        _isCaseFilter(operandString, property: 'floor');
  }

  /// Whether [operandString] is a `case` that reads [property] when the
  /// feature has it. Only this prefix is matched, not the fallback value. On
  /// iOS the platform hands the `has` check back as
  /// `['==', ['has', property], true]`.
  bool _isCaseFilter(String operandString, {required String property}) {
    if (Platform.isIOS) {
      return operandString.startsWith('["case",["==",["has","$property"],true],["get","$property"]');
    } else {
      return operandString.startsWith('["case",["has","$property"],["get","$property"]');
    }
  }
}
