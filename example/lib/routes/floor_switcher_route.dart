import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// Zurich main station, which has floors to switch between.
const _zurichHB = SBBCameraPosition(target: LatLng(47.3779, 8.5403), zoom: 17.0);

/// Shows the four floor switchers the default UI can render: both
/// orientations, each in its standard and compact size.
class FloorSwitcherRoute extends StatefulWidget {
  const FloorSwitcherRoute({super.key});

  @override
  State<FloorSwitcherRoute> createState() => _FloorSwitcherRouteState();
}

class _FloorSwitcherRouteState extends State<FloorSwitcherRoute> {
  SBBMapFloorSwitcherOrientation _orientation = .horizontal;
  bool _smallControls = false;

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBMapsMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );

    return Scaffold(
      appBar: const SBBHeader(titleText: 'Floor Switcher'),
      body: Column(
        children: [
          Expanded(
            child: SBBMap(
              mapStyler: mapStyler,
              initialCameraPosition: _zurichHB,
              isMyLocationEnabled: true,
              isFloorSwitchingEnabled: true,
              floorSwitcherOrientation: _orientation,
              smallControls: _smallControls,
            ),
          ),
          Padding(
            padding: const .all(SBBSpacing.medium),
            child: Column(
              children: [
                SBBSegmentedButton<SBBMapFloorSwitcherOrientation>(
                  segments: const [
                    SBBButtonSegment(value: .horizontal, labelText: 'Horizontal'),
                    SBBButtonSegment(value: .vertical, labelText: 'Vertical'),
                  ],
                  selected: _orientation,
                  onSelectionChanged: (value) => setState(() => _orientation = value),
                ),
                const SizedBox(height: SBBSpacing.medium),
                SBBContentBox(
                  child: SBBCheckboxListItem(
                    value: _smallControls,
                    titleText: 'Small controls',
                    subtitleText: 'Render the compact 32 px variants.',
                    onChanged: (value) => setState(() => _smallControls = value ?? false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
