import 'package:logger/logger.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/api_key_missing_exception.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/styler_config.dart';

/// Holds the Legacy Journey Maps styles and is responsible for creating a default [SBBMapStyler] for [SBBMap].
///
/// The base styles are:
///
/// * `journey_maps_bright_v1`
/// * `journey_maps_dark_v1`
/// * `journey_maps_aerial_v1`
///
/// The [initialStyleId] is `journey_maps_bright_v1`.
///
/// These styles are no longer served after 31.12.2026. Use [SBBMapsMapStyler],
/// which holds the styles replacing them.
@Deprecated(
  'The Journey Maps styles held by this styler are no longer served after 31.12.2026. '
  'Use SBBMapsMapStyler instead. Will be removed in the next major version.',
)
class SBBRokasMapStyler {
  static const _bright = 'journey_maps_bright_v1';
  static const _dark = 'journey_maps_dark_v1';
  static const _aerial = 'journey_maps_aerial_v1';

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
  /// To use integration data for vector tiles and POIs, set
  /// [useIntegrationData] to true.
  ///
  /// The [initialStyleId] is `journey_maps_bright_v1`.
  static SBBMapStyler full({String? apiKey, bool isDarkMode = false, bool useIntegrationData = false}) {
    final key = StylerConfig.apiKeyElseThrow(apiKey);
    final isInt = StylerConfig.resolveUseIntegrationData(useIntegrationData);
    _logDeprecation();

    final rokasDefaultStyle = SBBMapStyle.fromURL(
      id: _bright,
      brightStyleURL: StylerConfig.styleUrl(_bright, isInt: isInt),
      apiKey: key,
      darkStyleURL: StylerConfig.styleUrl(_dark, isInt: isInt),
    );

    final aerialStyle = SBBMapStyle.fromURL(
      id: _aerial,
      brightStyleURL: StylerConfig.styleUrl(_aerial, isInt: isInt),
      apiKey: key,
    );

    return SBBCustomMapStyler(
      styles: [rokasDefaultStyle],
      aerialStyle: aerialStyle,
      initialStyleId: _bright,
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
  /// To use integration data for vector tiles and POIs, set
  /// [useIntegrationData] to true.
  ///
  /// The [initialStyleId] is `journey_maps_bright_v1`.
  static SBBMapStyler noAerial({String? apiKey, bool isDarkMode = false, bool useIntegrationData = false}) {
    final key = StylerConfig.apiKeyElseThrow(apiKey);
    final isInt = StylerConfig.resolveUseIntegrationData(useIntegrationData);
    _logDeprecation();

    final rokasDefaultStyle = SBBMapStyle.fromURL(
      id: _bright,
      brightStyleURL: StylerConfig.styleUrl(_bright, isInt: isInt),
      apiKey: key,
      darkStyleURL: StylerConfig.styleUrl(_dark, isInt: isInt),
    );

    return SBBCustomMapStyler(styles: [rokasDefaultStyle], initialStyleId: _bright, isDarkMode: isDarkMode);
  }

  static bool _deprecationLogged = false;

  static void _logDeprecation() {
    if (_deprecationLogged) return;
    _deprecationLogged = true;

    final logger = Logger();
    logger.w(
      'sbb_maps_flutter: You are currently using the deprecated SBBRokasMapStyler.\n'
      'Its styles are no longer served after 31.12.2026. Switch to SBBMapsMapStyler.\n'
      'If you did not construct this styler yourself, SBBMap created it as its default: '
      'pass a SBBMapsMapStyler as mapStyler to opt out. This styler will become the '
      'default in the next major version.',
    );
  }
}
