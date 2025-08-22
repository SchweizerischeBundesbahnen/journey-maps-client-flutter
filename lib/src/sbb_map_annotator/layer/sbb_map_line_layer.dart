// coverage:ignore-file
part of 'sbb_map_layer_properties.dart';

/// Allows to specify some settings when drawing [SBBMapLine].
class SBBMapLineLayer implements SBBMapLayerProperties {
  SBBMapLineLayer();

  @override
  LayerProperties makeLayerExpressions() => const LineLayerProperties(
    lineJoin: [Expressions.get, 'lineJoin'],
    lineOpacity: [Expressions.get, 'lineOpacity'],
    lineColor: [Expressions.get, 'lineColor'],
    lineWidth: [Expressions.get, 'lineWidth'],
    lineGapWidth: [Expressions.get, 'lineGapWidth'],
    lineOffset: [Expressions.get, 'lineOffset'],
    lineBlur: [Expressions.get, 'lineBlur'],
  );
}
