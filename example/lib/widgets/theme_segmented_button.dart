import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/theme_provider.dart';

class ThemeSegmentedButton extends StatelessWidget {
  const ThemeSegmentedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return SBBSegmentedButton<int>(
      segments: [
        SBBButtonSegment(value: 0, leadingIconData: SBBIcons.sunshine_small),
        SBBButtonSegment(value: 1, leadingIconData: SBBIcons.smartphone_small),
        SBBButtonSegment(value: 2, leadingIconData: SBBIcons.moon_small),
      ],
      selected: _selectedIndexFrom(provider),
      onSelectionChanged: (value) => _updateProviderFromValue(context, value),
    );
  }

  void _updateProviderFromValue(BuildContext context, int value) {
    return Provider.of<ThemeProvider>(context, listen: false).updateTheme(
      value == 0
          ? false
          : value == 1
          ? null
          : true,
    );
  }

  int _selectedIndexFrom(ThemeProvider provider) => provider.useSystemTheme
      ? 1
      : provider.isDark
      ? 2
      : 0;
}
