// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';

const _kActionButtonPadding = EdgeInsets.fromLTRB(0, 16, 8, 0);

class SBBMapDefaultUI extends StatelessWidget {
  const SBBMapDefaultUI({
    super.key,
    required this.locationEnabled,
    required this.isFloorSwitchingEnabled,
    this.smallControls = false,
  });

  final bool locationEnabled;
  final bool isFloorSwitchingEnabled;

  /// When `true`, renders the compact 32 × 32 px variants of each control.
  final bool smallControls;

  @override
  Widget build(BuildContext context) {
    final uiContainer = SBBMapUiContainer.of(context);

    final bool showStyleSwitcher = uiContainer.mapStyler.getStyleIds().length > 1;
    final bool showStyleSwitcherAndMyLocation = showStyleSwitcher && locationEnabled;
    final bool showFloorSelector = isFloorSwitchingEnabled && uiContainer.mapFloorController.availableFloors.isNotEmpty;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: _kActionButtonPadding,
        child: Column(
          children: [
            if (showStyleSwitcher) smallControls ? const SBBMapStyleSwitcherSmall() : const SBBMapStyleSwitcher(),
            if (showStyleSwitcherAndMyLocation) SizedBox(height: 12.0),
            if (locationEnabled) smallControls ? const SBBMapMyLocationButtonSmall() : const SBBMapMyLocationButton(),
            if (showFloorSelector) SizedBox(height: smallControls ? 36.0 : 54.0),
            if (showFloorSelector) smallControls ? const SBBMapFloorSelectorSmall() : const SBBMapFloorSelector(),
          ],
        ),
      ),
    );
  }
}
