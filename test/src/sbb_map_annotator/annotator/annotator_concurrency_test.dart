import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';

import 'annotator.fixture.dart';
import 'annotator_test.mocks.dart';

void main() {
  late SBBMapAnnotatorImpl sut;
  late MockMapLibreMapController mockController;
  late List<OnFeatureInteractionCallback> featureTappedCallbacks;
  late List<Completer<void>> pendingSourceWrites;
  late List<Map<String, dynamic>> sentSourceData;

  final a = SBBMapCircle(center: AnnotatorFixture.fakeCoords);
  final b = SBBMapCircle(center: AnnotatorFixture.fakeCoords);
  final c = SBBMapCircle(center: AnnotatorFixture.fakeCoords);

  Map<String, dynamic> featuresOf(List<SBBMapAnnotation> annotations) =>
      buildFeatureCollection([for (final x in annotations) x.toGeoJson()]);

  /// Completes the held setGeoJsonSource calls until none are left, picking the
  /// most recent pending call first when [newestFirst] is set.
  Future<void> drainSourceWrites({required bool newestFirst}) async {
    await pumpEventQueue();
    while (pendingSourceWrites.isNotEmpty) {
      final next = newestFirst ? pendingSourceWrites.removeLast() : pendingSourceWrites.removeAt(0);
      next.complete();
      await pumpEventQueue();
    }
  }

  bool isKnown(SBBMapAnnotation annotation) {
    var tapped = false;
    sut.onCircleTapped((_) => tapped = true);
    featureTappedCallbacks.single(
      AnnotatorFixture.fakePoint,
      AnnotatorFixture.fakeCoords,
      annotation.id,
      AnnotatorFixture.fakeLayerId,
      AnnotatorFixture.fakeAnnotation,
    );
    return tapped;
  }

  setUp(() async {
    mockController = MockMapLibreMapController();
    featureTappedCallbacks = <OnFeatureInteractionCallback>[];
    when(mockController.onFeatureTapped).thenReturn(featureTappedCallbacks);
    sut = SBBMapAnnotatorImpl(controller: mockController);
    await sut.addAnnotation(a);

    pendingSourceWrites = [];
    sentSourceData = [];
    when(mockController.setGeoJsonSource(any, any)).thenAnswer((invocation) {
      sentSourceData.add(invocation.positionalArguments[1] as Map<String, dynamic>);
      final completer = Completer<void>();
      pendingSourceWrites.add(completer);
      return completer.future;
    });
  });

  for (final newestFirst in [false, true]) {
    final order = newestFirst ? 'newest first' : 'oldest first';

    group('platform calls completing $order', () {
      test('overlapping remove and add both take effect', () async {
        final removal = sut.removeAnnotation(a);
        final addition = sut.addAnnotation(b);

        await drainSourceWrites(newestFirst: newestFirst);
        await Future.wait([removal, addition]);

        expect(sentSourceData.last, featuresOf([b]));
        expect(isKnown(a), isFalse);
        expect(isKnown(b), isTrue);
      });

      test('overlapping adds both take effect', () async {
        final first = sut.addAnnotation(b);
        final second = sut.addAnnotation(c);

        await drainSourceWrites(newestFirst: newestFirst);
        await Future.wait([first, second]);

        expect(sentSourceData.last, featuresOf([a, b, c]));
        expect(isKnown(b), isTrue);
        expect(isKnown(c), isTrue);
      });

      test('removing an annotation whose add is still in flight removes it', () async {
        final addition = sut.addAnnotation(b);
        final removal = sut.removeAnnotation(b);

        await drainSourceWrites(newestFirst: newestFirst);
        await Future.wait([addition, removal]);

        expect(sentSourceData.last, featuresOf([a]));
        expect(isKnown(b), isFalse);
      });

      test('style change during an add re-syncs the added annotation', () async {
        final addition = sut.addAnnotation(b);
        final styleChange = sut.onStyleChanged();

        await drainSourceWrites(newestFirst: newestFirst);
        await Future.wait([addition, styleChange]);

        expect(sentSourceData.last, featuresOf([a, b]));
        expect(isKnown(b), isTrue);
      });
    });
  }

  test('a failed mutation does not block the next one', () async {
    final failing = sut.addAnnotation(b);
    final following = sut.addAnnotation(c);

    await pumpEventQueue();
    pendingSourceWrites.removeAt(0).completeError(PlatformException(code: 'fakeCode'));
    await expectLater(failing, throwsA(isA<AnnotationException>()));
    await drainSourceWrites(newestFirst: false);
    await following;

    expect(sentSourceData.last, featuresOf([a, c]));
    expect(isKnown(b), isFalse);
    expect(isKnown(c), isTrue);
  });
}
