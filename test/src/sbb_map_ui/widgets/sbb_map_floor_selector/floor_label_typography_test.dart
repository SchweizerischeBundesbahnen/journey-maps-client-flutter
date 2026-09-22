import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/sbb_map_style_container.dart';

@GenerateNiceMocks([MockSpec<SBBMapFloorController>(), MockSpec<SBBMapStyler>(), MockSpec<SBBMapLocator>()])
import 'floor_label_typography_test.mocks.dart';

/// A family no font shipped by this package declares. A floor label can only
/// render in it by inheriting it from the host application's theme.
const _hostFontFamily = 'HostAppFont';

const _availableFloors = [1, 0, -1];
const _floorLabel = '1';

void main() {
  group('Widget Test floor label typography', () {
    late MockSBBMapFloorController mockFloorController;
    late MockSBBMapStyler mockStyler;
    late MockSBBMapLocator mockLocator;

    setUp(() {
      mockFloorController = MockSBBMapFloorController();
      mockStyler = MockSBBMapStyler();
      mockLocator = MockSBBMapLocator();
      when(mockFloorController.availableFloors).thenReturn(_availableFloors);
      when(mockFloorController.currentFloor).thenReturn(0);
      when(mockStyler.isDarkMode).thenReturn(false);
    });

    testWidgets('floor label follows the host theme font family', (tester) async {
      await tester.pumpWidget(
        _hostApp(
          floorController: mockFloorController,
          styler: mockStyler,
          locator: mockLocator,
          child: const SBBMapFloorSelector(),
        ),
      );

      expect(_renderedLabelStyle(tester).fontFamily, _hostFontFamily);
    });

    testWidgets('small floor label follows the host theme font family', (tester) async {
      await tester.pumpWidget(
        _hostApp(
          floorController: mockFloorController,
          styler: mockStyler,
          locator: mockLocator,
          child: const SBBMapFloorSelectorSmall(),
        ),
      );

      expect(_renderedLabelStyle(tester).fontFamily, _hostFontFamily);
    });

    testWidgets('floor label keeps the package metrics while inheriting the font', (tester) async {
      await tester.pumpWidget(
        _hostApp(
          floorController: mockFloorController,
          styler: mockStyler,
          locator: mockLocator,
          child: const SBBMapFloorSelector(),
        ),
      );

      final style = _renderedLabelStyle(tester);
      expect(style.fontSize, 16.0);
      expect(style.height, 20.0 / 16.0);
      expect(style.fontWeight, FontWeight.w300);
      expect(style.fontStyle, FontStyle.normal);
    });

    testWidgets('small floor label keeps the package metrics while inheriting the font', (tester) async {
      await tester.pumpWidget(
        _hostApp(
          floorController: mockFloorController,
          styler: mockStyler,
          locator: mockLocator,
          child: const SBBMapFloorSelectorSmall(),
        ),
      );

      final style = _renderedLabelStyle(tester);
      expect(style.fontSize, 12.0);
      expect(style.height, 16.0 / 12.0);
      expect(style.fontWeight, FontWeight.w300);
      expect(style.fontStyle, FontStyle.normal);
    });
  });
}

/// Mirrors the widget tree [SBBMap] builds around its UI controls, below a host
/// application theme that declares [_hostFontFamily].
Widget _hostApp({
  required SBBMapFloorController floorController,
  required SBBMapStyler styler,
  required SBBMapLocator locator,
  required Widget child,
}) {
  return MaterialApp(
    theme: ThemeData(fontFamily: _hostFontFamily),
    home: SBBMapStyleContainer(
      child: SBBMapUiContainer(
        mapStyler: styler,
        mapLocator: locator,
        mapFloorController: floorController,
        child: Center(child: child),
      ),
    ),
  );
}

/// The style the floor label actually renders with, after the ambient default
/// text style and the package's own style have been merged.
TextStyle _renderedLabelStyle(WidgetTester tester) {
  final richText = tester.widget<RichText>(
    find.descendant(of: find.text(_floorLabel), matching: find.byType(RichText)),
  );
  return richText.text.style!;
}
