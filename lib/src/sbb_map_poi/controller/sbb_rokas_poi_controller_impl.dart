import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const _rokasPoiSourceId = 'journey-pois-source';
const _rokasPoiSourceLayerId = 'journey_pois';

const _rokasSelectedPoiLayerId = 'journey-pois-selected';

const _rokasHighlightedPoiLayerId = 'journey-pois-first';
const _rokasBasePoiClickableLayerId = 'journey-pois-second-lvl';
const _rokasBasePoiNonClickableLayerId = 'journey-pois-third-lvl';
const _rokasBasePoiWithoutLvlClickableLayerId = 'journey-pois-second-2d';

typedef _AllLayerVisibilityToFalseCreation = Map<RokasPoiLayer, bool> Function();
typedef _AllLayerPoiCategoriesCreation = Set<SBBPoiCategoryType> Function();

class SBBRokasPOIControllerImpl with ChangeNotifier implements SBBRokasPOIController {
  static const _allPoiLayerIds = {
    _rokasHighlightedPoiLayerId,
    _rokasBasePoiClickableLayerId,
    _rokasBasePoiNonClickableLayerId,
    _rokasBasePoiWithoutLvlClickableLayerId
  };

  SBBRokasPOIControllerImpl({
    required Future<MapLibreMapController> controller,
    this.onPoiSelected,
    this.onPoiDeselected,
  }) : _controller = controller;

  static _AllLayerPoiCategoriesCreation get _allPoiCategories =>
      () => Set<SBBPoiCategoryType>.from(SBBPoiCategoryType.values);

  Map<RokasPoiLayer, Set<SBBPoiCategoryType>> _layerToCategoryFilters = {
    RokasPoiLayer.highlighted: _allPoiCategories(),
    RokasPoiLayer.baseOnFloor: _allPoiCategories()
  };

  static _AllLayerVisibilityToFalseCreation get _allLayersWithVisibilityToFalse =>
      () => {for (var k in RokasPoiLayer.values) k: false};

  Map<RokasPoiLayer, bool> _layerToVisibility = _allLayersWithVisibilityToFalse();

  RokasPOI? _selectedPOI;
  final Future<MapLibreMapController> _controller;
  final OnPoiSelected? onPoiSelected;
  final VoidCallback? onPoiDeselected;

  @override
  List<SBBPoiCategoryType> get availablePOICategories => SBBPoiCategoryType.values.toList();

  @override
  List<SBBPoiCategoryType> get currentPOICategories => _layerToCategoryFilters[RokasPoiLayer.baseOnFloor]!.toList();

  @override
  bool get isPointsOfInterestVisible => _isAnyPoiLayerVisible;

  bool get _isAnyPoiLayerVisible => _layerToVisibility.values.any((isVisible) => isVisible);

  @override
  Set<SBBPoiCategoryType> getCategoryFilterByLayer({required RokasPoiLayer layer}) => _layerToCategoryFilters[layer]!;

  @override
  bool getVisibilityByLayer({required RokasPoiLayer layer}) => _layerToVisibility[layer]!;

  @override
  Future<void> showPointsOfInterest({
    RokasPoiLayer layer = RokasPoiLayer.baseOnFloor,
    List<SBBPoiCategoryType>? categories,
  }) async {
    final filters = categories?.toSet();
    await _controller.then((c) async {
      await _setFilterToLayerIfDifferent(c, layer, filters ?? availablePOICategories.toSet());
      await c.setLayerVisibility(_layerIdFromPoiLayer(layer), true);
    });
    _updateVisibilityAndFilterForLayer(layer: layer, isVisible: true, filters: filters);
  }

  @override
  Future<void> hidePointsOfInterest({RokasPoiLayer layer = RokasPoiLayer.baseOnFloor}) async {
    return _controller
        .then((c) async => await c.setLayerVisibility(_layerIdFromPoiLayer(layer), false))
        .then((_) => _updateVisibilityAndFilterForLayer(layer: layer, isVisible: false));
  }

  @override
  Future<void> hideAllPointsOfInterest() async =>
      _controller.then(_hideAllPointsOfInterest).then((_) => _updateVisibilityForAllLayer());

  /// For programmatic selection of a POI only.
  @override
  Future<void> selectPointOfInterest({required String sbbId}) async {
    if (!_isAnyPoiLayerVisible) return Future.value();
    final RokasPOI? poi = await _getPoiFromSBBId(sbbId);
    if (poi != null) await _selectPointOfInterest(poi);
    _updateAndNotifyListenersIfChanged(visibility: null, filters: null, selectedPOI: poi);
  }

  /// For programmatic deselection of a POI only.
  @override
  Future<void> deselectPointOfInterest() async {
    if (!_isAnyPoiLayerVisible || _selectedPOI == null) return Future.value();
    await _deselectPointOfInterest();
    _updateAndNotifyListenersIfChanged(visibility: null, filters: null, selectedPOI: null);
  }

  @override
  RokasPOI? get selectedPointOfInterest => _selectedPOI;

  /// Toggles the currently selected POI.
  ///
  /// This is used for reacting on user clicks on the map with the following behavior:
  /// * If the user clicks on a POI, it will be selected and the currently selected POI will be deselected.
  /// * If the user clicks on an empty space, the currently selected POI will be deselected.
  Future<void> toggleSelectedPointOfInterest(Point<double> p) async {
    if (!_isAnyPoiLayerVisible) return Future.value();
    RokasPOI? poi = await _searchPOIAtPoint(p);
    if (poi == null) {
      await deselectPointOfInterest();
    } else if (_selectedPOI != poi) {
      await _selectPointOfInterest(poi);
    }
    _updateAndNotifyListenersIfChanged(filters: null, visibility: null, selectedPOI: poi);
  }

  /// This method is called by [SBBMap] whenever the style changes.
  ///
  /// This reapplies all filters and visibilities to the style / layers.
  Future<void> synchronizeWithNewStyle() async {
    return _controller.then((c) async {
      await _hideAllPointsOfInterest(c);
      await _reapplyAllFilters(c);
      if (_isAnyPoiLayerVisible) await _reapplyVisibilities(c);
      // calling updateListeners for "losing" the POI
    }).then((_) => _updateAndNotifyListenersIfChanged(filters: null, visibility: null, selectedPOI: null));
  }

  Future<RokasPOI?> _searchPOIAtPoint(Point<double> p) async {
    return await _controller.then((c) async {
      final features = await c.queryRenderedFeatures(p, [..._allPoiLayerIds], null);
      return features.map((poi) => RokasPOI.fromGeoJSON(poi)).firstOrNull;
    });
  }

  void _updateAndNotifyListenersIfChanged({
    required Map<RokasPoiLayer, Set<SBBPoiCategoryType>>? filters,
    required Map<RokasPoiLayer, bool>? visibility,
    required RokasPOI? selectedPOI,
  }) {
    final previousVisibility = _layerToVisibility;
    final previousCategoriesFilter = _layerToCategoryFilters;
    final previousSelectedPOI = _selectedPOI;

    _layerToVisibility = visibility ?? _layerToVisibility;
    _layerToCategoryFilters = filters ?? _layerToCategoryFilters;
    _selectedPOI = selectedPOI;

    if (!MapEquality().equals(_layerToVisibility, previousVisibility) ||
        !MapEquality().equals(_layerToCategoryFilters, previousCategoriesFilter) ||
        previousSelectedPOI != _selectedPOI) {
      notifyListeners();
    }
  }

  Future<RokasPOI?> _getPoiFromSBBId(String sbbId) async {
    return _controller.then((c) async {
      final pois = await c.querySourceFeatures(
        _rokasPoiSourceId,
        _rokasPoiSourceLayerId,
        _buildSbbIdFilter(sbbId),
      );
      final poi = pois.map((poi) => RokasPOI.fromGeoJSON(poi)).firstOrNull;
      return poi;
    });
  }

  List<Object>? _buildSbbIdFilter(String sbbId) {
    return _buildPlatformSpecificFilter(
      [
        '==',
        ['get', 'sbbId'],
        sbbId
      ],
    );
  }

  Future<void> _selectPointOfInterest(RokasPOI poi) async {
    await _controller.then((c) async {
      c.setFilter(
        _rokasSelectedPoiLayerId,
        _buildSbbIdFilter(poi.sbbId),
      );
      c.setLayerProperties(
          _rokasSelectedPoiLayerId, const SymbolLayerProperties(iconOpacity: 1.0, visibility: 'visible'));
      onPoiSelected?.call(poi);
    });
  }

  Future<void> _deselectPointOfInterest() {
    return _controller.then((c) async {
      c.setLayerProperties(_rokasSelectedPoiLayerId, const SymbolLayerProperties(iconOpacity: 0.0, visibility: 'none'));
      onPoiDeselected?.call();
    });
  }

  Future<void> _setFilterToLayerIfDifferent(
    MapLibreMapController c,
    RokasPoiLayer layer,
    Set<SBBPoiCategoryType> filter,
  ) async {
    if (_isFilterSameAsCurrent(layer, filter)) return;
    return c.setFilter(_layerIdFromPoiLayer(layer), _buildCategoriesFilter(filter));
  }

  String _layerIdFromPoiLayer(RokasPoiLayer layer) => switch (layer) {
        RokasPoiLayer.baseOnFloor =>
          onPoiSelected != null ? _rokasBasePoiClickableLayerId : _rokasBasePoiNonClickableLayerId,
        RokasPoiLayer.highlighted => _rokasHighlightedPoiLayerId,
      };

  List<Object>? _buildCategoriesFilter(Set<SBBPoiCategoryType> list) {
    final filter = ['filter-in', 'subCategory', ...list.map((e) => e.name)];
    return _buildPlatformSpecificFilter(filter); // Android
  }

  List<Object>? _buildPlatformSpecificFilter(List<Object> filter) {
    if (Platform.isIOS) return _buildFilterExpressionIOS(filter);
    return filter; // Android
  }

  List<Object>? _buildFilterExpressionIOS(List<Object> filter) {
    return ['==', filter, true];
  }

  FutureOr _hideAllPointsOfInterest(MapLibreMapController c) async =>
      Future.wait(_allPoiLayerIds.map((layerId) => c.setLayerVisibility(layerId, false)));

  bool _isFilterSameAsCurrent(RokasPoiLayer layer, Set<SBBPoiCategoryType> filter) =>
      SetEquality().equals(_layerToCategoryFilters[layer]!, filter);

  void _updateVisibilityAndFilterForLayer({
    required RokasPoiLayer layer,
    required bool isVisible,
    Set<SBBPoiCategoryType>? filters,
  }) {
    final Map<RokasPoiLayer, bool> updatedVisibility = Map.from(_layerToVisibility)..[layer] = isVisible;
    final Map<RokasPoiLayer, Set<SBBPoiCategoryType>> updatedCategories = Map.from(_layerToCategoryFilters)
      ..[layer] = filters ?? _layerToCategoryFilters[layer]!;

    return _updateAndNotifyListenersIfChanged(
      filters: updatedCategories,
      visibility: updatedVisibility,
      selectedPOI: null,
    );
  }

  void _updateVisibilityForAllLayer() {
    return _updateAndNotifyListenersIfChanged(
      filters: null,
      visibility: _allLayersWithVisibilityToFalse(),
      selectedPOI: null,
    );
  }

  _reapplyAllFilters(MapLibreMapController c) {
    final List<Future<void>> result = [];
    for (final element in _layerToCategoryFilters.entries) {
      if (SetEquality().equals(element.value, _allPoiCategories())) continue;
      result.add(c.setFilter(_layerIdFromPoiLayer(element.key), _buildCategoriesFilter(element.value)));
    }
    return Future.wait(result);
  }

  _reapplyVisibilities(MapLibreMapController c) {
    final List<Future<void>> result = [];
    for (final element in _layerToVisibility.entries) {
      result.add(c.setLayerVisibility(_layerIdFromPoiLayer(element.key), element.value));
    }
    return Future.wait(result);
  }
}
