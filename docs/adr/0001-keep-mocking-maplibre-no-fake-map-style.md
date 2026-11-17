---
status: accepted
---

# Keep mocking the MapLibre controller; no fake map style behind an owned seam

Tests for the floor, POI, annotator, routing and locator controllers keep
mocking `MapLibreMapController` directly. We decided not to put an internal port
between these controllers and MapLibre with an in-memory fake map style behind
it. A fake would catch bugs that span several calls, which argument assertions
miss. Two examples are overlapping annotator writes and floor filters lost on a
style reload. A fake is only trustworthy if a contract suite run against real
MapLibre keeps it honest, and maplibre_gl cannot read back enough of its runtime
state for that suite to exist. An unverified fake would drift from MapLibre
unnoticed and give false confidence, which is worse than the known limits of
mocks.

## Evidence

A throwaway on-device probe ran on an iOS 15.5 simulator and an Android 16
emulator on 2026-11-17, with maplibre_gl 0.28.0. It was not merged. Both
platforms gave the same results:

- `getStyle()` returns the style as loaded. It ignores runtime filter and
  visibility changes, and leaves out layers and sources added at runtime.
- `getLayerProperties` returns live state, including layers added at runtime.
- `getLayerVisibility` returns live state, and `null` for a missing layer.
- `getLayerFilter` returns live state, with the same encoding on both platforms.
- `getSourceProperties` returns only `{"type": "geojson"}` for a GeoJSON source
  added at runtime, also after `setGeoJsonSource`. `querySourceFeatures` reads
  the data, but returns one copy of each feature per tile.
- No call reads back the images added with `addImage`.

An earlier probe on maplibre_gl 0.27.1, on 2026-10-16, found that `getStyle()`
returned `null` on iOS, `getLayerProperties` ignored runtime changes
(maplibre/flutter-maplibre-gl#985), and `getLayerVisibility` had no native
handler.

## Revisit when

All three of these hold on both platforms:

- `getStyle` returns the live style, including runtime changes.
- `getLayerProperties` returns live state, including layers added at runtime.
- `getLayerVisibility` has a native handler.

One or two of them alone do not reopen this decision. With maplibre_gl 0.28.0
the second and third hold and the first does not, so this decision still
applies.
