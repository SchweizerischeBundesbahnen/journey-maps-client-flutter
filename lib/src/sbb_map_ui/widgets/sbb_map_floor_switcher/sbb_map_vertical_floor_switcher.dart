// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_floor_label_builder.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_vertical_floor_switcher_tile_builder.dart';

const _kFloorSwitcherWidth = 44.0;

/// Only works in the [BuildContext] of the [SBBMap.uiControlsBuilder] method.
class SBBMapVerticalFloorSwitcher extends StatelessWidget {
  const SBBMapVerticalFloorSwitcher({super.key, this.floorLabelBuilder, this.style});

  /// Maps a floor to the label shown for it.
  ///
  /// Defaults to [defaultFloorLabel], the floor's integer string form.
  final SBBMapFloorLabelBuilder? floorLabelBuilder;

  final SBBMapFloorSwitcherStyle? style;

  @override
  Widget build(BuildContext context) {
    final floorController = SBBMapUiContainer.of(context).mapFloorController;
    final style = _resolveStyleWithInherited(context);
    return ListenableBuilder(
      listenable: floorController,
      builder: (context, child) => floorController.availableFloors.isEmpty
          ? SizedBox.shrink()
          : SizedBox(
              width: _kFloorSwitcherWidth,
              child: DecoratedBox(
                decoration: ShapeDecoration(shape: StadiumBorder(side: style.borderSide ?? BorderSide.none)),
                position: .foreground,
                child: VerticalFloorSwitcherTilesBuilder(
                  floorLabelBuilder: floorLabelBuilder ?? defaultFloorLabel,
                  style: style,
                ),
              ),
            ),
    );
  }

  SBBMapFloorSwitcherStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle = Theme.of(context).extension<SBBMapFloorSwitcherStyle>()!;
    return inheritedStyle.merge(style);
  }
}

/// The former name of [SBBMapVerticalFloorSwitcher].
@Deprecated(
  'Use SBBMapVerticalFloorSwitcher instead. Deprecated after 2.8.2. Will be removed in 3.0.0.',
)
typedef SBBMapFloorSelector = SBBMapVerticalFloorSwitcher;
