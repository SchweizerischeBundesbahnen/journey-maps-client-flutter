import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

final _kCameraZurich = SBBCameraUpdate.newLatLngZoom(const LatLng(47.3769, 8.5417), 15.0);

class TrackDeviceLocationRoute extends StatefulWidget {
  const TrackDeviceLocationRoute({super.key});

  @override
  State<TrackDeviceLocationRoute> createState() => _TrackDeviceLocationRouteState();
}

class _TrackDeviceLocationRouteState extends State<TrackDeviceLocationRoute> {
  late SBBMapController controller;

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(title: 'Track Device'),
      body: SBBMap(
        isMyLocationEnabled: true,
        mapStyler: mapStyler,
        onMapLocatorAvailable: (locator) => locator.trackDeviceLocation(),
        onMapCreated: (c) => controller = c,
        builder: (context) => Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: sbbDefaultSpacing,
              right: sbbDefaultSpacing / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SBBMapMyLocationButton(),
                const SizedBox(height: sbbDefaultSpacing),
                SBBMapIconButton(
                  onPressed: () => controller.animateCameraMove(cameraUpdate: _kCameraZurich),
                  icon: SBBIcons.station_small,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
