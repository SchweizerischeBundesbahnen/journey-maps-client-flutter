import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class SBBCustomMapStyler with ChangeNotifier implements SBBMapStyler {
  /// Creates a new [SBBCustomMapStyler] with the given [styles].
  ///
  /// The [initialStyleId] is optional and defaults to the first style in [styles].
  /// The [aerialStyle] is optional and can be toggled with [toggleAerialStyle].
  SBBCustomMapStyler({
    required List<SBBMapStyle> styles,
    SBBMapStyle? aerialStyle,
    String? initialStyleId,
    bool isDarkMode = false,
  })  : _aerialStyle = aerialStyle,
        _styles = Map.fromEntries(styles.map((e) => MapEntry(e.id, e))) {
    _currentStyle = initialStyleId != null ? _styles[initialStyleId] ?? _styles.values.first : _styles.values.first;
    if (_aerialStyle != null) {
      _styles[_aerialStyle.id] = aerialStyle!;
    }
    _isDarkMode = isDarkMode;
  }

  final Map<String, SBBMapStyle> _styles;
  late SBBMapStyle _currentStyle;
  final SBBMapStyle? _aerialStyle;
  SBBMapStyle? _preAerialStyle;
  late bool _isDarkMode;
  bool _isAerialStyle = false;

  @override
  String get currentStyleURI => _currentStyle.uri(isDarkStyle: _isDarkMode);

  @override
  List<String> getStyleIds() => _styles.keys.toList();

  @override
  bool get isAerialStyle => _isAerialStyle;

  @override
  bool get isDarkMode => _isDarkMode;

  @override
  void switchStyle(String styleId) {
    if (!_styles.containsKey(styleId) || _currentStyle.id == styleId) return;
    if (styleId == _aerialStyle?.id) {
      toggleAerialStyle();
    } else {
      _resumePreviousStyle();
      _currentStyle = _styles[styleId]!;
      notifyListeners();
    }
  }

  @override
  void toggleAerialStyle() {
    if (_aerialStyle == null) return;
    _isAerialStyle ? _resumePreviousStyle() : _switchToAerialStyle();
    notifyListeners();
  }

  @override
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  _resumePreviousStyle() {
    _currentStyle = _preAerialStyle ?? _styles.values.first;
    _preAerialStyle = null;
    _isAerialStyle = false;
  }

  _switchToAerialStyle() {
    _preAerialStyle = _currentStyle;
    _currentStyle = _aerialStyle!;
    _isAerialStyle = true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SBBCustomMapStyler &&
          const MapEquality().equals(_styles, other._styles) &&
          _currentStyle == other._currentStyle &&
          _aerialStyle == other._aerialStyle &&
          _preAerialStyle == other._preAerialStyle &&
          _isDarkMode == other._isDarkMode &&
          _isAerialStyle == other._isAerialStyle &&
          hasListeners == other.hasListeners;

  @override
  int get hashCode =>
      const MapEquality().hash(_styles) ^
      _currentStyle.hashCode ^
      _aerialStyle.hashCode ^
      _preAerialStyle.hashCode ^
      _isDarkMode.hashCode ^
      _isAerialStyle.hashCode ^
      hasListeners.hashCode;
}
