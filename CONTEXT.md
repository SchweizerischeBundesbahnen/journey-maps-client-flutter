# Context

`sbb_maps_flutter` is a Flutter package that wraps [MapLibre](https://maplibre.org/) to
render SBB-styled maps. It is a **library**, not an application: everything in `lib/`
is either public API or supports it, and the app in `example/` exists to exercise that
API rather than to ship.

This file is the ubiquitous language for the package. When naming a class, a test, an
issue or a commit, use the term as defined here.

## Glossary

### Map & styling

- **Map styler** (`SBBMapStyler`) — supplies the MapLibre style JSON and owns dark-mode
  state. `SBBRokasMapStyler` is the SBB-operated styler; `SBBCustomMapStyler` wraps an
  arbitrary style URL. Only ROKAS styles support floors and POIs.
- **ROKAS** — the SBB geodata platform providing tiles, service points and POI layers.
  Used as a proper noun and always upper-case.

### Floors

- **Floor** — a level of a building, identified by a signed integer. Ground level is
  `0`, basements are negative. This is the package's term; MapLibre style layers call
  the same concept **level** (layer ids ending `-lvl`, the `level` feature property) and
  ROKAS service-point features call it **floor** (`floor_liststring`). Both appear in
  `SBBMapFloorControllerImpl`, which is the only place the two vocabularies meet — do
  not let "level" leak into public API or UI code.
- **Available floors** (`SBBMapFloorController.availableFloors`) — the floors present in
  the currently visible map extent, in **descending** order, recomputed on every camera
  idle. Empty when the visible map has no indoor data, which is the normal case for most
  of Switzerland.
- **Current floor** (`SBBMapFloorController.currentFloor`) — the selected floor, or
  `null` for **no floor selected**. `null` and `0` produce the *same* map state (layer
  filters reset to level `0`) but are distinct UI states: `null` means the user has not
  chosen, `0` means the user chose ground level. UI must be able to express both.
- **Floor switcher** — the umbrella term for the UI control that displays available
  floors and switches between them. Two variants:
  - **Vertical floor switcher** (`SBBMapVerticalFloorSwitcher`) — the original control;
    a fixed 44 px column of tiles, always expanded.
  - **Horizontal floor switcher** (`SBBMapHorizontalFloorSwitcher`) — a collapsible
    stadium-shaped pill, anchored right, growing leftward when expanded. Default from
    3.0.0. See ADR 0002.

  Prefer **switcher** over **selector**. "Selector" survives only in deprecated
  typedefs kept for backward compatibility; see ADR 0002.
- **Floor label** — the string shown for a floor. The package renders `floor.toString()`
  by default and never localizes; SBB designs show `EG`/`UG`, which consumers supply via
  `floorLabelBuilder`. The package ships no localization of any kind — this is
  deliberate, so that consumers own their translation pipeline.

### UI controls

- **Small variant** — the compact 32 × 32 px form of a control, a separate class
  suffixed `Small` rather than a size parameter. `SBBMap.smallControls` selects them in
  the default UI. Every control has one.
- **Default UI** (`SBBMapDefaultUI`) — the right-aligned column of controls rendered when
  the consumer passes no `SBBMap.builder`. Supplying a builder replaces it wholesale.
- **Style** (`SBBMap*Style`) — a `ThemeExtension` carrying a control's colours, resolved
  by merging the theme's extension with an optional per-widget override. Registered in
  `sbb_map_style_container.dart`; a control with no registered extension throws.

## Known inconsistencies

Recorded so they are not mistaken for intent:

- `SBBMapTextStyles.sbbWebFont` resolves to `packages/design_system_flutter/SBBWeb`,
  naming a package that is not a dependency (`design_system_flutter` is the former name
  of `sbb_design_system_mobile`, which exposes `SBBWebLight`/`SBBWebRoman`, never a bare
  `SBBWeb`). This package ships the family itself as `packages/sbb_maps_flutter/SBBWeb`.
  All SBB map text therefore renders in the fallback font. Tracked separately.
- `.github/workflows/test.yml` points at "CONTEXT.md and ADR 0001" for the Flutter SDK
  support window. ADR 0001 has never been written; the number is reserved for it.
- `sbb_map_floor_selector/divider.dart` declares a class named `Divider`, shadowing
  Flutter's own.
