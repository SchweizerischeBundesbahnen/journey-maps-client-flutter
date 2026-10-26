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

const _rokasSelectedPoiBrightIcon = 'sbb_marker_poi_bright_selected';
const _rokasSelectedPoiDarkIcon = 'sbb_marker_poi_dark_selected';
const _rokasSelectedPoiIconAnchor = 'bottom';

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
    OnPoiSelected? onPoiSelected,
    VoidCallback? onPoiDeselected,
    bool Function()? isDarkMode,
  }) : _controller = controller,
       _onPoiSelected = onPoiSelected,
       _onPoiDeselected = onPoiDeselected,
       _isDarkMode = isDarkMode ?? _notDarkMode;

  static bool _notDarkMode() => false;

  final Future<MapLibreMapController> _controller;
  OnPoiSelected? _onPoiSelected;
  VoidCallback? _onPoiDeselected;

  final bool Function() _isDarkMode;

  static Set<SBBPoiCategoryType> Function() get _allPoiCategories =>
      () => Set<SBBPoiCategoryType>.from(SBBPoiCategoryType.values);

  static Map<SBBRokasPoiLayer, bool> Function() get _allLayersWithVisibilityToFalse =>
      () => {for (var k in SBBRokasPoiLayer.values) k: false};

  Map<SBBRokasPoiLayer, Set<SBBPoiCategoryType>> _layerToCategoryFilters = {
    .highlighted: _allPoiCategories(),
    .baseWithFloor: _allPoiCategories(),
  };
  Map<SBBRokasPoiLayer, bool> _layerToVisibility = _allLayersWithVisibilityToFalse();
  RokasPOI? _selectedPOI;

  /// Incremented by every call that changes the selection or the POI
  /// visibility, so that a lookup finishing after a newer call is dropped.
  int _selectionGeneration = 0;

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
  Future<void> hidePointsOfInterest({SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor}) async {
    _selectionGeneration++;
    final c = await _controller;
    await c.setLayerVisibility(_layerIdFromPoiLayer(layer), false);
    final visibility = {..._layerToVisibility, layer: false};
    await _applySelection(c, visibility.containsValue(true) ? _selectedPOI : null, visibility: visibility);
  }

  @override
  Future<void> hideAllPointsOfInterest() async {
    _selectionGeneration++;
    final c = await _controller;
    await _hideAllPointsOfInterest(c);
    await _applySelection(c, null, visibility: _allLayersWithVisibilityToFalse());
  }

  /// For programmatic selection of a POI only.
  @override
  Future<RokasPOI?> selectPointOfInterest({required String sbbId}) async {
    if (!_isAnyPoiLayerVisible) return _selectedPOI;
    final generation = ++_selectionGeneration;
    final c = await _controller;
    final poi = await _getPoiFromSBBId(sbbId);
    if (generation == _selectionGeneration) await _applySelection(c, poi);
    return _selectedPOI;
  }

  /// For programmatic deselection of a POI only.
  @override
  Future<void> deselectPointOfInterest() async {
    if (!_isAnyPoiLayerVisible) return;
    _selectionGeneration++;
    await _applySelection(await _controller, null);
  }

  @override
  Future<RokasPOI?> selectPointOfInterestAt({required LatLng coordinates, double zoomLevel = 18.0}) async {
    if (!_isAnyPoiLayerVisible) return _selectedPOI;
    final generation = ++_selectionGeneration;
    final c = await _controller;
    await c.moveCamera(CameraUpdate.newLatLngZoom(coordinates, zoomLevel));
    await Future.delayed(const Duration(milliseconds: 100));

    final point = await c.toScreenLocation(coordinates);
    final poi = await _searchPOIAtPoint(point.toDouble());
    if (generation == _selectionGeneration) await _applySelection(c, poi);
    return _selectedPOI;
  }

  /// Toggles the currently selected POI. Called by [SBBMap].
  ///
  /// This is used for reacting on user clicks on the map with the following behavior:
  /// * If the user clicks on a POI, it will be selected and the currently selected POI will be deselected.
  /// * If the user clicks on an empty space, the currently selected POI will be deselected.
  Future<void> toggleSelectedPointOfInterest(Point<double> p) async {
    if (!_isAnyPoiLayerVisible) return;
    final generation = ++_selectionGeneration;
    final c = await _controller;
    final poi = await _searchPOIAtPoint(p);
    if (generation == _selectionGeneration) await _applySelection(c, poi);
  }

  /// Replaces the callbacks called on POI selection and deselection.
  ///
  /// Whether [onPoiSelected] is set decides which style layer shows the
  /// [SBBRokasPoiLayer.baseWithFloor] POIs (clickable or not). When that
  /// changes, the layer's category filter and visibility are applied to the
  /// newly used style layer and the previously used one is hidden.
  Future<void> updateSelectionCallbacks({
    required OnPoiSelected? onPoiSelected,
    required VoidCallback? onPoiDeselected,
  }) async {
    final previousLayerId = _layerIdFromPoiLayer(SBBRokasPoiLayer.baseWithFloor);
    _onPoiSelected = onPoiSelected;
    _onPoiDeselected = onPoiDeselected;
    if (_layerIdFromPoiLayer(SBBRokasPoiLayer.baseWithFloor) == previousLayerId) return;

    await _controller.then((c) async {
      await c.setLayerVisibility(previousLayerId, false);
      await _reapplyFilter(c, SBBRokasPoiLayer.baseWithFloor);
      if (_layerToVisibility[SBBRokasPoiLayer.baseWithFloor]!) {
        await c.setLayerVisibility(_layerIdFromPoiLayer(SBBRokasPoiLayer.baseWithFloor), true);
      }
    });
  }

  /// This method is called by [SBBMap] whenever the style changes.
  ///
  /// This reapplies all filters, visibilities and the selection to the style / layers.
  Future<void> synchronizeWithNewStyle() async {
    _selectionGeneration++;
    final c = await _controller;
    await _hideAllPointsOfInterest(c);
    await _reapplyAllFilters(c);
    if (_isAnyPoiLayerVisible) await _reapplyVisibilities(c);
    await _reapplySelection(c);
  }

  /// Highlights the selected POI in the new style, or deselects it if the
  /// style has no layer to highlight it in.
  Future<void> _reapplySelection(MapLibreMapController c) async {
    if (_selectedPOI == null) return;
    final hasSelectedLayer = (await c.getLayerIds()).contains(_rokasSelectedPoiLayerId);
    // Read after the await: the selection may change while the layer ids are queried.
    final selectedPOI = _selectedPOI;
    if (!hasSelectedLayer) {
      _commitSelection(null);
    } else if (selectedPOI != null) {
      await _showHighlight(c, selectedPOI);
    }
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
        !_isSamePoi(previousSelectedPOI, _selectedPOI)) {
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

  /// Makes [poi] the selection (null deselects) together with the given
  /// [visibility] change.
  ///
  /// Runs synchronously up to the commit, so callers must pass the resolved
  /// controller [c] and call this right after reading the state they pass in.
  /// The highlight calls are sent before the commit and awaited after it, so
  /// they reach the map in the order the selection changes.
  Future<void> _applySelection(
    MapLibreMapController c,
    RokasPOI? poi, {
    Map<SBBRokasPoiLayer, bool>? visibility,
  }) async {
    if (_isSamePoi(poi, _selectedPOI)) {
      _commitSelection(_selectedPOI, visibility: visibility);
      return;
    }
    final highlight = poi != null ? _showHighlight(c, poi) : _hideHighlight(c);
    _commitSelection(poi, visibility: visibility);
    await highlight;
  }

  /// Updates the state and notifies listeners. If the selection changed,
  /// [_onPoiSelected] or [_onPoiDeselected] is called afterwards, so the
  /// callbacks already read the new [selectedPointOfInterest].
  void _commitSelection(RokasPOI? poi, {Map<SBBRokasPoiLayer, bool>? visibility}) {
    final isSelectionChanged = !_isSamePoi(poi, _selectedPOI);
    _updateAndNotifyListenersIfChanged(filters: null, visibility: visibility, selectedPOI: poi);
    if (!isSelectionChanged) return;
    if (poi != null) {
      _onPoiSelected?.call(poi);
    } else {
      _onPoiDeselected?.call();
    }
  }

  Future<void> _showHighlight(MapLibreMapController c, RokasPOI poi) => Future.wait([
    c.setFilter(_rokasSelectedPoiLayerId, _buildSbbIdFilter(poi.sbbId)),
    c.setLayerProperties(_rokasSelectedPoiLayerId, _selectedPoiLayerProperties(isSelectionVisible: true)),
  ]);

  Future<void> _hideHighlight(MapLibreMapController c) =>
      c.setLayerProperties(_rokasSelectedPoiLayerId, _selectedPoiLayerProperties(isSelectionVisible: false));

  static bool _isSamePoi(RokasPOI? a, RokasPOI? b) => a?.sbbId == b?.sbbId;

  /// [MapLibreMapController.setLayerProperties] serializes **all** symbol
  /// properties and sends `null` for every one that is omitted, which resets it
  /// to its default. Every property the layer relies on therefore has to be
  /// repeated on each write - otherwise the icon would be cleared along with
  /// the opacity and nothing would be drawn.
  SymbolLayerProperties _selectedPoiLayerProperties({required bool isSelectionVisible}) => SymbolLayerProperties(
    iconImage: _isDarkMode() ? _rokasSelectedPoiDarkIcon : _rokasSelectedPoiBrightIcon,
    iconAnchor: _rokasSelectedPoiIconAnchor,
    iconIgnorePlacement: true,
    iconOpacity: isSelectionVisible ? 1.0 : 0.0,
    visibility: isSelectionVisible ? 'visible' : 'none',
  );

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
      _onPoiSelected != null ? _rokasBaseLvlPoiClickableLayerId : _rokasBaseLvlPoiNonClickableLayerId,
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
      selectedPOI: _selectedPOI,
    );
  }

  Future<void> _reapplyVisibilities(MapLibreMapController c) {
    final List<Future<void>> result = [];
    for (final element in _layerToVisibility.entries) {
      result.add(c.setLayerVisibility(_layerIdFromPoiLayer(element.key), element.value));
    }
    return Future.wait(result);
  }

  Future<void> _reapplyAllFilters(MapLibreMapController c) =>
      Future.wait(_layerToCategoryFilters.keys.map((layer) => _reapplyFilter(c, layer)));

  /// Applies the layer's category filter to its style layer, unless it keeps
  /// all categories.
  Future<void> _reapplyFilter(MapLibreMapController c, SBBRokasPoiLayer layer) async {
    final filter = _layerToCategoryFilters[layer]!;
    if (const SetEquality().equals(filter, _allPoiCategories())) return;
    await _applyFilterToLayer(c, layer, filter);
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
