import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/horizontal_floor_switcher_body.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_floor_label_builder.dart';

/// A horizontal, collapsible floor switcher.
///
/// Only works in the [BuildContext] of the [SBBMap.builder] method.
///
/// Collapsed it is a single 44 px circle, the size of the other map buttons.
/// Tapping it expands a stadium-shaped pill leftwards, revealing the available
/// floors in a row with a close icon where the circle was. Picking a floor
/// switches to it and collapses again; picking the floor that is already
/// current deselects it, resetting the map to its default floor.
///
/// While collapsed the control shows the current floor, or a floors icon when
/// none is selected. It always starts collapsed, and renders nothing where the
/// map has no indoor data.
///
/// See [SBBMapHorizontalFloorSwitcherSmall] for the compact 32 px variant, and
/// [SBBMapVerticalFloorSwitcher] for the vertical one.
class SBBMapHorizontalFloorSwitcher extends StatelessWidget {
  const SBBMapHorizontalFloorSwitcher({super.key, this.floorLabelBuilder, this.style});

  /// Maps a floor to the label shown for it.
  ///
  /// Defaults to [defaultFloorLabel], the floor's integer string form.
  final SBBMapFloorLabelBuilder? floorLabelBuilder;

  final SBBMapFloorSwitcherStyle? style;

  @override
  Widget build(BuildContext context) {
    return HorizontalFloorSwitcherBody(
      metrics: HorizontalFloorSwitcherMetrics.standard,
      floorLabelBuilder: floorLabelBuilder ?? defaultFloorLabel,
      style: style,
    );
  }
}
