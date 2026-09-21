import 'package:flutter/foundation.dart';

/// Control the floor selection and available floors of a [SBBMap].
///
/// This works with any map style following the SBB layer conventions: the
/// available floors are read from the `service_points` source, and the floor is
/// applied by rewriting the filters of the layers whose id ends in `-lvl`.
///
/// Both the SBB Maps styles held by [SBBMapsMapStyler] and the Legacy Journey
/// Maps styles held by [SBBRokasMapStyler] satisfy this.
abstract class SBBMapFloorController with ChangeNotifier {
  /// Get the available floors in DESC order.
  ///
  /// If no floors are available, the list will be empty.
  List<int> get availableFloors;

  /// Switch the current floor of the map by applying layer filters.
  ///
  /// Will fail silently if the floor is not available.
  /// If the argument is null, all filters will be reset to the '0' level.
  Future<void> switchFloor(int? floor);

  /// Get the current floor of the map.
  ///
  /// Will return null if no floor is selected.
  /// This corresponds to the '0' level of the map.
  int? get currentFloor;
}
