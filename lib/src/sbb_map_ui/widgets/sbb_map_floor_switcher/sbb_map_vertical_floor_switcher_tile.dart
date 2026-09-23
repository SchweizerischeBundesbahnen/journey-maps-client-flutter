// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_floor_switcher/sbb_map_floor_label_builder.dart';

const _kFloorSwitcherTileSize = Size(36, 36);
const _kFloorSwitcherWidth = 44.0;
const _kElevation = 4.0;
const _kSelectedInnerContainerRadius = 8.0;
const _kSelectedInnerContainerPadding = EdgeInsets.all(6);
const _kAnimationDuration = Duration(milliseconds: 300);

class SBBMapVerticalFloorSwitcherTile extends StatelessWidget {
  const SBBMapVerticalFloorSwitcherTile({
    super.key,
    required this.floor,
    required this.floorLabelBuilder,
    required this.onPressed,
    this.isSelected = false,
    this.isLast = false,
    this.isFirst = false,
    this.style,
  });

  final int floor;
  final SBBMapFloorLabelBuilder floorLabelBuilder;
  final void Function() onPressed;
  final bool isSelected;
  final bool isLast;
  final bool isFirst;
  final SBBMapFloorSwitcherStyle? style;

  @override
  Widget build(BuildContext context) {
    SBBMapFloorSwitcherStyle resolvedStyle = _resolveStyleWithInherited(context);

    return Material(
      elevation: _kElevation,
      borderRadius: _determineFirstOrLastBorder(diameter: _kFloorSwitcherWidth, defaultRadius: Radius.zero),
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
            height: _kFloorSwitcherTileSize.height,
            width: _kFloorSwitcherTileSize.width,
            decoration: BoxDecoration(
              borderRadius: _determineFirstOrLastBorder(
                diameter: _kFloorSwitcherTileSize.width,
                defaultRadius: const Radius.circular(_kSelectedInnerContainerRadius),
              ),
              color: isSelected ? resolvedStyle.selectedBackgroundColor : resolvedStyle.backgroundColor,
            ),
            child: Center(
              child: Text(
                floorLabelBuilder(floor),
                style: SBBMapTextStyles.mediumLight.copyWith(
                  color: isSelected ? resolvedStyle.selectedTextColor : resolvedStyle.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// enables drawing the first and last tile with a rounded border
  BorderRadius _determineFirstOrLastBorder({required double diameter, required Radius defaultRadius}) {
    if (isFirst) {
      return BorderRadius.vertical(top: Radius.circular(diameter / 2), bottom: defaultRadius);
    } else if (isLast) {
      return BorderRadius.vertical(top: defaultRadius, bottom: Radius.circular(diameter / 2));
    } else {
      return BorderRadius.all(defaultRadius);
    }
  }

  SBBMapFloorSwitcherStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle = Theme.of(context).extension<SBBMapFloorSwitcherStyle>()!;
    return inheritedStyle.merge(style);
  }
}
