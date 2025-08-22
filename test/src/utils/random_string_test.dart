import 'dart:math';

import 'package:sbb_maps_flutter/src/utils/random_string.dart';
import 'package:test/test.dart';

void main() {
  group('Unit Test Random String', () {
    sut([len = 16, random]) => randomString(len: len, random: random);
    final rand = Random();

    test('Should return different strings for large number of trials', () {
      runNTimes(() {
        // act
        final String a = sut();
        final String b = sut();

        // expect
        expect(a != b, true);
      });
    });

    test('Should return n length', () {
      runNTimes(() {
        // act
        final expectedLength = rand.nextInt(100);
        final String a = sut(expectedLength);

        // expect
        expect(a.length, equals(expectedLength));
      });
    });

    test('Should contain only alphaNumeric chars ', () {
      runNTimes(() {
        // setup
        final alphaNumRegex = RegExp(r'^[a-zA-Z0-9]+$');

        // act
        final String a = sut();

        // expect
        expect(alphaNumRegex.hasMatch(a), true);
      });
    });

    test('Should return same string with fake random', () {
      runNTimes(() {
        // setup
        final fakeRandom = FakeRandom(nextInts: [0]);

        // act
        final String a = sut(16, fakeRandom);
        final String b = sut(16, fakeRandom);

        // expect
        expect(a, equals(b));
      });
    });
  });
}

void runNTimes(void Function() func, [n = 1000000]) {
  for (int i = 0; i < n; i++) {
    func.call();
  }
}

class FakeRandom implements Random {
  final Iterable<int>? nextInts;
  int _index;
  final _random = Random();

  FakeRandom({this.nextInts}) : _index = 0, super();

  @override
  bool nextBool() {
    return _random.nextBool();
  }

  @override
  double nextDouble() {
    return _random.nextDouble();
  }

  @override
  int nextInt(int max) {
    if (nextInts != null) {
      final result = nextInts!.elementAt(_index);
      _index = (_index + 1) % nextInts!.length;
      return result;
    } else {
      return _random.nextInt(max);
    }
  }
}
