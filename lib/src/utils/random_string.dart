import 'dart:math';

const _kChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
final _random = Random();

/// Returns a random [len] length string from [_kChars].
///
/// [len] defaults to 16.
String randomString({int len = 16, Random? random}) {
  final rand = random ?? _random;
  return List.generate(len, (index) => _kChars[rand.nextInt(_kChars.length)]).join();
}
