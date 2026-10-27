import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

void main() {
  group('Unit Test SBBMap', () {
    test('floorSwitcherOrientation_whenNotGiven_shouldBeHorizontal', () {
      expect(const SBBMap().floorSwitcherOrientation, SBBMapFloorSwitcherOrientation.horizontal);
    });
  });
}
