import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/horizontal_floor_switcher_body.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_floor_label_builder.dart';

/// A smaller (32 px high) variant of [SBBMapHorizontalFloorSwitcher], matching
/// the compact map controls.
///
/// Only works in the [BuildContext] of the [SBBMap.builder] method.
///
/// Behaves exactly like [SBBMapHorizontalFloorSwitcher]; see there for the
/// interaction.
class SBBMapHorizontalFloorSwitcherSmall extends StatelessWidget {
  const SBBMapHorizontalFloorSwitcherSmall({super.key, this.floorLabelBuilder, this.style});

  /// Maps a floor to the label shown for it.
  ///
  /// Defaults to [defaultFloorLabel], the floor's integer string form.
  final SBBMapFloorLabelBuilder? floorLabelBuilder;

  final SBBMapFloorSwitcherStyle? style;

  @override
  Widget build(BuildContext context) {
    return HorizontalFloorSwitcherBody(
      metrics: HorizontalFloorSwitcherMetrics.compact,
      floorLabelBuilder: floorLabelBuilder ?? defaultFloorLabel,
      style: style,
    );
  }
}
