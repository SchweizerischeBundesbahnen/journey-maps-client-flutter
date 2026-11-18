import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// Zurich main station, which has floors to switch between.
const _zurichHB = SBBCameraPosition(target: LatLng(47.3779, 8.5403), zoom: 17.0);

/// Shows the four floor switchers the default UI can render (both
/// orientations, each in its standard and compact size) and the two views the
/// map can show while no floor is selected.
class FloorSwitcherRoute extends StatefulWidget {
  const FloorSwitcherRoute({super.key});

  @override
  State<FloorSwitcherRoute> createState() => _FloorSwitcherRouteState();
}

class _FloorSwitcherRouteState extends State<FloorSwitcherRoute> {
  _FloorSwitcherSettings _settings = const _FloorSwitcherSettings();

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBMapsMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );

    return SBBMap(
      mapStyler: mapStyler,
      initialCameraPosition: _zurichHB,
      isFloorSwitchingEnabled: true,
      defaultViewWithoutFloor: _settings.viewWithoutFloor,
      builder: (context) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const .all(SBBSpacing.medium),
          child: Column(
            crossAxisAlignment: .end,
            children: [
              SBBMapIconButton(
                onPressed: () {
                  showSBBBottomSheet<_FloorSwitcherSettings>(
                    context: context,
                    useRootNavigator: false,
                    titleText: 'Floor Switcher',
                    body: _FloorSwitcherModalBody(settings: _settings),
                  ).then(_setStateWithSettings);
                },
                icon: SBBIcons.gears_small,
              ),
              const SizedBox(height: SBBSpacing.medium),
              _floorSwitcher(),
            ],
          ),
        ),
      ),
    );
  }

  /// The custom UI replaces the default UI, so the floor switcher named by the
  /// settings is rendered here.
  Widget _floorSwitcher() => switch ((_settings.orientation, _settings.smallControls)) {
    (.vertical, false) => const SBBMapVerticalFloorSwitcher(),
    (.vertical, true) => const SBBMapVerticalFloorSwitcherSmall(),
    (.horizontal, false) => const SBBMapHorizontalFloorSwitcher(),
    (.horizontal, true) => const SBBMapHorizontalFloorSwitcherSmall(),
  };

  void _setStateWithSettings(_FloorSwitcherSettings? settings) {
    setState(() {
      if (settings != null) {
        _settings = settings;
      }
    });
  }
}

class _FloorSwitcherSettings {
  const _FloorSwitcherSettings({
    this.orientation = .horizontal,
    this.smallControls = false,
    this.viewWithoutFloor = .twoD,
  });

  final SBBMapFloorSwitcherOrientation orientation;
  final bool smallControls;
  final SBBMapViewWithoutFloor viewWithoutFloor;

  _FloorSwitcherSettings copyWith({
    SBBMapFloorSwitcherOrientation? orientation,
    bool? smallControls,
    SBBMapViewWithoutFloor? viewWithoutFloor,
  }) => _FloorSwitcherSettings(
    orientation: orientation ?? this.orientation,
    smallControls: smallControls ?? this.smallControls,
    viewWithoutFloor: viewWithoutFloor ?? this.viewWithoutFloor,
  );
}

class _FloorSwitcherModalBody extends StatefulWidget {
  const _FloorSwitcherModalBody({required this.settings});

  final _FloorSwitcherSettings settings;

  @override
  State<_FloorSwitcherModalBody> createState() => _FloorSwitcherModalBodyState();
}

class _FloorSwitcherModalBodyState extends State<_FloorSwitcherModalBody> {
  late _FloorSwitcherSettings _settings;

  @override
  void initState() {
    _settings = widget.settings;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        const Text('Orientation'),
        const SizedBox(height: SBBSpacing.small),
        SBBSegmentedButton<SBBMapFloorSwitcherOrientation>(
          segments: const [
            SBBButtonSegment(value: .horizontal, labelText: 'Horizontal'),
            SBBButtonSegment(value: .vertical, labelText: 'Vertical'),
          ],
          selected: _settings.orientation,
          onSelectionChanged: (value) => _setModalStateWithSettings(_settings.copyWith(orientation: value)),
        ),
        const SizedBox(height: SBBSpacing.medium),
        SBBContentBox(
          child: SBBCheckboxListItem(
            value: _settings.smallControls,
            titleText: 'Small controls',
            subtitleText: 'Render the compact 32 px variants.',
            onChanged: (value) => _setModalStateWithSettings(_settings.copyWith(smallControls: value ?? false)),
          ),
        ),
        const SizedBox(height: SBBSpacing.medium),
        const Text('View without floor'),
        const SizedBox(height: SBBSpacing.small),
        SBBSegmentedButton<SBBMapViewWithoutFloor>(
          segments: const [
            SBBButtonSegment(value: .twoD, labelText: '2D View'),
            SBBButtonSegment(value: .floorZero, labelText: 'Floor 0'),
          ],
          selected: _settings.viewWithoutFloor,
          onSelectionChanged: (value) => _setModalStateWithSettings(_settings.copyWith(viewWithoutFloor: value)),
        ),
        const SizedBox(height: SBBSpacing.medium),
        SBBPrimaryButton(labelText: 'Apply Changes', onPressed: () => Navigator.pop(context, _settings)),
      ],
    );
  }

  void _setModalStateWithSettings(_FloorSwitcherSettings settings) {
    setState(() {
      _settings = settings;
    });
  }
}
