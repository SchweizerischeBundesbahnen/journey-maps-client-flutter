import 'package:collection/collection.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class LineString {
  const LineString({
    required this.coordinates,
  });

  factory LineString.fromGeoJSON(Map<String, dynamic> json) {
    var coordinatesList = (json['geometry']['coordinates'] as List)
        .map((coordinate) => LatLng(
              coordinate[1] as double,
              coordinate[0] as double,
            ))
        .toList();

    return LineString(
      coordinates: coordinatesList,
    );
  }

  final List<LatLng> coordinates;

  @override
  bool operator ==(Object other) {
    Function deepEq = const DeepCollectionEquality().equals;

    return identical(this, other) ||
        other is LineString && runtimeType == other.runtimeType && deepEq(coordinates, other.coordinates);
  }

  @override
  int get hashCode => coordinates.hashCode;
}
