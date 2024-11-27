import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sbb_maps_example/widgets/theme_segmented_button.dart';

const _kHeaderTitle = 'SBB Karten';
const _kPadding = EdgeInsets.symmetric(
  horizontal: sbbDefaultSpacing,
  vertical: sbbDefaultSpacing,
);

class FeaturesRoute extends StatefulWidget {
  const FeaturesRoute({super.key});

  @override
  State<FeaturesRoute> createState() => _FeaturesRouteState();
}

class _FeaturesRouteState extends State<FeaturesRoute> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SBBHeader(title: _kHeaderTitle),
      body: SingleChildScrollView(
        child: Padding(
          padding: _kPadding,
          child: Column(
            children: [
              ThemeSegmentedButton(),
              SBBListHeader('Basic'),
              SBBGroup(
                child: Column(
                  children: [
                    _FeatureRoute(
                      title: 'Standard',
                      routeName: '/standard',
                    ),
                    _FeatureRoute(
                      title: 'Plain',
                      routeName: '/plain',
                    ),
                    _FeatureRoute(
                      title: 'Track Device',
                      routeName: '/track_device_location',
                    ),
                    _FeatureRoute(
                      title: 'Moving Camera',
                      routeName: '/camera',
                      isLastElement: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sbbDefaultSpacing),
              SBBListHeader('More'),
              SBBGroup(
                child: Column(
                  children: [
                    _FeatureRoute(
                      title: 'Map Properties',
                      routeName: '/map_properties',
                    ),
                    _FeatureRoute(
                      title: 'Integration Data',
                      routeName: '/integration_data',
                    ),
                    _FeatureRoute(
                      title: 'Custom UI',
                      routeName: '/custom_ui',
                    ),
                    _FeatureRoute(
                      title: 'POI',
                      routeName: '/poi',
                    ),
                    _FeatureRoute(
                      title: 'Routing',
                      routeName: '/routing',
                      isLastElement: true,
                    )
                  ],
                ),
              ),
              SizedBox(height: sbbDefaultSpacing),
              SBBListHeader('Custom Annotations'),
              SBBGroup(
                child: Column(
                  children: [
                    _FeatureRoute(
                      title: 'Display Annotations',
                      routeName: '/display_annotations',
                      isLastElement: true,
                    ),
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
  const _FeatureRoute({
    required this.title,
    required this.routeName,
    this.isLastElement = false,
  });

  final String routeName;
  final String title;
  final bool isLastElement;

  @override
  Widget build(BuildContext context) {
    return SBBListItem(
      title: title,
      onPressed: () => Navigator.pushNamed(context, routeName),
      trailingIcon: SBBIcons.chevron_small_right_small,
      isLastElement: isLastElement,
    );
  }
}
