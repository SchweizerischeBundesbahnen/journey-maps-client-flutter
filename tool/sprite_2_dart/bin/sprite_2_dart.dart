import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  const rokasStyles = ['journey_maps_aerial_v1', 'journey_maps_dark_v1', 'journey_maps_bright_v1'];

  final allIcons = <String, String>{};
  final allIconKeys = <String, Set<String>>{};
  var keyIntersections = <String>{};

  bool isFirst = true;
  for (final path in rokasStyles) {
    final json = await fetchJsonFromUrl(
      'https://journey-maps-tiles.geocdn.sbb.ch/styles/$path/sprite@2x.json?api_key=',
    );
    final iconNameToId = buildIconNameToIdMap(json);
    final uniqueIconNames = iconNameToId.keys.toSet();
    allIcons.addAll(iconNameToId);
    allIconKeys[path] = uniqueIconNames;
    if (isFirst) keyIntersections = uniqueIconNames;
    isFirst = false;
  }
  for (final entry in allIconKeys.entries) {
    keyIntersections = keyIntersections.intersection(entry.value);
  }
  final resultedIcons = Map<String, String>.from(allIcons)..removeWhere((k, v) => !keyIntersections.contains(k));
  var fileContent = generateDartFileContent(resultedIcons);
  var outputFile = File('rokas_icon_identifier.dart');
  await outputFile.writeAsString(fileContent);
}

Future<Map<String, dynamic>> fetchJsonFromUrl(String url) async {
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw HttpException('Failed to load json from $url');
  }
}

Map<String, String> buildIconNameToIdMap(Map<String, dynamic> json) {
  final result = <String, String>{};
  for (final jsonKey in json.keys) {
    final validSBBMarkerKey = camelCaseSBBMarkers(jsonKey);
    if (validSBBMarkerKey != null) {
      result[validSBBMarkerKey] = jsonKey;
    }
  }
  return result;
}

String? camelCaseSBBMarkers(String key) {
  if (!key.startsWith('sbb')) return null;

  return key
      .replaceAll('_', '-')
      .split('-')
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join()
      .replaceAll(RegExp(r'(SbbMarker)|(Sbb)'), '')
      .toConstName();
}

String generateDartFileContent(Map<String, String> allIcons) {
  var buffer = StringBuffer();
  buffer.writeln('/// This file is auto-generated. Do not modify by hand.');
  buffer.writeln('sealed class RokasIcons {\n');
  buffer.writeln('  /// The icons which are present in all ROKAS styles.');
  buffer.writeln('  RokasIcons._();\n');

  allIcons.forEach((name, id) {
    buffer.writeln("  static const $name = '$id';");
  });

  buffer.writeln('\n}');

  return buffer.toString();
}

extension StringExtension on String {
  String toConstName() => length > 0 ? '${this[0].toLowerCase()}${substring(1)}' : '';
}
