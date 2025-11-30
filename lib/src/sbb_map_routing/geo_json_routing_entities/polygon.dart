import 'package:collection/collection.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class Polygon {
  const Polygon({required this.coordinates});

  factory Polygon.fromGeoJSON(Map<String, dynamic> json) {
    var coordinatesList = (json['geometry']['coordinates'] as List)
        .map(
          (ring) =>
              (ring as List).map((coordinate) => LatLng(coordinate[1] as double, coordinate[0] as double)).toList(),
        )
        .toList();

    return Polygon(coordinates: coordinatesList);
  }

  final List<List<LatLng>> coordinates;

  @override
  bool operator ==(Object other) {
    Function deepEq = const DeepCollectionEquality().equals;

    return identical(this, other) ||
        other is Polygon && runtimeType == other.runtimeType && deepEq(coordinates, other.coordinates);
  }

  @override
  int get hashCode => coordinates.hashCode;
}
