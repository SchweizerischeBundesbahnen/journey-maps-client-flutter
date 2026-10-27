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

/// A filter reading `floor_type` next to the `case` floor read. Only the floor
/// scalar may be substituted; the `floor_type` operand is not a floor.
const floorTypeReadFloor0Filter = [
  'all',
  [
    '==',
    ['get', 'floor_type'],
    'platform',
  ],
  [
    '==',
    [
      'case',
      ['has', 'floor'],
      ['get', 'floor'],
      0,
    ],
    0,
  ],
];
const floorTypeReadFloor1Filter = [
  'all',
  [
    '==',
    ['get', 'floor_type'],
    'platform',
  ],
  [
    '==',
    [
      'case',
      ['has', 'floor'],
      ['get', 'floor'],
      0,
    ],
    1,
  ],
];

/// The bare `floor` property name compared to a floor. No style family uses
/// this form, so it is not a Level Filter Idiom.
const bareFloorNameFilter = [
  '==',
  'floor',
  0,
];

/// A plain `['get', 'floor']` read compared to a floor. No style family uses
/// this form, so it is not a Level Filter Idiom.
const plainFloorReadFilter = [
  '==',
  ['get', 'floor'],
  0,
];

/// A floor clause followed by a scalar operand of the root group. The floor
/// clause decides only its own operands, never the root's.
const floorClauseThenScalarFloor0Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'floor'],
      ['get', 'floor'],
      0,
    ],
    0,
  ],
  true,
];
const floorClauseThenScalarFloor1Filter = [
  'all',
  [
    '==',
    [
      'case',
      ['has', 'floor'],
      ['get', 'floor'],
      0,
    ],
    1,
  ],
  true,
];

/// `level_platform_1x_kante-lvl` of `sbbmaps_bright`, verbatim: the bare
/// `['get', 'level']` idiom among reads that must stay as they are.
const platformKanteLevel0Filter = [
  'all',
  [
    '==',
    ['get', 'level'],
    0,
  ],
  [
    'match',
    ['get', 'kind'],
    ['platform', 'platform_fallback', 'platform_point_from_polygon'],
    true,
    false,
  ],
  [
    '==',
    ['get', 'mot_icon_count'],
    1,
  ],
  [
    '!',
    ['has', 'rail'],
  ],
  ['has', 'platform'],
  [
    '==',
    ['geometry-type'],
    'Point',
  ],
];
const platformKanteLevel1Filter = [
  'all',
  [
    '==',
    ['get', 'level'],
    1,
  ],
  [
    'match',
    ['get', 'kind'],
    ['platform', 'platform_fallback', 'platform_point_from_polygon'],
    true,
    false,
  ],
  [
    '==',
    ['get', 'mot_icon_count'],
    1,
  ],
  [
    '!',
    ['has', 'rail'],
  ],
  ['has', 'platform'],
  [
    '==',
    ['geometry-type'],
    'Point',
  ],
];

/// `level_label_streets_main-lvl` of `sbbmaps_bright`, verbatim: the `case`
/// level idiom next to a `match` on another property.
const labelStreetsMainLevel0Filter = [
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
    'match',
    ['get', 'kind'],
    ['motorway', 'primary', 'secondary', 'tertiary'],
    true,
    false,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
];
const labelStreetsMainLevel1Filter = [
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
    'match',
    ['get', 'kind'],
    ['motorway', 'primary', 'secondary', 'tertiary'],
    true,
    false,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
];

/// `level_railways_gravel-lvl` of `sbbmaps_bright`, verbatim: a `-lvl` layer
/// whose filter holds no level clause.
const railwaysGravelFilter = [
  'all',
  [
    'match',
    ['get', 'kind'],
    ['narrow_gauge', 'rail'],
    true,
    false,
  ],
  [
    '==',
    ['get', 'tunnel'],
    false,
  ],
  [
    '==',
    ['get', 'bridge'],
    false,
  ],
  [
    '>=',
    ['zoom'],
    ['get', 'minzoom'],
  ],
];

/// A level clause inside a `none` group inside an `all` group.
const noneGroupLevel0Filter = [
  'all',
  [
    '==',
    ['get', 'kind'],
    'room',
  ],
  [
    'none',
    [
      '==',
      ['get', 'level'],
      0,
    ],
    [
      '==',
      ['get', 'kind'],
      'wall',
    ],
  ],
];
const noneGroupLevel1Filter = [
  'all',
  [
    '==',
    ['get', 'kind'],
    'room',
  ],
  [
    'none',
    [
      '==',
      ['get', 'level'],
      1,
    ],
    [
      '==',
      ['get', 'kind'],
      'wall',
    ],
  ],
];

/// The bare `['get', 'level']` idiom at the filter root, with no group around it.
const rootLevel0Filter = [
  '==',
  ['get', 'level'],
  0,
];
const rootLevel1Filter = [
  '==',
  ['get', 'level'],
  1,
];
