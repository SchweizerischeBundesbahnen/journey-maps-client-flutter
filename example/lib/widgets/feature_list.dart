import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/feature_routes.dart';
import 'package:sbb_maps_example/widgets/theme_segmented_button.dart';

const _kFooterText = 'Built with Flutter 💙';

/// Lists every feature route under the heading of its group, below the theme
/// toggle and above the footer.
class FeatureList extends StatelessWidget {
  const FeatureList({super.key, required this.onSelected, this.selected});

  final ValueChanged<FeatureRoute> onSelected;

  /// The feature route to mark with a tick. The other rows then show no
  /// trailing icon.
  ///
  /// If null, every row shows a chevron.
  final FeatureRoute? selected;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<FeatureRoute>>{};
    for (final featureRoute in featureRoutes) {
      groups.putIfAbsent(featureRoute.group, () => []).add(featureRoute);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const .all(SBBSpacing.medium),
        child: Column(
          children: [
            const ThemeSegmentedButton(),
            for (final MapEntry(key: group, value: groupRoutes) in groups.entries) ...[
              if (group != groups.keys.first) const SizedBox(height: SBBSpacing.medium),
              SBBListHeader(group),
              SBBContentBox(
                child: Column(
                  children: SBBDivider.divideItems(
                    context: context,
                    items: [
                      for (final featureRoute in groupRoutes)
                        SBBListItem(
                          titleText: featureRoute.title,
                          onTap: () => onSelected(featureRoute),
                          trailingIconData: _trailingIconOf(featureRoute),
                        ),
                    ],
                  ).toList(),
                ),
              ),
            ],
            const SizedBox(height: SBBSpacing.large),
            Text(_kFooterText, style: sbbTextStyle.small.lightStyle),
          ],
        ),
      ),
    );
  }

  IconData? _trailingIconOf(FeatureRoute featureRoute) {
    if (selected == null) return SBBIcons.chevron_small_right_small;
    return featureRoute == selected ? SBBIcons.tick_small : null;
  }
}
