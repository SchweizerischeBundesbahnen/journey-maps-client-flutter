import 'package:logger/logger.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/api_key_missing_exception.dart';

/// Holds the ROKAS styles and is responsible for creating a default [SBBMapStyler] for [SBBMap].
///
/// The base styles are:
///
/// * `base_bright_v2_ki_v2`
/// * `base_dark_v2_ki_v2`
/// * `aerial_sbb_ki_v2`
///
/// The [initialStyleId] is `base_bright_v2_ki_v2`.
class SBBRokasMapStyler {
  static _rokasStyleUrl(String styleId) => 'https://journey-maps-tiles.geocdn.sbb.ch/styles/$styleId/style.json';

  static const _baseBrightV2KIV2 = 'base_bright_v2_ki_v2';
  static const _baseDarkV2KIV2 = 'base_dark_v2_ki_v2';
  static const _aerialSBBKIV2 = 'aerial_sbb_ki_v2';

  const SBBRokasMapStyler._();

  /// Creates a ROKAS [SBBMapStyler] with all styles.
  ///
  /// The styles are:
  ///
  /// * `base_bright_v2_ki_v2`
  /// * `base_dark_v2_ki_v2`
  /// * `aerial_sbb_ki_v2`
  ///
  /// The ROKAS styles need an API key for the Journey Maps Tiles API.
  ///
  /// Specify the API key:
  /// * as parameter or
  /// * set the environment variable `JOURNEY_MAPS_TILES_API_KEY`
  ///
  /// Throws an [ApiKeyMissing] exception **during runtime** if neither is given.
  ///
  /// The [initialStyleId] is `base_bright_v2_ki_v2`.
  static SBBMapStyler full({String? apiKey, bool isDarkMode = false}) {
    final key = _apiKeyElseThrow(apiKey);

    final rokasDefaultStyle = SBBMapStyle.fromURL(
      id: _baseBrightV2KIV2,
      brightStyleURL: _rokasStyleUrl(_baseBrightV2KIV2),
      apiKey: key,
      darkStyleURL: _rokasStyleUrl(_baseDarkV2KIV2),
    );

    final aerialStyle = SBBMapStyle.fromURL(
      id: _aerialSBBKIV2,
      brightStyleURL: _rokasStyleUrl(_aerialSBBKIV2),
      apiKey: key,
    );

    return SBBCustomMapStyler(
      styles: [rokasDefaultStyle],
      aerialStyle: aerialStyle,
      initialStyleId: _baseBrightV2KIV2,
      isDarkMode: isDarkMode,
    );
  }

  /// Creates a ROKAS [SBBMapStyler] without the aerial style.
  ///
  /// The styles are:
  ///
  /// * `base_bright_v2_ki_v2`
  /// * `base_dark_v2_ki_v2`
  ///
  /// The ROKAS styles need an API key for the Journey Maps Tiles API.
  ///
  /// Specify the API key:
  /// * as parameter or
  /// * set the environment variable `JOURNEY_MAPS_TILES_API_KEY`.
  ///
  /// Throws an [ApiKeyMissing] exception **during runtime** if neither is given.
  ///
  /// The [initialStyleId] is `base_bright_v2_ki_v2`.
  static SBBMapStyler noAerial({String? apiKey, bool isDarkMode = false}) {
    String key = _apiKeyElseThrow(apiKey);

    final rokasDefaultStyle = SBBMapStyle.fromURL(
      id: _baseBrightV2KIV2,
      brightStyleURL: _rokasStyleUrl(_baseBrightV2KIV2),
      apiKey: key,
      darkStyleURL: _rokasStyleUrl(_baseDarkV2KIV2),
    );

    return SBBCustomMapStyler(
      styles: [rokasDefaultStyle],
      initialStyleId: _baseBrightV2KIV2,
      isDarkMode: isDarkMode,
    );
  }

  static String _apiKeyElseThrow(String? apiKey) {
    String result = apiKey ?? const String.fromEnvironment('JOURNEY_MAPS_TILES_API_KEY');
    // @Deprecated(Remove in next major (3.x.x))
    if (result.isEmpty) result = _fetchLegacyApiKeyFromEnv();

    if (result == '') {
      throw ApiKeyMissing(
        'Set JOURNEY_MAPS_TILES_API_KEY as env var or as a constructor parameter.',
      );
    }
    return result;
  }

  static String _fetchLegacyApiKeyFromEnv() {
    const result = String.fromEnvironment('JOURNEY_MAPS_API_KEY');
    if (result != '') {
      final logger = Logger();
      logger.w(
        'sbb_maps_flutter: You are currently loading the API Key from the env var JOURNEY_MAPS_API_KEY.\n'
        'This is deprecated and will be removed in the next major version of the sbb_maps_flutter.',
      );
    }
    return result;
  }
}
