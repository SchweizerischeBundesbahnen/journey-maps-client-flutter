This package allows you to easily incorporate SBB styled maps into your Flutter application.
It is built on top of MapLibre and meant as a client for the [Journey Maps API].
You need to register your application at [developer.sbb.ch](https://developer.sbb.ch/apis/) to receive an API key
for style and routing usage (see details below). 

<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/main.webp" alt="iOS and Android example showcases" width="90%"></p>

## Table Of Contents

<details>
<summary>Click to expand</summary>

- [Journey Maps Client Flutter](#journey-maps-client-flutter)
      - [Table Of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting Started](#getting-started)
      - [Supported platforms](#supported-platforms)
      - [Precondition](#precondition)
      - [Installation](#installation)
      - [In code usage](#in-code-usage)
          - [API key](#api-key)
          - [Adding the map](#adding-the-map)
          - [Accessing user location](#accessing-user-location)
          - [Focusing on user location when building map](#focusing-on-user-location-when-building-map)
      - [Tested deployment platforms](#tested-deployment-platforms)
      - [Example App](#example-app)
  - [Documentation](#documentation)
      - [Features](#features)
      - [Custom Map Properties](#custom-map-properties)
    - [Gallery and Examples](#gallery-and-examples)
      - [Standard Map](#standard-map)
      - [Plain Map](#plain-map)
      - [Camera Movement](#camera-movement)
      - [Custom UI](#custom-ui)
      - [ROKAS Point of Interests](#rokas-point-of-interests)
      - [Custom UI](#custom-ui-1)
      - [Map Properties](#map-properties)
      - [Annotations](#annotations)
      - [Track device location on map build](#track-device-location-on-map-build)
    - [Read on](#read-on)
  - [License](#license)
  - [Contributing](#contributing)
    - [Maintainer](#maintainer)
    - [Contributors](#contributors)
    - [Coding Standards](#coding-standards)
    - [Code of Conduct](#code-of-conduct)
  - [Caveats, limitations and known bugs\*](#caveats-limitations-and-known-bugs)
    - [Limitations](#limitations)

</details>

<a id="Introduction"></a>

## Introduction

The package is meant as a client for the [Journey Maps API] and is based on the [Flutter Maplibre GL plugin] - solely for Android and iOS.

<a id="Getting-Started"></a>

## Getting Started

#### Supported platforms

<div id="supported_platforms">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS">
</div>

#### Precondition

In order to access styles and tile data, you need to register your application to the [Journey Maps Tiles API] to receive an API Key.
Create an account (e.g. using SwissPass Login) to be able to setup an application and then register this application to the API.

#### In code usage

###### API key

Make the API Key accessible to your application. Either

1. add it as env var (not recommended):
```sh
JOURNEY_MAPS_TILES_API_KEY='YOUR_API_KEY_HERE'
```
2. Or use a package such as [envied](https://pub.dev/packages/envied) for clean env var handling and
   *obfuscating* your API key, making it harder to reverse engineer (in public apps!). Pass the env key to the
   `SBBRokasMapStyler` as constructor parameter. Use this styler to the `SBBMap` as `mapStyler` parameter.
```dart
SBBRokasMapStyler.full(apiKey: Env.MY_API_KEY_NAME);
```

###### Adding the map

```dart
SBBMap(
  initialCameraPosition: const SBBCameraPosition(
    target: LatLng(46.947456, 7.451123), // Bern
    zoom: 15.0,
  ),
  mapStyler: _customStylerWithApiKey // as from above
)
```

###### Accessing user location

This package uses the [geolocator](https://pub.dev/packages/geolocator) flutter plugin for accessing the device location and
asking the user for permissions. See the package for detailed instructions on accessing the device location. In short:

*iOS*

Add this to your `Info.plist` file.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>YOUR DESCRIPTION WHY YOU NEED ACCESS TO THE MAP<string>
```

*Android*

Add these to your `AndroidManifest.xml` file. If both are specified, the geolocator plugin uses the `ACCESS_FINE_LOCATION` setting.

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

###### Focusing on user location when building map

To directly focus the map camera onto the device location when the `SBBMap` is built, use the `OnMapLocatorAvailable` callback and the `SBBMapLocator.trackDeviceLocation()` method. This has the nice side effect, that the user will be prompted for permissions if not granted already.

This can be seen in the *Track Device* route in the example app here: [track_device_location_route.dart](example/lib/routes/track_device_location_route.dart).


#### Tested deployment platforms

|               | iOS  | Android SDK |
| ------------- | ---- | ----------- |
| Oldest Tested | 15.5 | 28          |
| Latest Tested | 18.2 | 35          |

All versions are tested with the latest (3.27.0) and oldest supported (3.22.3) Flutter SDK.

#### Example App

<p align="left"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/app_icon/icon.webp" alt="Icon of the example app" width="5%"></p>

The **SBB Karten** demo application is available both in the SBB Enterprise Playstore (Android) and in the managed iOS SBB Store (Ivanti MobileIron).

<a id="Documentation"></a>

## Documentation

#### Features

| Feature                                 | iOS                | Android            |
| --------------------------------------- | ------------------ | ------------------ |
| Gesture                                 | :white_check_mark: | :white_check_mark: |
| Accessing INT Tiles & POIs              | :white_check_mark: | :white_check_mark: |
| Camera                                  | :white_check_mark: | :white_check_mark: |
| Map Styles (including ROKAS Styles)     | :white_check_mark: | :white_check_mark: |
| Location (including device tracking)    | :white_check_mark: | :white_check_mark: |
| Customizable UI                         | :white_check_mark: | :white_check_mark: |
| Floor Switcher (switch levels)          | :white_check_mark: | :white_check_mark: |
| ROKAS POIs: Display                     | :white_check_mark: | :white_check_mark: |
| ROKAS POIs: Event Triggering and Select | :white_check_mark: | :white_check_mark: |
| **Annotations**                         | :white_check_mark: | :white_check_mark: |
| - Circles (Display & OnClick)           | :white_check_mark: | :white_check_mark: |
| - ROKAS Markers (Display & OnClick)     | :white_check_mark: | :white_check_mark: |
| - Custom Markers  (Display & OnClick)   | :white_check_mark: | :white_check_mark: |
| - Fill Annotations  (Display & OnClick) | :white_check_mark: | :white_check_mark: |
| - Line Annotations  (Display & OnClick) | :white_check_mark: | :white_check_mark: |
| Routing (Beta)                          | :white_check_mark: | :white_check_mark: |


#### Custom Map Properties

Custom properties of the map (e.g. compass position, disabling certain gestures) can be set using
the `SBBMapProperties` class, given as `properties` parameter in the `SBBMap` constructor.

```dart
// the defaults
const SBBMapProperties({
    this.compassEnabled = true,
    this.compassViewPosition = CompassViewPosition.topLeft,
    this.compassViewMargins,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.doubleClickZoomEnabled = true,
    this.dragEnabled = true,
  });
```

#### Accessing INT Tiles & POIs

In order to access the INT data from [Journey Maps Tiles INT API], you need to register your application there and receive
a corresponding API Key. API Keys from the PROD API will not work. After that, either set the environment variable 
`SBB_MAPS_INT_ENABLED` to `true`:

```bash
SBB_MAPS_INT_ENABLED=true
```

or pass the `useIntegrationData` constructor parameter to a `SBBRokasMapStyler`:

```dart
SBBRokasMapStyler.full(apiKey: Env.MY_INT_API_KEY_NAME, useIntegrationData=true);
```

Using INT data will log to console as an info.

### Gallery and Examples

#### Standard Map
The default SBB map with ROKAS styling (see [standard_map_route.dart](example/lib/routes/standard_map_route.dart)).
<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/standard_map_example.webp" width='25%'>

#### Plain Map
How to disable all UI components while using ROKAS Map styling. (see [plain_map_route.dart](example/lib/routes/plain_map_route.dart)).
<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/plain_map_example.webp" width='25%'>

#### Camera Movement
Programmatic control over camera movement (see [camera_route.dart](example/lib/routes/camera_route.dart)).
<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/camera_example.webp" width='25%'>

#### Custom UI
Customizing the map UI using the builder (see [custom_ui_route.dart](example/lib/routes/custom_ui_route.dart)).
<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/custom_ui_example.webp" width='25%'>

#### ROKAS Point of Interests
Displaying and interacting ROKAS POIs (see [poi_route.dart](example/lib/routes/poi_route.dart)).
<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/poi_example.webp" width='25%'>

#### Custom UI
Customizing the map UI using the builder (see [custom_ui_route.dart](example/lib/routes/custom_ui_route.dart)).
<p align="center"><img src="https://raw.githubusercontent.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/main/example/gallery/custom_ui_example.webp" width='25%'>

#### Map Properties
Using map properties (see [map_properties_route.dart](example/lib/routes/map_properties_route.dart)).

#### Annotations
Displaying and interacting with custom annotations (see [display_annotations_route.dart](example/lib/routes/display_annotations_route.dart)).

#### Track device location on map build
Displaying user device location on build (see [track_device_location_route.dart](example/lib/routes/track_device_location_route.dart)).


### Read on

- [CODING_STANDARDS.md](CODING_STANDARDS.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [LICENSE.md](LICENSE.md)
- [Journey Maps API Documentation](https://developer.sbb.ch/apis/journey-maps/documentation)
- [Journey Maps Tiles API Documentation](https://developer.sbb.ch/apis/journey-maps-tiles/documentation)

<a id="License"></a>

## License

This project is licensed under [MIT](LICENSE.md).

<a id="Contributing"></a>

## Contributing

This repository includes a [CONTRIBUTING.md](CONTRIBUTING.md) file that outlines how to contribute to the project, including how to submit bug reports, feature requests, and pull requests.

### Maintainer

- [Nicolas Vidoni](https://github.com/smallTrogdor)

### Credits
In addition to the contributors on Github, we thank the following people for their work on previous versions:

 - Loris Sorace
 - Hoang Tran

<a id="coding-standards"></a>

### Coding Standards

See [CODING_STANDARDS.md](CODING_STANDARDS.md).

<a id="code-of-conduct"></a>

### Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Caveats, limitations and known bugs*

### Limitations

* When selecting POIs programmatically with the `RokasPOIController`, one can only select from the POIs that are loaded in the tile source, meaning that trying to select a POI at a very distant place will not be possible. The workaround would be to first move to the geo coordinate and then select the POI.


[Journey Maps API]: (https://developer.sbb.ch/apis/journey-maps/information)
[Flutter Maplibre GL plugin]: (https://github.com/maplibre/flutter-maplibre-gl/tree/main)
[Journey Maps Tiles API]: (https://developer.sbb.ch/apis/journey-maps-tiles/information)
[Journey Maps Tiles INT API]: (https://developer-int.sbb.ch/apis/journey-maps-tiles/information)