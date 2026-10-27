/// Which floor switcher the [SBBMap] default UI renders.
enum SBBMapFloorSwitcherOrientation {
  /// A column of floor tiles, always expanded, pinned below the other map
  /// controls — [SBBMapVerticalFloorSwitcher].
  vertical,

  /// A collapsible pill that expands leftwards out of a single circular
  /// control — [SBBMapHorizontalFloorSwitcher].
  ///
  /// The default.
  horizontal,
}
