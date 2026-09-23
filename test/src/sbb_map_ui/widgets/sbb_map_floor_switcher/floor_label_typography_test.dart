import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

import '../../../../util/fake_map_floor_controller.dart';
import '../../../../util/map_ui_harness.dart';

/// A family no font shipped by this package declares. A floor label can only
/// render in it by inheriting it from the host application's theme.
const _hostFontFamily = 'HostAppFont';

const _availableFloors = [1, 0, -1];
const _floorLabel = '1';

void main() {
  group('Widget Test floor label typography', () {
    late FakeMapFloorController floorController;

    setUp(() {
      floorController = FakeMapFloorController(availableFloors: _availableFloors, currentFloor: 0);
    });

    testWidgets('floor label follows the host theme font family', (tester) async {
      await tester.pumpWidget(_hostApp(floorController, const SBBMapVerticalFloorSwitcher()));

      expect(_renderedLabelStyle(tester).fontFamily, _hostFontFamily);
    });

    testWidgets('small floor label follows the host theme font family', (tester) async {
      await tester.pumpWidget(_hostApp(floorController, const SBBMapVerticalFloorSwitcherSmall()));

      expect(_renderedLabelStyle(tester).fontFamily, _hostFontFamily);
    });

    testWidgets('floor label keeps the package metrics while inheriting the font', (tester) async {
      await tester.pumpWidget(_hostApp(floorController, const SBBMapVerticalFloorSwitcher()));

      final style = _renderedLabelStyle(tester);
      expect(style.fontSize, 16.0);
      expect(style.height, 20.0 / 16.0);
      expect(style.fontWeight, FontWeight.w300);
      expect(style.fontStyle, FontStyle.normal);
    });

    testWidgets('small floor label keeps the package metrics while inheriting the font', (tester) async {
      await tester.pumpWidget(_hostApp(floorController, const SBBMapVerticalFloorSwitcherSmall()));

      final style = _renderedLabelStyle(tester);
      expect(style.fontSize, 12.0);
      expect(style.height, 16.0 / 12.0);
      expect(style.fontWeight, FontWeight.w300);
      expect(style.fontStyle, FontStyle.normal);
    });
  });
}

/// The map UI harness below a host application theme declaring [_hostFontFamily].
Widget _hostApp(FakeMapFloorController floorController, Widget child) => mapUiHarness(
  floorController: floorController,
  theme: ThemeData(fontFamily: _hostFontFamily),
  child: child,
);

/// The style the floor label actually renders with, after the ambient default
/// text style and the package's own style have been merged.
TextStyle _renderedLabelStyle(WidgetTester tester) {
  final richText = tester.widget<RichText>(
    find.descendant(of: find.text(_floorLabel), matching: find.byType(RichText)),
  );
  return richText.text.style!;
}
