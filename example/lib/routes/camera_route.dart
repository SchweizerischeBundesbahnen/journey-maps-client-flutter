import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

final _kCameraBern = SBBCameraUpdate.newLatLngZoom(const LatLng(46.947456, 7.451123), 14.0);
final _kCameraZurich = SBBCameraUpdate.newLatLngZoom(const LatLng(47.3769, 8.5417), 15.0);

/// Keeps the camera buttons clear of the map's attribution button in the
/// bottom right corner.
const _kCameraButtonsBottomPadding = 48.0;

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
    final mapStyler = SBBMapsMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return SBBMap(
      initialCameraPosition: const SBBCameraPosition(
        target: LatLng(46.947456, 7.451123), // Bern
        zoom: 8.0,
      ),
      mapStyler: mapStyler,
      isMyLocationEnabled: true,
      onMapCreated: (controller) => mapController.complete(controller),
      builder: (context) => Stack(
        children: [
          const Align(
            alignment: .topRight,
            child: Padding(
              padding: .only(top: SBBSpacing.medium, right: SBBSpacing.xSmall),
              child: Column(
                mainAxisSize: .min,
                spacing: SBBSpacing.small,
                children: [SBBMapStyleSwitcher(), SBBMapMyLocationButton()],
              ),
            ),
          ),
          Align(
            alignment: .bottomRight,
            child: SafeArea(
              child: Padding(
                padding: const .only(right: SBBSpacing.xSmall, bottom: _kCameraButtonsBottomPadding),
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .end,
                  spacing: SBBSpacing.small,
                  children: [
                    SBBTertiaryButtonSmall(labelText: 'Bern', onPressed: () => _moveCamera(_kCameraBern)),
                    SBBTertiaryButtonSmall(labelText: 'Zurich HB', onPressed: () => _moveCamera(_kCameraZurich)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveCamera(SBBCameraUpdate cameraUpdate) async {
    final controller = await mapController.future;
    await controller.animateCameraMove(cameraUpdate: cameraUpdate);
  }
}
