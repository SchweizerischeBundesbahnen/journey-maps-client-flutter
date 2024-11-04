import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class PlainMapRoute extends StatelessWidget {
  const PlainMapRoute({super.key});
  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.noAerial(
      apiKey: Env.journeyMapsApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(title: 'Plain'),
      body: SBBMap(
        mapStyler: mapStyler,
        isMyLocationEnabled: false,
        isFloorSwitchingEnabled: false,
      ),
    );
  }
}
