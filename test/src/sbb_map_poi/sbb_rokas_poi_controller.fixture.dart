import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const rokasPoiBaseLayerIdWithFloorNonClickable = 'journey-pois-third-lvl';
const rokasPoiBaseLayerIdWithFloorClickable = 'journey-pois-second-lvl';
const rokasPoiHighlightedLayerId = 'journey-pois-first';

const journeyPoisSource = 'journey-pois-source';
const selectedPoiLayerId = 'journey-pois-selected';

// applied filter fixtures
const emptySubCategoryFilterFixture = [
  'all',
  ['filter-in', 'subCategory', '']
];
const subCategoryFilterWithBakeryFixture = [
  'all',
  ['filter-in', 'subCategory', 'bakery']
];
final subCategoryFilterWithAllCategoriesFixture = ['all', allPOICategoriesFiltureFixture];

final lvlZeroWithEmptySubCategoryFilterFixture = ['all', ...lvlZeroFilterFixture, emptySubCategoryFilterFixture[1]];
final lvlZeroWithBakerySubCategoryFilterFixture = [
  'all',
  ...lvlZeroFilterFixture,
  subCategoryFilterWithBakeryFixture[1]
];
final lvlZeroMultiFilterWithBakerySubCategoryFilterFixture = [
  'all',
  ..._lvlZeroMultiFilterFixture,
  subCategoryFilterWithBakeryFixture[1]
];

const bikeParkingCategoriesFiltureFixture = [
  'all',
  ['filter-in', 'subCategory', 'bike_parking']
];

// lvl filter fixtures without categories
const lvlZeroFilterFixture = [
  "==",
  [
    "case",
    [
      "==",
      ["has", "level"],
      true
    ],
    ["get", "level"],
    0
  ],
  0
];
const _lvlZeroMultiFilterFixture = [
  [
    "==",
    [
      "case",
      [
        "==",
        ["has", "level"],
        true
      ],
      ["get", "level"],
      0
    ],
    0
  ],
  [
    "==",
    [
      "case",
      [
        "==",
        ["has", "level"],
        true
      ],
      ["get", "level"],
      0
    ],
    0
  ]
];
const lvlZeroMultiFilterFixture = ["all", ..._lvlZeroMultiFilterFixture];

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

const allPOICategoriesFiltureFixture = [
  'filter-in',
  'subCategory',
  'accommodation',
  'aquarium',
  'atm',
  'attraction',
  'bakery',
  'bar',
  'barracks',
  'beauty',
  'beverages',
  'bike_parking',
  'bike_sharing',
  'bnb',
  'books',
  'boutique',
  'bowling',
  'butcher',
  'cafe',
  'camp_site',
  'car_repair',
  'car_sharing',
  'casino',
  'catering',
  'cinema',
  'clothes',
  'cosmetics',
  'counter_other',
  'counter_sbb',
  'dance',
  'dentist',
  'department_store',
  'doctor',
  'drugstore',
  'electronics',
  'events_venue',
  'fast_food',
  'fitness_centre',
  'flowers',
  'food',
  'fuel',
  'furniture',
  'gallery',
  'games',
  'garden',
  'gifts',
  'hairdresser',
  'hardware_store',
  'historic',
  'hospital',
  'hostel',
  'hotel',
  'household',
  'ice_cream',
  'ice_rink',
  'infopoint',
  'jewelry',
  'kindergarten',
  'kiosk',
  'language_school',
  'leisure',
  'leisure_other',
  'library',
  'locker_sbb',
  'luggage_sbb',
  'massage',
  'meeting_point',
  'miniature_golf',
  'mobility',
  'money_exchange',
  'money_exchange_sbb',
  'motel',
  'motorbike_parking',
  'museum',
  'music',
  'musical_instruments',
  'music_school',
  'nightclub',
  'nursing_home',
  'office',
  'on_demand',
  'optician',
  'other',
  'outdoor',
  'p2p_car_sharing',
  'parking',
  'parking_deck',
  'parking_place',
  'park_rail',
  'perfumery',
  'pharmacy',
  'phone',
  'photo',
  'place_of_worship',
  'police',
  'post_office',
  'public',
  'public_bath',
  'public_other',
  'restaurant',
  'sbb_service_other',
  'sbb_services',
  'school',
  'service',
  'service_other',
  'shoes',
  'shopping',
  'shopping_center',
  'shopping_other',
  'social_facility',
  'sport',
  'sports_centre',
  'stationary',
  'supermarket',
  'swisspass_parking',
  'take_away',
  'tattoo',
  'taxi',
  'theatre',
  'theme_park',
  'thrift_shop',
  'toilet',
  'toilet_sbb',
  'touristinfo',
  'townhall',
  'toy_library',
  'toys',
  'university',
  'variety_store',
  'vending_machine_other',
  'vending_machine_sbb',
  'video_games',
  'waiting_room',
  'watches',
  'water_park',
  'zoo',
];
