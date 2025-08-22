import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/src/sbb_map_annotator/annotator/annotator_impl.dart';
import 'package:test/test.dart';

import 'annotator.fixture.dart';

import 'annotator_test.mocks.dart';

void main() {
  late SBBMapAnnotatorImpl sut;
  late MockMapLibreMapController mockController;

  group('SBBMapAnnotator Add Image Unit Tests', () {
    setUp(() async {
      mockController = MockMapLibreMapController();
      sut = SBBMapAnnotatorImpl(controller: mockController);
      reset(mockController);
    });

    test('should not add empty image and fail silently', () async {
      // act
      await sut.addImage(imageId: AnnotatorFixture.fakeImageName, imageBytes: AnnotatorFixture.emptyImage);
      // verify
      verifyZeroInteractions(mockController);
    });

    test('should add non empty image', () async {
      // act
      await sut.addImage(imageId: AnnotatorFixture.fakeImageName, imageBytes: AnnotatorFixture.fakeImage);
      // verify
      verify(mockController.addImage(AnnotatorFixture.fakeImageName, AnnotatorFixture.fakeImage)).called(1);
    });
  });
}
