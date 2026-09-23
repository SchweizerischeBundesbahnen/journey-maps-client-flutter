/// Which floor switcher the [SBBMap] default UI renders.
enum SBBMapFloorSwitcherOrientation {
  /// A column of floor tiles, always expanded, pinned below the other map
  /// controls — [SBBMapVerticalFloorSwitcher].
  ///
  /// The default throughout 2.x.
  vertical,

  /// A collapsible pill that expands leftwards out of a single circular
  /// control — [SBBMapHorizontalFloorSwitcher].
  ///
  /// Becomes the default in 3.0.0.
  horizontal,
}
