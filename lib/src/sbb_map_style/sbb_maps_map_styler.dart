import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/api_key_missing_exception.dart';
import 'package:sbb_maps_flutter/src/sbb_map_style/styler_config.dart';

/// Holds the SBB Maps styles and creates a [SBBMapStyler] for [SBBMap].
///
/// The base styles are:
///
/// * `sbbmaps_bright`
/// * `sbbmaps_dark`
/// * `sbbmaps_aerial`
///
/// The [initialStyleId] is `sbbmaps_bright`.
class SBBMapsMapStyler {
  static const _bright = 'sbbmaps_bright';
  static const _dark = 'sbbmaps_dark';
  static const _aerial = 'sbbmaps_aerial';

  const SBBMapsMapStyler._();

  /// Creates a SBB Maps [SBBMapStyler] with all styles.
  ///
  /// The styles are:
  ///
  /// * `sbbmaps_bright`
  /// * `sbbmaps_dark`
  /// * `sbbmaps_aerial`
  ///
  /// The SBB Maps styles need an API key for the Journey Maps Tiles API.
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
  /// The [initialStyleId] is `sbbmaps_bright`.
  static SBBMapStyler full({String? apiKey, bool isDarkMode = false, bool useIntegrationData = false}) {
    final key = StylerConfig.apiKeyElseThrow(apiKey);
    final isInt = StylerConfig.resolveUseIntegrationData(useIntegrationData);

    final defaultStyle = SBBMapStyle.fromURL(
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
      styles: [defaultStyle],
      aerialStyle: aerialStyle,
      initialStyleId: _bright,
      isDarkMode: isDarkMode,
    );
  }

  /// Creates a SBB Maps [SBBMapStyler] without the aerial style.
  ///
  /// The styles are:
  ///
  /// * `sbbmaps_bright`
  /// * `sbbmaps_dark`
  ///
  /// The SBB Maps styles need an API key for the Journey Maps Tiles API.
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
  /// The [initialStyleId] is `sbbmaps_bright`.
  static SBBMapStyler noAerial({String? apiKey, bool isDarkMode = false, bool useIntegrationData = false}) {
    final key = StylerConfig.apiKeyElseThrow(apiKey);
    final isInt = StylerConfig.resolveUseIntegrationData(useIntegrationData);

    final defaultStyle = SBBMapStyle.fromURL(
      id: _bright,
      brightStyleURL: StylerConfig.styleUrl(_bright, isInt: isInt),
      apiKey: key,
      darkStyleURL: StylerConfig.styleUrl(_dark, isInt: isInt),
    );

    return SBBCustomMapStyler(styles: [defaultStyle], initialStyleId: _bright, isDarkMode: isDarkMode);
  }
}
