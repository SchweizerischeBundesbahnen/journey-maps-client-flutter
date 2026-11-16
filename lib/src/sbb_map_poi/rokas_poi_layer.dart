/// The POI layers defined in the SBB map styles.
///
/// * [base] are circles / rounded squares icons shown in the 'background' on the map.
///   They follow the view of the map: in the 2D View (no Floor selected) they
///   show the POIs of every Floor, in the Floor View those of the selected Floor.
/// * [highlighted] are symbols appearing as 'pins' more in the 'foreground' on the map.
enum SBBRokasPoiLayer {
  base,
  highlighted;

  /// Alias of [base], which follows the view of the map rather than a Floor.
  @Deprecated('Use SBBRokasPoiLayer.base instead. Will be removed in v4.')
  static const SBBRokasPoiLayer baseWithFloor = base;
}
