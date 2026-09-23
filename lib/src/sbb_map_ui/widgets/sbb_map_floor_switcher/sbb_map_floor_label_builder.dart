/// Maps a floor to the label a floor switcher shows for it.
///
/// This package ships no localization and holds no opinion about floor naming:
/// supply a builder to show `EG` and `UG` to Swiss travellers, or whatever your
/// own localization pipeline produces, including for negative floors.
///
/// Defaults to [defaultFloorLabel] on every floor switcher.
typedef SBBMapFloorLabelBuilder = String Function(int floor);

/// The default [SBBMapFloorLabelBuilder]: the floor's integer string form.
String defaultFloorLabel(int floor) => floor.toString();
