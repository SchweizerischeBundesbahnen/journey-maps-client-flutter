import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const _kRokasPoiLayerId = 'journey-pois-first';
const _kRokasSelectedPoiLayerId = 'journey-pois-selected';
const _kRokasPoiSourceId = 'journey-pois-source';
const _kRokasPoiSourceLayerId = 'journey_pois';

class SBBRokasPOIControllerImpl with ChangeNotifier implements SBBRokasPOIController {
  SBBRokasPOIControllerImpl({
    required Future<MapLibreMapController> controller,
    this.onPoiSelected,
    this.onPoiDeselected,
  }) : _controller = controller;

  List<SBBPoiCategoryType> _currentPOICategories = SBBPoiCategoryType.values.toList();
  bool _isPOIsVisible = false;
  RokasPOI? _selectedPOI;
  final Future<MapLibreMapController> _controller;
  final OnPoiSelected? onPoiSelected;
  final VoidCallback? onPoiDeselected;

  @override
  List<SBBPoiCategoryType> get availablePOICategories => SBBPoiCategoryType.values.toList();

  @override
  List<SBBPoiCategoryType> get currentPOICategories => _currentPOICategories;

  @override
  bool get isPointsOfInterestVisible => _isPOIsVisible;

  @override
  Future<void> hidePointsOfInterest() {
    _controller.then((c) async => await c.setLayerVisibility(_kRokasPoiLayerId, false));
    _notifyListenersIfChanged(isPOIsVisible: false, selectedPOI: null);
    return Future.value();
  }

  @override
  Future<void> showPointsOfInterest({List<SBBPoiCategoryType>? categories}) async {
    await _controller.then((c) async {
      await c.setFilter(
        _kRokasPoiLayerId,
        _buildCategoriesFilter(categories ?? availablePOICategories),
      );
      await c.setLayerVisibility(_kRokasPoiLayerId, true);
    });
    _notifyListenersIfChanged(
      isPOIsVisible: true,
      appliedCategories: categories,
      selectedPOI: null,
    );
    return Future.value();
  }

  /// Toggles the currently selected POI.
  ///
  /// This is used for reacting on user clicks on the map with the following behavior:
  /// * If the user clicks on a POI, it will be selected and the currently selected POI will be deselected.
  /// * If the user clicks on an empty space, the currently selected POI will be deselected.
  Future<void> toggleSelectedPointOfInterest(Point<double> p) async {
    if (!_isPOIsVisible) return Future.value();
    RokasPOI? poi = await _searchPOIAtPoint(p);
    if (poi == null) {
      await deselectPointOfInterest();
    } else if (_selectedPOI != poi) {
      await _selectPointOfInterest(poi);
      _notifyListenersIfChanged(selectedPOI: poi);
    }
  }

  Future<RokasPOI?> _searchPOIAtPoint(Point<double> p) async {
    return await _controller.then((c) async {
      final features = await c.queryRenderedFeatures(p, [_kRokasPoiLayerId], null);
      return features.map((poi) => RokasPOI.fromGeoJSON(poi)).firstOrNull;
    });
  }

  /// For programmatic selection of a POI only.
  @override
  Future<void> selectPointOfInterest({required String sbbId}) async {
    if (!_isPOIsVisible) return Future.value();
    final RokasPOI? poi = await _getPoiFromSBBId(sbbId);
    if (poi != null) await _selectPointOfInterest(poi);
    _notifyListenersIfChanged(selectedPOI: poi);
  }

  /// For programmatic deselection of a POI only.
  @override
  Future<void> deselectPointOfInterest() async {
    if (!_isPOIsVisible || _selectedPOI == null) return Future.value();
    await _deselectPointOfInterest();
    _notifyListenersIfChanged(selectedPOI: null);
  }

  @override
  RokasPOI? get selectedPointOfInterest => _selectedPOI;

  void _notifyListenersIfChanged({
    bool? isPOIsVisible,
    List<SBBPoiCategoryType>? appliedCategories,
    required RokasPOI? selectedPOI,
  }) {
    final previousVisibility = _isPOIsVisible;
    final previousCategoriesFilter = _currentPOICategories;
    final previousSelectedPOI = _selectedPOI;

    _isPOIsVisible = isPOIsVisible ?? _isPOIsVisible;
    _currentPOICategories = appliedCategories ?? _currentPOICategories;
    _selectedPOI = selectedPOI;

    if (!listEquals(_currentPOICategories, previousCategoriesFilter) ||
        previousVisibility != _isPOIsVisible ||
        previousSelectedPOI != _selectedPOI) {
      notifyListeners();
    }
  }

  List<Object>? _buildCategoriesFilter(List<SBBPoiCategoryType> list) {
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

  Future<RokasPOI?> _getPoiFromSBBId(String sbbId) async {
    return _controller.then((c) async {
      final pois = await c.querySourceFeatures(
        _kRokasPoiSourceId,
        _kRokasPoiSourceLayerId,
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
        _kRokasSelectedPoiLayerId,
        _buildSbbIdFilter(poi.sbbId),
      );
      c.setLayerProperties(
          _kRokasSelectedPoiLayerId, const SymbolLayerProperties(iconOpacity: 1.0, visibility: 'visible'));
      onPoiSelected?.call(poi);
    });
  }

  Future<void> _deselectPointOfInterest() {
    return _controller.then((c) async {
      c.setLayerProperties(
          _kRokasSelectedPoiLayerId, const SymbolLayerProperties(iconOpacity: 0.0, visibility: 'none'));
      onPoiDeselected?.call();
    });
  }
}
