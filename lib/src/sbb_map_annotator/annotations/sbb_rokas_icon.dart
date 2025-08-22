part of 'sbb_map_annotation.dart';

class SBBRokasIcon implements SBBMapAnnotation {
  final String _symbolURI;
  final LatLng coords;
  final bool _draggable;
  final String _id;

  @override
  final Map<String, dynamic>? data;

  const SBBRokasIcon._({
    required String id,
    required String symbolURI,
    required this.coords,
    this.data,
    required bool draggable,
  }) : _id = id,
       _symbolURI = symbolURI,
       _draggable = draggable;

  /// A RokasIcon to be placed in a [SBBMap].
  ///
  /// * [symbolURI] is an identifier of an icon that was added to the style.
  ///   The available icons are embedded in the sprite of the map style. Therefore
  ///   the [symbolURI] must be available in the current style.
  ///
  ///   See [RokasIcons] for available identifier.
  /// * [coords] is the geometrical position of the [SBBMapSymbol].
  /// * [data] can be used to associate custom data with the [SBBMapSymbol].
  /// * [draggable] will allow the feature to become draggable.<br>
  ///   The default is false.
  SBBRokasIcon({required String symbolURI, required LatLng coords, Map<String, dynamic>? data, bool draggable = false})
    : this._(id: randomString(), symbolURI: symbolURI, coords: coords, data: data, draggable: draggable);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> toGeoJson() => {
    "type": "Feature",
    "id": id,
    "properties": {
      "id": id,
      "iconImage": _symbolURI,
      "draggable": _draggable,
      "sbbAnnotationType": runtimeType.toString(),
    },
    "geometry": {"type": "Point", "coordinates": coords.toGeoJsonCoordinates()},
  };

  SBBRokasIcon copyWith({String? symbolURI, LatLng? coords, bool? draggable, Map<String, String>? data}) {
    return SBBRokasIcon._(
      id: _id,
      symbolURI: symbolURI ?? _symbolURI,
      coords: coords ?? this.coords,
      draggable: draggable ?? _draggable,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBRokasIcon &&
        other._id == _id &&
        other._symbolURI == _symbolURI &&
        other.coords == coords &&
        other._draggable == _draggable &&
        const MapEquality().equals(other.data, data);
  }

  @override
  int get hashCode {
    return Object.hashAll([_id.hashCode, _symbolURI.hashCode, coords.hashCode, _draggable.hashCode, data.hashCode]);
  }

  @override
  List<Object> get annotationFilter => [
    Expressions.equal,
    [Expressions.get, _kPropertyTypeKey],
    runtimeType.toString(),
  ];
}
