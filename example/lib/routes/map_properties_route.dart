import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class MapPropertiesRoute extends StatefulWidget {
  const MapPropertiesRoute({super.key});

  @override
  State<MapPropertiesRoute> createState() => _MapPropertiesRouteState();
}

class _MapPropertiesRouteState extends State<MapPropertiesRoute> {
  SBBMapProperties properties = const SBBMapProperties();

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );

    return Scaffold(
      appBar: const SBBHeader(title: 'Map Properties'),
      body: SBBMap(
        mapStyler: mapStyler,
        isMyLocationEnabled: false,
        isFloorSwitchingEnabled: true,
        properties: properties,
        builder: (context) => Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(sbbDefaultSpacing),
            child: SBBMapIconButton(
              onPressed: () {
                showSBBModalSheet<SBBMapProperties>(
                  context: context,
                  title: 'Map Properties',
                  child: _MapPropertiesModalBody(properties: properties),
                ).then(_setStateWithProperties);
              },
              icon: SBBIcons.gears_small,
            ),
          ),
        ),
      ),
    );
  }

  void _setStateWithProperties(SBBMapProperties? properties) {
    setState(() {
      if (properties != null) {
        this.properties = properties;
      }
    });
  }
}

class _MapPropertiesModalBody extends StatefulWidget {
  const _MapPropertiesModalBody({required this.properties});

  final SBBMapProperties properties;

  @override
  State<_MapPropertiesModalBody> createState() => _MapPropertiesModalBodyState();
}

class _MapPropertiesModalBodyState extends State<_MapPropertiesModalBody> {
  late SBBMapProperties _properties;

  @override
  void initState() {
    _properties = widget.properties;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SBBCheckboxListItem(
            value: _properties.compassEnabled,
            label: 'Enable Compass',
            secondaryLabel: 'Show compass when map is rotated.',
            onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(compassEnabled: v)),
          ),
          SBBCheckboxListItem(
            value: _properties.zoomGesturesEnabled,
            label: 'Enable Zoom',
            secondaryLabel: 'Enable zoom gestures.',
            onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(zoomGesturesEnabled: v)),
          ),
          SBBCheckboxListItem(
            value: _properties.rotateGesturesEnabled,
            label: 'Enable Rotation',
            secondaryLabel: 'Enable rotation gesture.',
            onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(rotateGesturesEnabled: v)),
          ),
          SBBCheckboxListItem(
            value: _properties.scrollGesturesEnabled,
            label: 'Enable Scroll',
            secondaryLabel: 'Enable scrolling the map by pan gesture.',
            onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(scrollGesturesEnabled: v)),
            isLastElement: true,
          ),
          const SizedBox(height: sbbDefaultSpacing),
          SBBPrimaryButton(label: 'Apply Changes', onPressed: () => Navigator.pop(context, _properties)),
          const SizedBox(height: sbbDefaultSpacing),
        ],
      ),
    );
  }

  void _setModalStateWithProperties(SBBMapProperties properties) {
    setState(() {
      _properties = properties;
    });
  }
}
