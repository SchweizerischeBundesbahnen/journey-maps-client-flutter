import 'package:maplibre_gl/maplibre_gl.dart';

class RokasPOI {
  const RokasPOI({
    required this.id,
    required this.sbbId,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.icon,
    this.operator,
    required this.coordinates,
  });

  factory RokasPOI.fromGeoJSON(Map<String, dynamic> json) {
    return RokasPOI(
      // ignore: unnecessary_cast
      id: json['id'].toString() as String,
      sbbId: json['properties']['sbbId'] as String,
      name: json['properties']['name'] as String,
      category: json['properties']['category'] as String,
      subCategory: json['properties']['subCategory'] as String,
      icon: json['properties']['icon'] as String,
      operator: json['properties']['operator'] != null ? json['properties']['operator'] as String : null,
      coordinates: LatLng(
        json['geometry']['coordinates'][1] as double,
        json['geometry']['coordinates'][0] as double,
      ),
    );
  }
  final String id;
  final String sbbId;
  final String name;
  final String category;
  final String subCategory;
  final String icon;
  final String? operator;
  final LatLng coordinates;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RokasPOI &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sbbId == other.sbbId &&
          name == other.name &&
          category == other.category &&
          subCategory == other.subCategory &&
          icon == other.icon &&
          operator == other.operator &&
          coordinates == other.coordinates;

  @override
  int get hashCode =>
      id.hashCode ^
      sbbId.hashCode ^
      name.hashCode ^
      category.hashCode ^
      subCategory.hashCode ^
      icon.hashCode ^
      operator.hashCode ^
      coordinates.hashCode;
}
