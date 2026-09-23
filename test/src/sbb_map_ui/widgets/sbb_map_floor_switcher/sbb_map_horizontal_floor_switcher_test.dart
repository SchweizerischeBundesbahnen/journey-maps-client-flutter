import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';

import '../../../../util/fake_map_floor_controller.dart';
import '../../../../util/map_ui_harness.dart';

/// The controller reports floors descending; the traveller reads them
/// ascending, left to right.
const _availableFloors = [1, 0, -1];

const _floorsIcon = SBBMapIcons.layers_with_arrows_small;
const _closeIcon = SBBMapIcons.cross_small;

/// The kind of label a Swiss consumer supplies.
String _swissFloorLabel(int floor) => switch (floor) {
  0 => 'EG',
  < 0 => 'UG${-floor}',
  _ => '$floor',
};

typedef _SwitcherFactory = Widget Function({SBBMapFloorLabelBuilder? floorLabelBuilder});

void main() {
  _horizontalFloorSwitcherTests(
    SBBMapHorizontalFloorSwitcher,
    ({floorLabelBuilder}) => SBBMapHorizontalFloorSwitcher(floorLabelBuilder: floorLabelBuilder),
  );

  _horizontalFloorSwitcherTests(
    SBBMapHorizontalFloorSwitcherSmall,
    ({floorLabelBuilder}) => SBBMapHorizontalFloorSwitcherSmall(floorLabelBuilder: floorLabelBuilder),
  );
}

void _horizontalFloorSwitcherTests(Type switcherType, _SwitcherFactory switcher) {
  group('Widget Test $switcherType', () {
    late FakeMapFloorController floorController;

    setUp(() {
      floorController = FakeMapFloorController(availableFloors: _availableFloors);
    });

    Future<void> mount(WidgetTester tester, {SBBMapFloorLabelBuilder? floorLabelBuilder}) => tester.pumpWidget(
      mapUiHarness(
        floorController: floorController,
        child: switcher(floorLabelBuilder: floorLabelBuilder),
      ),
    );

    Future<void> expand(WidgetTester tester) async {
      await tester.tap(find.byIcon(_floorsIcon));
      await tester.pumpAndSettle();
    }

    /// Collapsed means: no close affordance, and no floor offered for picking.
    /// A collapsed control still shows [showing], the floor currently selected.
    void expectCollapsed({int? showing}) {
      expect(find.byIcon(_closeIcon), findsNothing);
      for (final floor in _availableFloors) {
        expect(
          find.text('$floor'),
          floor == showing ? findsOneWidget : findsNothing,
          reason: 'floor $floor should not be offered while collapsed',
        );
      }
    }

    void expectExpanded() {
      expect(find.byIcon(_closeIcon), findsOneWidget);
      for (final floor in _availableFloors) {
        expect(find.text('$floor'), findsOneWidget, reason: 'floor $floor should be offered while expanded');
      }
    }

    testWidgets('starts collapsed, showing the floors icon when no floor is selected', (tester) async {
      await mount(tester);

      expect(find.byIcon(_floorsIcon), findsOneWidget);
      expectCollapsed();
    });

    testWidgets('shows the current floor instead of the icon once one is selected', (tester) async {
      floorController.updateCurrentFloor(0);
      await mount(tester);

      expect(find.byIcon(_floorsIcon), findsNothing);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('expands when the collapsed circle is tapped', (tester) async {
      await mount(tester);

      await expand(tester);

      expectExpanded();
    });

    testWidgets('collapses again when the close icon is tapped', (tester) async {
      await mount(tester);
      await expand(tester);

      await tester.tap(find.byIcon(_closeIcon));
      await tester.pumpAndSettle();

      expectCollapsed();
      expect(find.byIcon(_floorsIcon), findsOneWidget);
      expect(floorController.switchedFloors, isEmpty);
    });

    testWidgets('selecting a floor switches to it and collapses', (tester) async {
      await mount(tester);
      await expand(tester);

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(floorController.switchedFloors, [1]);
      expectCollapsed(showing: 1);
    });

    testWidgets('does not show the picked floor twice while collapsing', (tester) async {
      await mount(tester);
      await expand(tester);

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byIcon(_closeIcon), findsOneWidget, reason: 'the cap stays a close icon until the pill is gone');
      expect(find.text('1'), findsOneWidget);

      await tester.pumpAndSettle();
      expectCollapsed(showing: 1);
    });

    testWidgets('selecting the current floor deselects it and returns to the icon state', (tester) async {
      floorController.updateCurrentFloor(1);
      await mount(tester);

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(floorController.switchedFloors, [null]);
      expect(floorController.currentFloor, isNull);
      expect(find.byIcon(_floorsIcon), findsOneWidget);
      expectCollapsed();
    });

    testWidgets('renders nothing when no floors are available', (tester) async {
      floorController = FakeMapFloorController();
      await mount(tester);

      expect(find.byIcon(_floorsIcon), findsNothing);
      expect(tester.getSize(find.byType(switcherType)), Size.zero);
    });

    testWidgets('a floor set that differs by value collapses the control', (tester) async {
      await mount(tester);
      await expand(tester);

      floorController.updateAvailableFloors(const [2, 1, 0]);
      await tester.pumpAndSettle();

      expect(find.byIcon(_closeIcon), findsNothing);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('an equal but rebuilt floor set leaves the control expanded', (tester) async {
      await mount(tester);
      await expand(tester);

      floorController.updateAvailableFloors(List<int>.of(_availableFloors));
      await tester.pumpAndSettle();

      expectExpanded();
    });

    testWidgets('expansion resets when the floor list empties and refills', (tester) async {
      await mount(tester);
      await expand(tester);

      floorController.updateAvailableFloors(const []);
      await tester.pumpAndSettle();
      floorController.updateAvailableFloors(_availableFloors);
      await tester.pumpAndSettle();

      expectCollapsed();
      expect(find.byIcon(_floorsIcon), findsOneWidget);
    });

    testWidgets('offers the floors ascending from left to right', (tester) async {
      await mount(tester);
      await expand(tester);

      final left = tester.getCenter(find.text('-1')).dx;
      final middle = tester.getCenter(find.text('0')).dx;
      final right = tester.getCenter(find.text('1')).dx;

      expect(left, lessThan(middle));
      expect(middle, lessThan(right));
      expect(right, lessThan(tester.getCenter(find.byIcon(_closeIcon)).dx));
    });

    testWidgets('applies the floor label builder to the offered floors', (tester) async {
      await mount(tester, floorLabelBuilder: _swissFloorLabel);
      await expand(tester);

      expect(find.text('EG'), findsOneWidget);
      expect(find.text('UG1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('applies the floor label builder to the collapsed current floor', (tester) async {
      floorController.updateCurrentFloor(0);
      await mount(tester, floorLabelBuilder: _swissFloorLabel);

      expect(find.text('EG'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}
