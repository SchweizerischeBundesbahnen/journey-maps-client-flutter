part of 'sbb_map_annotation.dart';

class SBBMapSymbol implements SBBMapAnnotation {
  final String _symbolURI;

  /// The text displayed with the symbol.
  ///
  /// The text can be stylized using the [SBBMapSymbolStyle] options.
  final String? _text;
  final SBBMapSymbolStyle? style;
  final bool _draggable;

  /// The coordinates at which this symbol will appear.
  final LatLng coords;

  @override
  final Map<String, dynamic>? data;

  final String _id;

  const SBBMapSymbol._({
    required String id,
    required String symbolURI,
    required this.coords,
    String? text,
    this.style,
    this.data,
    required bool draggable,
  })  : _id = id,
        _symbolURI = symbolURI,
        _text = text,
        _draggable = draggable;

  /// A symbol to be placed in a [SBBMap].
  ///
  /// Styling can be done with [SBBMapSymbolStyle].
  ///
  /// * [symbolURI] is an identifier of an icon that was added to the style.
  /// * [coords] is the geometrical position of the [SBBMapSymbol].
  /// * [text] allows to place text with the icon.
  /// * [data] can be used to associate custom data with the [SBBMapSymbol].
  /// * [draggable] will allow the feature to become draggable.<br>
  ///   The default is false.
  SBBMapSymbol({
    required String symbolURI,
    required LatLng coords,
    String? text,
    SBBMapSymbolStyle? style,
    Map<String, dynamic>? data,
    bool draggable = false,
  }) : this._(
          id: randomString(),
          symbolURI: symbolURI,
          coords: coords,
          text: text,
          style: style,
          data: data,
          draggable: draggable,
        );

  @override
  String get id => _id;

  @override
  Map<String, dynamic> toGeoJson() {
    return {
      "type": "Feature",
      "id": id,
      "properties": _buildFeaturePropertiesFromStyle(),
      "geometry": {"type": "Point", "coordinates": coords.toGeoJsonCoordinates()}
    };
  }

  Map<String, dynamic> _buildFeaturePropertiesFromStyle() {
    final properties = style != null ? style!.toJson() : <String, dynamic>{};
    final additionalProperties = {
      "id": id,
      "iconImage": _symbolURI,
      "draggable": _draggable,
      if (_text != null) ...{"textField": _text},
      "sbbAnnotationType": runtimeType.toString(),
    };
    properties.addAll(additionalProperties);
    return properties;
  }

  SBBMapSymbol copyWith({
    String? symbolURI,
    LatLng? coords,
    String? text,
    SBBMapSymbolStyle? style,
    bool? draggable,
    Map<String, String>? data,
  }) {
    return SBBMapSymbol._(
      id: _id,
      symbolURI: symbolURI ?? _symbolURI,
      coords: coords ?? this.coords,
      text: text ?? _text,
      style: style == null ? this.style : this.style?.copyWith(style),
      draggable: draggable ?? _draggable,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapSymbol &&
        other._id == _id &&
        other._symbolURI == _symbolURI &&
        other._text == _text &&
        other.coords == coords &&
        other.style == style &&
        other._draggable == _draggable &&
        const MapEquality().equals(other.data, data);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      _id.hashCode,
      _symbolURI.hashCode,
      _text.hashCode,
      coords.hashCode,
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

/// Configuration options for [SBBMapSymbol] instances.
///
/// Null values are ignored when styling the symbol.
class SBBMapSymbolStyle {
  /// Creates a set of [SBBMapSymbol] configuration options.
  ///
  /// Null values are ignored when styling the symbol.
  const SBBMapSymbolStyle({
    this.iconSize,
    this.iconRotate,
    this.iconOffset,
    this.iconAnchor,
    this.fontNames,
    this.textSize,
    this.textMaxWidth,
    this.textLetterSpacing,
    this.textJustify,
    this.textAnchor,
    this.textRotate,
    this.textTransform,
    this.textOffset,
    this.iconOpacity,
    this.iconColor,
    this.iconHaloColor,
    this.iconHaloWidth,
    this.iconHaloBlur,
    this.textOpacity,
    this.textColor,
    this.textHaloColor,
    this.textHaloWidth,
    this.textHaloBlur,
  });

  /// Font stack to use for displaying text.
  ///
  /// The default values are: [Open Sans Regular, Arial Unicode MS Regular].
  ///
  /// These must be provided as glyphs in the style.
  final List<String>? fontNames;

  /// Which part of the icon should be placed closest to its anchor.
  ///
  /// The options are:<br>
  /// "center" | "left" | "right" | "top" | "bottom" |<br>
  /// "top-left" | "top-right" | "bottom-left" | "bottom-right"
  final String? iconAnchor;

  /// The color of the symbol. This can only be used with sdf icons.
  ///
  /// The default value is: [Colors.black]
  final Color? iconColor;

  /// Fade out the symbol's halo towards the outside.
  ///
  /// Symbol halos can only be used with .sdf icons.
  ///
  /// The default is 0.<br>
  /// Cannot be negative.
  final double? iconHaloBlur;

  /// The color of the symbol's halo.
  ///
  /// Symbol halos can only be used with .sdf icons.
  ///
  /// The default value is: [Colors.black]
  final Color? iconHaloColor;

  /// Distance of halo to the symbol outline.
  ///
  /// Symbol halos can only be used with .sdf icons.
  ///
  /// The default is 0.<br>
  /// Cannot be negative.
  final double? iconHaloWidth;

  /// Distance between the symbols's anchor and its geometrical position.
  ///
  /// Positive values indicate right and down, while negative values
  /// indicate left and up.
  ///
  /// The default is [Offset.zero].
  final Offset? iconOffset;

  /// The opacity at which the symbol will be drawn.
  ///
  /// The default is 1.0.<br>
  /// The accepted range is: [0, 1]
  final double? iconOpacity;

  /// Rotates the icon clockwise.
  ///
  /// The default value is 0.
  final double? iconRotate;

  /// Scales the original size of the icon by the provided factor.
  ///
  /// The default value is 1.0.
  final double? iconSize;

  /// Which part of the text should be placed closest to its anchor.
  ///
  /// The options are:<br>
  /// "center" | "left" | "right" | "top" | "bottom" |<br>
  /// "top-left" | "top-right" | "bottom-left" | "bottom-right"
  ///
  /// The default is "center".
  final String? textAnchor;

  /// The color with which the text will be drawn.
  ///
  /// The default value is: [Colors.black]
  final Color? textColor;

  /// The halo's fadeout distance towards the outside.
  ///
  /// The default value is 0.<br>
  /// The value cannot be negative.
  final double? textHaloBlur;

  /// The color of the text's halo, which helps it stand out from
  /// backgrounds.
  ///
  /// The default value is [Colors.black].
  final Color? textHaloColor;

  /// Distance of halo to the font outline.
  ///
  /// The max text halo width is 0.25 * text-size.
  ///
  /// The default value is 0.<br>
  /// The value cannot be negative.
  final double? textHaloWidth;

  /// The justification of the text field.
  ///
  /// The options are:<br>
  ///   "auto" | "left" | "center" | "right"
  ///
  /// The default is "center".
  final String? textJustify;

  /// The spacing between letters of the [SBBMapSymbol] text field.
  ///
  /// Defaults to 0.<br>
  /// Cannot be negative.
  final double? textLetterSpacing;

  /// The maximum line width for text wrapping.
  ///
  /// The default value is 10.<br>
  /// Cannot be negative.
  final double? textMaxWidth;

  /// The offset between the text's anchor and the symbol's position.
  ///
  /// The default is [Offset.zero].
  final Offset? textOffset;

  /// The opacity at which the text will be drawn.
  ///
  /// The default is 1.0.<br>
  /// The accepted range is: [0, 1]
  final double? textOpacity;

  /// Rotates the text clockwise.
  ///
  /// The default value is 0.
  final double? textRotate;

  /// The font size of the [SBBMapSymbol] text field.
  ///
  /// The default value is 16.<br>
  /// Cannot be negative.
  final double? textSize;

  /// Specifies how to capitalize text, similar to the CSS `text-transform`
  /// property.
  ///
  /// Options:
  /// * "none": The text is not altered (default).
  /// * "uppercase": Forces all letters to be displayed in uppercase.
  /// * "lowercase": Forces all letters to be displayed in lowercase.
  final String? textTransform;

  SBBMapSymbolStyle copyWith(SBBMapSymbolStyle other) {
    return SBBMapSymbolStyle(
      iconSize: other.iconSize ?? iconSize,
      iconRotate: other.iconRotate ?? iconRotate,
      iconOffset: other.iconOffset ?? iconOffset,
      iconAnchor: other.iconAnchor ?? iconAnchor,
      fontNames: other.fontNames ?? fontNames,
      textSize: other.textSize ?? textSize,
      textMaxWidth: other.textMaxWidth ?? textMaxWidth,
      textLetterSpacing: other.textLetterSpacing ?? textLetterSpacing,
      textJustify: other.textJustify ?? textJustify,
      textAnchor: other.textAnchor ?? textAnchor,
      textRotate: other.textRotate ?? textRotate,
      textTransform: other.textTransform ?? textTransform,
      textOffset: other.textOffset ?? textOffset,
      iconOpacity: other.iconOpacity ?? iconOpacity,
      iconColor: other.iconColor ?? iconColor,
      iconHaloColor: other.iconHaloColor ?? iconHaloColor,
      iconHaloWidth: other.iconHaloWidth ?? iconHaloWidth,
      iconHaloBlur: other.iconHaloBlur ?? iconHaloBlur,
      textOpacity: other.textOpacity ?? textOpacity,
      textColor: other.textColor ?? textColor,
      textHaloColor: other.textHaloColor ?? textHaloColor,
      textHaloWidth: other.textHaloWidth ?? textHaloWidth,
      textHaloBlur: other.textHaloBlur ?? textHaloBlur,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (iconSize != null) ...{'iconSize': iconSize},
      if (iconRotate != null) ...{'iconRotate': iconRotate},
      if (iconOffset != null) ...{
        'iconOffset': [iconOffset!.dx, iconOffset!.dy]
      },
      if (iconAnchor != null) ...{'iconAnchor': iconAnchor},
      if (fontNames != null) ...{'fontNames': fontNames},
      if (textSize != null) ...{'textSize': textSize},
      if (textMaxWidth != null) ...{'textMaxWidth': textMaxWidth},
      if (textLetterSpacing != null) ...{'textLetterSpacing': textLetterSpacing},
      if (textJustify != null) ...{'textJustify': textJustify},
      if (textAnchor != null) ...{'textAnchor': textAnchor},
      if (textRotate != null) ...{'textRotate': textRotate},
      if (textTransform != null) ...{'textTransform': textTransform},
      if (textOffset != null) ...{
        'textOffset': [textOffset!.dx, textOffset!.dy]
      },
      if (iconOpacity != null) ...{'iconOpacity': iconOpacity},
      if (iconColor != null) ...{'iconColor': iconColor!.toHexStringRGB()},
      if (iconHaloColor != null) ...{'iconHaloColor': iconHaloColor!.toHexStringRGB()},
      if (iconHaloWidth != null) ...{'iconHaloWidth': iconHaloWidth},
      if (iconHaloBlur != null) ...{'iconHaloBlur': iconHaloBlur},
      if (textOpacity != null) ...{'textOpacity': textOpacity},
      if (textColor != null) ...{'textColor': textColor!.toHexStringRGB()},
      if (textHaloColor != null) ...{'textHaloColor': textHaloColor!.toHexStringRGB()},
      if (textHaloWidth != null) ...{'textHaloWidth': textHaloWidth},
      if (textHaloBlur != null) ...{'textHaloBlur': textHaloBlur},
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SBBMapSymbolStyle &&
        other.iconSize == iconSize &&
        other.iconRotate == iconRotate &&
        other.iconOffset == iconOffset &&
        other.iconAnchor == iconAnchor &&
        const ListEquality().equals(other.fontNames, fontNames) &&
        other.textSize == textSize &&
        other.textMaxWidth == textMaxWidth &&
        other.textLetterSpacing == textLetterSpacing &&
        other.textJustify == textJustify &&
        other.textAnchor == textAnchor &&
        other.textRotate == textRotate &&
        other.textTransform == textTransform &&
        other.textOffset == textOffset &&
        other.iconOpacity == iconOpacity &&
        other.iconColor == iconColor &&
        other.iconHaloColor == iconHaloColor &&
        other.iconHaloWidth == iconHaloWidth &&
        other.iconHaloBlur == iconHaloBlur &&
        other.textOpacity == textOpacity &&
        other.textColor == textColor &&
        other.textHaloColor == textHaloColor &&
        other.textHaloWidth == textHaloWidth &&
        other.textHaloBlur == textHaloBlur;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      iconSize,
      iconRotate,
      iconOffset,
      iconAnchor,
      fontNames,
      textSize,
      textMaxWidth,
      textLetterSpacing,
      textJustify,
      textAnchor,
      textRotate,
      textTransform,
      textOffset,
      iconOpacity,
      iconColor,
      iconHaloColor,
      iconHaloWidth,
      iconHaloBlur,
      textOpacity,
      textColor,
      textHaloColor,
      textHaloWidth,
      textHaloBlur,
    ]);
  }
}
