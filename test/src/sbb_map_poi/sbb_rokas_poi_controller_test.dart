import 'dart:async';
import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/controller/sbb_rokas_poi_controller_impl.dart';
import 'package:test/test.dart';

import '../../util/mock_callback_function.dart';
import 'sbb_rokas_poi_controller.fixture.dart';
@GenerateNiceMocks([MockSpec<MapLibreMapController>()])
import 'sbb_rokas_poi_controller_test.mocks.dart';

void main() {
  late SBBRokasPOIControllerImpl sut;
  late MockMapLibreMapController mockController;
  final listener = MockCallbackFunction();

  group('Unit Test SBBRokasPoiController', () {
    setUp(() => {
          mockController = MockMapLibreMapController(),
          sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController)),
          sut.addListener(listener.call),
          reset(mockController),
          reset(listener)
        });

    test('getAvailablePOICategories_shouldReturnAllAvailablePoiCategories', () {
      // arrange
      // act
      final result = sut.availablePOICategories;
      // expect
      expect(result, SBBPoiCategoryType.values.toList());
      verifyNever(listener());
    });

    test('getCurrentPoiCategories_whenNoFilter_shouldReturnAllAvailablePoiCategories', () {
      // act
      final result = sut.currentPOICategories;
      // expect
      expect(result, SBBPoiCategoryType.values.toList());
      verifyNever(listener());
    });

    test('getCurrentPoiCategories_whenShowWithBaseLayerAndNoFilter_shouldReturnAllAvailablePoiCategories', () async {
      // act
      await sut.showPointsOfInterest();
      final result = sut.currentPOICategories;
      // expect
      expect(result, SBBPoiCategoryType.values.toList());
      verify(listener()).called(1); // for switching visibility
    });

    test('getCurrentPoiCategories_whenShowWithBaseLayerAndAllFiltered_shouldReturnEmptyList', () async {
      // arrange
      // act
      await sut.showPointsOfInterest(categories: []);
      final result = sut.currentPOICategories;
      // expect
      expect(result, []);
      verify(listener()).called(1);
    });

    test('getCurrentPoiCategories_whenShowWithBaseLayerAnd([bike_parking])_shouldReturn[bike_parking]', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(categories: categories);
      final result = sut.currentPOICategories;
      // expect
      expect(result, categories);
      verify(listener()).called(1);
    });

    test('getCurrentPoiCategories_whenShowWithHighlightedPoiLayer_shouldReturnAllPOICategories', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted, categories: categories);
      final result = sut.currentPOICategories;
      // expect
      expect(result, SBBPoiCategoryType.values.toList());
      verify(listener()).called(1);
    });

    test('getCurrentPoiCategories_whenShowPointsOfInterestWithVaryingPoiTypes_shouldReturnBaseOnFloorFilter', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor, categories: categories);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted, categories: []);
      final result = sut.currentPOICategories;
      // expect
      expect(result, categories);
      verify(listener()).called(2);
    });

    test('getCategoryFilterByLayer_whenNoFilterAndBaseLayer_shouldReturnAllAvailablePoiCategories', () {
      // act
      final result = sut.getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, SBBPoiCategoryType.values.toSet());
      verifyNever(listener());
    });

    test('getCategoryFilterByLayer_whenShowWithBaseLayerAndNoFilter_shouldReturnAllAvailablePoiCategories', () async {
      // arrange
      // act
      await sut.showPointsOfInterest();
      final result = sut.getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, SBBPoiCategoryType.values.toSet());
      verify(listener()).called(1); // for switching visibility
    });

    test('getCategoryFilterByLayer_whenShowWithBaseLayerAndAllFiltered_shouldReturnEmptyList', () async {
      // arrange
      // act
      await sut.showPointsOfInterest(categories: []);
      final result = sut.getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, <SBBPoiCategoryType>{});
      verify(listener()).called(1);
    });

    test('getCategoryFilterByLayer_whenShowWithBaseLayerAnd([bike_parking])_shouldReturn[bike_parking]', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(categories: categories);
      final result = sut.getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, categories.toSet());
      verify(listener()).called(1);
    });

    test('getCategoryFilterByLayer_whenShowWithHighlightedPoiLayer_shouldReturnAllPOICategories', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted, categories: categories);
      final result = sut.getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, SBBPoiCategoryType.values.toSet());
      verify(listener()).called(1);
    });

    test('getCategoryFilterByLayer_whenShowPointsOfInterestWithVaryingPoiTypes_shouldReturnBaseOnFloorFilter',
        () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor, categories: categories);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted, categories: []);
      final result = sut.getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, categories.toSet());
      verify(listener()).called(2);
    });

    test('isPointsOfInterestVisible_whenDefault_shouldReturnFalse', () {
      // act
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, false);
      verifyNever(listener());
    });

    test('isPointsOfInterestVisible_whenShow(null)_shouldReturnTrue', () async {
      // arrange
      // act
      await sut.showPointsOfInterest();
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, true);
      verify(listener()).called(1);
    });

    test('isPointsOfInterestVisible_whenShow([])_shouldReturnTrue', () async {
      // act
      await sut.showPointsOfInterest(categories: []);
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, true);
      verify(listener()).called(1);
    });

    test('isPointsOfInterestVisible_whenShow([bike_parking])_shouldReturnTrue', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(categories: categories);
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, true);
      verify(listener()).called(1);
    });

    test('isPointsOfInterestVisible_whenShowAndHidePointsOfInterest_shouldReturnFalse', () async {
      // act
      await sut.showPointsOfInterest();
      await sut.hidePointsOfInterest();
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, false);
      verify(listener()).called(2);
    });

    test('isPointsOfInterestVisible_whenShowTwoTypes_shouldReturnTrue', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, true);
      verify(listener()).called(2);
    });

    test('isPointsOfInterestVisible_whenShowTwoTypesAndHideOneType_shouldReturnTrue(Any)', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      await sut.hidePointsOfInterest();
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, true);
      verify(listener()).called(3);
    });

    test('isPointsOfInterestVisible_whenShowTwoTypesAndHideTwoTypes_shouldReturnFalse', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      await sut.hidePointsOfInterest();
      await sut.hidePointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      final result = sut.isPointsOfInterestVisible;
      // expect
      expect(result, false);
      verify(listener()).called(4);
    });

    test('getVisibilityByLayer_whenDefault_shouldReturnFalse', () {
      // act
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, false);
      verifyNever(listener());
    });

    test('getVisibilityByLayer_whenShow(null)_shouldReturnTrue', () async {
      // arrange
      // act
      await sut.showPointsOfInterest();
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, true);
      verify(listener()).called(1);
    });

    test('getVisibilityByLayer_whenShow([])_shouldReturnTrue', () async {
      // act
      await sut.showPointsOfInterest(categories: []);
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, true);
      verify(listener()).called(1);
    });

    test('getVisibilityByLayer_whenShow([bike_parking])_shouldReturnTrue', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest(categories: categories);
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, true);
      verify(listener()).called(1);
    });

    test('getVisibilityByLayer_whenShowOtherTypeThanQueried_shouldReturnFalse', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.highlighted);
      // expect
      expect(result, false);
      verify(listener()).called(1);
    });

    test('getVisibilityByLayer_whenShowAndHidePointsOfInterest_shouldReturnFalse', () async {
      // act
      await sut.showPointsOfInterest();
      await sut.hidePointsOfInterest();
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, false);
      verify(listener()).called(2);
    });

    test('getVisibilityByLayer_whenShowTwoTypesAndOtherType_shouldReturnTrue', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.highlighted);
      // expect
      expect(result, true);
      verify(listener()).called(2);
    });

    test('getVisibilityByLayer_whenShowTwoTypesAndHideQueriedType_shouldReturnFalse', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      await sut.hidePointsOfInterest();
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, false);
      verify(listener()).called(3);
    });

    test('getVisibilityByLayer_whenShowTwoTypesAndHideTwoTypes_shouldReturnFalse', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      await sut.hidePointsOfInterest();
      await sut.hidePointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      final result = sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      expect(result, false);
      verify(listener()).called(4);
    });

    test('showPointsOfInterest_WhenDefaultLayer_shouldSetVisibilityToTrue', () async {
      // act
      await sut.showPointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, true)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_WhenDefaultLayerCalledTwice_shouldUpdateOnlyOnce', () async {
      // act
      await sut.showPointsOfInterest();
      await sut.showPointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, true)).called(2);
      verifyNever(mockController.setFilter(any, any));
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_WhenHighlightedLayer_shouldSetVisibilityToTrue', () async {
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      // expect
      verify(mockController.setLayerVisibility(rokasPoiHighlightedLayerId, true)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_WhenPoiAreClickable_shouldSetVisibilityInInteractableLayerToTrue', () async {
      // arrange
      onPoiSelected(_) {}
      sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController), onPoiSelected: onPoiSelected);
      // act
      await sut.showPointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorClickable, true)).called(1);
      verifyNever(mockController.setFilter(any, any));
    });

    test('showPointsOfInterest_whenCalledOnceWithoutFilterAndOnceWithFilter_shouldUpdateTwice', () async {
      // arrange
      final categories = [SBBPoiCategoryType.bike_parking];
      // act
      await sut.showPointsOfInterest();
      await sut.showPointsOfInterest(categories: categories);
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, true)).called(2);
      verify(mockController.setFilter(any, any)).called(1);
      verify(listener()).called(2);
    });

    test('showPointsOfInterest_whenEmptyListAndNoLayerFilters_shouldApplyWithEmptyList', () async {
      // arrange
      final categories = <SBBPoiCategoryType>[];
      // act
      await sut.showPointsOfInterest(categories: categories);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          emptySubCategoryFilterFixture,
        ),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenSingleCategoryAndNoLayerFilters_shouldApplyWithSingleCategory', () async {
      // arrange
      final categories = <SBBPoiCategoryType>[SBBPoiCategoryType.bakery];
      // act
      await sut.showPointsOfInterest(categories: categories);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          subCategoryFilterWithBakeryFixture,
        ),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenEmptyListAndExistingFilterWithoutSubCategory_shouldAddToLevelFilter', () async {
      // arrange
      when(mockController.getFilter(rokasPoiBaseLayerIdWithFloorNonClickable))
          .thenAnswer((_) => Future.value(lvlZeroFilterFixture));

      // act
      await sut.showPointsOfInterest(categories: []);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          lvlZeroWithEmptySubCategoryFilterFixture,
        ),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenSingleCategoryAndExistingFilterWithoutSubCategory_shouldAddToFilter', () async {
      // arrange
      when(mockController.getFilter(rokasPoiBaseLayerIdWithFloorNonClickable))
          .thenAnswer((_) => Future.value(lvlZeroFilterFixture));

      // act
      await sut.showPointsOfInterest(categories: [SBBPoiCategoryType.bakery]);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          lvlZeroWithBakerySubCategoryFilterFixture,
        ),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenSingleCategoryAndExistingMultiFilterWithoutSubCategory_shouldAddToFilter', () async {
      // arrange
      when(mockController.getFilter(rokasPoiBaseLayerIdWithFloorNonClickable))
          .thenAnswer((_) => Future.value(lvlZeroMultiFilterFixture));

      // act
      await sut.showPointsOfInterest(categories: [SBBPoiCategoryType.bakery]);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          lvlZeroMultiFilterWithBakerySubCategoryFilterFixture,
        ),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenNoCategoryAndNoLayerFilters_shouldApplyWithAllCategories', () async {
      // arrange
      await sut.showPointsOfInterest(categories: []);
      reset(mockController);

      // act
      await sut.showPointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          subCategoryFilterWithAllCategoriesFixture,
        ),
      ).called(1);
      verify(listener()).called(1);
    });

    test('hidePointsOfInterest_whenDefault_shouldNotNotifyListenersAndMakeCall', () async {
      // act
      await sut.hidePointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, false)).called(1);
      verifyNever(listener());
    });

    test('hidePointsOfInterest_whenInteractableSut_shouldNotNotifyListenersAndMakeCall', () async {
      // arrange
      onPoiSelected(_) {}
      sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController), onPoiSelected: onPoiSelected);
      // act
      await sut.hidePointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorClickable, false)).called(1);
      verifyNever(listener());
    });

    test('hidePointsOfInterest_whenVisibleBefore_shouldNotifyListenersAndMakeCall', () async {
      // arrange
      await sut.showPointsOfInterest();
      reset(listener);
      // act
      await sut.hidePointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, false)).called(1);
      verify(listener()).called(1);
    });

    test('hidePointsOfInterest_whenInvisibleOtherThanDefault_shouldNotNotifyListenersAndMakeCall', () async {
      // arrange
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      reset(listener);
      // act
      await sut.hidePointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, false)).called(1);
      verifyNever(listener());
    });

    test('hideAllPointsOfInterest_whenDefault_shouldNotCallListenerAndMakeCalls', () async {
      // act
      await sut.hideAllPointsOfInterest();
      // expect
      verify(mockController.setLayerVisibility(any, false)).called(4);
      verifyNever(listener());
    });

    test('hideAllPointsOfInterest_whenCalledAfterShowingSome_shouldNotHaveAnyVisibilityAndNotifyListeners', () async {
      // arrange
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      reset(listener);
      // act
      await sut.hideAllPointsOfInterest();
      // expect
      verify(listener()).called(1);
      verify(mockController.setLayerVisibility(any, false)).called(4);
      expect(sut.isPointsOfInterestVisible, false);
    });

    test('selectPointOfInterest_ifPOIsNotVisible_shouldNotDoAnything', () async {
      // act
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      // expect
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(mockController.querySourceFeatures(any, any, any));
      verifyNever(listener());
    });

    test('selectPointOfInterest_ifPOIsVisibleAndPoiSelected_shouldNotifyListeners', () async {
      // arrange
      await sut.showPointsOfInterest();
      reset(mockController);
      reset(listener);
      when(mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture))
          .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

      // act
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);

      // expect
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      verify(mockController.querySourceFeatures(journeyPoisSource, any, mobilityBikeSharingFilterFixture)).called(1);
      verify(mockController.setFilter(selectedPoiLayerId, mobilityBikeSharingFilterFixture)).called(1);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
      verify(listener()).called(1);
    });

    test('selectPointOfInterestAt_ifPOIsNotVisible_shouldNotDoAnything', () async {
      // act
      await sut.selectPointOfInterestAt(coordinates: LatLng(0, 0));
      // expect
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(mockController.querySourceFeatures(any, any, any));
      verifyNever(listener());
    });

    test('selectPointOfInterestAt_ifPoiIsVisibleButNoPoiUnderneath_shouldNotDoAnything', () async {
      // arrange
      const coordinates = LatLng(0, 0);
      const point = Point(0.0, 0.0);
      await sut.showPointsOfInterest();
      reset(mockController);
      reset(listener);
      when(mockController.moveCamera(any)).thenAnswer((_) => Future.value());
      when(mockController.toScreenLocation(coordinates)).thenAnswer((_) => Future.value(point));
      when(mockController.queryRenderedFeatures(point, any, any)).thenAnswer((_) => Future.value([]));

      // act
      await sut.selectPointOfInterestAt(coordinates: coordinates);
      // expect
      verify(mockController.moveCamera(any)).called(1);
      verify(mockController.toScreenLocation(any)).called(1);
      verify(mockController.queryRenderedFeatures(any, any, any)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(listener());
    });

    test('selectPointOfInterestAt_ifPoiIsVisibleAndPoiUnderneath_shouldSelectPoi', () async {
      // arrange
      const coordinates = LatLng(0, 0);
      const point = Point(0.0, 0.0);
      await sut.showPointsOfInterest();
      reset(mockController);
      reset(listener);
      when(mockController.moveCamera(any)).thenAnswer((_) => Future.value());
      when(mockController.toScreenLocation(coordinates)).thenAnswer((_) => Future.value(point));
      when(mockController.queryRenderedFeatures(point, any, any))
          .thenAnswer((_) => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

      // act
      await sut.selectPointOfInterestAt(coordinates: coordinates);
      // expect
      verify(mockController.moveCamera(any)).called(1);
      verify(mockController.toScreenLocation(any)).called(1);
      verify(mockController.queryRenderedFeatures(any, any, any)).called(1);
      verify(mockController.setFilter(any, any)).called(1);
      verify(mockController.setLayerProperties(any, any)).called(1);
      verify(listener()).called(1);
    });

    test('deselectPointOfInterest_ifNotVisibleAndPOIIsDeselected_shouldNotNotifyListeners', () async {
      // arrange
      await sut.showPointsOfInterest();

      when(mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture))
          .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      await sut.hidePointsOfInterest();
      reset(mockController);
      reset(listener);

      // act
      await sut.deselectPointOfInterest();

      // expect
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(listener());
    });

    test('deselectPointOfInterest_IfVisibleAndPoiSelected_shouldNotifyListenersAndMakeCalls', () async {
      // arrange
      await sut.showPointsOfInterest();

      when(mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture))
          .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      reset(mockController);
      reset(listener);

      // act
      await sut.deselectPointOfInterest();

      // expect
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
      verify(listener()).called(1);
    });

    test('toggleSelectedPointOfInterest_IfPoiNotVisible_shouldNotDoAnything', () async {
      // arrange + act (is POIs visible is false by default)
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));
      // expect
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(mockController.querySourceFeatures(any, any, any));
      verifyNever(listener());
    });

    test('toggleSelectedPointOfInterest_IfVisibleAndPoiSelected_shouldMakeCallsAndNotify', () async {
      // arrange
      await sut.showPointsOfInterest();
      reset(mockController);
      reset(listener);
      when(mockController.queryRenderedFeatures(any, any, any))
          .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

      // act
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));

      // expect
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      verify(mockController.setFilter(selectedPoiLayerId, mobilityBikeSharingFilterFixture)).called(1);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
      verify(listener()).called(1);
    });

    test('synchronizeWithNewStyle_whenDefault_shouldCallVisibilityFalseAndNotNotify', () async {
      // act
      await sut.synchronizeWithNewStyle();

      // expect
      verify(mockController.setLayerVisibility(any, false)).called(4);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(listener()); // never called except for POI dropped
    });

    test('synchronizeWithNewStyle_whenDefaultLayerIsVisible_shouldCallVisibilityTrue', () async {
      // arrange
      await sut.showPointsOfInterest();
      reset(listener);
      reset(mockController);

      // act
      await sut.synchronizeWithNewStyle();

      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, true)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(listener()); // never called except for POI dropped
    });

    test('synchronizeWithNewStyle_whenDefaultLayerIsVisibleAndFiltered_shouldCallFilters', () async {
      // arrange
      await sut.showPointsOfInterest(categories: [SBBPoiCategoryType.bike_parking]);
      reset(listener);
      reset(mockController);

      // act
      await sut.synchronizeWithNewStyle();

      // expect
      verify(mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, true)).called(1);
      verify(
        mockController.setFilter(
          rokasPoiBaseLayerIdWithFloorNonClickable,
          bikeParkingCategoriesFiltureFixture,
        ),
      ).called(1);
      verifyNever(listener()); // never called except for POI dropped
    });
  });
}
