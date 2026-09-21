/// extracted floors
const groundAndFirstFloor = [1, 0];
const threeFloorsFromThreeFeatures = [1, 0, -1];

/// Source features with available floors
const threeFeatureWithThreeFloors = [
  {
    'type': 'Feature',
    'properties': {'floor_liststring': '1'},
  },
  {
    'type': 'Feature',
    'properties': {'floor_liststring': '-1,1'},
  },
  {
    'type': 'Feature',
    'properties': {'floor_liststring': '-1,0'},
  },
];
const oneFeatureGroundAndFirstFloor = [
  {
    'type': 'Feature',
    'properties': {'floor_liststring': '0,1'},
  },
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
      0.0,
    ],
    0.0,
  ],
  [
    '==',
    ['get', 'rail'],
    1.0,
  ],
  [
    '==',
    ['get', 'class'],
    'stop_position',
  ],
  ['has', 'platform'],
];
const layer2Level1Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0,
    ],
    1,
  ],
  [
    '==',
    ['get', 'rail'],
    1,
  ],
  [
    '==',
    ['get', 'class'],
    'stop_position',
  ],
  ['has', 'platform'],
];

/// Level Filter Idiom of the SBB Maps style family, used by every `level_*`
/// basemap layer: a bare `['get', 'level']` read compared to the floor.
const newIdiomLevel0Filter = [
  'all',
  [
    '==',
    ['get', 'level'],
    0,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
];
const newIdiomLevel1Filter = [
  'all',
  [
    '==',
    ['get', 'level'],
    1,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
];

/// Both Level Filter Idioms in one filter. The SBB Maps style family carries
/// the legacy `case` idiom on its POI layers and the bare `['get', 'level']`
/// idiom on its `level_*` layers, so a style holds both at once.
const bothIdiomsLevel0Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0,
    ],
    0,
  ],
  [
    '==',
    ['get', 'level'],
    0,
  ],
  [
    '==',
    ['get', 'class'],
    'stop_position',
  ],
];
const bothIdiomsLevel1Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0,
    ],
    1,
  ],
  [
    '==',
    ['get', 'level'],
    1,
  ],
  [
    '==',
    ['get', 'class'],
    'stop_position',
  ],
];

/// A filter reading other properties around the level clause. Only the level
/// scalar may be substituted; the zoom bounds and the `level_name` read are
/// what a loose level marker would clobber.
const otherPropertyReadsLevel0Filter = [
  'all',
  [
    '==',
    ['get', 'level'],
    0,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
  [
    '<',
    ['zoom'],
    ['get', 'maxzoom'],
  ],
  [
    '==',
    ['get', 'level_name'],
    'level',
  ],
];
const otherPropertyReadsLevel1Filter = [
  'all',
  [
    '==',
    ['get', 'level'],
    1,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
  [
    '<',
    ['zoom'],
    ['get', 'maxzoom'],
  ],
  [
    '==',
    ['get', 'level_name'],
    'level',
  ],
];

/// A level read under an operator other than `==`. The operand following it is
/// not a floor scalar, so substituting it would corrupt the filter.
const levelUnderOtherOperatorFilter = [
  'all',
  [
    'in',
    ['get', 'level'],
    [
      'literal',
      [0, 1],
    ],
  ],
];

/// `rokas-walk-platform-lvl`, as the platform hands it back. Its floor clause
/// sits inside an `any` of two `all` groups — one level deeper than every other
/// floor-dependent layer.
const nestedGroupLevel0Filter = [
  'any',
  [
    'all',
    [
      '==',
      ['get', 'type'],
      'platform',
    ],
    [
      '==',
      [
        'case',
        ['has', 'floor'],
        ['get', 'floor'],
        0.0,
      ],
      0.0,
    ],
  ],
  [
    'all',
    [
      '==',
      ['get', 'type'],
      'quay',
    ],
    [
      '==',
      [
        'case',
        ['has', 'floor'],
        ['get', 'floor'],
        0.0,
      ],
      0.0,
    ],
  ],
];
const nestedGroupLevel1Filter = [
  'any',
  [
    'all',
    [
      '==',
      ['get', 'type'],
      'platform',
    ],
    [
      '==',
      [
        'case',
        ['has', 'floor'],
        ['get', 'floor'],
        0.0,
      ],
      1,
    ],
  ],
  [
    'all',
    [
      '==',
      ['get', 'type'],
      'quay',
    ],
    [
      '==',
      [
        'case',
        ['has', 'floor'],
        ['get', 'floor'],
        0.0,
      ],
      1,
    ],
  ],
];

/// `journey-pois-second-lvl`, as the platform hands it back: the level clause is
/// a direct child, but a nested `any` of `all` groups of zoom bounds follows it.
/// Only the level scalar may change.
const nestedZoomGroupsLevel0Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0.0,
    ],
    0.0,
  ],
  [
    'any',
    [
      'all',
      [
        '<',
        ['zoom'],
        16.0,
      ],
      [
        '>=',
        [
          'to-number',
          ['get', 'baseRelevance'],
        ],
        0.8,
      ],
    ],
    [
      'all',
      [
        '>=',
        ['zoom'],
        16.0,
      ],
      [
        '>=',
        [
          'to-number',
          ['get', 'baseRelevance'],
        ],
        0.5,
      ],
    ],
  ],
];
const nestedZoomGroupsLevel1Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'level'],
      ['get', 'level'],
      0.0,
    ],
    1,
  ],
  [
    'any',
    [
      'all',
      [
        '<',
        ['zoom'],
        16.0,
      ],
      [
        '>=',
        [
          'to-number',
          ['get', 'baseRelevance'],
        ],
        0.8,
      ],
    ],
    [
      'all',
      [
        '>=',
        ['zoom'],
        16.0,
      ],
      [
        '>=',
        [
          'to-number',
          ['get', 'baseRelevance'],
        ],
        0.5,
      ],
    ],
  ],
];
