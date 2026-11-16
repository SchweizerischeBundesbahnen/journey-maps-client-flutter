import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class SBBMapFloorControllerImpl with ChangeNotifier implements SBBMapFloorController {
  static const _levelsFeaturePropertyName = 'floor_liststring';
  static const _servicePointSourceId = 'service_points';
  static const _servicePointLayerId = 'rokas_service_points';

  /// Layer to display to grey out everything except the currently selected
  /// floor if it's different than 0.
  static const _greyoutLayerId = 'level_greyout';

  static const _floorDependentLayerIdSuffix = '-lvl';
  static const _floorIndependentLayerIdSuffix = '-2d';

  /// The POI layers are owned by the POI controller, which follows the view
  /// through the Map Session.
  static const _poiLayerIdPrefix = 'journey-pois-';

  SBBMapFloorControllerImpl(this._controller, {this._viewWithoutFloor = .twoD});

  final Future<MapLibreMapController> _controller;
  List<int> _availableFloors = [];
  int? _currentFloor;
  SBBMapViewWithoutFloor _viewWithoutFloor;
  final Logger _logger = Logger();

  @override
  List<int> get availableFloors => _availableFloors;

  @override
  int? get currentFloor => _currentFloor;

  /// Whether the map shows the 2D View: no Floor is selected and the view
  /// without a Floor is [SBBMapViewWithoutFloor.twoD]. Otherwise it shows the
  /// Floor View of [currentFloor], or of Floor 0 when none is selected.
  bool get isTwoDView => _isTwoDViewFor(_currentFloor);

  bool _isTwoDViewFor(int? floor) => floor == null && _viewWithoutFloor == .twoD;

  @override
  Future<void> switchFloor(int? floor) async {
    if (floor != null && !_availableFloors.contains(floor)) return;
    await _applyView(floor: floor);
    _notifyListenersIfChanged(currentFloor: floor);
  }

  /// Called by the Map Session when `SBBMap.defaultViewWithoutFloor` changes.
  ///
  /// Re-applies the view if no Floor is selected. With a selected Floor nothing
  /// changes until it is deselected.
  Future<void> updateViewWithoutFloor(SBBMapViewWithoutFloor viewWithoutFloor) async {
    if (_viewWithoutFloor == viewWithoutFloor) return;
    _viewWithoutFloor = viewWithoutFloor;
    if (_currentFloor == null) await _applyView(floor: null);
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
      await _applyView(floor: null);
      updatedFloor = null;
    }
    _notifyListenersIfChanged(currentFloor: updatedFloor, availableFloors: updatedFloors);
  }

  /// Called by the Map Session after every style load.
  ///
  /// A new style ships with the Floor View of Floor 0, so the view and the
  /// [currentFloor] are re-applied to its layers.
  Future<void> synchronizeWithNewStyle() => _applyView(floor: _currentFloor);

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

  /// Applies the view [floor] stands for: the 2D View for `null` with
  /// [SBBMapViewWithoutFloor.twoD], otherwise the Floor View of [floor] or of
  /// Floor 0.
  ///
  /// The view is decided by the visibility of the floor-independent (`-2d`) and
  /// floor-dependent (`-lvl`) layers, found by id suffix as `maplibre_gl` cannot
  /// read their `general.floor` metadata. The POI layers are left to the POI
  /// controller. In the Floor View the Floor is written into the filters of the
  /// `-lvl` layers before they are shown, so no other Floor flashes, and the
  /// greyout is shown for a Floor other than 0.
  Future<void> _applyView({required int? floor}) async {
    final isTwoDView = _isTwoDViewFor(floor);
    final viewFloor = floor ?? 0;
    final controller = await _controller;
    final layerIds = (await controller.getLayerIds()).cast<String>().toList();

    if (!isTwoDView) await _applyFloorFilters(controller, layerIds, floor: viewFloor);
    await _setViewLayerVisibilities(controller, layerIds, isTwoDView: isTwoDView);
    await _trySettingGreyoutVisibility(controller, visible: !isTwoDView && viewFloor != 0);
  }

  Future<void> _setViewLayerVisibilities(
    MapLibreMapController controller,
    List<String> layerIds, {
    required bool isTwoDView,
  }) async {
    final viewLayerIds = layerIds.where((id) => !id.startsWith(_poiLayerIdPrefix));
    final writes = <Future<void>>[
      for (final id in viewLayerIds.where((id) => id.endsWith(_floorIndependentLayerIdSuffix)))
        _trySettingLayerVisibility(controller, id, visible: isTwoDView),
      for (final id in viewLayerIds.where((id) => id.endsWith(_floorDependentLayerIdSuffix)))
        _trySettingLayerVisibility(controller, id, visible: !isTwoDView),
    ];
    await Future.wait(writes);
  }

  Future<void> _trySettingLayerVisibility(
    MapLibreMapController controller,
    String layerId, {
    required bool visible,
  }) async {
    try {
      await controller.setLayerVisibility(layerId, visible);
    } catch (e) {
      _logger.e('Failed to set visibility on layer=$layerId');
    }
  }

  /// Writes [floor] into the filters of the floor-dependent layers among
  /// [layerIds].
  Future<void> _applyFloorFilters(
    MapLibreMapController controller,
    List<String> layerIds, {
    required int floor,
  }) async {
    final knownLayerIds = layerIds.where((id) => id.endsWith(_floorDependentLayerIdSuffix));
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
          await controller.setLayerFilter(layerId, newFilter);
        }
      } catch (e) {
        _logger.e('Failed to set new layer filter on layer=$layerId');
      }
    }
  }

  /// A style without the greyout layer keeps its Floor switch; only the greyout
  /// is skipped.
  Future<void> _trySettingGreyoutVisibility(MapLibreMapController controller, {required bool visible}) async {
    try {
      await controller.setLayerVisibility(_greyoutLayerId, visible);
    } catch (e) {
      _logger.i('Failed to set visibility on layer: $_greyoutLayerId\nSkipping greyout.');
    }
  }

  Future<dynamic> _tryGettingOldFilter(MapLibreMapController controller, layerId) async {
    try {
      final result = await controller.getLayerFilter(layerId);
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
  /// feature has it. Only this prefix is matched, not the fallback value.
  bool _isCaseFilter(String operandString, {required String property}) =>
      operandString.startsWith('["case",["has","$property"],["get","$property"]');
}
