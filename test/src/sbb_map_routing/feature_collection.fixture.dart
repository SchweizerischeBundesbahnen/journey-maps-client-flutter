import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/feature.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/feature_collection.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/geometry_type.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/line_string.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/point.dart';
import 'package:sbb_maps_flutter/src/sbb_map_routing/geo_json_routing_entities/polygon.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';

const featureCollectionFixtureGeneralJSON = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [40.0, 0.5]
      },
      "properties": {"name": "Example Point"}
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [40.0, 0.0],
          [41.0, 1.0],
          [42.0, 2.0],
          [43.0, 3.0]
        ]
      },
      "properties": {"name": "Example LineString"}
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [40.0, 0.0],
            [41.0, 0.0],
            [41.0, 1.0],
            [40.0, 1.0],
            [40.0, 0.0]
          ]
        ]
      },
      "properties": {"name": "Example Polygon"}
    }
  ],
  "bbox": [0.0, 40.0, 1.0, 41.0]
};

const featureCollectionFixtureGeneral = FeatureCollection(features: [
  Feature(
      geometry: Point(coordinates: LatLng(0.5, 40.0)),
      geometryType: GeometryType.point,
      properties: {"name": "Example Point"}),
  Feature(
      geometry: LineString(coordinates: [
        LatLng(0.0, 40.0),
        LatLng(1.0, 41.0),
        LatLng(2.0, 42.0),
        LatLng(3.0, 43.0),
      ]),
      geometryType: GeometryType.lineString,
      properties: {"name": "Example LineString"}),
  Feature(
      geometry: Polygon(coordinates: [
        [
          LatLng(0.0, 40.0),
          LatLng(0.0, 41.0),
          LatLng(1.0, 41.0),
          LatLng(1.0, 40.0),
          LatLng(0.0, 40.0),
        ]
      ]),
      geometryType: GeometryType.polygon,
      properties: {"name": "Example Polygon"}),
], bbox: [
  0.0,
  40.0,
  1.0,
  41.0
]);

final pointAnnotationFixtureGeneral = SBBMapCircle(center: const LatLng(102.0, 0.5));
final lineAnnotationFixtureGeneral = SBBMapLine(vertices: [
  const LatLng(40.0, 0.0),
  const LatLng(41.0, 1.0),
  const LatLng(42.0, 0.0),
  const LatLng(43.0, 1.0),
]);
final polygonAnnotationFixtureGeneral = SBBMapFill(coords: [
  [
    const LatLng(40.0, 0.0),
    const LatLng(41.0, 0.0),
    const LatLng(41.0, 1.0),
    const LatLng(40.0, 1.0),
    const LatLng(40.0, 0.0),
  ]
]);

const lineStyleFixtureCurrentFloor = SBBMapLineStyle(
  lineColor: SBBMapColors.sky,
  lineWidth: 5,
);

const lineStyleFixtureOtherFloors = SBBMapLineStyle(
  lineColor: SBBMapColors.smoke,
  lineWidth: 5,
);

const featureCollectionFixtureSBBJSON = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [7.54268921098, 47.20419250288]
      },
      "properties": {
        "endpointType": "from",
        "durationInSeconds": 988,
        "transportType": "",
        "label": "Solothurn",
        "distanceInMeter": 975,
        "type": "endpoint"
      },
      "id": null
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [7.53194915011, 47.20671728842]
      },
      "properties": {
        "endpointType": "to",
        "durationInSeconds": 988,
        "transportType": "",
        "label": "Solothurn West",
        "distanceInMeter": 975,
        "type": "endpoint"
      },
      "id": null
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [7.542682938487567, 47.204188655990855],
          [7.5426226891142525, 47.20417602654045],
          [7.542558335092475, 47.20416703462801],
        ]
      },
      "properties": {
        "stationLevels": [0, -1],
        "station_from": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20419250288,
          "name": "Solothurn",
          "id": 8500207,
          "distanceInMeter": 975,
          "platform": "Solothurn",
          "longitude": 7.54268921098
        },
        "station_to": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20671728842,
          "name": "Solothurn West",
          "id": 8500206,
          "distanceInMeter": 975,
          "platform": "Solothurn West",
          "longitude": 7.53194915011
        },
        "step": 1,
        "type": "path",
        "pathType": "walk_indoor",
        "floor": 0,
        "routeStartLevel": 0,
        "layer": 0
      },
      "id": null
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [7.5419544894522605, 47.20421359527064]
      },
      "properties": {
        "travelType": "RAMP",
        "sourceFloor": 0,
        "station_from": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20419250288,
          "name": "Solothurn",
          "id": 8500207,
          "distanceInMeter": 975,
          "platform": "Solothurn",
          "longitude": 7.54268921098
        },
        "station_to": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20671728842,
          "name": "Solothurn West",
          "id": 8500206,
          "distanceInMeter": 975,
          "platform": "Solothurn West",
          "longitude": 7.53194915011
        },
        "step": 2,
        "placement": "SOUTHWEST",
        "destinationFloor": -1,
        "type": "path",
        "pathType": "leit_poi",
        "floor": 0,
        "direction": "downstairs"
      },
      "id": null
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [7.5419544894522605, 47.20421359527064],
          [7.54193680380646, 47.204295937872764],
          [7.5419094466869945, 47.20438482047204]
        ]
      },
      "properties": {
        "station_from": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20419250288,
          "name": "Solothurn",
          "id": 8500207,
          "distanceInMeter": 975,
          "platform": "Solothurn",
          "longitude": 7.54268921098
        },
        "station_to": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20671728842,
          "name": "Solothurn West",
          "id": 8500206,
          "distanceInMeter": 975,
          "platform": "Solothurn West",
          "longitude": 7.53194915011
        },
        "step": 3,
        "type": "path",
        "pathType": "walk",
        "floor": -1,
        "layer": -1
      },
      "id": null
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [7.541558052762115, 47.20464413456318]
      },
      "properties": {
        "travelType": "RAMP",
        "sourceFloor": -1,
        "station_from": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20419250288,
          "name": "Solothurn",
          "id": 8500207,
          "distanceInMeter": 975,
          "platform": "Solothurn",
          "longitude": 7.54268921098
        },
        "station_to": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20671728842,
          "name": "Solothurn West",
          "id": 8500206,
          "distanceInMeter": 975,
          "platform": "Solothurn West",
          "longitude": 7.53194915011
        },
        "step": 4,
        "placement": "SOUTHEAST",
        "destinationFloor": 0,
        "type": "path",
        "pathType": "leit_poi",
        "floor": -1,
        "direction": "upstairs"
      },
      "id": null
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [7.541558052762115, 47.20464413456318],
          [7.541442314083994, 47.20465373004942],
          [7.541410316720975, 47.204660686974485],
        ]
      },
      "properties": {
        "station_from": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20419250288,
          "name": "Solothurn",
          "id": 8500207,
          "distanceInMeter": 975,
          "platform": "Solothurn",
          "longitude": 7.54268921098
        },
        "station_to": {
          "durationInSeconds": 988,
          "ident_source": "sbb",
          "latitude": 47.20671728842,
          "name": "Solothurn West",
          "id": 8500206,
          "distanceInMeter": 975,
          "platform": "Solothurn West",
          "longitude": 7.53194915011
        },
        "step": 5,
        "type": "path",
        "pathType": "walk",
        "floor": 0,
        "layer": 0
      },
      "id": null
    }
  ],
  "bbox": [7.532241111213004, 47.20412512135358, 7.542682938487567, 47.20672317314559]
};
