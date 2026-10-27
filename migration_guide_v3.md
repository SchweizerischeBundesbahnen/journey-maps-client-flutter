# Migrating to 3.0.0

`sbb_maps_flutter` 3.0.0 removes the APIs deprecated in 2.x and changes some defaults. Each section
below names what changed and what to do about it.

## The default map styler is `SBBMapsMapStyler`

An `SBBMap` without a `mapStyler` creates a `SBBMapsMapStyler.full()`, showing the SBB Maps style
family (`sbbmaps_bright`, `sbbmaps_dark`, `sbbmaps_aerial`). In 2.x it created a
`SBBRokasMapStyler.full()`, whose Legacy Journey Maps style family is no longer served after
31.12.2026.

The API key and the integration data flag are resolved as in 2.x, except for the removed
`JOURNEY_MAPS_API_KEY` (see below). If you passed a `mapStyler` already, nothing changes for you.

Pass the styler yourself to start in dark mode, to use integration data or to give the API key in
code:

```dart
SBBMap(
  mapStyler: SBBMapsMapStyler.full(
    apiKey: Env.MY_API_KEY_NAME,
    isDarkMode: true,
    useIntegrationData: true,
  ),
);
```

## Removed deprecated APIs

| Removed in 3.0.0 | Use instead |
|---|---|
| `SBBRokasMapStyler.full()` / `.noAerial()` | `SBBMapsMapStyler.full()` / `.noAerial()`, same parameters |
| `JOURNEY_MAPS_API_KEY` environment variable | `JOURNEY_MAPS_TILES_API_KEY`, or the `apiKey` parameter of the styler |
| `SBBMapPOISettings.isPointOfInterestVisible` | `SBBRokasPOIController.showPointsOfInterest()` / `hidePointsOfInterest()` |
| `SBBRokasPOIController.currentPOICategories` | `getCategoryFilterByLayer(layer: SBBRokasPoiLayer.baseWithFloor)` |
| `SBBRokasPOIController.isPointsOfInterestVisible` | `getVisibilityByLayer(layer: …)` for each `SBBRokasPoiLayer` |
| `SBBMapFloorSelector` | `SBBMapVerticalFloorSwitcher` |
| `SBBMapFloorSelectorSmall` | `SBBMapVerticalFloorSwitcherSmall` |
| `SBBMapFloorSelectorStyle` | `SBBMapFloorSwitcherStyle` |

The floor switcher renames are mechanical: the widgets and the style take the same parameters.

`currentPOICategories` returned a `List`; `getCategoryFilterByLayer` returns a `Set`.
`isPointsOfInterestVisible` was `true` while any POI layer was visible:

```dart
final anyVisible = SBBRokasPoiLayer.values.any((layer) => poiController.getVisibilityByLayer(layer: layer));
```

`isPointOfInterestVisible` had no effect: show POIs from `onPoiControllerAvailable` instead:

```dart
SBBMap(
  poiSettings: SBBMapPOISettings(
    onPoiControllerAvailable: (poiController) => poiController.showPointsOfInterest(),
  ),
);
```

## The default floor switcher is horizontal

## `onPoiDeselected` receives the deselected POI

## Floor filters in custom styles
