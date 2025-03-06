import 'package:flutter/foundation.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

typedef OnPoiControllerAvailable = void Function(SBBRokasPOIController poiController);

typedef OnPoiSelected = void Function(RokasPOI poi);

class SBBMapPOISettings {
  /// Callback for once the POI controller is available.
  ///
  /// This is called after the map is ready to be interacted with (style loaded for the first time).
  /// May be used to receive the [SBBRokasPOIController] instance of the map.
  ///
  /// This is useful for programmatically controlling POIs.
  final OnPoiControllerAvailable? onPoiControllerAvailable;

  /// Callback that is called when a POI is selected.
  ///
  /// Selecting POIs through user interaction is only enabled
  /// if this is not null.
  ///
  /// Points of Interests from the ROKAS base layer will be shown as
  /// rounded square icons when this is non null.
  ///
  /// It is called both when a POI is selected by the user and when a POI is
  /// selected programmatically.
  final OnPoiSelected? onPoiSelected;

  /// Callback that is called when a POI is deselected.
  ///
  /// It is called both when a POI is deselected by the user and when a POI is
  /// deselected programmatically.
  final VoidCallback? onPoiDeselected;

  /// Deprecated. Use SBBRokasPOIController.showPointsOfInterest instead. Does exactly that.
  @Deprecated("Use SBBRokasPOIController.showPointsOfInterest. Deprecated after 2.4.0.")
  final bool isPointOfInterestVisible;

  const SBBMapPOISettings({
    this.onPoiControllerAvailable,
    this.onPoiSelected,
    this.onPoiDeselected,
    this.isPointOfInterestVisible = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapPOISettings &&
        other.onPoiControllerAvailable == onPoiControllerAvailable &&
        other.onPoiSelected == onPoiSelected &&
        other.onPoiDeselected == onPoiDeselected &&
        other.isPointOfInterestVisible == isPointOfInterestVisible;
  }

  @override
  int get hashCode {
    return onPoiControllerAvailable.hashCode ^
        onPoiSelected.hashCode ^
        onPoiDeselected.hashCode ^
        isPointOfInterestVisible.hashCode;
  }
}
