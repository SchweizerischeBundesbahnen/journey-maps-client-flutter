import 'dart:async';

import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class POIRoute extends StatefulWidget {
  const POIRoute({super.key});

  @override
  State<POIRoute> createState() => _POIRouteState();
}

class _POIRouteState extends State<POIRoute> {
  final Completer<SBBRokasPOIController> _poiController = Completer();

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(title: 'POI'),
      body: SBBMap(
        initialCameraPosition: const SBBCameraPosition(
          target: LatLng(46.947456, 7.451123), // Bern
          zoom: 15.0,
        ),
        isMyLocationEnabled: true,
        mapStyler: mapStyler,
        poiSettings: SBBMapPOISettings(
          isPointOfInterestVisible: true,
          onPoiControllerAvailable: (poiController) =>
              !_poiController.isCompleted ? _poiController.complete(poiController) : null,
          onPoiSelected: (poi) => showSBBModalSheet(
            context: context,
            title: poi.name,
            child: const SizedBox(height: 64),
          ).then(
            (_) => _poiController.future.then(
              (c) => c.deselectPointOfInterest(),
            ),
          ),
        ),
      ),
    );
  }
}
