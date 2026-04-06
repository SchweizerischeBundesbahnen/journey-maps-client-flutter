// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';

/// The fixed width of the small floor selector (32 logical pixels).
const double kSmallFloorSelectorWidth = 32.0;
const Size _kSmallTileSize = Size(24, 24);
const double _kElevation = 4.0;
const double _kSelectedInnerContainerRadius = 6.0;
const EdgeInsets _kSelectedInnerContainerPadding = EdgeInsets.all(4);
const _kAnimationDuration = Duration(milliseconds: 300);

/// A smaller (32 px wide) tile used inside [SBBMapFloorSelectorSmall].
class SBBMapFloorSelectorTileSmall extends StatelessWidget {
  const SBBMapFloorSelectorTileSmall({
    super.key,
    required this.floor,
    required this.onPressed,
    this.isSelected = false,
    this.isLast = false,
    this.isFirst = false,
    this.style,
  });

  final int floor;
  final void Function() onPressed;
  final bool isSelected;
  final bool isLast;
  final bool isFirst;
  final SBBMapFloorSelectorStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = _resolveStyleWithInherited(context);

    return Material(
      elevation: _kElevation,
      borderRadius: _determineFirstOrLastBorder(
        diameter: kSmallFloorSelectorWidth,
        defaultRadius: Radius.zero,
      ),
      shadowColor: resolvedStyle.shadowColor,
      color: resolvedStyle.backgroundColor,
      child: InkResponse(
        containedInkWell: true,
        highlightColor: resolvedStyle.pressedColor,
        splashColor: resolvedStyle.pressedColor,
        onTap: onPressed,
        child: Padding(
          padding: _kSelectedInnerContainerPadding,
          child: AnimatedContainer(
            duration: _kAnimationDuration,
            height: _kSmallTileSize.height,
            width: _kSmallTileSize.width,
            decoration: BoxDecoration(
              borderRadius: _determineFirstOrLastBorder(
                diameter: _kSmallTileSize.width,
                defaultRadius: const Radius.circular(_kSelectedInnerContainerRadius),
              ),
              color: isSelected
                  ? resolvedStyle.selectedBackgroundColor
                  : resolvedStyle.backgroundColor,
            ),
            child: Center(
              child: Text(
                floor.toString(),
                style: SBBMapTextStyles.extraSmallLight.copyWith(
                  color: isSelected
                      ? resolvedStyle.selectedTextColor
                      : resolvedStyle.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius _determineFirstOrLastBorder({
    required double diameter,
    required Radius defaultRadius,
  }) {
    if (isFirst) {
      return BorderRadius.vertical(
        top: Radius.circular(diameter / 2),
        bottom: defaultRadius,
      );
    } else if (isLast) {
      return BorderRadius.vertical(
        top: defaultRadius,
        bottom: Radius.circular(diameter / 2),
      );
    } else {
      return BorderRadius.all(defaultRadius);
    }
  }

  SBBMapFloorSelectorStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle =
        Theme.of(context).extension<SBBMapFloorSelectorStyle>()!;
    return inheritedStyle.merge(style);
  }
}

/// Thin divider between tiles in the small floor selector.
class _SmallDivider extends StatelessWidget {
  const _SmallDivider();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SBBMapUiContainer.of(context).mapStyler.isDarkMode;
    return Container(
      constraints: const BoxConstraints(maxWidth: kSmallFloorSelectorWidth),
      height: 1.0,
      color: isDarkMode ? SBBMapColors.metal : SBBMapColors.cement,
    );
  }
}

/// Builds the column of [SBBMapFloorSelectorTileSmall] widgets.
class _SmallFloorSelectorTilesBuilder extends StatelessWidget {
  const _SmallFloorSelectorTilesBuilder({this.style});

  final SBBMapFloorSelectorStyle? style;

  @override
  Widget build(BuildContext context) {
    final mapFloorController =
        SBBMapUiContainer.of(context).mapFloorController;

    final tiles = <Widget>[];
    for (var i = 0; i < mapFloorController.availableFloors.length; i++) {
      final tileFloor = mapFloorController.availableFloors[i];
      if (i > 0) tiles.add(const _SmallDivider());
      tiles.add(
        SBBMapFloorSelectorTileSmall(
          floor: tileFloor,
          onPressed: () => _toggleSelectedFloor(
            tileFloor,
            mapFloorController.currentFloor,
            mapFloorController.switchFloor,
          ),
          isSelected: mapFloorController.currentFloor == tileFloor,
          isFirst: i == 0 && mapFloorController.availableFloors.length > 1,
          isLast: i == mapFloorController.availableFloors.length - 1 &&
              mapFloorController.availableFloors.length > 1,
          style: style,
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: tiles);
  }

  void _toggleSelectedFloor(
    int tileFloor,
    int? selectedFloor,
    Future<void> Function(int?) onFloorSelected,
  ) {
    onFloorSelected(selectedFloor == tileFloor ? null : tileFloor);
  }
}

/// A smaller (32 px wide) variant of [SBBMapFloorSelector].
///
/// Only works inside the [BuildContext] of [SBBMap.builder].
///
/// The maximum width of this widget is constrained to 32 logical pixels.
class SBBMapFloorSelectorSmall extends StatelessWidget {
  const SBBMapFloorSelectorSmall({super.key, this.style});

  final SBBMapFloorSelectorStyle? style;

  @override
  Widget build(BuildContext context) {
    final floorController =
        SBBMapUiContainer.of(context).mapFloorController;
    final resolvedStyle = _resolveStyleWithInherited(context);

    return ListenableBuilder(
      listenable: floorController,
      builder: (context, child) => floorController.availableFloors.isEmpty
          ? const SizedBox.shrink()
          : SizedBox(
              width: kSmallFloorSelectorWidth,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: StadiumBorder(
                    side: resolvedStyle.borderSide ?? BorderSide.none,
                  ),
                ),
                position: DecorationPosition.foreground,
                child: _SmallFloorSelectorTilesBuilder(style: resolvedStyle),
              ),
            ),
    );
  }

  SBBMapFloorSelectorStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle =
        Theme.of(context).extension<SBBMapFloorSelectorStyle>()!;
    return inheritedStyle.merge(style);
  }
}

