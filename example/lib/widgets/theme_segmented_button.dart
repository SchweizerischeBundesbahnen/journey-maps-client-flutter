import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/theme_provider.dart';

class ThemeSegmentedButton extends StatelessWidget {
  const ThemeSegmentedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return SBBSegmentedButton.icon(
      icons: {
        SBBIcons.sunshine_small: 'Light theme',
        SBBIcons.smartphone_small: 'System theme',
        SBBIcons.moon_small: 'Dark theme',
      },
      selectedStateIndex: provider.useSystemTheme
          ? 1
          : provider.isDark
          ? 2
          : 0,
      selectedIndexChanged: (value) {
        Provider.of<ThemeProvider>(context, listen: false).updateTheme(
          value == 0
              ? false
              : value == 1
              ? null
              : true,
        );
      },
    );
  }
}
