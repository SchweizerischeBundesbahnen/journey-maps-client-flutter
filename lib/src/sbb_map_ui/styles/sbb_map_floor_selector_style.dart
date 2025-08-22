import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_base_style.dart';

/// A style for the [SBBMapFloorSelector].
class SBBMapFloorSelectorStyle extends ThemeExtension<SBBMapFloorSelectorStyle> {
  SBBMapFloorSelectorStyle({
    this.selectedBackgroundColor,
    this.borderSide,
    this.backgroundColor,
    this.shadowColor,
    this.textColor,
    this.selectedTextColor,
    this.pressedColor,
  });

  factory SBBMapFloorSelectorStyle.$default({required SBBMapBaseStyle baseStyle}) {
    return SBBMapFloorSelectorStyle(
      selectedBackgroundColor: baseStyle.themeValue(SBBMapColors.charcoal, SBBMapColors.graphite),
      borderSide: baseStyle.themeValue(BorderSide.none, const BorderSide(color: SBBMapColors.metal)),
      backgroundColor: baseStyle.themeValue(SBBMapColors.white, SBBMapColors.black),
      shadowColor: SBBMapColors.cement,
      textColor: baseStyle.themeValue(SBBMapColors.black, SBBMapColors.white),
      selectedTextColor: baseStyle.themeValue(SBBMapColors.white, SBBMapColors.black),
      pressedColor: SBBMapColors.transparent,
    );
  }

  /// The background color of the selected floor.
  final Color? selectedBackgroundColor;

  /// The border side of the floor selector.
  final BorderSide? borderSide;

  /// The background color of the floor selector.
  final Color? backgroundColor;

  /// The shadow color of the floor selector.
  final Color? shadowColor;

  /// The text color of the floor selector.
  final Color? textColor;

  /// The text color of the selected floor.
  final Color? selectedTextColor;

  /// The color of the floor selector when pressed.
  ///
  /// This color corresponds to the color of the ink splash and highlight effect.
  final Color? pressedColor;

  @override
  SBBMapFloorSelectorStyle copyWith({
    Color? selectedBackgroundColor,
    BorderSide? borderSide,
    Color? backgroundColor,
    Color? shadowColor,
    Color? textColor,
    Color? selectedTextColor,
    Color? pressedColor,
  }) {
    return SBBMapFloorSelectorStyle(
      selectedBackgroundColor: selectedBackgroundColor ?? this.selectedBackgroundColor,
      borderSide: borderSide ?? this.borderSide,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      textColor: textColor ?? this.textColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      pressedColor: pressedColor ?? this.pressedColor,
    );
  }

  SBBMapFloorSelectorStyle merge(SBBMapFloorSelectorStyle? other) {
    if (other == null) return this;
    return copyWith(
      selectedBackgroundColor: other.selectedBackgroundColor,
      borderSide: other.borderSide,
      backgroundColor: other.backgroundColor,
      shadowColor: other.shadowColor,
      textColor: other.textColor,
      selectedTextColor: other.selectedTextColor,
      pressedColor: other.pressedColor,
    );
  }

  @override
  ThemeExtension<SBBMapFloorSelectorStyle> lerp(SBBMapFloorSelectorStyle? other, double t) {
    if (other == null) return this;
    return copyWith(
      selectedBackgroundColor: Color.lerp(selectedBackgroundColor, other.selectedBackgroundColor, t),
      borderSide: BorderSide.lerp(borderSide ?? BorderSide.none, other.borderSide ?? BorderSide.none, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      selectedTextColor: Color.lerp(selectedTextColor, other.selectedTextColor, t),
      pressedColor: Color.lerp(pressedColor, other.pressedColor, t),
    );
  }
}
