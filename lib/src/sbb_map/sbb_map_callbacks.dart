import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator.dart';
import 'package:sbb_maps_flutter/src/sbb_map_controller/sbb_map_controller.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller.dart';
import 'package:sbb_maps_flutter/src/sbb_map_locator/sbb_map_locator.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/controller/sbb_routing_controller.dart';

typedef MapCreatedCallback = void Function(SBBMapController controller);
typedef OnMapLocatorAvailable = void Function(SBBMapLocator locator);
typedef OnMapAnnotatorAvailable = void Function(SBBMapAnnotator annotator);
typedef OnFloorControllerAvailable = void Function(SBBMapFloorController floorController);
typedef OnRoutingControllerAvailable = void Function(SBBRoutingController routingController);
