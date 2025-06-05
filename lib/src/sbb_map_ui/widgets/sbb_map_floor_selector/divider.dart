// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';

const _kFloorSelectorWidth = 48.0;
const _kFloorSelectorDividerHeight = 1.0;

class Divider extends StatelessWidget {
  const Divider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SBBMapUiContainer.of(context).mapStyler.isDarkMode;
    return Container(
      constraints: const BoxConstraints(maxWidth: _kFloorSelectorWidth),
      height: _kFloorSelectorDividerHeight,
      color: isDarkMode ? SBBMapColors.metal : SBBMapColors.cement,
    );
  }
}
