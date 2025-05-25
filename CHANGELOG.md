# Changelog

## [2.6.0](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/compare/2.5.0...2.6.0) (2025-05-25)


### Features

* add selectPointOfInterestAt to select poi after camera movement to coordinates ([#128](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/128)) ([cd5f820](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/cd5f8205dbbd08ad8d569018e993bffbfdc2f70b))
* drop support for flutter 3.24.x ([#119](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/119)) ([85144d2](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/85144d268c9ec9cdffaba8cd2df4981f4a4ed415))


### Bug Fixes

* `SBBMapFloorSelector` only draws if floors available ([#126](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/126)) ([b1904da](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/b1904da6ba434413cab17e804fc48d1ff8a04ea5))
* filter POIs for categories and floors at the same time ([#127](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/127)) ([d39fb85](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/d39fb850ec9e20a35687dad56c2ce1438eda5038))
* map style change does not update camera position ([#124](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/124)) ([a796bc7](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/a796bc70df9f85f9582610304c7515429afe280f))
* poi controller available only called first style loaded ([#125](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/125)) ([a375dc8](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/a375dc8eb86110d08c0da05b80fe97e019c9c031))

## [2.5.0](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/compare/2.4.0...2.5.0) (2025-03-06)


### Features

* add getCategoryFilterByLayer in SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* add getVisibilityByLayer in SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* add hideAllPointsOfInterests to SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* add new ROKAS POI customization possibilities ([#96](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/96)) ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* add SBBRokasPoiLayer with baseWithFloor and highlighted ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* deprecate currentPOICategories, isPointsOfInterestVisible in SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* deprecate isPointOfInterestVisible in SBBMapPoiSettings ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* do not show ROKAS POIs by default, use showPointsOfInterest in SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* dropped support for flutter 3 22 x ([#93](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/93)) ([54b4f6f](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/54b4f6fa9b9b60c9225d63d7c68f42c0766bdd00))
* extend hidePointsOfInterest with optional layer in SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* extend showPointsOfInterest with optional layer in SBBRokasPoiController ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* extend the set of possible SBBPoiCategoryType to match latest categories ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))
* minimum supported Flutter SDK is 3.22.0 ([#74](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/74)) ([a4fe10c](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/a4fe10c4a9fe48e52cacd99025c06eb2e0d1696d))


### Bug Fixes

* **deps:** update dependency maplibre_gl to ^0.21.0 ([#91](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/91)) ([2bb9c36](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/2bb9c363cf472ae5da25e1e6162d7a589a74e908))
* repeatedly calling addAnnotations results in fatal crash ([#78](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/78)) ([3f0dcaa](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/3f0dcaa14760327491ef03dab6ce0e1fe7465651))
* synchronize style switching to filtered PointsOfInterests ([75f2c0e](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/75f2c0eb155328cd9417f695eaf1373ac37a971b))

## [2.4.0](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/compare/2.3.1...2.4.0) (2024-11-27)


### Features

* add convenience constructor for SBBMapProperties allDisabled ([#33](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/33)) ([2b8abf2](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/2b8abf241a7ee59a8bf82023ec0450bac32c1812))
* deprecate JOURNEY_MAPS_API_KEY env. replace with JOURNEY_MAPS_TILES_API_KEY ([#52](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/52)) ([3833568](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/3833568026be56b7af67101468ee69d03d2900aa))
* deprecate old ROKAS map styles and replace with new map styles ([08e7f7a](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/08e7f7aaa8b9d149ca951687720d4e01e3ac8816))
* enable accessing INT ROKAS data ([#54](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/54)) ([5aedf40](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/5aedf40549dcfcf695d52dd0e15848b9a395a550))


### Bug Fixes

* **deps:** update envied to v1 ([#39](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/39)) ([7beeb67](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/7beeb67b193b617d0184769bf3563673fcc08519))

## [2.3.1](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/compare/2.3.0...2.3.1) (2024-11-13)


### Bug Fixes

* dismissTracking called only when SBBMap leaves tracking mode ([#28](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/28)) ([8ba8ae2](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/8ba8ae270f0291e0c14e891699481bb1bab23992))
* initialCameraPosition null causes crash in SBBMap ([#30](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/issues/30)) ([57b15b7](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/57b15b782f44908c21a47c830b50192069eaa495))
* rebuilding the CustomMapStyler correctly wires it to the MapStyleButton ([6ff2a70](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/6ff2a70c075a46987cb594bf736d84c8b0250fa5))

## [2.3.0](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/compare/v2.2.0...2.3.0) (2024-11-04)


### Features

* add example app and make README complete ([3d2b016](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/3d2b016296dc8e93e2affd4eae5025ae1e6232dd))
* add version 2_3_0 following open source standards ([ab9aa0f](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/ab9aa0fa33291c8d6423f166a481e83e049b47b1))
* add version 2_3_0 open source standards api keyless ([6e2b988](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/6e2b9882d207259104740d936b8779c801bb03a5))
* exclude v in release tag, exclude component in tag, update renovate ([60529f7](https://github.com/SchweizerischeBundesbahnen/journey-maps-client-flutter/commit/60529f73ab827ad287c73ad723a0a6d863da986b))
