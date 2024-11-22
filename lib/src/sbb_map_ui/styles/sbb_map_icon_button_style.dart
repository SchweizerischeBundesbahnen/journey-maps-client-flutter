import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_base_style.dart';

/// A style for the [SBBMapIconButton].
class SBBMapIconButtonStyle extends ThemeExtension<SBBMapIconButtonStyle> {
  SBBMapIconButtonStyle({
    this.iconColor,
    this.borderSide,
    this.backgroundColor,
    this.shadowColor,
    this.pressedColor,
  });

  factory SBBMapIconButtonStyle.$default({
    required SBBMapBaseStyle baseStyle,
  }) {
    return SBBMapIconButtonStyle(
      iconColor: baseStyle.themeValue(SBBMapColors.black, SBBMapColors.white),
      borderSide: baseStyle.themeValue(BorderSide.none, const BorderSide(color: SBBMapColors.metal)),
      backgroundColor: baseStyle.themeValue(SBBMapColors.white, SBBMapColors.black),
      shadowColor: SBBMapColors.cement,
      pressedColor: baseStyle.themeValue(SBBMapColors.cloud, SBBMapColors.iron),
    );
  }

  /// The color of the icon.
  final Color? iconColor;

  /// The border side of the icon button.
  final BorderSide? borderSide;

  /// The background color of the icon button.
  final Color? backgroundColor;

  /// The shadow color of the icon button.
  final Color? shadowColor;

  /// The color of the icon button when pressed.
  final Color? pressedColor;

  @override
  SBBMapIconButtonStyle copyWith({
    Color? iconColor,
    BorderSide? borderSide,
    Color? backgroundColor,
    Color? shadowColor,
    Color? pressedColor,
  }) {
    return SBBMapIconButtonStyle(
      iconColor: iconColor ?? this.iconColor,
      borderSide: borderSide ?? this.borderSide,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      pressedColor: pressedColor ?? this.pressedColor,
    );
  }

  SBBMapIconButtonStyle merge(SBBMapIconButtonStyle? other) {
    if (other == null) return this;
    return copyWith(
      iconColor: other.iconColor,
      borderSide: other.borderSide,
      backgroundColor: other.backgroundColor,
      shadowColor: other.shadowColor,
      pressedColor: other.pressedColor,
    );
  }

  @override
  ThemeExtension<SBBMapIconButtonStyle> lerp(SBBMapIconButtonStyle? other, double t) {
    if (other == null) return this;
    return copyWith(
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      borderSide: BorderSide.lerp(borderSide ?? BorderSide.none, other.borderSide ?? BorderSide.none, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      pressedColor: Color.lerp(pressedColor, other.pressedColor, t),
    );
  }
}
