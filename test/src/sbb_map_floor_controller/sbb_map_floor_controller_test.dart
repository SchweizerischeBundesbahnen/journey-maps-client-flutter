import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller_impl.dart';
import 'package:test/test.dart';

import '../../util/mock_callback_function.dart';
import 'sbb_map_floor_controller.fixture.dart';
@GenerateNiceMocks([MockSpec<MapLibreMapController>()])
import 'sbb_map_floor_controller_test.mocks.dart';

void main() {
  late SBBMapFloorControllerImpl sut;
  late MockMapLibreMapController mockController;
  final listener = MockCallbackFunction();

  group('Unit Test SBBMapFloorProvider', () {
    setUp(() {
      mockController = MockMapLibreMapController();
      sut = SBBMapFloorControllerImpl(Future.value(mockController));
      sut.addListener(listener.call);
      reset(mockController);
      reset(listener);
    });

    group('updateAvailableFloors', () {
      test('updateAvailableFloors_whenEmptySource_shouldExtractEmptyAndNotCallListeners', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => []);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, []);
        verifyNever(listener());
      });

      test('updateAvailableFloors_whenOneFeatureWithTwoFloors_shouldExtractGroundAndFirstFloor', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => oneFeatureGroundAndFirstFloor);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, groundAndFirstFloor);
        verify(listener()).called(1);
      });
      test('updateAvailableFloors_whenThreeFeatures_shouldExtractAllFiveFloorsIncludingNegative', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => threeFeatureWithThreeFloors);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, threeFloorsFromThreeFeatures);
        verify(listener()).called(1);
      });
      test('updateAvailableFloors_whenCalledTwiceAndFeatureDoNotChange_shouldNotCallListenerAgain', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => threeFeatureWithThreeFloors);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, threeFloorsFromThreeFeatures);
        verify(listener()).called(1);
      });
    });
    group('switchFloor', () {
      setUp(() async {
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => threeFeatureWithThreeFloors);
        await sut.updateAvailableFloors();
        expect(sut.availableFloors, threeFloorsFromThreeFeatures);
        verify(listener()).called(1);
      });
      test('switchFloor_whenNonExistingFloor_shouldFailSilently', () async {
        // act
        sut.switchFloor(10);

        // expect
        expect(sut.currentFloor, null);
        verifyNever(listener());
      });
      test('switchFloor_ifFloorNoLongerAvailableInSource_shouldResetCurrentFloor', () async {
        // arrange
        await sut.switchFloor(-1);
        expect(sut.currentFloor, -1);

        // act
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => oneFeatureGroundAndFirstFloor);
        await sut.updateAvailableFloors();

        // expect
        expect(sut.currentFloor, null);
        verify(listener()).called(2);
      });
      test('switchFloor_whenNoLevelLayersAvailable_anyFloorSwitchShouldNotApplyFilters', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => noLevelLayers);

        for (var floor in threeFloorsFromThreeFeatures) {
          // act
          await sut.switchFloor(floor);

          // expect
          expect(sut.currentFloor, floor);
        }
        // expect calls
        verifyNever(mockController.getFilter(any));
        verifyNever(mockController.setFilter(any, any));
        verify(listener()).called(threeFloorsFromThreeFeatures.length); // first call checked in setUp
      });

      test('switchFloor_whenLayerFilterRespondsWithNull_shouldNotChangeFilters', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => null);

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.getFilter('layer2-lvl')).called(1);
        verifyNever(mockController.setFilter(any, any));
        verify(listener()).called(1); // first call checked in setUp
      });

      test('switchFloor_whenEmptyLayerFilter_shouldNotChangeFilters', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => []);

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.getFilter('layer2-lvl')).called(1);
        verifyNever(mockController.setFilter(any, any));
        verify(listener()).called(1); // first call checked in setUp
      });

      test('switchFloor_whenLayerFilterInResponse_shouldApplyFilter', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => layer2Level0Filter);

        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.getFilter('layer2-lvl')).called(1);
        verify(mockController.setFilter('layer2-lvl', layer2Level1Filter)).called(1);
        verify(listener()).called(1); // first call checked in setUp
      });
    });
  });
}
