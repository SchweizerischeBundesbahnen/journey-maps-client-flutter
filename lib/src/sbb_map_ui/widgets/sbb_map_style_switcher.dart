// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/widgets/sbb_map_icon_button.dart';

/// Only works in the [BuildContext] of the [SBBMap.uiControlsBuilder] method.
class SBBMapStyleSwitcher extends StatelessWidget {
  const SBBMapStyleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBMapUiContainer.of(context).mapStyler;
    return ListenableBuilder(
      listenable: mapStyler,
      builder: (BuildContext context, Widget? child) => SBBMapIconButton(
        onPressed: () => mapStyler.toggleAerialStyle(),
        icon: SBBMapIcons.layers_small,
      ),
    );
  }
}
