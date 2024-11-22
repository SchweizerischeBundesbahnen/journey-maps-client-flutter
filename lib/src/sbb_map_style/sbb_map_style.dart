/// A style for the [SBBMap].
///
/// The style is defined by a [styleUrl] and an optional [apiKey].
class SBBMapStyle {
  final String _id;
  final String _brightStyleURI;
  final String? _apiKey;
  final String _darkStyleURI;

  const SBBMapStyle._(
    this._id,
    this._brightStyleURI,
    this._apiKey,
    this._darkStyleURI,
  );

  /// Will create a new [SBBMapStyle] with the given [id] and [brightStyleURL].
  ///
  /// The [darkStyleURL] is optional and defaults to [brightStyleURL].
  /// If an [apiKey] is given, the [uri] will contain the API key as query parameter.
  const SBBMapStyle.fromURL({
    required String id,
    required String brightStyleURL,
    String? apiKey,
    String? darkStyleURL,
  }) : this._(
          id,
          brightStyleURL,
          apiKey,
          darkStyleURL ?? brightStyleURL,
        );

  const SBBMapStyle.fromLocalAsset({
    required String id,
    required String brightStyleRelativePath,
    String? darkStyleRelativePath,
  }) : this._(
          id,
          brightStyleRelativePath,
          null,
          darkStyleRelativePath ?? brightStyleRelativePath,
        );

  /// The URI of the style depending on the [isDarkStyle].
  ///
  /// If [isDarkStyle] is `true`, the dark style URI will be returned.
  String uri({bool isDarkStyle = false}) {
    return isDarkStyle ? _generateDarkURI() : _generateBrightURI();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SBBMapStyle &&
          _id == other._id &&
          _brightStyleURI == other._brightStyleURI &&
          _apiKey == other._apiKey &&
          _darkStyleURI == other._darkStyleURI;

  @override
  int get hashCode => id.hashCode ^ _brightStyleURI.hashCode ^ _apiKey.hashCode ^ _darkStyleURI.hashCode;

  String _generateDarkURI() {
    return _apiKey == null ? _darkStyleURI : '$_darkStyleURI?api_key=$_apiKey';
  }

  String _generateBrightURI() {
    return _apiKey == null ? _brightStyleURI : '$_brightStyleURI?api_key=$_apiKey';
  }

  String get id => _id;
}
