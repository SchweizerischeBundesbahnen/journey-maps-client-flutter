import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class PlainMapRoute extends StatelessWidget {
  const PlainMapRoute({super.key});
  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBMapsMapStyler.noAerial(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return SBBMap(mapStyler: mapStyler, isMyLocationEnabled: false, isFloorSwitchingEnabled: false);
  }
}
