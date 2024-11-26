import 'package:logger/logger.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/api_key_missing_exception.dart';

/// Holds the ROKAS styles and is responsible for creating a default [SBBMapStyler] for [SBBMap].
///
/// The base styles are:
///
/// * `journey_maps_bright_v1`
/// * `journey_maps_dark_v1`
/// * `journey_maps_aerial_v1`
///
/// The [initialStyleId] is `journey_maps_bright_v1`.
class SBBRokasMapStyler {
  static _rokasStyleUrl(String styleId) => 'https://journey-maps-tiles.geocdn.sbb.ch/styles/$styleId/style.json';

  static const _brightV1 = 'journey_maps_bright_v1';
  static const _darkV1 = 'journey_maps_dark_v1';
  static const _aerialV1 = 'journey_maps_aerial_v1';

  const SBBRokasMapStyler._();

  /// Creates a ROKAS [SBBMapStyler] with all styles.
  ///
  /// The styles are:
  ///
  /// * `journey_maps_bright_v1`
  /// * `journey_maps_dark_v1`
  /// * `journey_maps_aerial_v1`
  ///
  /// The ROKAS styles need an API key for the Journey Maps Tiles API.
  ///
  /// Specify the API key:
  /// * as parameter or
  /// * set the environment variable `JOURNEY_MAPS_TILES_API_KEY`
  ///
  /// Throws an [ApiKeyMissing] exception **during runtime** if neither is given.
  ///
  /// The [initialStyleId] is `journey_maps_bright_v1`.
  static SBBMapStyler full({String? apiKey, bool isDarkMode = false}) {
    final key = _apiKeyElseThrow(apiKey);

    final rokasDefaultStyle = SBBMapStyle.fromURL(
      id: _brightV1,
      brightStyleURL: _rokasStyleUrl(_brightV1),
      apiKey: key,
      darkStyleURL: _rokasStyleUrl(_darkV1),
    );

    final aerialStyle = SBBMapStyle.fromURL(
      id: _aerialV1,
      brightStyleURL: _rokasStyleUrl(_aerialV1),
      apiKey: key,
    );

    return SBBCustomMapStyler(
      styles: [rokasDefaultStyle],
      aerialStyle: aerialStyle,
      initialStyleId: _brightV1,
      isDarkMode: isDarkMode,
    );
  }

  /// Creates a ROKAS [SBBMapStyler] without the aerial style.
  ///
  /// The styles are:
  ///
  /// * `journey_maps_bright_v1`
  /// * `journey_maps_dark_v1`
  ///
  /// The ROKAS styles need an API key for the Journey Maps Tiles API.
  ///
  /// Specify the API key:
  /// * as parameter or
  /// * set the environment variable `JOURNEY_MAPS_TILES_API_KEY`.
  ///
  /// Throws an [ApiKeyMissing] exception **during runtime** if neither is given.
  ///
  /// The [initialStyleId] is `journey_maps_bright_v1`.
  static SBBMapStyler noAerial({String? apiKey, bool isDarkMode = false}) {
    String key = _apiKeyElseThrow(apiKey);

    final rokasDefaultStyle = SBBMapStyle.fromURL(
      id: _brightV1,
      brightStyleURL: _rokasStyleUrl(_brightV1),
      apiKey: key,
      darkStyleURL: _rokasStyleUrl(_darkV1),
    );

    return SBBCustomMapStyler(
      styles: [rokasDefaultStyle],
      initialStyleId: _brightV1,
      isDarkMode: isDarkMode,
    );
  }

  static String _apiKeyElseThrow(String? apiKey) {
    String result = apiKey ?? const String.fromEnvironment('JOURNEY_MAPS_TILES_API_KEY');
    // @Deprecated(Remove in next major (3.x.x))
    if (result.isEmpty) result = _fetchLegacyApiKeyFromEnv();

    if (result.isEmpty) {
      throw ApiKeyMissing(
        'Set JOURNEY_MAPS_TILES_API_KEY as env var or as a constructor parameter.',
      );
    }
    return result;
  }

  static String _fetchLegacyApiKeyFromEnv() {
    const legacyKey = String.fromEnvironment('JOURNEY_MAPS_API_KEY');
    if (legacyKey.isNotEmpty) {
      final logger = Logger();
      logger.w(
        'sbb_maps_flutter: You are currently loading the API Key from the env var JOURNEY_MAPS_API_KEY.\n'
        'This is deprecated and will be removed in the next major version of the sbb_maps_flutter.',
      );
    }
    return legacyKey;
  }
}
