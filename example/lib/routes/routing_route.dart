import 'dart:async';

import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class RoutingRoute extends StatefulWidget {
  const RoutingRoute({super.key});

  @override
  State<RoutingRoute> createState() => _RoutingRouteState();
}

class _RoutingRouteState extends State<RoutingRoute> {
  final Completer<SBBRoutingController> _routingController = Completer();

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(title: 'Routing'),
      body: SBBMap(
        initialCameraPosition: const SBBCameraPosition(
          target: LatLng(47.2040547, 7.541883), // Solothurn Bahnhof
          zoom: 17.0,
        ),
        isMyLocationEnabled: true,
        mapStyler: mapStyler,
        onRoutingControllerAvailable: (routingController) {
          !_routingController.isCompleted ? _routingController.complete(routingController) : null;

          routingController.routeFromGeoJSON(geoJson);
        },
      ),
    );
  }
}

const geoJson = {
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
          [7.542228292337066, 47.20412968010665],
          [7.54215396950702, 47.20412512135358],
          [7.542125220686996, 47.204130065691494],
          [7.542111211918433, 47.20413765094622],
          [7.54210098929294, 47.204148314864945],
          [7.542077844664744, 47.20418775317639],
          [7.542055973068727, 47.2042037941462],
          [7.54201448203873, 47.204212144743586],
          [7.5419544894522605, 47.20421359527064]
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
          [7.5419094466869945, 47.20438482047204],
          [7.541897993851269, 47.204413799996296],
          [7.541879397411206, 47.204440371424255],
          [7.541840351509436, 47.204469845025116],
          [7.541558052762115, 47.20464413456318]
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
          [7.541372056579749, 47.20467655435588],
          [7.541272594316407, 47.20472880229586],
          [7.5412206589819295, 47.204742483365294],
          [7.541160195796188, 47.204743397777854],
          [7.5410036572316725, 47.20472848537452],
          [7.540880081522821, 47.20472634744534],
          [7.540737439308476, 47.20471395165126],
          [7.540652045562001, 47.20471411532869],
          [7.540584078288275, 47.20472208129434],
          [7.540555197700796, 47.204733703917235],
          [7.5404925952432, 47.20476793648316],
          [7.54047175174422, 47.204773121317594],
          [7.540437115065781, 47.20477486811858],
          [7.540388766976055, 47.204768794703135],
          [7.540280837994489, 47.20474603169211],
          [7.540044684035806, 47.204717627856155],
          [7.539892757445072, 47.204693809874904],
          [7.5393516423852995, 47.20463195573997],
          [7.539147547237443, 47.204601551069544],
          [7.538766462472363, 47.204561026688914],
          [7.538603609741509, 47.204554940175484],
          [7.53856939691784, 47.20455857885388],
          [7.5385073619927025, 47.20457542415256],
          [7.538474327570406, 47.20458082704439],
          [7.538336560504768, 47.204575723259495],
          [7.538212086415581, 47.20459052113984],
          [7.538094601118777, 47.204597495183485],
          [7.538032692415257, 47.20459624193436],
          [7.537862787679026, 47.20457959507088],
          [7.53781363001686, 47.2045791451858],
          [7.537771628161422, 47.20458940894466],
          [7.537708137004607, 47.20462236059445],
          [7.537667843282603, 47.20463518172576],
          [7.537569023268052, 47.20465181330314],
          [7.537498655503859, 47.20465618183593],
          [7.537395794947481, 47.20464847628961],
          [7.536656108311492, 47.204565085274005],
          [7.536605001981961, 47.2045615654087],
          [7.536570413502918, 47.20456385411807],
          [7.536550558711178, 47.204569274448495],
          [7.536526016101924, 47.20458329577081],
          [7.536444515758705, 47.20466356644069],
          [7.536303262276803, 47.20484693340515],
          [7.536159964659714, 47.205014486668816],
          [7.536137973020344, 47.20503378367874],
          [7.536112793414041, 47.2050498719398],
          [7.536041031194344, 47.20507812062048],
          [7.5360274024296405, 47.20508779365886],
          [7.536010537405036, 47.20510601624851],
          [7.535883224250693, 47.205297775343155],
          [7.53562888419569, 47.20575203321936],
          [7.535607167606955, 47.20578024345022],
          [7.5355725958871025, 47.20581454462901],
          [7.53554129425099, 47.20584027149436],
          [7.535515086816714, 47.205855790018475],
          [7.53547367974218, 47.20586607430305],
          [7.53542619067938, 47.205864176148566],
          [7.535143678241873, 47.20581233799014],
          [7.5350511140189305, 47.20578873101309],
          [7.534834056928597, 47.205716996043506],
          [7.534762452739807, 47.20570122334643],
          [7.53455368435824, 47.20567823825295],
          [7.534505083981052, 47.20567862078265],
          [7.5344720185070075, 47.2056839757459],
          [7.534423945192583, 47.20570343541483],
          [7.534319052961189, 47.20576583591909],
          [7.5342276130136545, 47.20579351445833],
          [7.534189520795944, 47.20580963080541],
          [7.533962404820098, 47.2059450570796],
          [7.533907459810993, 47.20597251562382],
          [7.533876357400514, 47.20598080975462],
          [7.533853545128507, 47.205983228736045],
          [7.5337285671830765, 47.205978977863886],
          [7.533669478848424, 47.205981944202954],
          [7.533637785352465, 47.205989353202405],
          [7.533550399917547, 47.2060231021758],
          [7.533451805259273, 47.206040067123084],
          [7.5334018988674485, 47.206056781719965],
          [7.533332319020776, 47.20609890327948],
          [7.532969799352741, 47.20634248407843],
          [7.532828314379591, 47.20642324534852],
          [7.532430216824024, 47.20668668232815],
          [7.53237795776722, 47.20671613154344],
          [7.532359797849944, 47.206721730822],
          [7.532341636266251, 47.20672317314559],
          [7.532315722623324, 47.20671630551018],
          [7.532285448981898, 47.20669400963345],
          [7.532241111213004, 47.206641297103815]
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
