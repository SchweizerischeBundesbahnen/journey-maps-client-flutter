import 'package:flutter/foundation.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// A hand-written stand-in for [SBBMapFloorController].
///
/// Widget tests need to drive state changes — replace the available floors,
/// change the current floor, notify — and then assert that the control reacts.
/// Driving a [ChangeNotifier] through a generated mock is awkward, so this is
/// written by hand.
///
/// Like the real controller it emits a single, undifferentiated change
/// notification for both floor set and selection changes.
class FakeMapFloorController extends ChangeNotifier implements SBBMapFloorController {
  FakeMapFloorController({List<int> availableFloors = const <int>[], int? currentFloor})
    : _availableFloors = availableFloors,
      _currentFloor = currentFloor;

  List<int> _availableFloors;
  int? _currentFloor;

  /// Every floor passed to [switchFloor], in call order.
  final List<int?> switchedFloors = <int?>[];

  @override
  List<int> get availableFloors => _availableFloors;

  @override
  int? get currentFloor => _currentFloor;

  @override
  Future<void> switchFloor(int? floor) async {
    switchedFloors.add(floor);
    _currentFloor = floor;
    notifyListeners();
  }

  /// Replaces the available floors, as the real controller does on every
  /// camera idle, and notifies.
  void updateAvailableFloors(List<int> floors) {
    _availableFloors = floors;
    notifyListeners();
  }

  /// Changes the current floor without recording a [switchFloor] call.
  void updateCurrentFloor(int? floor) {
    _currentFloor = floor;
    notifyListeners();
  }
}
