import 'package:flutter/foundation.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/sbb_map_poi.dart';

/// Controls visibility and selection of the ROKAS POIs
/// embedded in the [SBBRokasPoiLayer] layers of the ROKAS map styles.
///
/// Using this class will only work,
/// when the according [SBBMap] is used with a [SBBRokasMapStyler] style.
///
/// There are two types of ROKAS Points Of Interest in varying layers, see [SBBRokasPoiLayer]:
/// 1. Base points of interest (small rounded squares / circles icons)
/// 2. Highlighted points of interest (larger symbols appearing as "pins")
///
/// POIs can be filtered by their category. The available categories
/// can be queried with [availablePOICategories].
///
/// The [SBBRokasPOIController] is a [ChangeNotifier] and notifies listeners
/// when the POI visibility or the POI category filter changes.
abstract class SBBRokasPOIController with ChangeNotifier {
  /// Get the available POI categories.
  List<SBBPoiCategoryType> get availablePOICategories;

  /// Deprecated.
  ///
  /// Use [getCategoryFilterByLayer] with [SBBRokasPoiLayer.baseWithFloor].
  @Deprecated("Deprecated after v.2.4.0. Use getCategoryFilterByLayer with `RokasPoiLayer.baseOnFloor`.")
  List<SBBPoiCategoryType> get currentPOICategories;

  /// Deprecated. This will indicate whether ANY point of interest layer is visible.
  ///
  /// Use [getVisibilityByLayer] with the correct layer.
  @Deprecated("Deprecated after v.2.4.0. Use getVisibilityByLayer with a `RokasPoiLayer`.")
  bool get isPointsOfInterestVisible;

  /// Gets the currently applied POI category filter for the given [SBBRokasPoiLayer].
  ///
  /// Each filter is set individually for each [SBBRokasPoiLayer] when calling [showPointsOfInterest].
  Set<SBBPoiCategoryType> getCategoryFilterByLayer({required SBBRokasPoiLayer layer});

  /// Gets the current visibility of the given [SBBRokasPoiLayer].
  ///
  /// Each visibility is set individually for each [SBBRokasPoiLayer] when calling [showPointsOfInterest]
  /// or [hidePointsOfInterest].
  bool getVisibilityByLayer({required SBBRokasPoiLayer layer});

  /// Shows ROKAS POIs on the map.
  ///
  /// [layer] allows controlling which ROKAS POI type will be shown:
  /// The baseOnFloor POIs are the round / rounded rectangle colored icons on the map (default).
  /// The highlighted POIs are symbols appearing as "pins" on the map.
  ///
  /// Only POIs of the given [categories] will be visible.
  /// If the argument is null, POIs from all [availablePOICategories]
  /// will be shown.
  ///
  /// The currently applied POI category's filter can be queried with
  /// [getCategoryFilterByLayer].
  Future<void> showPointsOfInterest({
    SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor,
    List<SBBPoiCategoryType>? categories,
  });

  /// Hides points of interest.
  ///
  /// [layer] allows controlling which ROKAS POI will be hidden.
  Future<void> hidePointsOfInterest({SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor});

  /// Hides all points of interest regardless of the [SBBRokasPoiLayer].
  Future<void> hideAllPointsOfInterest();

  /// For programmatic selection of a POI.
  ///
  /// Only works if the POIs are visible.
  Future<void> selectPointOfInterest({required String sbbId});

  /// Deselects the currently selected POI.
  ///
  /// Only works if the POIs are visible.
  Future<void> deselectPointOfInterest();

  /// The currently selected POI.
  RokasPOI? get selectedPointOfInterest;
}
