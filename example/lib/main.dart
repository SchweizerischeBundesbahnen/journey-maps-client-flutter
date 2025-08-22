import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/routes/integration_data_route.dart';
import 'routes/camera_route.dart';
import 'routes/custom_ui_route.dart';
import 'routes/display_annotations_route.dart';
import 'routes/features_route.dart';
import 'routes/map_properties_route.dart';
import 'routes/plain_map_route.dart';
import 'routes/poi_route.dart';
import 'routes/routing_route.dart';
import 'routes/standard_map_route.dart';
import 'routes/track_device_location_route.dart';
import 'theme_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final themeProvider = ThemeProvider();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: Consumer<ThemeProvider>(
        builder:
            (BuildContext context, ThemeProvider themeProvider, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: SBBTheme.light(),
              darkTheme: SBBTheme.dark(),
              themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
              initialRoute: '/features',
              routes: {
                '/features': (context) => const FeaturesRoute(),
                '/plain': (context) => const PlainMapRoute(),
                '/camera': (context) => const CameraRoute(),
                '/standard': (context) => const StandardMapRoute(),
                '/custom_ui': (context) => const CustomUiRoute(),
                '/poi': (context) => const POIRoute(),
                '/routing': (context) => const RoutingRoute(),
                '/map_properties': (context) => const MapPropertiesRoute(),
                '/integration_data': (context) => const IntegrationDataRoute(),
                '/display_annotations': (context) => const DisplayAnnotationsRoute(),
                '/track_device_location': (context) => const TrackDeviceLocationRoute(),
              },
            ),
      ),
    );
  }
}
