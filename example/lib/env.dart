import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'JOURNEY_MAPS_TILES_API_KEY', obfuscate: true)
  static String journeyMapsTilesApiKey = _Env.journeyMapsTilesApiKey;
}
