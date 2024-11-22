// DO NOT AUTO FORMAT
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const allPOICategoriesFiltureFixture = [
  'filter-in',
  'subCategory',
  'bike_parking',
  'park_rail',
  'bike_sharing',
  'car_sharing',
  'p2p_car_sharing',
  'on_demand'
];
const bikeParkingCategoriesFiltureFixture = ['filter-in', 'subCategory', 'bike_parking'];

// PointOfInterest
const mobilityBikesharingPoiFixture = RokasPOI(
  id: '35258099',
  sbbId: 'c595b6be-8387-4659-9adf-d62a6a1d3f17',
  name: 'PubliBike Kursaal',
  category: 'mobility',
  subCategory: 'bike_sharing',
  icon: 'mobility_bikesharing',
  operator: 'PubliBike',
  coordinates: LatLng(46.952527097150444, 7.449835538864136),
);
const mobilityBikesharingPoiGeoJSONFixture = {
  'id': '35258099',
  'properties': {
    'sbbId': 'c595b6be-8387-4659-9adf-d62a6a1d3f17',
    'name': 'PubliBike Kursaal',
    'category': 'mobility',
    'subCategory': 'bike_sharing',
    'icon': 'mobility_bikesharing',
    'operator': 'PubliBike',
  },
  'geometry': {
    'type': 'Point',
    'coordinates': [7.449835538864136, 46.952527097150444],
  },
};
const mobilityBikeSharingFilterFixture = [
  '==',
  [
    'get',
    'sbbId',
  ],
  'c595b6be-8387-4659-9adf-d62a6a1d3f17'
];
