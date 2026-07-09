import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/widgets/theme_segmented_button.dart';

const _kHeaderTitle = 'SBB Karten';

class FeaturesRoute extends StatefulWidget {
  const FeaturesRoute({super.key});

  @override
  State<FeaturesRoute> createState() => _FeaturesRouteState();
}

class _FeaturesRouteState extends State<FeaturesRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SBBHeader(titleText: _kHeaderTitle),
      body: SingleChildScrollView(
        child: Padding(
          padding: .all(SBBSpacing.medium),
          child: Column(
            children: [
              ThemeSegmentedButton(),
              SBBListHeader('Basic'),
              SBBContentBox(
                child: Column(
                  children: SBBDivider.divideItems(
                    context: context,
                    items: [
                      _FeatureRoute(title: 'Standard', routeName: '/standard'),
                      _FeatureRoute(title: 'Plain', routeName: '/plain'),
                      _FeatureRoute(title: 'Track Device', routeName: '/track_device_location'),
                      _FeatureRoute(title: 'Moving Camera', routeName: '/camera'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SBBSpacing.medium),
              SBBListHeader('More'),
              SBBContentBox(
                child: Column(
                  children: SBBDivider.divideItems(
                    context: context,
                    items: [
                      _FeatureRoute(title: 'Map Properties', routeName: '/map_properties'),
                      _FeatureRoute(title: 'Integration Data', routeName: '/integration_data'),
                      _FeatureRoute(title: 'Custom UI', routeName: '/custom_ui'),
                      _FeatureRoute(title: 'POI', routeName: '/poi'),
                      _FeatureRoute(title: 'Routing', routeName: '/routing'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SBBSpacing.medium),
              SBBListHeader('Custom Annotations'),
              SBBContentBox(
                child: Column(
                  children: [
                    _FeatureRoute(title: 'Display Annotations', routeName: '/display_annotations'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRoute extends StatelessWidget {
  const _FeatureRoute({required this.title, required this.routeName});

  final String routeName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SBBListItem(
      titleText: title,
      onTap: () => Navigator.pushNamed(context, routeName),
      trailingIconData: SBBIcons.chevron_small_right_small,
    );
  }
}
