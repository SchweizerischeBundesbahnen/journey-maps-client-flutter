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
      test('Should extract empty floor list from empty feature list and not call listener', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => []);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, []);
        verifyNever(listener());
      });

      test('Should extract ground and first floors from one feature', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => oneFeatureGroundAndFirstFloor);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, groundAndFirstFloor);
        verify(listener()).called(1);
      });
      test('Should extract five floors with negative floors from three features', () async {
        // arrange
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => threeFeatureWithThreeFloors);
        expect(sut.availableFloors, []);

        // act
        await sut.updateAvailableFloors();

        // expect
        expect(sut.availableFloors, threeFloorsFromThreeFeatures);
        verify(listener()).called(1);
      });
      test('Should extract same features twice but call listener only once', () async {
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
      test('Should fail silently switching to nonexisting floor', () async {
        // act
        sut.switchFloor(10);

        // expect
        expect(sut.currentFloor, null);
        verifyNever(listener());
      });
      test('Should reset currentFloor if no longer available in source', () async {
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
      test('Should switch to any floor not changing any filters when no level layers available', () async {
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

      test('Should switch to floor 1 not changing filters if null level layer filters', () async {
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

      test('Should switch to floor 1 not changing filters if empty level layer filters', () async {
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

      test('Should switch to floor 1 changing filters of lvl layer', () async {
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
