import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class AnnotatorFixture {
  // only available here and in Annotator
  static const kSourceId = 'sbb_map_annotations';
  static const kSymbolIdentifier = 'sbb_map_annotator_symbol';
  static const kRokasIconIdentifier = 'sbb_map_annotator_rokas_icon';

  static const fakeURI = 'fakeURI';
  static const fakeCoords = LatLng(0.1, 1.0);
  static const fakePoint = Point(0.2, 1.5);
  static const fakeLayerId = "fakeLayerId";
  static final fakeAnnotation = Circle('fakeId', CircleOptions());

  static SBBMapSymbol simpleSymbol() => SBBMapSymbol(symbolURI: fakeURI, coords: fakeCoords);

  static SBBRokasIcon simpleRokasIcon() => SBBRokasIcon(symbolURI: fakeURI, coords: fakeCoords);

  static const fakeImageName = 'fakeImageName';
  static final emptyImage = Uint8List(0);
  static final fakeImage = Uint8List(12);
  static const fakeImageName2 = 'fakeImageName2';
}
