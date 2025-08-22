import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

import 'geometry_type.dart';
import 'point.dart';
import 'multi_point.dart';
import 'line_string.dart';
import 'multi_line_string.dart';
import 'polygon.dart';
import 'multi_polygon.dart';

/// Represents a geographic feature.
///
/// This class encapsulates the geometry, geometry type, and properties
/// of a geographic feature.
class Feature {
  /// Creates a [Feature] with the specified geometry, geometry type, and properties.
  ///
  /// The [geometry] parameter is required and represents the geometric shape of the feature.
  /// The [geometryType] parameter is required and indicates the type of geometry.
  /// The [properties] parameter is required and represents additional data associated with the feature.
  const Feature({required this.geometry, required this.geometryType, required this.properties});

  /// Creates a [Feature] from a GeoJSON map.
  ///
  /// The [json] parameter is a map representation of the GeoJSON object.
  /// This factory constructor parses the GeoJSON and initializes the [geometry],
  /// [geometryType], and [properties].
  factory Feature.fromGeoJSON(Map<String, dynamic> json) {
    GeometryType geometryType;
    dynamic geometry;
    String type = json['geometry']['type'] as String;

    switch (type) {
      case 'Point':
        geometryType = GeometryType.point;
        geometry = Point.fromGeoJSON(json);
        break;
      case 'MultiPoint':
        geometryType = GeometryType.multiPoint;
        geometry = MultiPoint.fromGeoJSON(json);
        break;
      case 'LineString':
        geometryType = GeometryType.lineString;
        geometry = LineString.fromGeoJSON(json);
        break;
      case 'MultiLineString':
        geometryType = GeometryType.multiLineString;
        geometry = MultiLineString.fromGeoJSON(json);
        break;
      case 'Polygon':
        geometryType = GeometryType.polygon;
        geometry = Polygon.fromGeoJSON(json);
        break;
      case 'MultiPolygon':
        geometryType = GeometryType.multiPolygon;
        geometry = MultiPolygon.fromGeoJSON(json);
        break;
      default:
        geometryType = GeometryType.unknown;
        geometry = null;
    }

    return Feature(geometry: geometry, geometryType: geometryType, properties: json['properties']);
  }

  /// The geometric shape of the feature.
  final dynamic geometry;

  /// The type of geometry.
  final GeometryType geometryType;

  /// Additional data associated with the feature.
  final Map<String, dynamic> properties;

  /// Converts the feature to an [SBBMapAnnotation].
  ///
  /// Depending on the [geometryType], this method creates the corresponding
  /// map annotation. Throws an [UnimplementedError] for unsupported geometry types.
  SBBMapAnnotation toAnnotation() {
    return switch (geometryType) {
      GeometryType.point => SBBMapCircle(center: (geometry as Point).coordinates),
      GeometryType.multiPoint => throw UnimplementedError(),
      GeometryType.lineString => SBBMapLine(vertices: (geometry as LineString).coordinates),
      GeometryType.multiLineString => throw UnimplementedError(),
      GeometryType.polygon => SBBMapFill(coords: (geometry as Polygon).coordinates),
      GeometryType.multiPolygon => throw UnimplementedError(),
      GeometryType.unknown => throw UnimplementedError(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Feature &&
          runtimeType == other.runtimeType &&
          geometry == other.geometry &&
          geometryType == other.geometryType;

  @override
  int get hashCode => geometry.hashCode ^ geometryType.hashCode;
}
