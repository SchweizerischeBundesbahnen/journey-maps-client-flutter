// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';

const _kActionButtonPadding = EdgeInsets.fromLTRB(0, 16, 8, 0);

class SBBMapDefaultUI extends StatelessWidget {
  const SBBMapDefaultUI({super.key, required this.locationEnabled, required this.isFloorSwitchingEnabled});

  final bool locationEnabled;
  final bool isFloorSwitchingEnabled;

  @override
  Widget build(BuildContext context) {
    final uiContainer = SBBMapUiContainer.of(context);

    bool showStyleSwitcher = uiContainer.mapStyler.getStyleIds().length > 1;
    bool showStyleSwitcherAndMyLocation = showStyleSwitcher && locationEnabled;
    bool showFloorSelector = isFloorSwitchingEnabled && uiContainer.mapFloorController.availableFloors.isNotEmpty;
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: _kActionButtonPadding,
        child: Column(
          children: [
            if (showStyleSwitcher) const SBBMapStyleSwitcher(),
            if (showStyleSwitcherAndMyLocation) const SizedBox(height: 12),
            if (locationEnabled) const SBBMapMyLocationButton(),
            if (showFloorSelector) const SizedBox(height: 54),
            if (showFloorSelector) const SBBMapFloorSelector(),
          ],
        ),
      ),
    );
  }
}
