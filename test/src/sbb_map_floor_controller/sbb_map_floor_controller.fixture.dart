/// extracted floors
const groundAndFirstFloor = [1, 0];
const threeFloorsFromThreeFeatures = [1, 0, -1];

/// Source features with available floors
const threeFeatureWithThreeFloors = [
  {
    'type': 'Feature',
    'properties': {
      'floor_liststring': '1',
    }
  },
  {
    'type': 'Feature',
    'properties': {
      'floor_liststring': '-1,1',
    }
  },
  {
    'type': 'Feature',
    'properties': {
      'floor_liststring': '-1,0',
    }
  }
];
const oneFeatureGroundAndFirstFloor = [
  {
    'type': 'Feature',
    'properties': {
      'floor_liststring': '0,1',
    }
  }
];

/// Layers
const noLevelLayers = ['layer1', 'layer2'];
const oneLevelLayers = ['nolvlLayer', 'layer2-lvl'];

/// Layer Filters (DO NOT AUTOFORMAT)
const layer2Level0Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0.0
    ],
    0.0
  ],
  [
    '==',
    ['get', 'rail'],
    1.0
  ],
  [
    '==',
    ['get', 'class'],
    'stop_position'
  ],
  ['has', 'platform']
];
const layer2Level1Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0
    ],
    1
  ],
  [
    '==',
    ['get', 'rail'],
    1
  ],
  [
    '==',
    ['get', 'class'],
    'stop_position'
  ],
  ['has', 'platform']
];
