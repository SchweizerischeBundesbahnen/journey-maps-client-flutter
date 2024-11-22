import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const fakeURI = 'fakeURI';
const fakeCoords = LatLng(12.0, 19.0);

const LatLng fakeCenter = LatLng(47.3769, 8.5417);
const Map<String, dynamic> fakeData = {'key': 'value'};

final simpleSymbolFixture = SBBMapSymbol(symbolURI: fakeURI, coords: fakeCoords);

const fakeRokasIconURI = RokasIcons.brightActiveBlackConstruction;
final simpleRokasIconFixture = SBBRokasIcon(
  symbolURI: fakeRokasIconURI,
  coords: fakeCoords,
);

List<Object> createAnnotationFilter(String type) {
  return [
    '==',
    ['get', 'sbbAnnotationType'],
    type
  ];
}

// Helper function to create a fixture of SBBMapCircle

SBBMapCircle createCircleFixture({
  LatLng center = fakeCenter,
  SBBMapCircleStyle? style,
  Map<String, dynamic>? data,
  bool draggable = false,
}) {
  return SBBMapCircle(
    center: center,
    style: style,
    data: data,
    draggable: draggable,
  );
}

SBBMapLine createLineFixture({
  List<LatLng>? vertices,
  SBBMapLineStyle? style,
  Map<String, dynamic>? data,
  bool draggable = false,
}) {
  // Replace with your actual SBBMapLine creation logic
  return SBBMapLine(
    vertices: vertices ?? [const LatLng(0, 0), const LatLng(1, 1)],
    style: style,
    data: data,
    draggable: draggable,
  );
}

// Helper function to create a default SBBMapFill instance for testing
SBBMapFill createFillFixture({
  List<List<LatLng>>? coords,
  SBBMapFillStyle? style,
  Map<String, dynamic>? data,
  bool draggable = false,
}) {
  return SBBMapFill(
    coords: coords ??
        [
          [const LatLng(0, 0), const LatLng(0, 1), const LatLng(1, 1), const LatLng(1, 0)]
        ],
    style: style,
    data: data,
    draggable: draggable,
  );
}
