import 'package:collection/collection.dart';

import 'point.dart';

class MultiPoint {
  const MultiPoint({required this.points});

  factory MultiPoint.fromGeoJSON(Map<String, dynamic> json) {
    var pointsList = (json['geometry']['coordinates'] as List)
        .map((point) => Point.fromGeoJSON(point as Map<String, dynamic>))
        .toList();

    return MultiPoint(points: pointsList);
  }

  final List<Point> points;

  @override
  bool operator ==(Object other) {
    Function deepEq = const DeepCollectionEquality().equals;

    return identical(this, other) ||
        other is MultiPoint && runtimeType == other.runtimeType && deepEq(points, other.points);
  }

  @override
  int get hashCode => points.hashCode;
}
