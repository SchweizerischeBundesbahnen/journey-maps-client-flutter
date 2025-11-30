import 'dart:async';

import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

final _kCameraBern = SBBCameraUpdate.newLatLngZoom(const LatLng(46.947456, 7.451123), 14.0);
final _kCameraZurich = SBBCameraUpdate.newLatLngZoom(const LatLng(47.3769, 8.5417), 15.0);

class CameraRoute extends StatefulWidget {
  const CameraRoute({super.key});

  @override
  State<CameraRoute> createState() => _CameraRouteState();
}

class _CameraRouteState extends State<CameraRoute> {
  final Completer<SBBMapController> mapController = Completer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(title: 'Camera'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SBBMap(
                initialCameraPosition: const SBBCameraPosition(
                  target: LatLng(46.947456, 7.451123), // Bern
                  zoom: 8.0,
                ),
                mapStyler: mapStyler,
                isMyLocationEnabled: true,
                onMapCreated: (controller) => mapController.complete(controller),
              ),
            ),
            SBBGroup(
              padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing / 2, vertical: sbbDefaultSpacing / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SBBTertiaryButtonSmall(
                    label: 'Bern',
                    icon: SBBIcons.house_small,
                    onPressed: () => mapController.future.then((c) => c.animateCameraMove(cameraUpdate: _kCameraBern)),
                  ),
                  SBBTertiaryButtonSmall(
                    label: 'Zurich',
                    icon: SBBIcons.station_small,
                    onPressed: () =>
                        mapController.future.then((c) => c.animateCameraMove(cameraUpdate: _kCameraZurich)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
