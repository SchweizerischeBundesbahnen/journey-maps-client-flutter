import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

import '../../../../util/fake_map_floor_controller.dart';
import '../../../../util/map_ui_harness.dart';

const _availableFloors = [1, 0, -1];

/// The kind of label a Swiss consumer supplies: "EG" for the ground floor,
/// "UG" for the basement.
String _swissFloorLabel(int floor) => switch (floor) {
  0 => 'EG',
  < 0 => 'UG${-floor}',
  _ => '$floor',
};

void main() {
  group('Widget Test SBBMapVerticalFloorSwitcher', () {
    late FakeMapFloorController floorController;

    setUp(() {
      floorController = FakeMapFloorController(availableFloors: _availableFloors, currentFloor: 0);
    });

    testWidgets('shows the integer floor when no label builder is given', (tester) async {
      await tester.pumpWidget(
        mapUiHarness(floorController: floorController, child: const SBBMapVerticalFloorSwitcher()),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
    });

    testWidgets('shows the consumer floor label when a label builder is given', (tester) async {
      await tester.pumpWidget(
        mapUiHarness(
          floorController: floorController,
          child: const SBBMapVerticalFloorSwitcher(floorLabelBuilder: _swissFloorLabel),
        ),
      );

      expect(find.text('EG'), findsOneWidget);
      expect(find.text('UG1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });

  group('Widget Test SBBMapVerticalFloorSwitcherSmall', () {
    late FakeMapFloorController floorController;

    setUp(() {
      floorController = FakeMapFloorController(availableFloors: _availableFloors, currentFloor: 0);
    });

    testWidgets('shows the integer floor when no label builder is given', (tester) async {
      await tester.pumpWidget(
        mapUiHarness(floorController: floorController, child: const SBBMapVerticalFloorSwitcherSmall()),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
    });

    testWidgets('shows the consumer floor label when a label builder is given', (tester) async {
      await tester.pumpWidget(
        mapUiHarness(
          floorController: floorController,
          child: const SBBMapVerticalFloorSwitcherSmall(floorLabelBuilder: _swissFloorLabel),
        ),
      );

      expect(find.text('EG'), findsOneWidget);
      expect(find.text('UG1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}
