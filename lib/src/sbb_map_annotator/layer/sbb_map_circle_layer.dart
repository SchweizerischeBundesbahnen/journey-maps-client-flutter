// coverage:ignore-file
part of 'sbb_map_layer_properties.dart';

/// Allows to specify some settings when drawing [SBBMapCircle].
class SBBMapCircleLayer implements SBBMapLayerProperties {
  SBBMapCircleLayer();

  @override
  LayerProperties makeLayerExpressions() => const CircleLayerProperties(
    circleRadius: [Expressions.get, 'circleRadius'],
    circleColor: [Expressions.get, 'circleColor'],
    circleBlur: [Expressions.get, 'circleBlur'],
    circleOpacity: [Expressions.get, 'circleOpacity'],
    circleStrokeWidth: [Expressions.get, 'circleStrokeWidth'],
    circleStrokeColor: [Expressions.get, 'circleStrokeColor'],
    circleStrokeOpacity: [Expressions.get, 'circleStrokeOpacity'],
  );
}
