import 'package:collection/collection.dart';

import 'line_string.dart';

class MultiLineString {
  const MultiLineString({
    required this.lineStrings,
  });

  factory MultiLineString.fromGeoJSON(Map<String, dynamic> json) {
    var lineStringsList = (json['geometry']['coordinates'] as List)
        .map((lineString) => LineString.fromGeoJSON(lineString as Map<String, dynamic>))
        .toList();

    return MultiLineString(
      lineStrings: lineStringsList,
    );
  }

  final List<LineString> lineStrings;

  @override
  bool operator ==(Object other) {
    Function deepEq = const DeepCollectionEquality().equals;

    return identical(this, other) ||
        other is MultiLineString && runtimeType == other.runtimeType && deepEq(lineStrings, other.lineStrings);
  }

  @override
  int get hashCode => lineStrings.hashCode;
}
