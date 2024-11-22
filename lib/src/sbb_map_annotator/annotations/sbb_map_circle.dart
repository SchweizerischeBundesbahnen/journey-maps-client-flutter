part of 'sbb_map_annotation.dart';

class SBBMapCircle implements SBBMapAnnotation {
  final String _id;
  final LatLng _center;
  final SBBMapCircleStyle? style;
  final bool _draggable;

  @override
  final Map<String, dynamic>? data;

  const SBBMapCircle._({
    required String id,
    required LatLng center,
    this.style,
    required bool draggable,
    this.data,
  })  : _id = id,
        _center = center,
        _draggable = draggable;

  /// A circle to be placed in a [SBBMap].
  ///
  /// Styling can be done with [SBBMapCircleStyle].
  ///
  /// * [center] is the geometrical center of the [SBBMapCircle].
  /// * [style] contains the style properties for this circle.
  /// * [data] can be used to associate custom data with the [SBBMapCircle].
  /// * [draggable] will allow the feature to become draggable. The default is false.
  SBBMapCircle({
    required LatLng center,
    SBBMapCircleStyle? style,
    Map<String, dynamic>? data,
    bool draggable = false,
  }) : this._(
          id: randomString(),
          center: center,
          style: style,
          draggable: draggable,
          data: data,
        );

  @override
  String get id => _id;

  LatLng get center => _center;

  bool get draggable => _draggable;

  @override
  Map<String, dynamic> toGeoJson() {
    final properties = style != null ? style!.toJson() : <String, dynamic>{};
    properties.addAll({
      "id": _id,
      "draggable": _draggable,
      _kPropertyTypeKey: runtimeType.toString(),
    });

    return {
      "type": "Feature",
      "id": _id,
      "properties": properties,
      "geometry": {
        "type": "Point",
        "coordinates": _center.toGeoJsonCoordinates(),
      },
    };
  }

  SBBMapCircle copyWith({
    LatLng? center,
    SBBMapCircleStyle? style,
    bool? draggable,
    Map<String, dynamic>? data,
  }) {
    return SBBMapCircle._(
      id: _id,
      center: center ?? _center,
      style: style ?? this.style,
      draggable: draggable ?? _draggable,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapCircle &&
        other._id == _id &&
        other._center == _center &&
        other.style == style &&
        other._draggable == _draggable &&
        const MapEquality().equals(other.data, data);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      _id.hashCode,
      _center.hashCode,
      style.hashCode,
      _draggable.hashCode,
      const MapEquality().hash(data),
    ]);
  }

  @override
  List<Object> get annotationFilter => [
        Expressions.equal,
        [Expressions.get, _kPropertyTypeKey],
        runtimeType.toString()
      ];
}

class SBBMapCircleStyle {
  /// The radius of the circle, measured in pixels.
  ///
  /// The default value is 5 pixels.
  ///
  /// Circles are sized according to this value before being scaled by `circleScale`.
  final double? radius;

  /// The fill color of the circle.
  ///
  /// The default value is black (`#000000`).
  ///
  /// This property allows for the circle to be filled with a color.
  final Color? fillColor;

  /// The opacity at which the circle's fill will be drawn.
  ///
  /// The default value is 1 (opaque).
  ///
  /// This property allows for the circle's fill to be semi-transparent.
  final double? fillOpacity;

  /// Amount to blur the circle's fill. 1 blurs the circle such that only the
  /// centerpoint is full opacity.
  ///
  /// The default value is 0 (no blur).
  ///
  /// This property allows for the circle's fill to have a blur effect.
  final double? fillBlur;

  /// The color of the circle's stroke.
  ///
  /// The default value is black (`#000000`).
  ///
  /// This property allows for the circle to have a stroke with a color.
  final Color? strokeColor;

  /// The opacity at which the circle's stroke will be drawn.
  ///
  /// The default value is 1 (opaque).
  ///
  /// This property allows for the circle's stroke to be semi-transparent.
  final double? strokeOpacity;

  /// The width of the circle's stroke, measured in pixels.
  ///
  /// The default value is 0 pixels.
  ///
  /// This property allows for the circle to have a stroke with a specific width.
  final double? strokeWidth;

  const SBBMapCircleStyle({
    this.radius,
    this.fillColor,
    this.fillOpacity,
    this.fillBlur,
    this.strokeColor,
    this.strokeOpacity,
    this.strokeWidth,
  });

  SBBMapCircleStyle copyWith(SBBMapCircleStyle other) {
    return SBBMapCircleStyle(
      radius: other.radius ?? radius,
      fillColor: other.fillColor ?? fillColor,
      fillOpacity: other.fillOpacity ?? fillOpacity,
      fillBlur: other.fillBlur ?? fillBlur,
      strokeColor: other.strokeColor ?? strokeColor,
      strokeOpacity: other.strokeOpacity ?? strokeOpacity,
      strokeWidth: other.strokeWidth ?? strokeWidth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (radius != null) 'circleRadius': radius,
      if (fillColor != null) 'circleColor': fillColor!.toHexStringRGB(),
      if (fillOpacity != null) 'circleOpacity': fillOpacity,
      if (fillBlur != null) 'circleBlur': fillBlur,
      if (strokeColor != null) 'circleStrokeColor': strokeColor!.toHexStringRGB(),
      if (strokeOpacity != null) 'circleStrokeOpacity': strokeOpacity,
      if (strokeWidth != null) 'circleStrokeWidth': strokeWidth,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapCircleStyle &&
        other.radius == radius &&
        other.fillColor == fillColor &&
        other.fillOpacity == fillOpacity &&
        other.fillBlur == fillBlur &&
        other.strokeColor == strokeColor &&
        other.strokeOpacity == strokeOpacity &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode {
    return Object.hash(
      radius,
      fillColor,
      fillOpacity,
      fillBlur,
      strokeColor,
      strokeOpacity,
      strokeWidth,
    );
  }
}
