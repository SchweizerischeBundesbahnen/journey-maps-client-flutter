import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

import 'geometry_type.dart';
import 'line_string.dart';
import 'multi_line_string.dart';
import 'multi_point.dart';
import 'multi_polygon.dart';
import 'point.dart';
import 'polygon.dart';

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
        geometryType = .point;
        geometry = Point.fromGeoJSON(json);
        break;
      case 'MultiPoint':
        geometryType = .multiPoint;
        geometry = MultiPoint.fromGeoJSON(json);
        break;
      case 'LineString':
        geometryType = .lineString;
        geometry = LineString.fromGeoJSON(json);
        break;
      case 'MultiLineString':
        geometryType = .multiLineString;
        geometry = MultiLineString.fromGeoJSON(json);
        break;
      case 'Polygon':
        geometryType = .polygon;
        geometry = Polygon.fromGeoJSON(json);
        break;
      case 'MultiPolygon':
        geometryType = .multiPolygon;
        geometry = MultiPolygon.fromGeoJSON(json);
        break;
      default:
        geometryType = .unknown;
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
      .point => SBBMapCircle(center: (geometry as Point).coordinates),
      .multiPoint => throw UnimplementedError(),
      .lineString => SBBMapLine(vertices: (geometry as LineString).coordinates),
      .multiLineString => throw UnimplementedError(),
      .polygon => SBBMapFill(coords: (geometry as Polygon).coordinates),
      .multiPolygon => throw UnimplementedError(),
      .unknown => throw UnimplementedError(),
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
