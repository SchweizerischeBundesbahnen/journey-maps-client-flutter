// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// The [SBBMapUiContainer] is an [InheritedWidget] that provides the
/// [SBBMapStyler], [SBBMapLocator] and [SBBMapFloorController] to the
/// * [SBBMapMyLocationButton]
/// * [SBBMapFloorSelector]
/// * [SBBMapStyleSwitcher]
///
/// and all other widgets that are used in the [SBBMap.uiControlsBuilder] method.
class SBBMapUiContainer extends InheritedWidget {
  const SBBMapUiContainer({
    super.key,
    required this.mapStyler,
    required this.mapLocator,
    required this.mapFloorController,
    required super.child,
  });

  final SBBMapLocator mapLocator;
  final SBBMapStyler mapStyler;
  final SBBMapFloorController mapFloorController;

  static SBBMapUiContainer? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SBBMapUiContainer>();
  }

  static SBBMapUiContainer of(BuildContext context) {
    final SBBMapUiContainer? result = maybeOf(context);
    assert(result != null, 'No SBBMapUiContainer found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SBBMapUiContainer oldWidget) =>
      mapStyler != oldWidget.mapStyler ||
      mapLocator != oldWidget.mapLocator ||
      mapFloorController != oldWidget.mapFloorController;
}
