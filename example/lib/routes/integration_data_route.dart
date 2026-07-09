import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class IntegrationDataRoute extends StatefulWidget {
  const IntegrationDataRoute({super.key});

  @override
  State<IntegrationDataRoute> createState() => _IntegrationDataRouteState();
}

class _IntegrationDataRouteState extends State<IntegrationDataRoute> {
  bool useIntegration = false;

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: useIntegration ? Env.journeyMapsTilesIntApiKey : Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
      useIntegrationData: useIntegration,
    );

    return Scaffold(
      appBar: const SBBHeader(titleText: 'Integration Data'),
      body: SBBMap(
        mapStyler: mapStyler,
        isMyLocationEnabled: false,
        isFloorSwitchingEnabled: true,
        builder: (context) => Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const .all(SBBSpacing.medium),
            child: SBBMapIconButton(
              onPressed: () {
                showSBBBottomSheet<bool>(
                  context: context,
                  titleText: 'Integration Data',
                  body: _IntegrationDataModalBody(useIntegration: useIntegration),
                ).then(_setStateWithProperties);
              },
              icon: SBBIcons.gears_small,
            ),
          ),
        ),
      ),
    );
  }

  void _setStateWithProperties(bool? useIntegration) {
    setState(() {
      if (useIntegration != null) {
        this.useIntegration = useIntegration;
      }
    });
  }
}

class _IntegrationDataModalBody extends StatefulWidget {
  const _IntegrationDataModalBody({required this.useIntegration});

  final bool useIntegration;

  @override
  State<_IntegrationDataModalBody> createState() => _IntegrationDataModalBodyState();
}

class _IntegrationDataModalBodyState extends State<_IntegrationDataModalBody> {
  late bool _useIntegration;

  @override
  void initState() {
    _useIntegration = widget.useIntegration;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        SBBSwitchListItemBoxed(
          value: _useIntegration,
          titleText: 'Use INT Data',
          subtitleText: 'Accesses developer-int.sbb.ch data.',
          onChanged: (v) => setState(() {
            _useIntegration = v ?? false;
          }),
        ),
        const SizedBox(height: SBBSpacing.medium),
        SBBPrimaryButton(labelText: 'Apply Changes', onPressed: () => Navigator.pop(context, _useIntegration)),
      ],
    );
  }
}
