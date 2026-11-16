import 'package:flutter/foundation.dart';

/// Control the floor selection and available floors of a [SBBMap].
///
/// This works with any map style following the SBB layer conventions: the
/// available floors are read from the `service_points` source, a selected
/// floor is applied by rewriting the filters of the layers whose id ends in
/// `-lvl`, and the view is applied by showing either those layers (Floor View)
/// or the layers whose id ends in `-2d` (2D View).
///
/// The SBB Maps styles held by [SBBMapsMapStyler] satisfy this.
abstract class SBBMapFloorController with ChangeNotifier {
  /// Get the available floors in DESC order.
  ///
  /// If no floors are available, the list will be empty.
  List<int> get availableFloors;

  /// Switch the current floor of the map by applying layer filters.
  ///
  /// Will fail silently if the floor is not available.
  /// If the argument is null, no floor is selected and the map shows the view
  /// named by [SBBMap.defaultViewWithoutFloor]: the 2D View by default.
  Future<void> switchFloor(int? floor);

  /// Get the current floor of the map.
  ///
  /// Will return null if no floor is selected, in which case the map shows
  /// the view named by [SBBMap.defaultViewWithoutFloor].
  int? get currentFloor;
}
