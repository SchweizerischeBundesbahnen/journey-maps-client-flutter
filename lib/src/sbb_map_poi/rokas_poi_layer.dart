import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// The POI layers defined in the [SBBRokasMapStyler] styles.
///
/// * [baseOnFloor] are circles / rounded squares icons shown in the 'background' on the map.
///   They are dependent on the currently selected floor.
/// * [highlighted] are symbols appearing as 'pins' more in the 'foreground' on the map.
enum RokasPoiLayer {
  baseOnFloor,
  highlighted,
}
