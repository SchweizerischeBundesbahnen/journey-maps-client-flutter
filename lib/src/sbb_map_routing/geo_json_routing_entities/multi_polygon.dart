import 'package:collection/collection.dart';

import 'polygon.dart';

class MultiPolygon {
  const MultiPolygon({required this.polygons});

  factory MultiPolygon.fromGeoJSON(Map<String, dynamic> json) {
    var polygonsList = (json['geometry']['coordinates'] as List)
        .map((polygon) => Polygon.fromGeoJSON(polygon as Map<String, dynamic>))
        .toList();

    return MultiPolygon(polygons: polygonsList);
  }

  final List<Polygon> polygons;

  @override
  bool operator ==(Object other) {
    Function deepEq = const DeepCollectionEquality().equals;

    return identical(this, other) ||
        other is MultiPolygon && runtimeType == other.runtimeType && deepEq(polygons, other.polygons);
  }

  @override
  int get hashCode => polygons.hashCode;
}
