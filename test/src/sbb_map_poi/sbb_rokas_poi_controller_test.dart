import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_poi/controller/sbb_rokas_poi_controller_impl.dart';

import '../../util/mock_callback_function.dart';
import 'sbb_rokas_poi_controller.fixture.dart';
@GenerateNiceMocks([MockSpec<MapLibreMapController>()])
import 'sbb_rokas_poi_controller_test.mocks.dart';

void main() {
  late SBBRokasPOIControllerImpl sut;
  late MockMapLibreMapController mockController;
  final listener = MockCallbackFunction();

  group('Unit Test SBBRokasPoiController', () {
    setUp(
      () => {
        mockController = MockMapLibreMapController(),
        sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController)),
        sut.addListener(listener.call),
        reset(mockController),
        reset(listener),
      },
    );

    test('getAvailablePOICategories_shouldReturnAllAvailablePoiCategories', () {
      // arrange
      // act
      final result = sut.availablePOICategories;
      // expect
      expect(result, SBBPoiCategoryType.values.toList());
      verifyNever(listener());
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

    test(
      'getCategoryFilterByLayer_whenShowPointsOfInterestWithVaryingPoiTypes_shouldReturnBaseOnFloorFilter',
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
      },
    );

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
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorNonClickable, emptySubCategoryFilterFixture),
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
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorNonClickable, subCategoryFilterWithBakeryFixture),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenEmptyListAndExistingFilterWithoutSubCategory_shouldAddToLevelFilter', () async {
      // arrange
      when(
        mockController.getFilter(rokasPoiBaseLayerIdWithFloorNonClickable),
      ).thenAnswer((_) => Future.value(lvlZeroFilterFixture));

      // act
      await sut.showPointsOfInterest(categories: []);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorNonClickable, lvlZeroWithEmptySubCategoryFilterFixture),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenSingleCategoryAndExistingFilterWithoutSubCategory_shouldAddToFilter', () async {
      // arrange
      when(
        mockController.getFilter(rokasPoiBaseLayerIdWithFloorNonClickable),
      ).thenAnswer((_) => Future.value(lvlZeroFilterFixture));

      // act
      await sut.showPointsOfInterest(categories: [SBBPoiCategoryType.bakery]);
      // expect
      verify(mockController.setLayerVisibility(any, any)).called(1);
      verify(
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorNonClickable, lvlZeroWithBakerySubCategoryFilterFixture),
      ).called(1);
      verify(listener()).called(1);
    });

    test('showPointsOfInterest_whenSingleCategoryAndExistingMultiFilterWithoutSubCategory_shouldAddToFilter', () async {
      // arrange
      when(
        mockController.getFilter(rokasPoiBaseLayerIdWithFloorNonClickable),
      ).thenAnswer((_) => Future.value(lvlZeroMultiFilterFixture));

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
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorNonClickable, subCategoryFilterWithAllCategoriesFixture),
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
      expect(sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.baseWithFloor), false);
      expect(sut.getVisibilityByLayer(layer: SBBRokasPoiLayer.highlighted), false);
    });

    test('selectPointOfInterest_ifPOIsNotVisible_shouldNotDoAnything', () async {
      // act
      final result = await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      // expect
      expect(result, isNull);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(mockController.querySourceFeatures(any, any, any));
      verifyNever(listener());
    });

    test('selectPointOfInterest_ifPOIsVisibleAndPoiSelected_shouldNotifyListeners', () async {
      // arrange
      final selectedPois = <RokasPOI>[];
      sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController), onPoiSelected: selectedPois.add);
      sut.addListener(listener.call);
      await sut.showPointsOfInterest();
      reset(mockController);
      reset(listener);
      when(
        mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

      // act
      final result = await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);

      // expect
      expect(result, mobilityBikesharingPoiFixture);
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      expect(selectedPois, [mobilityBikesharingPoiFixture]);
      verify(mockController.querySourceFeatures(journeyPoisSource, any, mobilityBikeSharingFilterFixture)).called(1);
      verify(mockController.setFilter(selectedPoiLayerId, mobilityBikeSharingFilterFixture)).called(1);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
      verify(listener()).called(1);
    });

    test('selectPointOfInterest_ifPoiSelectedAndIdUnknown_shouldDeselectAndReturnNull', () async {
      // arrange
      final onPoiDeselected = MockCallbackPoiFunction();
      sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController), onPoiDeselected: onPoiDeselected.call);
      sut.addListener(listener.call);
      await sut.showPointsOfInterest();
      when(
        mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      reset(mockController);
      reset(listener);
      when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => Future.value([]));

      // act
      final result = await sut.selectPointOfInterest(sbbId: 'unknown');

      // expect
      expect(result, isNull);
      expect(sut.selectedPointOfInterest, isNull);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verify(onPoiDeselected(mobilityBikesharingPoiFixture)).called(1);
      verify(listener()).called(1);
    });

    test('selectPointOfInterest_ifNothingSelectedAndIdUnknown_shouldNotDeselectAndReturnNull', () async {
      // arrange
      final onPoiDeselected = MockCallbackPoiFunction();
      sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController), onPoiDeselected: onPoiDeselected.call);
      sut.addListener(listener.call);
      await sut.showPointsOfInterest();
      reset(mockController);
      reset(listener);
      when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => Future.value([]));

      // act
      final result = await sut.selectPointOfInterest(sbbId: 'unknown');

      // expect
      expect(result, isNull);
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(onPoiDeselected(any));
      verifyNever(listener());
    });

    test('selectPointOfInterestAt_ifPOIsNotVisible_shouldNotDoAnything', () async {
      // act
      final result = await sut.selectPointOfInterestAt(coordinates: LatLng(0, 0));
      // expect
      expect(result, isNull);
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
      final result = await sut.selectPointOfInterestAt(coordinates: coordinates);
      // expect
      expect(result, isNull);
      verify(mockController.moveCamera(any)).called(1);
      verify(mockController.toScreenLocation(any)).called(1);
      verify(mockController.queryRenderedFeatures(any, any, any)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
      verifyNever(listener());
    });

    test('selectPointOfInterestAt_ifPoiSelectedAndNoPoiUnderneath_shouldDeselectAndReturnNull', () async {
      // arrange
      const coordinates = LatLng(0, 0);
      const point = Point(0.0, 0.0);
      final onPoiDeselected = MockCallbackPoiFunction();
      sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController), onPoiDeselected: onPoiDeselected.call);
      sut.addListener(listener.call);
      await sut.showPointsOfInterest();
      when(
        mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      reset(mockController);
      reset(listener);
      when(mockController.moveCamera(any)).thenAnswer((_) => Future.value());
      when(mockController.toScreenLocation(coordinates)).thenAnswer((_) => Future.value(point));
      when(mockController.queryRenderedFeatures(point, any, any)).thenAnswer((_) => Future.value([]));

      // act
      final result = await sut.selectPointOfInterestAt(coordinates: coordinates);

      // expect
      expect(result, isNull);
      expect(sut.selectedPointOfInterest, isNull);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
      verifyNever(mockController.setFilter(any, any));
      verify(onPoiDeselected(mobilityBikesharingPoiFixture)).called(1);
      verify(listener()).called(1);
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
      when(
        mockController.queryRenderedFeatures(point, any, any),
      ).thenAnswer((_) => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

      // act
      final result = await sut.selectPointOfInterestAt(coordinates: coordinates);
      // expect
      expect(result, mobilityBikesharingPoiFixture);
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

      when(
        mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
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

      when(
        mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
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
      when(
        mockController.queryRenderedFeatures(any, any, any),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

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
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorNonClickable, bikeParkingCategoriesFiltureFixture),
      ).called(1);
      verifyNever(listener()); // never called except for POI dropped
    });
  });

  group('Unit Test SBBRokasPoiController selected layer properties', () {
    late MockMapLibreMapController mockController;

    setUp(() {
      mockController = MockMapLibreMapController();
    });

    Future<Map<String, dynamic>> capturePropertiesOnSelect({bool isDarkMode = false}) async {
      final sut = SBBRokasPOIControllerImpl(
        controller: Future.value(mockController),
        isDarkMode: () => isDarkMode,
      );
      await sut.showPointsOfInterest();
      when(
        mockController.queryRenderedFeatures(any, any, any),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

      await sut.toggleSelectedPointOfInterest(const Point(0, 0));

      final properties =
          verify(mockController.setLayerProperties(selectedPoiLayerId, captureAny)).captured.last
              as SymbolLayerProperties;
      return properties.toJson(skipNulls: false);
    }

    test('selectPointOfInterest_shouldKeepIconImageOfSelectedLayer', () async {
      // act
      final json = await capturePropertiesOnSelect();

      // expect
      // setLayerProperties sends null for every omitted property, which resets
      // it on the native side. The icon has to survive the opacity override.
      expect(json['icon-image'], selectedPoiBrightIcon);
      expect(json['icon-anchor'], 'bottom');
      expect(json['icon-ignore-placement'], isTrue);
      expect(json['icon-opacity'], 1.0);
      expect(json['visibility'], 'visible');
    });

    test('selectPointOfInterest_whenDarkMode_shouldUseDarkIcon', () async {
      // act
      final json = await capturePropertiesOnSelect(isDarkMode: true);

      // expect
      expect(json['icon-image'], selectedPoiDarkIcon);
    });

    test('deselectPointOfInterest_shouldKeepIconImageOfSelectedLayer', () async {
      // arrange
      final sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController));
      await sut.showPointsOfInterest();
      when(
        mockController.queryRenderedFeatures(any, any, any),
      ).thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));

      // act
      await sut.deselectPointOfInterest();

      // expect
      final properties =
          verify(mockController.setLayerProperties(selectedPoiLayerId, captureAny)).captured.last
              as SymbolLayerProperties;
      final json = properties.toJson(skipNulls: false);
      expect(json['icon-image'], selectedPoiBrightIcon);
      expect(json['icon-opacity'], 0.0);
      expect(json['visibility'], 'none');
    });
  });

  group('Unit Test SBBRokasPoiController selection callbacks update', () {
    late MockMapLibreMapController mockController;
    late List<String> calls;

    setUp(() {
      mockController = MockMapLibreMapController();
      calls = [];
      when(
        mockController.queryRenderedFeatures(any, any, any),
      ).thenAnswer((_) async => [mobilityBikesharingPoiGeoJSONFixture]);
    });

    SBBRokasPOIControllerImpl createSut() => SBBRokasPOIControllerImpl(
      controller: Future.value(mockController),
      onPoiSelected: (_) => calls.add('oldSelected'),
      onPoiDeselected: (_) => calls.add('oldDeselected'),
    );

    test('updateSelectionCallbacks_whenPoiSelectedThenDeselected_shouldCallNewCallbacksOnly', () async {
      // arrange
      final sut = createSut();
      await sut.showPointsOfInterest();
      // act
      await sut.updateSelectionCallbacks(
        onPoiSelected: (_) => calls.add('newSelected'),
        onPoiDeselected: (poi) => calls.add('newDeselected ${poi.sbbId}'),
      );
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));
      when(mockController.queryRenderedFeatures(any, any, any)).thenAnswer((_) async => []);
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));
      // expect
      expect(calls, ['newSelected', 'newDeselected ${mobilityBikesharingPoiFixture.sbbId}']);
    });

    test('updateSelectionCallbacks_whenPoisBecomeClickable_shouldMoveVisibilityAndFilterToClickableLayer', () async {
      // arrange
      final sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController));
      await sut.showPointsOfInterest(categories: [SBBPoiCategoryType.bakery]);
      reset(mockController);
      // act
      await sut.updateSelectionCallbacks(onPoiSelected: (_) {}, onPoiDeselected: null);
      // expect
      verifyInOrder([
        mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, false),
        mockController.setFilter(rokasPoiBaseLayerIdWithFloorClickable, subCategoryFilterWithBakeryFixture),
        mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorClickable, true),
      ]);
    });

    test('updateSelectionCallbacks_whenPoisStopBeingClickable_shouldMoveVisibilityToNonClickableLayer', () async {
      // arrange
      final sut = createSut();
      await sut.showPointsOfInterest();
      reset(mockController);
      // act
      await sut.updateSelectionCallbacks(onPoiSelected: null, onPoiDeselected: null);
      // expect
      verifyInOrder([
        mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorClickable, false),
        mockController.setLayerVisibility(rokasPoiBaseLayerIdWithFloorNonClickable, true),
      ]);
      verifyNever(mockController.setFilter(any, any));
    });

    test('updateSelectionCallbacks_whenHiddenAndClickabilityChanges_shouldKeepPoisHidden', () async {
      // arrange
      final sut = SBBRokasPOIControllerImpl(controller: Future.value(mockController));
      // act
      await sut.updateSelectionCallbacks(onPoiSelected: (_) {}, onPoiDeselected: null);
      // expect
      verifyNever(mockController.setLayerVisibility(any, true));
      verifyNever(mockController.setFilter(any, any));
    });

    test('updateSelectionCallbacks_whenClickabilityUnchanged_shouldNotTouchLayers', () async {
      // arrange
      final sut = createSut();
      await sut.showPointsOfInterest(categories: [SBBPoiCategoryType.bakery]);
      reset(mockController);
      // act
      await sut.updateSelectionCallbacks(onPoiSelected: (_) {}, onPoiDeselected: (_) {});
      // expect
      verifyZeroInteractions(mockController);
    });
  });

  group('Unit Test SBBRokasPoiController selection consistency', () {
    late MockMapLibreMapController mockController;
    late SBBRokasPOIControllerImpl sut;
    late List<String> calls;

    setUp(() {
      mockController = MockMapLibreMapController();
      calls = [];
      sut = SBBRokasPOIControllerImpl(
        controller: Future.value(mockController),
        onPoiSelected: (poi) => calls.add('selected ${poi.sbbId}, state ${sut.selectedPointOfInterest?.sbbId}'),
        onPoiDeselected: (poi) => calls.add('deselected ${poi.sbbId}, state ${sut.selectedPointOfInterest?.sbbId}'),
      );
      sut.addListener(() => calls.add('notified'));
      when(
        mockController.queryRenderedFeatures(any, any, any),
      ).thenAnswer((_) async => [mobilityBikesharingPoiGeoJSONFixture]);
    });

    Future<void> showAndSelectPoi() async {
      await sut.showPointsOfInterest();
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));
      calls.clear();
      clearInteractions(mockController);
    }

    test('hideAllPointsOfInterest_whenPoiSelected_shouldClearHighlightNotifyAndThenCallDeselected', () async {
      // arrange
      await showAndSelectPoi();
      // act
      await sut.hideAllPointsOfInterest();
      // expect
      expect(sut.selectedPointOfInterest, isNull);
      expect(calls, ['notified', 'deselected ${mobilityBikesharingPoiFixture.sbbId}, state null']);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
    });

    test('hidePointsOfInterest_whenLastVisibleLayerHidden_shouldDeselect', () async {
      // arrange
      await showAndSelectPoi();
      // act
      await sut.hidePointsOfInterest();
      // expect
      expect(sut.selectedPointOfInterest, isNull);
      expect(calls, ['notified', 'deselected ${mobilityBikesharingPoiFixture.sbbId}, state null']);
      verify(mockController.setLayerProperties(selectedPoiLayerId, any)).called(1);
    });

    test('hidePointsOfInterest_whenOtherLayerStaysVisible_shouldKeepSelection', () async {
      // arrange
      await showAndSelectPoi();
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      calls.clear();
      // act
      await sut.hidePointsOfInterest();
      // expect
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      expect(calls, ['notified']);
      verifyNever(mockController.setLayerProperties(selectedPoiLayerId, any));
    });

    test('selectPointOfInterest_whenOtherPoiFound_shouldNotifyAndThenCallSelectedWithNewState', () async {
      // arrange
      await sut.showPointsOfInterest();
      calls.clear();
      when(
        mockController.querySourceFeatures(any, any, any),
      ).thenAnswer((_) async => [mobilityBikesharingPoiGeoJSONFixture]);
      // act
      await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      // expect
      final sbbId = mobilityBikesharingPoiFixture.sbbId;
      expect(calls, ['notified', 'selected $sbbId, state $sbbId']);
    });

    test('selectPointOfInterest_whenOtherPoiFoundWhilePoiSelected_shouldCallSelectedOnly', () async {
      // arrange
      await showAndSelectPoi();
      const otherSbbId = 'other-sbb-id';
      final otherPoiGeoJSON = {
        ...mobilityBikesharingPoiGeoJSONFixture,
        'properties': {...?mobilityBikesharingPoiGeoJSONFixture['properties'] as Map?, 'sbbId': otherSbbId},
      };
      when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) async => [otherPoiGeoJSON]);
      // act
      await sut.selectPointOfInterest(sbbId: otherSbbId);
      // expect
      expect(calls, ['notified', 'selected $otherSbbId, state $otherSbbId']);
    });

    test('selectPointOfInterest_whenSamePoiAlreadySelected_shouldDoNothingAndReturnIt', () async {
      // arrange
      await showAndSelectPoi();
      when(
        mockController.querySourceFeatures(any, any, any),
      ).thenAnswer((_) async => [mobilityBikesharingPoiGeoJSONFixture]);
      // act
      final result = await sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      // expect
      expect(result, mobilityBikesharingPoiFixture);
      expect(calls, isEmpty);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
    });

    test('toggleSelectedPointOfInterest_whenSameSbbIdWithOtherCoordinates_shouldDoNothing', () async {
      // arrange
      await showAndSelectPoi();
      final shiftedPoi = {
        ...mobilityBikesharingPoiGeoJSONFixture,
        'geometry': {
          'type': 'Point',
          'coordinates': [7.4498355, 46.9525271],
        },
      };
      when(mockController.queryRenderedFeatures(any, any, any)).thenAnswer((_) async => [shiftedPoi]);
      // act
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));
      // expect
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      expect(calls, isEmpty);
      verifyNever(mockController.setFilter(any, any));
      verifyNever(mockController.setLayerProperties(any, any));
    });

    test('deselectPointOfInterest_whenPoiSelected_shouldNotifyAndThenCallDeselectedWithNewState', () async {
      // arrange
      await showAndSelectPoi();
      // act
      await sut.deselectPointOfInterest();
      // expect
      expect(calls, ['notified', 'deselected ${mobilityBikesharingPoiFixture.sbbId}, state null']);
    });

    test('synchronizeWithNewStyle_whenPoiSelected_shouldKeepSelectionAndReapplyHighlight', () async {
      // arrange
      await showAndSelectPoi();
      when(mockController.getLayerIds()).thenAnswer((_) async => [selectedPoiLayerId]);
      // act
      await sut.synchronizeWithNewStyle();
      // expect
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      expect(calls, isEmpty);
      verify(mockController.setFilter(selectedPoiLayerId, mobilityBikeSharingFilterFixture)).called(1);
      final properties =
          verify(mockController.setLayerProperties(selectedPoiLayerId, captureAny)).captured.single
              as SymbolLayerProperties;
      expect(properties.toJson()['visibility'], 'visible');
    });

    test('synchronizeWithNewStyle_whenPoiSelectedAndStyleHasNoSelectedLayer_shouldDeselect', () async {
      // arrange
      await showAndSelectPoi();
      when(mockController.getLayerIds()).thenAnswer((_) async => []);
      // act
      await sut.synchronizeWithNewStyle();
      // expect
      expect(sut.selectedPointOfInterest, isNull);
      expect(calls, ['notified', 'deselected ${mobilityBikesharingPoiFixture.sbbId}, state null']);
      verifyNever(mockController.setFilter(selectedPoiLayerId, any));
      verifyNever(mockController.setLayerProperties(selectedPoiLayerId, any));
    });

    test('toggleSelectedPointOfInterest_whenAllPoisHiddenDuringHighlight_shouldEndWithHighlightHidden', () async {
      // arrange
      final highlight = Completer<void>();
      when(mockController.setFilter(selectedPoiLayerId, any)).thenAnswer((_) => highlight.future);
      await sut.showPointsOfInterest();
      calls.clear();
      final tap = sut.toggleSelectedPointOfInterest(const Point(0, 0));
      await pumpEventQueue();
      // act
      await sut.hideAllPointsOfInterest();
      highlight.complete();
      await tap;
      // expect
      final sbbId = mobilityBikesharingPoiFixture.sbbId;
      expect(sut.selectedPointOfInterest, isNull);
      expect(calls, ['notified', 'selected $sbbId, state $sbbId', 'notified', 'deselected $sbbId, state null']);
      final properties = verify(mockController.setLayerProperties(selectedPoiLayerId, captureAny)).captured;
      expect((properties.last as SymbolLayerProperties).toJson()['visibility'], 'none');
    });

    test('showPointsOfInterest_whenPoiSelected_shouldKeepSelection', () async {
      // arrange
      await showAndSelectPoi();
      // act
      await sut.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
      // expect
      expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
      expect(calls, ['notified']);
      verifyNever(mockController.setLayerProperties(selectedPoiLayerId, any));
    });
  });

  group('Unit Test SBBRokasPoiController overlapping selections', () {
    late MockMapLibreMapController mockController;
    late SBBRokasPOIControllerImpl sut;
    late List<String> calls;
    late Completer<List> lookup;

    setUp(() async {
      mockController = MockMapLibreMapController();
      calls = [];
      lookup = Completer();
      sut = SBBRokasPOIControllerImpl(
        controller: Future.value(mockController),
        onPoiSelected: (poi) => calls.add('selected ${poi.sbbId}'),
        onPoiDeselected: (_) => calls.add('deselected'),
      );
      when(mockController.querySourceFeatures(any, any, any)).thenAnswer((_) => lookup.future);
      await sut.showPointsOfInterest();
    });

    Future<RokasPOI?> completeLookup(Future<RokasPOI?> selection) {
      lookup.complete([mobilityBikesharingPoiGeoJSONFixture]);
      return selection;
    }

    test('selectPointOfInterest_whenAllPoisHiddenDuringLookup_shouldNotSelect', () async {
      // arrange
      final selection = sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      await sut.hideAllPointsOfInterest();
      // act
      final result = await completeLookup(selection);
      // expect
      expect(result, isNull);
      expect(sut.selectedPointOfInterest, isNull);
      expect(calls, isEmpty);
      verifyNever(mockController.setFilter(selectedPoiLayerId, any));
    });

    test('selectPointOfInterest_whenPoisHiddenAndShownDuringLookup_shouldNotSelect', () async {
      // arrange
      final selection = sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      await sut.hidePointsOfInterest();
      await sut.showPointsOfInterest();
      // act
      final result = await completeLookup(selection);
      // expect
      expect(result, isNull);
      expect(calls, isEmpty);
    });

    test('selectPointOfInterest_whenStyleChangesDuringLookup_shouldNotSelect', () async {
      // arrange
      final selection = sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      await sut.synchronizeWithNewStyle();
      // act
      final result = await completeLookup(selection);
      // expect
      expect(result, isNull);
      expect(calls, isEmpty);
    });

    test('selectPointOfInterest_whenPoiTappedDuringLookup_shouldKeepTappedPoi', () async {
      // arrange
      final tappedPoi = {
        ...mobilityBikesharingPoiGeoJSONFixture,
        'properties': {...?mobilityBikesharingPoiGeoJSONFixture['properties'] as Map?, 'sbbId': 'tapped'},
      };
      when(mockController.queryRenderedFeatures(any, any, any)).thenAnswer((_) async => [tappedPoi]);
      final selection = sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      await sut.toggleSelectedPointOfInterest(const Point(0, 0));
      // act
      final result = await completeLookup(selection);
      // expect
      expect(result?.sbbId, 'tapped');
      expect(sut.selectedPointOfInterest?.sbbId, 'tapped');
      expect(calls, ['selected tapped']);
    });

    test('selectPointOfInterest_whenDeselectedDuringLookup_shouldStayDeselected', () async {
      // arrange
      final selection = sut.selectPointOfInterest(sbbId: mobilityBikesharingPoiFixture.sbbId);
      await sut.deselectPointOfInterest();
      // act
      final result = await completeLookup(selection);
      // expect
      expect(result, isNull);
      expect(sut.selectedPointOfInterest, isNull);
      expect(calls, isEmpty);
    });
  });
}
