part of 'sbb_map_annotation.dart';

class SBBMapLine implements SBBMapAnnotation {
  final String _id;
  final List<LatLng> _vertices;
  final SBBMapLineStyle? style;
  final bool _draggable;

  @override
  final Map<String, dynamic>? data;

  const SBBMapLine._({
    required String id,
    required List<LatLng> vertices,
    this.style,
    required bool draggable,
    this.data,
  }) : _id = id,
       _vertices = vertices,
       _draggable = draggable;

  /// A line to be placed in a [SBBMap].
  ///
  /// Styling can be done with [SBBMapLineStyle].
  ///
  /// * [vertices] are the geographic points of this [SBBMapLine].
  /// * [style] contains the style properties for this line.
  /// * [data] can be used to associate custom data with the [SBBMapLine].
  /// * [draggable] will allow the feature to become draggable. The default is false.
  SBBMapLine({
    required List<LatLng> vertices,
    SBBMapLineStyle? style,
    Map<String, dynamic>? data,
    bool draggable = false,
  }) : this._(id: randomString(), vertices: vertices, style: style, draggable: draggable, data: data);

  @override
  String get id => _id;

  List<LatLng> get vertices => _vertices;

  bool get draggable => _draggable;

  @override
  Map<String, dynamic> toGeoJson() {
    final properties = style != null ? style!.toJson() : <String, dynamic>{};
    properties.addAll({"id": _id, "draggable": _draggable, "sbbAnnotationType": runtimeType.toString()});

    return {
      "type": "Feature",
      "id": _id,
      "properties": properties,
      "geometry": {"type": "LineString", "coordinates": _vertices.map((n) => n.toGeoJsonCoordinates()).toList()},
    };
  }

  SBBMapLine copyWith({List<LatLng>? nodes, SBBMapLineStyle? style, bool? draggable, Map<String, dynamic>? data}) {
    return SBBMapLine._(
      id: _id,
      vertices: nodes ?? _vertices,
      style: style ?? this.style,
      draggable: draggable ?? _draggable,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapLine &&
        other._id == _id &&
        const ListEquality().equals(other._vertices, _vertices) &&
        other.style == style &&
        other._draggable == _draggable &&
        const MapEquality().equals(other.data, data);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      _id.hashCode,
      const ListEquality().hash(_vertices),
      style.hashCode,
      _draggable.hashCode,
      const MapEquality().hash(data),
    ]);
  }

  @override
  List<Object> get annotationFilter => [
    Expressions.equal,
    [Expressions.get, _kPropertyTypeKey],
    runtimeType.toString(),
  ];
}

class SBBMapLineStyle {
  /// The display of lines when joining.
  ///
  /// Options:
  ///   "bevel"
  ///      A join with a squared-off end which is drawn beyond the endpoint
  ///      of the line at a distance of one-half of the line's width.
  ///   "round"
  ///      A join with a rounded end which is drawn beyond the endpoint of
  ///      the line at a radius of one-half of the line's width and centered
  ///      on the endpoint of the line.
  ///   "miter"
  ///      A join with a sharp, angled corner which is drawn with the outer
  ///      sides beyond the endpoint of the path until they meet.
  final String? lineJoin;

  // Paint Properties
  /// The opacity at which the line will be drawn.
  ///
  /// The default is: 1.
  ///
  /// Must be in the range [0, 1].
  final double? lineOpacity;

  /// The color with which the line will be drawn.
  ///
  /// The default value is [Colors.black].
  final Color? lineColor;

  /// Stroke thickness.
  ///
  /// The default is: 1. Cannot be negative.
  final double? lineWidth;

  /// Draws a line casing outside of a line's actual path. Value indicates
  /// the width of the inner gap.
  ///
  /// The default is: 0. Cannot be negative.
  final double? lineGapWidth;

  /// The line's offset. A positive value offsets the
  /// line to the right, relative to the direction of the line, and a
  /// negative value to the left.
  ///
  /// The default is: 0.
  final double? lineOffset;

  /// Blur applied to the line, in pixels.
  ///
  /// The default is: 0. Cannot be negative.
  final double? lineBlur;

  /// Specifies the lengths of the alternating dashes and gaps that form the
  /// dash pattern. The lengths are later scaled by the line width. To
  /// convert a dash length to pixels, multiply the length by the current
  /// line width. Note that GeoJSON sources with `lineMetrics: true`
  /// specified won't render dashed lines to the expected scale. Also note
  /// that zoom-dependent expressions will be evaluated only at integer zoom
  /// levels.
  final List<double>? lineDasharray;

  /// Name of image in sprite to use for drawing image lines. For seamless
  /// patterns, image width must be a factor of two (2, 4, 8, ..., 512).
  /// Note that zoom-dependent expressions will be evaluated only at integer
  /// zoom levels.
  ///
  /// Type: resolvedImage
  final String? linePattern;

  const SBBMapLineStyle({
    this.lineJoin,
    this.lineOpacity,
    this.lineColor,
    this.lineWidth,
    this.lineGapWidth,
    this.lineOffset,
    this.lineBlur,
    this.lineDasharray,
    this.linePattern,
  });

  SBBMapLineStyle copyWith(SBBMapLineStyle other) {
    return SBBMapLineStyle(
      lineJoin: other.lineJoin ?? lineJoin,
      lineOpacity: other.lineOpacity ?? lineOpacity,
      lineColor: other.lineColor ?? lineColor,
      lineWidth: other.lineWidth ?? lineWidth,
      lineGapWidth: other.lineGapWidth ?? lineGapWidth,
      lineOffset: other.lineOffset ?? lineOffset,
      lineBlur: other.lineBlur ?? lineBlur,
      lineDasharray: other.lineDasharray ?? lineDasharray,
      linePattern: other.linePattern ?? linePattern,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lineJoin != null) 'lineJoin': lineJoin,
      if (lineOpacity != null) 'lineOpacity': lineOpacity,
      if (lineColor != null) 'lineColor': lineColor!.toHexStringRGB(),
      if (lineWidth != null) 'lineWidth': lineWidth,
      if (lineGapWidth != null) 'lineGapWidth': lineGapWidth,
      if (lineOffset != null) 'lineOffset': lineOffset,
      if (lineBlur != null) 'lineBlur': lineBlur,
      if (lineDasharray != null) 'lineDasharray': lineDasharray.toString(),
      if (linePattern != null) 'linePattern': linePattern,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapLineStyle &&
        other.lineJoin == lineJoin &&
        other.lineOpacity == lineOpacity &&
        other.lineColor == lineColor &&
        other.lineWidth == lineWidth &&
        other.lineGapWidth == lineGapWidth &&
        other.lineOffset == lineOffset &&
        other.lineBlur == lineBlur &&
        const ListEquality().equals(other.lineDasharray, lineDasharray) &&
        other.linePattern == linePattern;
  }

  @override
  int get hashCode {
    return Object.hash(
      lineJoin,
      lineOpacity,
      lineColor,
      lineWidth,
      lineGapWidth,
      lineOffset,
      lineBlur,
      lineDasharray,
      linePattern,
    );
  }
}
