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

    group('get availablePOICategories', () {
      test('Should return all available POI categories', () {
        // arrange
        // act
        final result = sut.availablePOICategories;
        // expect
        expect(result, SBBPoiCategoryType.values.toList());
        verifyNever(listener());
      });
    });

    group('get currentPOICategories', () {
      test('Should return all available POI categories by default', () {
        // arrange
        // act
        final result = sut.currentPOICategories;
        // expect
        expect(result, SBBPoiCategoryType.values.toList());
        verifyNever(listener());
      });

      test('Should return all available POI categories after showPointsOfInterest(null)', () async {
        // arrange
        // act
        await sut.showPointsOfInterest();
        final result = sut.currentPOICategories;
        // expect
        expect(result, SBBPoiCategoryType.values.toList());
        verify(listener()).called(1); // for switching visibility
      });

      test('Should return empty list after showPointsOfInterest([])', () async {
        // arrange
        // act
        await sut.showPointsOfInterest(categories: []);
        final result = sut.currentPOICategories;
        // expect
        expect(result, []);
        verify(listener()).called(1);
      });

      test('Should return [bike_parking] after showPointsOfInterest([bike_parking])', () async {
        // arrange
        final categories = [SBBPoiCategoryType.bike_parking];
        // act
        await sut.showPointsOfInterest(categories: categories);
        final result = sut.currentPOICategories;
        // expect
        expect(result, categories);
        verify(listener()).called(1);
      });
    });
    group('get isPointsOfInterestVisible', () {
      test('Should return false by default', () {
        // arrange
        // act
        final result = sut.isPointsOfInterestVisible;
        // expect
        expect(result, false);
        verifyNever(listener());
      });

      test('Should return true after showPointsOfInterest(null)', () async {
        // arrange
        // act
        await sut.showPointsOfInterest();
        final result = sut.isPointsOfInterestVisible;
        // expect
        expect(result, true);
        verify(listener()).called(1);
      });

      test('Should return true after showPointsOfInterest([])', () async {
        // arrange
        // act
        await sut.showPointsOfInterest(categories: []);
        final result = sut.isPointsOfInterestVisible;
        // expect
        expect(result, true);
        verify(listener()).called(1);
      });

      test('Should return true after showPointsOfInterest([bike_parking])', () async {
        // arrange
        final categories = [SBBPoiCategoryType.bike_parking];
        // act
        await sut.showPointsOfInterest(categories: categories);
        final result = sut.isPointsOfInterestVisible;
        // expect
        expect(result, true);
        verify(listener()).called(1);
      });
    });
    group('showPointsOfInterest', () {
      const poiLayerId = 'journey-pois';
      test('Should set visibility to true and ', () async {
        // arrange
        // act
        await sut.showPointsOfInterest();
        // expect
        verify(mockController.setLayerVisibility(poiLayerId, true)).called(1);
        verify(
          mockController.setFilter(poiLayerId, allPOICategoriesFiltureFixture),
        ).called(1);
        verify(listener()).called(1);
      });

      test('Should set visibility to true and apply filter', () async {
        // arrange
        final categories = [SBBPoiCategoryType.bike_parking];
        // act
        await sut.showPointsOfInterest(categories: categories);
        // expect
        verify(mockController.setLayerVisibility(poiLayerId, true)).called(1);
        verify(
          mockController.setFilter(
            poiLayerId,
            bikeParkingCategoriesFiltureFixture,
          ),
        ).called(1);
        verify(listener()).called(1);
      });
    });
    group('hidePointsOfInterest', () {
      const poiLayerId = 'journey-pois';
      test('Should not notify listeners if not visible before', () async {
        // arrange
        // act
        await sut.hidePointsOfInterest();
        // expect
        verify(mockController.setLayerVisibility(poiLayerId, false)).called(1);
        verifyNever(listener());
      });

      test('Should notify listeners if visible before', () async {
        // arrange
        await sut.showPointsOfInterest();
        // act
        await sut.hidePointsOfInterest();
        // expect
        verify(mockController.setLayerVisibility(poiLayerId, false)).called(1);
        verify(listener()).called(2);
      });
    });
    group('selectPointOfInterest', () {
      const journeyPoisSource = 'journey-pois-source';
      const selectedPoiLayerId = 'journey-pois-selected';
      test('Should not do anything if POIs not visible', () async {
        // arrange + act (is POIs visible is false by default)
        await sut.selectPointOfInterest(
          sbbId: mobilityBikesharingPoiFixture.sbbId,
        );
        // expect
        verifyNever(mockController.setFilter(any, any));
        verifyNever(mockController.setLayerProperties(any, any));
        verifyNever(mockController.querySourceFeatures(any, any, any));
        verifyNever(listener());
      });

      test('Should notify listeners if visible and poi is selected', () async {
        // arrange
        await sut.showPointsOfInterest();
        reset(mockController);
        reset(listener);
        when(mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture))
            .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));

        // act
        await sut.selectPointOfInterest(
          sbbId: mobilityBikesharingPoiFixture.sbbId,
        );

        // expect
        expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
        verify(mockController.querySourceFeatures(
          journeyPoisSource,
          any,
          mobilityBikeSharingFilterFixture,
        )).called(1);
        verify(mockController.setFilter(
          selectedPoiLayerId,
          mobilityBikeSharingFilterFixture,
        )).called(1);
        verify(mockController.setLayerProperties(
          selectedPoiLayerId,
          any,
        )).called(1);
        verify(listener()).called(1);
      });
    });
    group('deselectPointOfInterest', () {
      const journeyPoisSource = 'journey-pois-source';
      const selectedPoiLayerId = 'journey-pois-selected';
      test('Should not notify listeners if not visible and poi is deselected', () async {
        // arrange
        await sut.showPointsOfInterest();

        when(mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture))
            .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
        await sut.selectPointOfInterest(
          sbbId: mobilityBikesharingPoiFixture.sbbId,
        );
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

      test('Should notify listeners if visible and poi is deselected', () async {
        // arrange
        await sut.showPointsOfInterest();

        when(mockController.querySourceFeatures(journeyPoisSource, 'journey_pois', mobilityBikeSharingFilterFixture))
            .thenAnswer((_) async => Future.value([mobilityBikesharingPoiGeoJSONFixture]));
        await sut.selectPointOfInterest(
          sbbId: mobilityBikesharingPoiFixture.sbbId,
        );
        expect(sut.selectedPointOfInterest, mobilityBikesharingPoiFixture);
        reset(mockController);
        reset(listener);
        // act

        await sut.deselectPointOfInterest();

        // expect
        verify(mockController.setLayerProperties(
          selectedPoiLayerId,
          any,
        )).called(1);
        verify(listener()).called(1);
      });
    });
    group('toggleSelectedPointOfInterest', () {
      const selectedPoiLayerId = 'journey-pois-selected';

      test('Should not do anything if POIs not visible', () async {
        // arrange + act (is POIs visible is false by default)
        await sut.toggleSelectedPointOfInterest(const Point(0, 0));
        // expect
        verifyNever(mockController.setFilter(any, any));
        verifyNever(mockController.setLayerProperties(any, any));
        verifyNever(mockController.querySourceFeatures(any, any, any));
        verifyNever(listener());
      });
      test('Should notify listeners if visible and poi is selected', () async {
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
        verify(mockController.setFilter(
          selectedPoiLayerId,
          mobilityBikeSharingFilterFixture,
        )).called(1);
        verify(mockController.setLayerProperties(
          selectedPoiLayerId,
          any,
        )).called(1);
        verify(listener()).called(1);
      });
    });
  });
}
