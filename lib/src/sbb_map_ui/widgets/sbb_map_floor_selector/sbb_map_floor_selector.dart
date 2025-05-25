import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_selector/sbb_map_floor_selector_tile_builder.dart';

const _kFloorSelectorWidth = 48.0;

/// Only works in the [BuildContext] of the [SBBMap.uiControlsBuilder] method.
class SBBMapFloorSelector extends StatelessWidget {
  const SBBMapFloorSelector({super.key, this.style});

  final SBBMapFloorSelectorStyle? style;

  @override
  Widget build(BuildContext context) {
    final floorController = SBBMapUiContainer.of(context).mapFloorController;
    final style = _resolveStyleWithInherited(context);
    return ListenableBuilder(
      listenable: floorController,
      builder: (context, child) => floorController.availableFloors.isEmpty
          ? SizedBox.shrink()
          : SizedBox(
              width: _kFloorSelectorWidth,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: StadiumBorder(
                    side: style.borderSide ?? BorderSide.none,
                  ),
                ),
                position: DecorationPosition.foreground,
                child: FloorSelectorTilesBuilder(style: style),
              ),
            ),
    );
  }

  SBBMapFloorSelectorStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle = Theme.of(context).extension<SBBMapFloorSelectorStyle>()!;
    return inheritedStyle.merge(style);
  }
}
