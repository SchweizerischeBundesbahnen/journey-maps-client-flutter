import 'dart:async';
import 'dart:convert';
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
const _rokasBaseLvlPoiClickableLayerId = 'journey-pois-second-lvl';
const _rokasBaseLvlPoiNonClickableLayerId = 'journey-pois-third-lvl';
const _rokasBasePoiClickableLayerId = 'journey-pois-second-2d';

class SBBRokasPOIControllerImpl with ChangeNotifier implements SBBRokasPOIController {
  static const _allPoiLayerIds = {
    _rokasHighlightedPoiLayerId,
    _rokasBaseLvlPoiClickableLayerId,
    _rokasBaseLvlPoiNonClickableLayerId,
    _rokasBasePoiClickableLayerId,
  };

  SBBRokasPOIControllerImpl({
    required Future<MapLibreMapController> controller,
    this.onPoiSelected,
    this.onPoiDeselected,
  }) : _controller = controller;

  final Future<MapLibreMapController> _controller;
  final OnPoiSelected? onPoiSelected;
  final VoidCallback? onPoiDeselected;

  static Set<SBBPoiCategoryType> Function() get _allPoiCategories =>
      () => Set<SBBPoiCategoryType>.from(SBBPoiCategoryType.values);

  static Map<SBBRokasPoiLayer, bool> Function() get _allLayersWithVisibilityToFalse =>
      () => {for (var k in SBBRokasPoiLayer.values) k: false};

  Map<SBBRokasPoiLayer, Set<SBBPoiCategoryType>> _layerToCategoryFilters = {
    SBBRokasPoiLayer.highlighted: _allPoiCategories(),
    SBBRokasPoiLayer.baseWithFloor: _allPoiCategories(),
  };
  Map<SBBRokasPoiLayer, bool> _layerToVisibility = _allLayersWithVisibilityToFalse();
  RokasPOI? _selectedPOI;

  @override
  List<SBBPoiCategoryType> get availablePOICategories => SBBPoiCategoryType.values.toList();

  @override
  RokasPOI? get selectedPointOfInterest => _selectedPOI;

  @override
  List<SBBPoiCategoryType> get currentPOICategories =>
      _layerToCategoryFilters[SBBRokasPoiLayer.baseWithFloor]!.toList();

  @override
  bool get isPointsOfInterestVisible => _isAnyPoiLayerVisible;

  bool get _isAnyPoiLayerVisible => _layerToVisibility.values.any((isVisible) => isVisible);

  @override
  Set<SBBPoiCategoryType> getCategoryFilterByLayer({required SBBRokasPoiLayer layer}) =>
      _layerToCategoryFilters[layer]!;

  @override
  bool getVisibilityByLayer({required SBBRokasPoiLayer layer}) => _layerToVisibility[layer]!;

  @override
  Future<void> showPointsOfInterest({
    SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor,
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
  Future<void> hidePointsOfInterest({SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor}) async => _controller
      .then((c) async => await c.setLayerVisibility(_layerIdFromPoiLayer(layer), false))
      .then((_) => _updateVisibilityAndFilterForLayer(layer: layer, isVisible: false));

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
  Future<void> selectPointOfInterestAt({required LatLng coordinates, double zoomLevel = 18.0}) async {
    if (!_isAnyPoiLayerVisible) return Future.value();
    return _controller.then((c) async {
      await c.moveCamera(CameraUpdate.newLatLngZoom(coordinates, zoomLevel));
      await Future.delayed(const Duration(milliseconds: 100));

      final point = await c.toScreenLocation(coordinates);
      final poi = await _searchPOIAtPoint(point.toDouble());
      if (poi != null) await _selectPointOfInterest(poi);

      _updateAndNotifyListenersIfChanged(filters: null, visibility: null, selectedPOI: poi);
    });
  }

  /// Toggles the currently selected POI. Called by [SBBMap].
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
    return _controller
        .then((c) async {
          await _hideAllPointsOfInterest(c);
          await _reapplyAllFilters(c);
          if (_isAnyPoiLayerVisible) await _reapplyVisibilities(c);
          // calling updateListeners for "losing" the POI
        })
        .then((_) => _updateAndNotifyListenersIfChanged(filters: null, visibility: null, selectedPOI: null));
  }

  Future<RokasPOI?> _searchPOIAtPoint(Point<double> p) async {
    return await _controller.then((c) async {
      final features = await c.queryRenderedFeatures(p, [..._allPoiLayerIds], null);
      return features.map((poi) => RokasPOI.fromGeoJSON(poi)).firstOrNull;
    });
  }

  void _updateAndNotifyListenersIfChanged({
    required Map<SBBRokasPoiLayer, Set<SBBPoiCategoryType>>? filters,
    required Map<SBBRokasPoiLayer, bool>? visibility,
    required RokasPOI? selectedPOI,
  }) {
    final previousVisibility = _layerToVisibility;
    final previousCategoriesFilter = _layerToCategoryFilters;
    final previousSelectedPOI = _selectedPOI;

    _layerToVisibility = visibility ?? _layerToVisibility;
    _layerToCategoryFilters = filters ?? _layerToCategoryFilters;
    _selectedPOI = selectedPOI;

    if (!const MapEquality().equals(_layerToVisibility, previousVisibility) ||
        !const MapEquality().equals(_layerToCategoryFilters, previousCategoriesFilter) ||
        previousSelectedPOI != _selectedPOI) {
      notifyListeners();
    }
  }

  Future<RokasPOI?> _getPoiFromSBBId(String sbbId) async {
    return _controller.then((c) async {
      final pois = await c.querySourceFeatures(_rokasPoiSourceId, _rokasPoiSourceLayerId, _buildSbbIdFilter(sbbId));
      final poi = pois.map((poi) => RokasPOI.fromGeoJSON(poi)).firstOrNull;
      return poi;
    });
  }

  List<Object>? _buildSbbIdFilter(String sbbId) {
    return _buildPlatformSpecificFilter([
      '==',
      ['get', 'sbbId'],
      sbbId,
    ]);
  }

  Future<void> _selectPointOfInterest(RokasPOI poi) async {
    await _controller.then((c) async {
      c.setFilter(_rokasSelectedPoiLayerId, _buildSbbIdFilter(poi.sbbId));
      c.setLayerProperties(
        _rokasSelectedPoiLayerId,
        const SymbolLayerProperties(iconOpacity: 1.0, visibility: 'visible'),
      );
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
    SBBRokasPoiLayer layer,
    Set<SBBPoiCategoryType> filter,
  ) async {
    if (_isFilterSameAsCurrent(layer, filter)) return;
    return _applyFilterToLayer(c, layer, filter);
  }

  String _layerIdFromPoiLayer(SBBRokasPoiLayer layer) => switch (layer) {
    SBBRokasPoiLayer.baseWithFloor =>
      onPoiSelected != null ? _rokasBaseLvlPoiClickableLayerId : _rokasBaseLvlPoiNonClickableLayerId,
    SBBRokasPoiLayer.highlighted => _rokasHighlightedPoiLayerId,
  };

  FutureOr _hideAllPointsOfInterest(MapLibreMapController c) async =>
      Future.wait(_allPoiLayerIds.map((layerId) => c.setLayerVisibility(layerId, false)));

  bool _isFilterSameAsCurrent(SBBRokasPoiLayer layer, Set<SBBPoiCategoryType> filter) =>
      const SetEquality().equals(_layerToCategoryFilters[layer]!, filter);

  void _updateVisibilityAndFilterForLayer({
    required SBBRokasPoiLayer layer,
    required bool isVisible,
    Set<SBBPoiCategoryType>? filters,
  }) {
    final Map<SBBRokasPoiLayer, bool> updatedVisibility = Map.from(_layerToVisibility)..[layer] = isVisible;
    final Map<SBBRokasPoiLayer, Set<SBBPoiCategoryType>> updatedCategories = Map.from(_layerToCategoryFilters)
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

  Future<void> _reapplyVisibilities(MapLibreMapController c) {
    final List<Future<void>> result = [];
    for (final element in _layerToVisibility.entries) {
      result.add(c.setLayerVisibility(_layerIdFromPoiLayer(element.key), element.value));
    }
    return Future.wait(result);
  }

  Future<void> _reapplyAllFilters(MapLibreMapController c) {
    final List<Future<void>> result = [];
    for (final element in _layerToCategoryFilters.entries) {
      if (const SetEquality().equals(element.value, _allPoiCategories())) continue;
      result.add(_applyFilterToLayer(c, element.key, element.value));
    }
    return Future.wait(result);
  }

  Future<void> _applyFilterToLayer(
    MapLibreMapController c,
    SBBRokasPoiLayer layer,
    Set<SBBPoiCategoryType> categoryFilters,
  ) async {
    final layerId = _layerIdFromPoiLayer(layer);

    final oldFilter = await c.getFilter(layerId);

    return c.setFilter(_layerIdFromPoiLayer(layer), _buildCategoriesFilter(oldFilter, categoryFilters));
  }

  List<dynamic>? _buildCategoriesFilter(List<dynamic>? oldFilter, Set<SBBPoiCategoryType> categoryFilters) {
    if (oldFilter == null || oldFilter.isEmpty) {
      final filter = ["all", _buildInnerCategoryFilter(categoryFilters)];
      return _buildPlatformSpecificFilter(filter);
    }

    final prunedFilter = oldFilter.whereNot(_isSubCategoryFilter).toList();
    if (oldFilter[0] == 'all') prunedFilter.removeAt(0);

    return ['all', ...prunedFilter, _buildInnerCategoryFilter(categoryFilters)];
  }

  bool _isSubCategoryFilter(dynamic filter) {
    if (Platform.isIOS) return jsonEncode(filter).startsWith('["==",["filter-in",["subCategory"');
    return jsonEncode(filter).startsWith('["filter-in",["subCategory"');
  }

  List<Object> _buildInnerCategoryFilter(Set<SBBPoiCategoryType> categoryFilters) {
    final filter = [
      'filter-in',
      'subCategory',
      ...categoryFilters.isEmpty ? [''] : categoryFilters.map((e) => e.name),
    ];
    return _buildPlatformSpecificFilter(filter)!;
  }

  List<Object>? _buildPlatformSpecificFilter(List<Object>? filter) {
    if (Platform.isIOS) return _buildFilterExpressionIOS(filter);
    return filter; // Android
  }

  List<Object>? _buildFilterExpressionIOS(List<Object>? filter) {
    if (filter == null) return filter;
    return ['==', filter, true];
  }
}

extension _ToDouble on Point<num> {
  Point<double> toDouble() => Point(x.toDouble(), y.toDouble());
}
