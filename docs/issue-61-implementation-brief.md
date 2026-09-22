# Issue #61 — implementation brief

Outcome of a grilling session on 2026-09-22. Decisions are recorded in
[ADR 0002](adr/0002-horizontal-floor-switcher-and-selector-rename.md); vocabulary in
[CONTEXT.md](../CONTEXT.md). This file is the work breakdown.

## Blocked by

The SBB Web typeface is **being removed from the package**, not repaired — see #261, with
tickets #262 (migrate the test suite to `flutter_test`) and #263 (remove the typeface).
Land both first.

Background: `SBBMapTextStyles.sbbWebFont` is `'packages/design_system_flutter/SBBWeb'`,
naming a package that is not a dependency — `design_system_flutter` is the former name of
`sbb_design_system_mobile`, which exposes `SBBWebLight`/`SBBWebRoman` and never a bare
`SBBWeb`. So the typeface has never rendered. Rather than correct the string, the package
stops shipping the typeface altogether: it is proprietary, and this package is MIT, which
grants consumers the right to sublicense and sell everything in it. Map text will instead
inherit the host application's typography.

Consequences for #61:

- The horizontal switcher's labels must be written against inherited typography — the
  package's text styles will still carry size, weight, height and style, but no family.
- #262 also delivers this issue's `flutter_test` dev-dependency and import migration, so
  the "Tests" section below no longer needs to do it.
- The blast radius of the typeface change is exactly the two floor tiles; every other
  control renders icons from the SBB icon font, which is kept and is unaffected.

## Scope

### 1. Rename (no behaviour change)

| Before | After | Note |
| --- | --- | --- |
| `SBBMapFloorSelector` | `SBBMapVerticalFloorSwitcher` | deprecated typedef |
| `SBBMapFloorSelectorSmall` | `SBBMapVerticalFloorSwitcherSmall` | deprecated typedef |
| `SBBMapFloorSelectorStyle` | `SBBMapFloorSwitcherStyle` | deprecated typedef |
| `SBBMapFloorSelectorTile` | `SBBMapVerticalFloorSwitcherTile` | internal, no typedef |
| `FloorSelectorTilesBuilder` | `VerticalFloorSwitcherTilesBuilder` | internal, no typedef |

Typedef wording:

```dart
@Deprecated("Use SBBMapVerticalFloorSwitcher. Deprecated after 2.9.0. Removed in 3.0.0.")
typedef SBBMapFloorSelector = SBBMapVerticalFloorSwitcher;
```

Also update: the `widgets/sbb_map_ui_widgets.dart` barrel, `styles/styles.dart`,
`sbb_map_style_container.dart`, the doc references in `sbb_map.dart` (including the
dangling `[SBBMapFloorSwitcher]` in the `builder` doc comment, which finally resolves —
note `[SBBMapStyleSwitcherButton]` alongside it is dangling too, the real name being
`SBBMapStyleSwitcher`), the README feature table, and
`example/lib/routes/custom_ui_route.dart`.

Deprecation is not itself breaking — land as `feat:` so release-please cuts a minor.

### 2. `floorLabelBuilder`

Add to **both** orientations:

```dart
typedef SBBMapFloorLabelBuilder = String Function(int floor);
```

Defaults to `(floor) => floor.toString()`, preserving today's output. The package ships
no localization; `EG`/`UG` in the design are the consumer's labels. This also covers
negative floors.

### 3. `SBBMapHorizontalFloorSwitcher` + `SBBMapHorizontalFloorSwitcherSmall`

Collapsible by definition — no `collapsible` or `initiallyExpanded` parameter; always
starts collapsed.

**States**

| Current floor | Collapsed shows | Expanded right-hand element |
| --- | --- | --- |
| none | `SBBMapIcons.layers_with_arrows_small` (0xf24b) | `SBBMapIcons.cross_small` (0xf1c2) |
| selected | the floor label, filled | `SBBMapIcons.cross_small` |

**Transitions**

- collapsed circle tapped → expand
- cross tapped → collapse
- floor tapped → `switchFloor(n)`, then collapse
- current floor tapped → `switchFloor(null)`, then collapse (reverts to the icon)
- `availableFloors` changes by value → collapse and reset expansion state
- `availableFloors` empty → `SizedBox.shrink()` (existing guard) **and** reset expansion

**Layout**

- Floors ascending left→right — reverse `availableFloors`, which is descending.
- Pill anchored right, grows leftward. Cross occupies the collapsed circle's position.
- Current floor: **bold and filled**, using `selectedBackgroundColor` /
  `selectedTextColor`.
- Cross and layers glyph are full-height end caps, not floor tiles: 24 px icon with 8 px
  padding in the 44 px variant (matching `SBBMapIconButton`), 24 px centred in 32 px for
  the small variant (matching `SBBMapIconButtonSmall`). Not the padded 24 px inner tile
  geometry, so the tap target stays full height.
- 300 ms expand/collapse, `Curves.easeInOut`, width-only — the floor list is clipped by
  the animating pill rather than separately faded.

**Floor-set comparison.** `SBBMapFloorControllerImpl._notifyListenersIfChanged` emits one
undifferentiated `notifyListeners()` for both floor-set and selection changes, so the
widget must cache the previous list and compare by value:

```dart
const ListEquality<int>().equals(previous, controller.availableFloors)
```

Identity comparison would collapse the pill on every camera idle. `collection` is already
a direct dependency.

### 4. Style

`SBBMapFloorSwitcherStyle` gains exactly one token: **`iconColor`**, defaulting to the
same `themeValue(black, white)` as `textColor`. Everything else reuses existing tokens —
the pill background is `backgroundColor`, the dark-mode ring is the existing `borderSide`
drawn by `StadiumBorder`, the filled selection is `selectedBackgroundColor` /
`selectedTextColor`.

### 5. `SBBMap.floorSwitcherOrientation`

```dart
enum SBBMapFloorSwitcherOrientation { vertical, horizontal }
```

New `SBBMap` parameter defaulting to `.vertical`. `SBBMapDefaultUI` selects the variant,
crossed with the existing `smallControls` flag (four combinations). The horizontal branch
keeps the same 54.0 / 36.0 spacers as the vertical one, wrapped in
`Align(alignment: Alignment.centerRight)` so the right edge stays pinned and the pill
grows leftward instead of centring itself in the `Column`.

Flips to `.horizontal` in 3.0.0.

### 6. Tests

The `flutter_test` dev dependency and the suite-wide import migration arrive with #262, so
this issue inherits a widget-test-capable suite. Remove `// coverage:ignore-file` from the
new horizontal files only; leave the vertical files as they are.

Widget tests:

- collapsed → expanded → collapsed, via the circle and via the cross
- layers icon shown when `currentFloor == null`; floor label when set
- selecting a floor calls `switchFloor(n)` and collapses
- re-selecting the current floor calls `switchFloor(null)` and collapses to the icon
- empty `availableFloors` renders `SizedBox.shrink()`
- a value-differing floor set resets expansion; an equal-but-rebuilt one does not
- `floorLabelBuilder` is applied, in both orientations

Expect the Sonar coverage number to move on the first PR.

## Explicitly out of scope

- **Golden tests.** Visual regressions will not be caught automatically. The repo has no
  golden infrastructure and CI runs `flutter test` across the whole SDK support window on
  Linux, where pinned images are fragile. If this is revisited, `sbb_design_system_mobile`
  has a transferable pattern: `test/flutter_test_config.dart` → a `setupAll` that walks
  `FontManifest.json` and `FontLoader`s each family as `packages/<pkg>/<family>`, plus a
  `TestSpecs.run` helper looping light/dark into `goldens/<name>.<brightness>.png`. It
  pins comparison to a macOS runner.
- **Accessibility.** No `Semantics` anywhere in `lib/` today, and a collapsible control
  is worse for screen readers than an always-expanded list. Worth revisiting before
  3.0.0 makes horizontal the default.
- **Overflow with many floors.** The pill can grow past the left screen edge. Not
  handled, and deliberately not documented.
- **Configurable expand direction.** Fixed right-anchored, growing left.
- **Any visual change to the vertical variant.**

## Worth a check with design

- `layers_with_arrows_small` renders ~54 px below the style switcher's `layers_small` in
  the default UI — two near-identical layer glyphs, stacked, meaning different things.
  The Figma frame shows the switcher in isolation, so this adjacency was not visible.
- The default-UI spacing and alignment of the horizontal pill, once it runs in the
  example app. Same reason: not in the frame.
- Whether the Figma specifies an expand/collapse duration. If it does, it beats the
  300 ms chosen here for consistency with the existing tile animation.
