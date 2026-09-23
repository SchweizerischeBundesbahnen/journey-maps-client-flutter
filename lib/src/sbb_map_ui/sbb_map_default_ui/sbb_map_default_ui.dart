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
    this.floorSwitcherOrientation = SBBMapFloorSwitcherOrientation.vertical,
    this.smallControls = false,
  });

  final bool locationEnabled;
  final bool isFloorSwitchingEnabled;

  /// Which of the two floor switchers to render.
  final SBBMapFloorSwitcherOrientation floorSwitcherOrientation;

  /// When `true`, renders the compact 32 × 32 px variants of each control.
  final bool smallControls;

  bool get _isHorizontal => floorSwitcherOrientation == SBBMapFloorSwitcherOrientation.horizontal;

  @override
  Widget build(BuildContext context) {
    final uiContainer = SBBMapUiContainer.of(context);

    final bool showStyleSwitcher = uiContainer.mapStyler.getStyleIds().length > 1;
    final bool showStyleSwitcherAndMyLocation = showStyleSwitcher && locationEnabled;
    final bool showFloorSwitcher = isFloorSwitchingEnabled && uiContainer.mapFloorController.availableFloors.isNotEmpty;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: _kActionButtonPadding,
        child: Column(
          crossAxisAlignment: .end,
          children: [
            if (showStyleSwitcher) smallControls ? const SBBMapStyleSwitcherSmall() : const SBBMapStyleSwitcher(),
            if (showStyleSwitcherAndMyLocation) const SizedBox(height: 12.0),
            if (locationEnabled) smallControls ? const SBBMapMyLocationButtonSmall() : const SBBMapMyLocationButton(),
            if (showFloorSwitcher) SizedBox(height: _heightDependingOnLayout()),
            if (showFloorSwitcher) _floorSwitcher(),
          ],
        ),
      ),
    );
  }

  double _heightDependingOnLayout() {
    if (smallControls) return _isHorizontal ? 12.0 : 36.0;

    return _isHorizontal ? 16.0 : 54.0;
  }

  Widget _floorSwitcher() => switch ((floorSwitcherOrientation, smallControls)) {
    (.vertical, false) => const SBBMapVerticalFloorSwitcher(),
    (.vertical, true) => const SBBMapVerticalFloorSwitcherSmall(),
    (.horizontal, false) => const SBBMapHorizontalFloorSwitcher(),
    (.horizontal, true) => const SBBMapHorizontalFloorSwitcherSmall(),
  };
}
