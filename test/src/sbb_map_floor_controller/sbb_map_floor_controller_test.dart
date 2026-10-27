import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/src/sbb_map_floor_controller/sbb_map_floor_controller_impl.dart';

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
    group('synchronizeWithNewStyle', () {
      setUp(() async {
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => threeFeatureWithThreeFloors);
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => layer2Level0Filter);
        await sut.updateAvailableFloors();
        reset(listener);
      });

      test('synchronizeWithNewStyle_whenFloorSelected_shouldReapplyItToNewStyleLayers', () async {
        // arrange
        await sut.switchFloor(1);
        clearInteractions(mockController);
        reset(listener);

        // act: the new style's layers show floor 0 again
        await sut.synchronizeWithNewStyle();

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', layer2Level1Filter)).called(1);
        verify(mockController.setLayerVisibility('rokas_background_mask', false)).called(1);
        verifyNever(listener());
      });

      test('synchronizeWithNewStyle_whenNoFloorSelected_shouldLeaveNewStyleUntouched', () async {
        // act
        await sut.synchronizeWithNewStyle();

        // expect
        expect(sut.currentFloor, null);
        verifyNever(mockController.setFilter(any, any));
        verifyNever(mockController.setLayerVisibility(any, any));
        verifyNever(listener());
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
      test('switchFloor_ifFloorNoLongerAvailableInSource_shouldApplyGroundFloorBeforeNotifying', () async {
        // arrange
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => layer2Level0Filter);
        await sut.switchFloor(-1);
        final layerIds = Completer<List<dynamic>>();
        when(mockController.getLayerIds()).thenAnswer((_) => layerIds.future);
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => oneFeatureGroundAndFirstFloor);
        var notifications = 0;
        sut.addListener(() {
          notifications++;
          expect(layerIds.isCompleted, isTrue);
        });

        // act
        final update = sut.updateAvailableFloors();
        await pumpEventQueue();

        // expect
        expect(notifications, 0);
        layerIds.complete(oneLevelLayers);
        await update;
        expect(notifications, 1);
        expect(sut.currentFloor, null);
      });
      test('switchFloor_ifFloorNoLongerAvailableInSource_shouldNotCompleteBeforeGroundFloorIsApplied', () async {
        // arrange
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => layer2Level0Filter);
        await sut.switchFloor(-1);
        final layerIds = Completer<List<dynamic>>();
        when(mockController.getLayerIds()).thenAnswer((_) => layerIds.future);
        when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => oneFeatureGroundAndFirstFloor);
        var updateCompleted = false;

        // act
        final update = sut.updateAvailableFloors().then((_) => updateCompleted = true);
        await pumpEventQueue();

        // expect
        expect(updateCompleted, isFalse);
        layerIds.complete(oneLevelLayers);
        await update;
        expect(updateCompleted, isTrue);
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

      test('switchFloor_whenNewLevelIdiomInFilter_shouldApplyFilter', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => newIdiomLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', newIdiomLevel1Filter)).called(1);
      });

      test('switchFloor_whenBothLevelIdiomsInFilter_shouldApplyBothSubstitutions', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => bothIdiomsLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', bothIdiomsLevel1Filter)).called(1);
      });

      test('switchFloor_whenFilterReadsOtherProperties_shouldOnlySubstituteTheLevel', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => otherPropertyReadsLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', otherPropertyReadsLevel1Filter)).called(1);
      });

      test('switchFloor_whenLevelReadIsNotAnEqualityOperand_shouldNotChangeFilters', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => levelUnderOtherOperatorFilter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verifyNever(mockController.setFilter(any, any));
      });

      test('switchFloor_whenLevelClauseIsNestedInBooleanGroup_shouldApplyFilter', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => nestedGroupLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', nestedGroupLevel1Filter)).called(1);
      });

      test('switchFloor_whenNestedGroupsHoldNoLevelClause_shouldLeaveThemUntouched', () async {
        // arrange mock controller for non iOS platform (we do not check iOS platform here)
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => nestedZoomGroupsLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', nestedZoomGroupsLevel1Filter)).called(1);
      });

      test('switchFloor_whenFilterReadsOtherFloorProperties_shouldOnlySubstituteTheFloor', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => floorTypeReadFloor0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', floorTypeReadFloor1Filter)).called(1);
      });

      test('switchFloor_whenBareFloorNameFilter_shouldNotChangeFilters', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => bareFloorNameFilter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verifyNever(mockController.setFilter(any, any));
      });

      test('switchFloor_whenPlainFloorReadFilter_shouldNotChangeFilters', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => plainFloorReadFilter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verifyNever(mockController.setFilter(any, any));
      });

      test('switchFloor_whenFloorClauseIsFollowedByScalar_shouldLeaveTheScalarUntouched', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => floorClauseThenScalarFloor0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', floorClauseThenScalarFloor1Filter)).called(1);
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

      test('switchFloor_whenSbbMapsPlatformLayerFilter_shouldOnlySubstituteTheLevel', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => platformKanteLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', platformKanteLevel1Filter)).called(1);
      });

      test('switchFloor_whenSbbMapsLabelLayerFilter_shouldOnlySubstituteTheLevel', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => labelStreetsMainLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', labelStreetsMainLevel1Filter)).called(1);
      });

      test('switchFloor_whenSbbMapsLevelLayerHoldsNoLevelClause_shouldNotChangeFilters', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => railwaysGravelFilter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verifyNever(mockController.setFilter(any, any));
      });

      test('switchFloor_whenLevelClauseIsNestedInNoneGroup_shouldApplyFilter', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => noneGroupLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', noneGroupLevel1Filter)).called(1);
      });

      test('switchFloor_whenLevelClauseIsFilterRoot_shouldApplyFilter', () async {
        // arrange mock controller
        when(mockController.getLayerIds()).thenAnswer((_) async => oneLevelLayers);
        when(mockController.getFilter('layer2-lvl')).thenAnswer((_) async => rootLevel0Filter);
        when(mockController.setFilter(any, any)).thenAnswer((_) async => {});

        // act
        await sut.switchFloor(1);

        // expect
        expect(sut.currentFloor, 1);
        verify(mockController.setFilter('layer2-lvl', rootLevel1Filter)).called(1);
      });
    });
  });
}
