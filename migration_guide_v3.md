# Migrating to 3.0.0

`sbb_maps_flutter` 3.0.0 removes the APIs deprecated in 2.x and changes some defaults. Each section
below names what changed and what to do about it.

## The default map styler is `SBBMapsMapStyler`

An `SBBMap` without a `mapStyler` creates a `SBBMapsMapStyler.full()`, showing the SBB Maps style
family (`sbbmaps_bright`, `sbbmaps_dark`, `sbbmaps_aerial`). In 2.x it created a
`SBBRokasMapStyler.full()`, whose Legacy Journey Maps style family is no longer served after
31.12.2026.

Both stylers resolve the API key and the integration data flag the same way. If you passed a
`mapStyler` already, nothing changes for you.

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

## The default floor switcher is horizontal

## `onPoiDeselected` receives the deselected POI

## Floor filters in custom styles
