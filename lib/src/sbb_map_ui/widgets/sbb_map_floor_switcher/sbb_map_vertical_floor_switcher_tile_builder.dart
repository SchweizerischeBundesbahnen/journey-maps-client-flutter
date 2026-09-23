// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_floor_label_builder.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_vertical_floor_switcher_tile.dart';

class VerticalFloorSwitcherTilesBuilder extends StatelessWidget {
  const VerticalFloorSwitcherTilesBuilder({super.key, required this.floorLabelBuilder, this.style});

  final SBBMapFloorLabelBuilder floorLabelBuilder;
  final SBBMapFloorSwitcherStyle? style;

  @override
  Widget build(BuildContext context) {
    final uiContainer = SBBMapUiContainer.of(context);
    final mapFloorController = uiContainer.mapFloorController;

    final tiles = <Widget>[];
    for (var i = 0; i < mapFloorController.availableFloors.length; i++) {
      final tileFloor = mapFloorController.availableFloors[i];
      if (i > 0) tiles.add(const Divider());
      tiles.add(
        SBBMapVerticalFloorSwitcherTile(
          floor: tileFloor,
          floorLabelBuilder: floorLabelBuilder,
          onPressed: () => _toggleSelectedFloor(
            tileFloor,
            mapFloorController.currentFloor,
            (int? floor) => mapFloorController.switchFloor(floor),
          ),
          isSelected: mapFloorController.currentFloor == null
              ? false
              : mapFloorController.currentFloor == mapFloorController.availableFloors[i],
          isFirst: i == 0 && mapFloorController.availableFloors.length > 1,
          isLast: i == mapFloorController.availableFloors.length - 1 && mapFloorController.availableFloors.length > 1,
          style: style,
        ),
      );
    }
    return Column(mainAxisSize: .min, children: tiles);
  }

  void _toggleSelectedFloor(int tileFloor, int? selectedFloor, Future<void> Function(int? floor) onFloorSelected) {
    if (selectedFloor == tileFloor) {
      onFloorSelected(null);
    } else {
      onFloorSelected(tileFloor);
    }
  }
}
