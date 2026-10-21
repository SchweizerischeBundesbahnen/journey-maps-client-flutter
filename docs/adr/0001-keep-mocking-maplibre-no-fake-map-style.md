---
status: accepted
---

# Keep mocking the MapLibre controller; no fake map style behind an owned seam

Tests for the floor, POI, annotator, routing and locator controllers keep
mocking `MapLibreMapController` directly. We decided not to put an internal port
between these controllers and MapLibre with an in-memory fake map style behind
it, even though a fake would catch bugs that span several calls, which argument
assertions miss (overlapping annotator writes, floor filters lost on a style
reload). A fake is only trustworthy if a contract suite run against real MapLibre
keeps it honest, and maplibre_gl cannot currently read back enough of its
runtime state for that suite to exist. An unverified fake would drift from
MapLibre unnoticed and give false confidence, which is worse than the known
limits of mocks.

## Evidence

A throwaway on-device probe (not merged; maplibre_gl 0.27.1, on an iOS
simulator and an Android emulator, 2026-10-16) found:

- `getStyle()` returns `null` on iOS, because the plugin's native `map#getStyle`
  handler hard-codes `result = false`. On Android it returns the style as loaded
  and ignores runtime changes.
- `getLayerProperties` returns the style as loaded on both platforms, and `null`
  for layers added at runtime (maplibre/flutter-maplibre-gl#985).
- `getLayerVisibility` has no native handler on either platform
  (`MissingPluginException`).
- The only state that reflects runtime changes is `getFilter` (with
  platform-specific encoding), `getLayerIds`, `getSourceIds` and
  `querySourceFeatures` on GeoJSON sources. Visibility and layout properties
  cannot be checked at all.

## Revisit when

maplibre_gl can read the live style back on both platforms (a working
`getStyle`, live `getLayerProperties`, or a native `getLayerVisibility`). At that
point a contract suite becomes possible and this decision should be reopened.
