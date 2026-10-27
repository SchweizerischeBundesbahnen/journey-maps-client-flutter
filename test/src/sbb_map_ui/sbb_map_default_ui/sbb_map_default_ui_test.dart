import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_default_ui/sbb_map_default_ui.dart';

import '../../../util/fake_map_floor_controller.dart';
import '../../../util/map_ui_harness.dart';

void main() {
  group('Widget Test SBBMapDefaultUI', () {
    Future<void> mount(
      WidgetTester tester, {
      required SBBMapFloorSwitcherOrientation orientation,
      bool smallControls = false,
    }) => tester.pumpWidget(
      mapUiHarness(
        floorController: FakeMapFloorController(availableFloors: const [1, 0, -1]),
        child: SBBMapDefaultUI(
          locationEnabled: false,
          isFloorSwitchingEnabled: true,
          floorSwitcherOrientation: orientation,
          smallControls: smallControls,
        ),
      ),
    );

    const allSwitchers = [
      SBBMapHorizontalFloorSwitcher,
      SBBMapHorizontalFloorSwitcherSmall,
      SBBMapVerticalFloorSwitcher,
      SBBMapVerticalFloorSwitcherSmall,
    ];

    void expectOnlySwitcher(Type shown) {
      for (final switcher in allSwitchers) {
        expect(find.byType(switcher), switcher == shown ? findsOneWidget : findsNothing);
      }
    }

    testWidgets('floorSwitcher_whenHorizontal_shouldShowHorizontalFloorSwitcher', (tester) async {
      await mount(tester, orientation: .horizontal);

      expectOnlySwitcher(SBBMapHorizontalFloorSwitcher);
    });

    testWidgets('floorSwitcher_whenHorizontalAndSmallControls_shouldShowHorizontalFloorSwitcherSmall', (tester) async {
      await mount(tester, orientation: .horizontal, smallControls: true);

      expectOnlySwitcher(SBBMapHorizontalFloorSwitcherSmall);
    });

    testWidgets('floorSwitcher_whenVertical_shouldShowVerticalFloorSwitcher', (tester) async {
      await mount(tester, orientation: .vertical);

      expectOnlySwitcher(SBBMapVerticalFloorSwitcher);
    });

    testWidgets('floorSwitcher_whenVerticalAndSmallControls_shouldShowVerticalFloorSwitcherSmall', (tester) async {
      await mount(tester, orientation: .vertical, smallControls: true);

      expectOnlySwitcher(SBBMapVerticalFloorSwitcherSmall);
    });
  });
}
