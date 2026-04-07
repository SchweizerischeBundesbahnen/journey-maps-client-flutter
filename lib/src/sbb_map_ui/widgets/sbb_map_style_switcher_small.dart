// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_icon_button_small.dart';

/// A smaller (32 × 32) variant of [SBBMapStyleSwitcher].
///
/// Only works inside the [BuildContext] of [SBBMap.builder].
///
/// Toggles the aerial style of the map.
class SBBMapStyleSwitcherSmall extends StatelessWidget {
  const SBBMapStyleSwitcherSmall({super.key});

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBMapUiContainer.of(context).mapStyler;
    return ListenableBuilder(
      listenable: mapStyler,
      builder: (BuildContext context, Widget? child) => SBBMapIconButtonSmall(
        onPressed: () => mapStyler.toggleAerialStyle(),
        icon: SBBMapIcons.layers_small,
      ),
    );
  }
}
