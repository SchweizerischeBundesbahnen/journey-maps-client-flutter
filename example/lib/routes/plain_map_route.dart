import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class PlainMapRoute extends StatelessWidget {
  const PlainMapRoute({super.key});
  @override
  Widget build(BuildContext context) {
    // Deliberately pinned to the deprecated styler: this is the only route left
    // on the Legacy Journey Maps styles, so that a regression on that path is
    // noticed before it is removed in the next major.
    // ignore: deprecated_member_use
    final mapStyler = SBBRokasMapStyler.noAerial(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(titleText: 'Plain'),
      body: SBBMap(mapStyler: mapStyler, isMyLocationEnabled: false, isFloorSwitchingEnabled: false),
    );
  }
}
