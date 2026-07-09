import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_example/widgets/theme_segmented_button.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class CustomUiRoute extends StatefulWidget {
  const CustomUiRoute({super.key});

  @override
  State<CustomUiRoute> createState() => _CustomUiRouteState();
}

class _CustomUiRouteState extends State<CustomUiRoute> {
  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(titleText: 'Custom UI'),
      body: SBBMap(
        mapStyler: mapStyler,
        isMyLocationEnabled: true,
        isFloorSwitchingEnabled: true,
        builder: (context) => const Align(
          alignment: Alignment.topRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShadowedThemeButton(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: SBBSpacing.medium, bottom: SBBSpacing.xLarge),
                    child: SBBMapStyleSwitcherSmall(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: SBBSpacing.medium, bottom: SBBSpacing.xLarge),
                    child: SBBMapMyLocationButtonSmall(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: SBBSpacing.medium, bottom: SBBSpacing.xLarge),
                    child: SBBMapFloorSelectorSmall(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShadowedThemeButton extends StatelessWidget {
  final _blurRadius = 2.0;
  final _shadowOffset = const Offset(0, 1);

  const _ShadowedThemeButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(SBBSpacing.medium),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: .circular(SBBSpacing.medium),
          boxShadow: [
            BoxShadow(blurRadius: _blurRadius, color: SBBColors.black.withValues(alpha: 0.1), offset: _shadowOffset),
          ],
        ),
        child: const ThemeSegmentedButton(),
      ),
    );
  }
}
