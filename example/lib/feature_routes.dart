import 'package:flutter/material.dart';

import 'routes/camera_route.dart';
import 'routes/custom_ui_route.dart';
import 'routes/display_annotations_route.dart';
import 'routes/floor_switcher_route.dart';
import 'routes/integration_data_route.dart';
import 'routes/map_properties_route.dart';
import 'routes/plain_map_route.dart';
import 'routes/poi_route.dart';
import 'routes/routing_route.dart';
import 'routes/standard_map_route.dart';
import 'routes/track_device_location_route.dart';

/// A screen of the example app that demonstrates one feature of the library.
class FeatureRoute {
  const FeatureRoute({required this.title, required this.group, required this.builder});

  /// Shown in the feature list and in the header of the phone layout.
  final String title;

  /// The heading the feature list shows this feature route under.
  final String group;

  /// Builds the body of the feature route. The layout around it supplies the
  /// [Scaffold] and the header.
  final WidgetBuilder builder;
}

/// Every feature route, in the order of the feature list.
final featureRoutes = <FeatureRoute>[
  FeatureRoute(title: 'Standard', group: 'Basic', builder: (_) => const StandardMapRoute()),
  FeatureRoute(title: 'Plain', group: 'Basic', builder: (_) => const PlainMapRoute()),
  FeatureRoute(title: 'Track Device', group: 'Basic', builder: (_) => const TrackDeviceLocationRoute()),
  FeatureRoute(title: 'Moving Camera', group: 'Basic', builder: (_) => const CameraRoute()),
  FeatureRoute(title: 'Map Properties', group: 'More', builder: (_) => const MapPropertiesRoute()),
  FeatureRoute(title: 'Integration Data', group: 'More', builder: (_) => const IntegrationDataRoute()),
  FeatureRoute(title: 'Custom UI', group: 'More', builder: (_) => const CustomUiRoute()),
  FeatureRoute(title: 'Floor Switcher', group: 'More', builder: (_) => const FloorSwitcherRoute()),
  FeatureRoute(title: 'POI', group: 'More', builder: (_) => const POIRoute()),
  FeatureRoute(title: 'Routing', group: 'More', builder: (_) => const RoutingRoute()),
  FeatureRoute(
    title: 'Display Annotations',
    group: 'Custom Annotations',
    builder: (_) => const DisplayAnnotationsRoute(),
  ),
];
