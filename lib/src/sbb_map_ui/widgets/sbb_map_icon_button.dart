// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_icon_button_style.dart';

const double _kElevation = 4;
const double _kButtonSize = 48;
const EdgeInsets _kButtonPadding = EdgeInsets.all(8.0);

/// A styled icon button that can be placed on the [SBBMap].
class SBBMapIconButton extends StatelessWidget {
  const SBBMapIconButton({
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
    SBBMapIconButtonStyle resolvedStyle = _resolveStyleWithInherited(context);

    return Material(
      shape: const CircleBorder(),
      elevation: _kElevation,
      shadowColor: resolvedStyle.shadowColor,
      child: Ink(
        decoration: ShapeDecoration(
          color: resolvedStyle.backgroundColor,
          shape: CircleBorder(
            side: resolvedStyle.borderSide ?? BorderSide.none,
          ),
        ),
        width: _kButtonSize,
        height: _kButtonSize,
        child: InkResponse(
          splashColor: resolvedStyle.pressedColor,
          highlightColor: resolvedStyle.pressedColor,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: _kButtonPadding,
            child: Icon(icon, color: resolvedStyle.iconColor),
          ),
        ),
      ),
    );
  }

  SBBMapIconButtonStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle = Theme.of(context).extension<SBBMapIconButtonStyle>()!;
    return inheritedStyle.merge(style);
  }
}
