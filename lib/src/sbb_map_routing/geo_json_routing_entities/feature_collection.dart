import 'package:collection/collection.dart';

import 'feature.dart';

/// A collection of geographic features.
///
/// This class represents a collection of geographic features
/// along with a bounding box
class FeatureCollection {
  /// Creates a [FeatureCollection] with the specified features and bounding box.
  ///
  /// The [features] parameter is required and represents the list of geographic features.
  /// The [bbox] parameter is required and represents the bounding box of the features.
  const FeatureCollection({required this.features, required this.bbox});

  /// Creates a [FeatureCollection] from a GeoJSON map.
  ///
  /// The [json] parameter is a map representation of the GeoJSON object.
  /// This factory constructor parses the GeoJSON and initializes the [features] and [bbox].
  factory FeatureCollection.fromGeoJSON(Map<String, dynamic> json) {
    var featuresList = (json['features'] as List)
        .map((feature) => Feature.fromGeoJSON(feature as Map<String, dynamic>))
        .toList();

    return FeatureCollection(features: featuresList, bbox: List<double>.from(json['bbox'] as List));
  }

  /// The list of geographic features in this collection.
  final List<Feature> features;

  /// The bounding box of the geographic features.
  final List<double> bbox;

  @override
  bool operator ==(Object other) {
    Function deepEq = const DeepCollectionEquality().equals;

    return identical(this, other) ||
        other is FeatureCollection &&
            runtimeType == other.runtimeType &&
            deepEq(features, other.features) &&
            deepEq(bbox, other.bbox);
  }

  @override
  int get hashCode => features.hashCode;
}
