part of 'sbb_map_annotation.dart';

class SBBMapFill implements SBBMapAnnotation {
  final String _id;
  final List<List<LatLng>> _coords;
  final SBBMapFillStyle? style;
  final bool _draggable;

  @override
  final Map<String, dynamic>? data;

  const SBBMapFill._({
    required String id,
    required List<List<LatLng>> coords,
    this.style,
    required bool draggable,
    this.data,
  })  : _id = id,
        _coords = coords,
        _draggable = draggable;

  /// A fill to be placed in a [SBBMap].
  ///
  /// Styling can be done with [SBBMapFillStyle].
  ///
  /// * [coords] are the geographic points of this [SBBMapFill].
  ///   This is an array of array, because there can be holes and islands in the outer polygon.
  /// * [style] contains the style properties for this line.
  /// * [data] can be used to associate custom data with the [SBBMapFill].
  /// * [draggable] will allow the feature to become draggable. The default is false.
  SBBMapFill({
    required List<List<LatLng>> coords,
    SBBMapFillStyle? style,
    Map<String, dynamic>? data,
    bool draggable = false,
  }) : this._(
          id: randomString(),
          coords: coords,
          style: style,
          draggable: draggable,
          data: data,
        );

  @override
  String get id => _id;

  List<List<LatLng>> get coords => _coords;

  bool get draggable => _draggable;

  @override
  Map<String, dynamic> toGeoJson() {
    final properties = style != null ? style!.toJson() : <String, dynamic>{};
    properties.addAll({
      "id": _id,
      "draggable": _draggable,
      "sbbAnnotationType": runtimeType.toString(),
    });

    return {
      "type": "Feature",
      "id": _id,
      "properties": properties,
      "geometry": {
        "type": "Polygon",
        "coordinates": _coords
            .map((List<LatLng> latLngList) => latLngList.map((LatLng latLng) => latLng.toGeoJsonCoordinates()).toList())
            .toList()
      },
    };
  }

  SBBMapFill copyWith({
    List<List<LatLng>>? coords,
    SBBMapFillStyle? style,
    bool? draggable,
    Map<String, dynamic>? data,
  }) {
    return SBBMapFill._(
      id: _id,
      coords: coords ?? _coords,
      style: style ?? this.style,
      draggable: draggable ?? _draggable,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapFill &&
        other._id == _id &&
        const DeepCollectionEquality().equals(other._coords, _coords) &&
        other.style == style &&
        other._draggable == _draggable &&
        const MapEquality().equals(other.data, data);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      _id.hashCode,
      const DeepCollectionEquality().hash(_coords),
      style.hashCode,
      _draggable.hashCode,
      const MapEquality().hash(data)
    ]);
  }

  @override
  List<Object> get annotationFilter => [
        Expressions.equal,
        [Expressions.get, _kPropertyTypeKey],
        runtimeType.toString()
      ];
}

class SBBMapFillStyle {
  /// The opacity of the entire fill layer.
  ///
  /// The default value is 1 (fully opaque).
  ///
  /// In contrast to the `fill-color`, this value will also affect the 1px
  /// stroke around the fill, if the stroke is used.
  final double? fillOpacity;

  /// The color of the filled part of this layer.
  ///
  /// The default value is black (`#000000`).
  ///
  /// This color can be specified as `rgba` with an alpha component and the
  /// color's opacity will not affect the opacity of the 1px stroke, if it is used.
  final Color? fillColor;

  /// The outline color of the fill.
  ///
  /// The default value is black (`#000000`).
  ///
  /// Matches the value of `fill-color` if unspecified.
  final Color? fillOutlineColor;

  /// Name of image in sprite to use for drawing image fills. For seamless
  /// patterns, image width and height must be a factor of two (2, 4, 8,
  /// ..., 512). Note that zoom-dependent expressions will be evaluated only
  /// at integer zoom levels.
  final String? fillPattern;

  const SBBMapFillStyle({
    this.fillOpacity,
    this.fillColor,
    this.fillOutlineColor,
    this.fillPattern,
  });

  SBBMapFillStyle copyWith(SBBMapFillStyle other) {
    return SBBMapFillStyle(
      fillOpacity: other.fillOpacity ?? fillOpacity,
      fillColor: other.fillColor ?? fillColor,
      fillOutlineColor: other.fillOutlineColor ?? fillOutlineColor,
      fillPattern: other.fillPattern ?? fillPattern,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fillOpacity != null) 'fillOpacity': fillOpacity,
      if (fillColor != null) 'fillColor': fillColor!.toHexStringRGB(),
      if (fillOutlineColor != null) 'fillOutlineColor': fillOutlineColor!.toHexStringRGB(),
      if (fillPattern != null) 'fillPattern': fillPattern,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapFillStyle &&
        other.fillOpacity == fillOpacity &&
        other.fillColor == fillColor &&
        other.fillOutlineColor == fillOutlineColor &&
        other.fillPattern == fillPattern;
  }

  @override
  int get hashCode {
    return Object.hash(
      fillOpacity,
      fillColor,
      fillOutlineColor,
      fillPattern,
    );
  }
}
