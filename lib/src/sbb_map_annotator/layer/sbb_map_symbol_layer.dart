// coverage:ignore-file
part of 'sbb_map_layer_properties.dart';

/// Allows to specify some settings when drawing [SBBMapSymbol].
class SBBMapSymbolLayer implements SBBMapLayerProperties {
  /// If true, the icon will be visible even if it collides with other
  /// previously drawn symbols.
  ///
  /// The default is false.
  final bool iconAllowOverlap;

  /// If true, the text will be visible even if it collides with other
  /// previously drawn symbols.
  ///
  /// The default is false.
  final bool iconIgnorePlacement;

  /// Whether to allow overlap of the text of [SBBMapSymbol].
  ///
  /// The default is false.
  final bool textAllowOverlap;

  /// If true, other symbols can be visible even if they collide with the
  /// text.
  ///
  /// The default is false.
  final bool textIgnorePlacement;

  SBBMapSymbolLayer({
    this.iconAllowOverlap = false,
    this.iconIgnorePlacement = false,
    this.textAllowOverlap = false,
    this.textIgnorePlacement = false,
  });

  @override
  LayerProperties makeLayerExpressions() => SymbolLayerProperties(
    iconSize: [Expressions.get, 'iconSize'],
    iconImage: [Expressions.get, 'iconImage'],
    iconRotate: [Expressions.get, 'iconRotate'],
    iconOffset: [Expressions.get, 'iconOffset'],
    iconAnchor: [Expressions.get, 'iconAnchor'],
    iconOpacity: [Expressions.get, 'iconOpacity'],
    iconColor: [Expressions.get, 'iconColor'],
    iconHaloColor: [Expressions.get, 'iconHaloColor'],
    iconHaloWidth: [Expressions.get, 'iconHaloWidth'],
    iconHaloBlur: [Expressions.get, 'iconHaloBlur'],
    textFont: [
      Expressions.caseExpression,
      [Expressions.has, 'fontNames'],
      [Expressions.get, 'fontNames'],
      [
        Expressions.literal,
        ["Open Sans Regular", "Arial Unicode MS Regular"],
      ],
    ],
    textField: [Expressions.get, 'textField'],
    textSize: [Expressions.get, 'textSize'],
    textMaxWidth: [Expressions.get, 'textMaxWidth'],
    textLetterSpacing: [Expressions.get, 'textLetterSpacing'],
    textJustify: [Expressions.get, 'textJustify'],
    textAnchor: [Expressions.get, 'textAnchor'],
    textRotate: [Expressions.get, 'textRotate'],
    textTransform: [Expressions.get, 'textTransform'],
    textOffset: [Expressions.get, 'textOffset'],
    textOpacity: [Expressions.get, 'textOpacity'],
    textColor: [Expressions.get, 'textColor'],
    textHaloColor: [Expressions.get, 'textHaloColor'],
    textHaloWidth: [Expressions.get, 'textHaloWidth'],
    textHaloBlur: [Expressions.get, 'textHaloBlur'],
    symbolSortKey: [Expressions.get, 'zIndex'],
    iconAllowOverlap: iconAllowOverlap,
    iconIgnorePlacement: iconIgnorePlacement,
    textAllowOverlap: textAllowOverlap,
    textIgnorePlacement: textIgnorePlacement,
  );
}
