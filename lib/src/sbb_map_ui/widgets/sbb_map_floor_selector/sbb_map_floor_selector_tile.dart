// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';

const _kFloorSelectorTileSize = Size(36, 36);
const _kFloorSelectorWidth = 48.0;
const _kElevation = 4.0;
const _kSelectedInnerContainerRadius = 8.0;
const _kSelectedInnerContainerPadding = EdgeInsets.all(6);
const _kAnimationDuration = Duration(milliseconds: 300);

class SBBMapFloorSelectorTile extends StatelessWidget {
  const SBBMapFloorSelectorTile({
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
    SBBMapFloorSelectorStyle resolvedStyle = _resolveStyleWithInherited(context);

    return Material(
      elevation: _kElevation,
      borderRadius: _determineFirstOrLastBorder(
        diameter: _kFloorSelectorWidth,
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
            height: _kFloorSelectorTileSize.height,
            width: _kFloorSelectorTileSize.width,
            decoration: BoxDecoration(
              borderRadius: _determineFirstOrLastBorder(
                diameter: _kFloorSelectorTileSize.width,
                defaultRadius: const Radius.circular(_kSelectedInnerContainerRadius),
              ),
              color: isSelected ? resolvedStyle.selectedBackgroundColor : resolvedStyle.backgroundColor,
            ),
            child: Center(
              child: Text(
                floor.toString(),
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
    final inheritedStyle = Theme.of(context).extension<SBBMapFloorSelectorStyle>()!;
    return inheritedStyle.merge(style);
  }
}
