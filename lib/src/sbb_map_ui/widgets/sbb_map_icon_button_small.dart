// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_icon_button_style.dart';

const double _kElevation = 4;

/// The fixed size of the small map icon button (32 × 32 logical pixels).
const double kSmallButtonSize = 32.0;

/// A smaller (32 × 32) variant of [SBBMapIconButton] that can be placed on
/// the [SBBMap].
///
/// Shares the same [SBBMapIconButtonStyle] as [SBBMapIconButton] so it
/// picks up theme colors automatically.
class SBBMapIconButtonSmall extends StatelessWidget {
  const SBBMapIconButtonSmall({
    super.key,
    required this.onPressed,
    required this.icon,
    this.style,
  });

  final void Function() onPressed;
  final IconData icon;
  final SBBMapIconButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = _resolveStyleWithInherited(context);

    return Material(
      shape: const CircleBorder(),
      elevation: _kElevation,
      shadowColor: resolvedStyle.shadowColor,
      child: Ink(
        decoration: ShapeDecoration(
          color: resolvedStyle.backgroundColor,
          shape: CircleBorder(side: resolvedStyle.borderSide ?? BorderSide.none),
        ),
        width: kSmallButtonSize,
        height: kSmallButtonSize,
        child: InkResponse(
          splashColor: resolvedStyle.pressedColor,
          highlightColor: resolvedStyle.pressedColor,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(child: Icon(icon, color: resolvedStyle.iconColor, size: 24.0)),
        ),
      ),
    );
  }

  SBBMapIconButtonStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle = Theme.of(context).extension<SBBMapIconButtonStyle>()!;
    return inheritedStyle.merge(style);
  }
}
