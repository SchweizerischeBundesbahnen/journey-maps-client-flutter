import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
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
      appBar: const SBBHeader(titleText: 'Map Properties'),
      body: SBBMap(
        mapStyler: mapStyler,
        isMyLocationEnabled: false,
        isFloorSwitchingEnabled: true,
        properties: properties,
        builder: (context) => Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const .all(SBBSpacing.medium),
            child: SBBMapIconButton(
              onPressed: () {
                showSBBBottomSheet<SBBMapProperties>(
                  context: context,
                  titleText: 'Map Properties',
                  body: _MapPropertiesModalBody(properties: properties),
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
    return Column(
      mainAxisSize: .min,
      children: [
        SBBContentBox(
          child: Column(
            mainAxisSize: .min,
            children: [
              ...SBBDivider.divideItems(
                context: context,
                items: [
                  SBBCheckboxListItem(
                    value: _properties.compassEnabled,
                    titleText: 'Enable Compass',
                    subtitleText: 'Show compass when map is rotated.',
                    onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(compassEnabled: v)),
                  ),
                  SBBCheckboxListItem(
                    value: _properties.zoomGesturesEnabled,
                    titleText: 'Enable Zoom',
                    subtitleText: 'Enable zoom gestures.',
                    onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(zoomGesturesEnabled: v)),
                  ),
                  SBBCheckboxListItem(
                    value: _properties.rotateGesturesEnabled,
                    titleText: 'Enable Rotation',
                    subtitleText: 'Enable rotation gesture.',
                    onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(rotateGesturesEnabled: v)),
                  ),
                  SBBCheckboxListItem(
                    value: _properties.scrollGesturesEnabled,
                    titleText: 'Enable Scroll',
                    subtitleText: 'Enable scrolling the map by pan gesture.',
                    onChanged: (v) => _setModalStateWithProperties(_properties.copyWith(scrollGesturesEnabled: v)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SBBSpacing.medium),
        SBBPrimaryButton(labelText: 'Apply Changes', onPressed: () => Navigator.pop(context, _properties)),
      ],
    );
  }

  void _setModalStateWithProperties(SBBMapProperties properties) {
    setState(() {
      _properties = properties;
    });
  }
}
