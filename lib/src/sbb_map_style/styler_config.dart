import 'package:logger/logger.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/api_key_missing_exception.dart';

/// Resolves the API key, the integration flag and the style URLs for
/// `SBBMapsMapStyler`.
///
/// Not exported from the package.
abstract final class StylerConfig {
  static String _prodStyleUrl(String styleId) => 'https://journey-maps-tiles.geocdn.sbb.ch/styles/$styleId/style.json';

  static String _intStyleUrl(String styleId) =>
      'https://journey-maps-tiles.geocdn-int.sbb.ch/styles/$styleId/style.json';

  /// The URL of the published style with the given [styleId].
  static String styleUrl(String styleId, {bool isInt = false}) =>
      isInt ? _intStyleUrl(styleId) : _prodStyleUrl(styleId);

  /// Resolves the API key for the Journey Maps Tiles API.
  ///
  /// Resolution order is the [apiKey] parameter, then the environment variable
  /// `JOURNEY_MAPS_TILES_API_KEY`.
  ///
  /// Throws an [ApiKeyMissing] exception if none of them yields a key.
  static String apiKeyElseThrow(String? apiKey) {
    final result = apiKey ?? const String.fromEnvironment('JOURNEY_MAPS_TILES_API_KEY');
    if (result.isEmpty) {
      throw ApiKeyMissing('Set JOURNEY_MAPS_TILES_API_KEY as env var or as a constructor parameter.');
    }
    return result;
  }

  /// Whether integration data should be used, given the [useIntegrationData]
  /// parameter and the environment variable `SBB_MAPS_INT_ENABLED`.
  ///
  /// Logs once if the answer is yes.
  static bool resolveUseIntegrationData(bool useIntegrationData) {
    final isInt = useIntegrationData || _intEnvVarSet();
    _logIfIsInt(isInt);
    return isInt;
  }

  static bool _intEnvVarSet() {
    const intFlag = String.fromEnvironment('SBB_MAPS_INT_ENABLED');
    if (intFlag.isNotEmpty) return intFlag == 'true';

    return false;
  }

  static void _logIfIsInt(bool isInt) {
    if (!isInt) return;
    final logger = Logger();
    logger.i('sbb_maps_flutter: You are currently opted in to use integration data.');
  }
}
