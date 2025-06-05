// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_icon_button.dart';

/// Only works in the [BuildContext] of the [SBBMap.uiControlsBuilder] method.
///
/// Triggers the tracking of the device location.
class SBBMapMyLocationButton extends StatelessWidget {
  const SBBMapMyLocationButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uiContainer = SBBMapUiContainer.of(context);
    final mapLocator = uiContainer.mapLocator;

    return ListenableBuilder(
      listenable: mapLocator,
      builder: (BuildContext context, Widget? child) {
        return SBBMapIconButton(
          onPressed: () => mapLocator.trackDeviceLocation(),
          icon: _filledIconIf(mapLocator.isTracking),
        );
      },
    );
  }

  IconData _filledIconIf(bool isTracking) {
    return isTracking ? SBBMapIcons.arrow_compass_filled_small : SBBMapIcons.arrow_compass_small;
  }
}
