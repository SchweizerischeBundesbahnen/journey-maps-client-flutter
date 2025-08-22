// coverage:ignore-file
part of 'sbb_map_layer_properties.dart';

/// Allows to specify some settings when drawing [SBBMapFill].
class SBBMapFillLayer implements SBBMapLayerProperties {
  SBBMapFillLayer();

  @override
  LayerProperties makeLayerExpressions() => const FillLayerProperties(
    fillOpacity: [Expressions.get, 'fillOpacity'],
    fillColor: [Expressions.get, 'fillColor'],
    fillOutlineColor: [Expressions.get, 'fillOutlineColor'],
  );
}
