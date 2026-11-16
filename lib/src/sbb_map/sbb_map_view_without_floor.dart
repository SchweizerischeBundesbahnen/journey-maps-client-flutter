/// What an `SBBMap` shows while no Floor is selected.
///
/// The SBB Maps styles draw a station in one of two ways. The 2D View shows the
/// floor-independent layers: tunnels, underground passages, labels, platform
/// numbers and the base POIs of every Floor at once. The Floor View shows the
/// floor-dependent layers of one Floor. Selecting a Floor always switches to the
/// Floor View; this enum decides the rendering while no Floor is selected.
enum SBBMapViewWithoutFloor {
  /// The 2D View, as sbb.ch renders a station: the features of every Floor at
  /// once. The default.
  twoD,

  /// The Floor View at Floor 0. [SBBMapFloorController.currentFloor] stays
  /// `null` and the 2D View is unreachable.
  floorZero,
}
