import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// Holds [SBBMapStyle]s and notifies listeners when the style changes.
///
/// The [SBBMap] listens to its [SBBMapStyler] and updates the style accordingly.
abstract class SBBMapStyler with ChangeNotifier {
  /// Switch to the style with the given [styleId].
  ///
  /// Quietly fails if the style is not registered
  /// or [styleId] is the same as the current one.
  ///
  /// If [aerialStyle] is defined, [styleId] can be the id of the aerial style.
  /// In that case, the [aerialStyle] will be toggled.
  ///
  /// This notifies all listeners of the style change.
  /// The [SBBMap] will listen to this and update the style.
  void switchStyle(String styleId);

  /// Toggles between the dark and bright mode of [currentStyle].
  ///
  /// Some [SBBMapStyle]s do not support dark mode (e.g. `journey_maps_aerial_v1`).
  /// In that case, there will be no visual change in the map.
  /// The [SBBMapStyler] however will be in dark mode, meaning [switchStyle] will
  /// switch to the dark mode of the style.
  void toggleDarkMode();

  /// Toggles the aerial style if an aerial style is defined.
  ///
  /// If no aerial style is defined, this will do nothing.
  ///
  /// Will resume the previous style if called again.
  void toggleAerialStyle();

  /// Returns the ids of registered styles.
  List<String> getStyleIds();

  /// Returns the current style URI.
  String get currentStyleURI;

  /// Whether the current style is dark.
  bool get isDarkMode;

  /// Whether the current style is the one defined as aerial in this styler.
  ///
  /// If no aerial style is defined, this will always return false.
  bool get isAerialStyle;
}
