import 'package:flutter/material.dart';

/// A base style that is used to resolve theme values based on the
/// current brightness of the theme.
class SBBMapBaseStyle {
  SBBMapBaseStyle({this.brightness});

  final Brightness? brightness;

  T themeValue<T>(T lightThemeValue, T darkThemeValue) =>
      resolve(brightness == Brightness.light, lightThemeValue, darkThemeValue);

  static T resolve<T>(bool isLight, T lightThemeValue, T darkThemeValue) => isLight ? lightThemeValue : darkThemeValue;
}
