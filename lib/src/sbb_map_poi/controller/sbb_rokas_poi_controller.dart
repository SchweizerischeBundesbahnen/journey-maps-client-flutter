import 'package:flutter/foundation.dart';

import '../../../sbb_maps_flutter.dart';

/// Controls visibility and selection of the ROKAS POIs
/// embedded in the [SBBRokasPoiLayer] layers of the SBB map styles.
///
/// Using this class will only work when the according [SBBMap] is used with a
/// style carrying those layers (e.g. [SBBMapsMapStyler]).
///
/// There are two types of ROKAS Points Of Interest in varying layers, see [SBBRokasPoiLayer]:
/// 1. Base points of interest (small rounded squares / circles icons)
/// 2. Highlighted points of interest (larger symbols appearing as "pins")
///
/// POIs can be filtered by their category. The available categories
/// can be queried with [availablePOICategories].
///
/// The [SBBRokasPOIController] is a [ChangeNotifier] and notifies listeners
/// when the POI visibility, the POI category filter or the
/// [selectedPointOfInterest] changes.
///
/// Whenever [selectedPointOfInterest] changes, listeners are notified first
/// and then [SBBMapPOISettings.onPoiSelected] or
/// [SBBMapPOISettings.onPoiDeselected] is called, so both already see the new
/// value. Two POIs count as the same when their [RokasPOI.sbbId] is equal.
abstract class SBBRokasPOIController with ChangeNotifier {
  /// Get the available POI categories.
  List<SBBPoiCategoryType> get availablePOICategories;

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
  /// If the argument is null, POIs from all [availablePOICategories] will be shown.
  ///
  /// The currently applied POI category's filter can be queried with
  /// [getCategoryFilterByLayer].
  ///
  /// Does not change the [selectedPointOfInterest].
  Future<void> showPointsOfInterest({
    SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor,
    List<SBBPoiCategoryType>? categories,
  });

  /// Hides points of interest.
  ///
  /// [layer] allows controlling which ROKAS POI will be hidden.
  ///
  /// If no POI layer stays visible, the selected POI is deselected.
  Future<void> hidePointsOfInterest({SBBRokasPoiLayer layer = SBBRokasPoiLayer.baseWithFloor});

  /// Hides all points of interest regardless of the [SBBRokasPoiLayer].
  ///
  /// Deselects the selected POI.
  Future<void> hideAllPointsOfInterest();

  /// For programmatic selection of a POI.
  ///
  /// Only works if the POIs are visible. Only POIs in the loaded map tiles can
  /// be found by [sbbId]. If none is found, the currently selected POI is
  /// deselected. Selecting the already selected POI changes nothing.
  ///
  /// Returns [selectedPointOfInterest] after the call.
  Future<RokasPOI?> selectPointOfInterest({required String sbbId});

  /// For selection of a POI at [LatLng] [coordinates].
  ///
  /// Only works if POIs are visible. If no POI is underneath the given
  /// [coordinates], the currently selected POI is deselected. Selecting the
  /// already selected POI changes nothing.
  /// Set the [zoomLevel] to make sure the desired POIs are rendered.
  ///
  /// Will move the camera center to the given [coordinates].
  ///
  /// Returns [selectedPointOfInterest] after the call.
  Future<RokasPOI?> selectPointOfInterestAt({required LatLng coordinates, double zoomLevel});

  /// Deselects the currently selected POI.
  ///
  /// Only works if the POIs are visible.
  Future<void> deselectPointOfInterest();

  /// The currently selected POI.
  ///
  /// The highlight on the map is shown exactly while this is not null. It is
  /// kept when the map style changes, unless the new style cannot show it.
  RokasPOI? get selectedPointOfInterest;
}
