import 'package:maplibre_gl/maplibre_gl.dart';

class Point {
  const Point({
    required this.coordinates,
  });

  factory Point.fromGeoJSON(Map<String, dynamic> json) {
    return Point(
      coordinates: LatLng(
        json['geometry']['coordinates'][1] as double,
        json['geometry']['coordinates'][0] as double,
      ),
    );
  }

  final LatLng coordinates;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Point && runtimeType == other.runtimeType && coordinates == other.coordinates;

  @override
  int get hashCode => coordinates.hashCode;
}
