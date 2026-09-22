# 2. Horizontal floor switcher, and the Selector → Switcher rename

Date: 2026-09-22

## Status

Accepted

## Context

The floor switcher is a fixed 44 px vertical column of tiles pinned to the top right of
the map. It is always expanded, so with five floors it occupies roughly a third of the
screen height whether or not the user cares about floors. Design produced a collapsible
horizontal alternative: a stadium pill that shows a single circular affordance when
collapsed and expands leftward into the floor list when tapped (issue #61).

The control is public API. Every class is named `SBBMapFloorSelector*`, while the verb
on the controller is `switchFloor`, the flag on `SBBMap` is `isFloorSwitchingEnabled`,
the README feature table says "Floor Switcher", and a dangling doc comment in
`sbb_map.dart` already refers to a non-existent `SBBMapFloorSwitcher`. Introducing a
second variant forces a naming decision that has been deferred until now: adding
`SBBMapHorizontalFloorSelector` alongside the existing name would make the split between
the noun and the verb permanent.

The package is at 2.x and is consumed outside this repository, so the existing names
cannot simply disappear.

## Decision

**Adopt "switcher" as the single term** and rename the whole family in one move:

| Before | After |
| --- | --- |
| `SBBMapFloorSelector` | `SBBMapVerticalFloorSwitcher` |
| `SBBMapFloorSelectorSmall` | `SBBMapVerticalFloorSwitcherSmall` |
| `SBBMapFloorSelectorStyle` | `SBBMapFloorSwitcherStyle` |
| — | `SBBMapHorizontalFloorSwitcher` |
| — | `SBBMapHorizontalFloorSwitcherSmall` |

Each old name survives as a `@Deprecated` typedef, worded to match existing precedent in
the package:

```dart
@Deprecated("Use SBBMapVerticalFloorSwitcher. Deprecated after 2.9.0. Removed in 3.0.0.")
typedef SBBMapFloorSelector = SBBMapVerticalFloorSwitcher;
```

Internal types that are not exported from the barrel (`SBBMapFloorSelectorTile`,
`FloorSelectorTilesBuilder`, `Divider`) are renamed without typedefs.

**The horizontal variant is collapsible by definition.** There is no `collapsible` flag
and no `initiallyExpanded` flag: it always starts collapsed. Its state machine:

| Current floor | Collapsed shows | Expanded right-hand element |
| --- | --- | --- |
| none | `SBBMapIcons.layers_with_arrows_small` | `SBBMapIcons.cross_small` |
| selected | the floor label | `SBBMapIcons.cross_small` |

Tapping the collapsed circle expands the pill; tapping the cross collapses it. Selecting
a floor collapses it. Re-selecting the already-current floor calls `switchFloor(null)`
and collapses back to the icon — the same deselect-on-retap toggle the vertical variant
has, which is only expressible here because "no floor selected" has a distinct icon.
Floors render ascending left-to-right (reversing `availableFloors`, which is descending),
the pill is anchored right and grows leftward, and the cross sits exactly where the
collapsed circle was so the control expands out from the point of touch. The current
floor is drawn bold and filled, reusing `selectedBackgroundColor`/`selectedTextColor`.
Expansion animates over 300 ms, matching the existing tile animation.

When `availableFloors` changes — compared by value with `ListEquality`, not identity, so
that an equal-but-rebuilt list from a camera idle does not disturb the user — the pill
collapses and resets its expansion state. The controller emits a single undifferentiated
`notifyListeners()` for both floor-set and selection changes, so the widget caches the
previous list and compares it itself.

**Styling stays on one `ThemeExtension`.** `SBBMapFloorSwitcherStyle` gains exactly one
new token, `iconColor`, for the affordance glyphs; the pill background, dark-mode ring
and selected fill all reuse tokens the vertical variant already defines. Consumers who
have themed the floor switcher get the horizontal variant themed for free.

**The default stays vertical until 3.0.0.** `SBBMap.floorSwitcherOrientation` takes a new
`SBBMapFloorSwitcherOrientation` enum defaulting to `.vertical`, so the horizontal
variant is opt-in throughout 2.x and the 3.0.0 change is a one-line default flip rather
than new code written against a major-version deadline.

## Consequences

- Consumers see no break in 2.x. Upgrading to 3.0.0 requires renaming call sites and
  accepting the new default orientation; both are mechanical.
- The vertical variant is untouched beyond the rename and the new `floorLabelBuilder`
  parameter. Converging the two visually is a separate decision.
- Four widget classes now exist where two did ({vertical, horizontal} × {normal, small}),
  following the established per-size-class convention. Collapsing all four behind a size
  parameter is a candidate for 3.0.0 but is explicitly out of scope here.
- Behaviour is covered by widget tests; **no golden tests**. Layout, spacing and colour
  regressions will not be caught automatically. This is a deliberate trade against the
  cost of standing up golden infrastructure (the repo has none, `flutter_test` is not
  yet a dependency, and CI runs `flutter test` across the whole Flutter SDK support
  window on Linux, where pinned reference images are fragile).
- No `Semantics` annotations. A collapsible control is meaningfully worse for screen
  readers than an always-expanded list, since the floor list is absent from the tree
  when collapsed. Accepted for now; worth revisiting before 3.0.0 makes it the default.
- Overflow is unhandled. With enough floors the pill will grow past the left edge of the
  screen. Deliberately not addressed and deliberately not documented.

## Alternatives considered

- **Keep "selector" and add `SBBMapHorizontalFloorSelector`.** Cheapest, no deprecations.
  Rejected: it permanently cements the split between `switchFloor` /
  `isFloorSwitchingEnabled` and the widget names, and the rename only gets more
  expensive as the API grows.
- **Collapsibility as an orthogonal wrapper usable by both orientations.** Rejected: no
  design exists for a collapsible vertical switcher or a non-collapsible horizontal one,
  so the extra axis would be untested speculation.
- **A separate `SBBMapHorizontalFloorSwitcherStyle` extension.** Rejected: it is one more
  extension for consumers to register, and the two variants share almost every token.
- **A configurable expand direction.** Rejected: it doubles the animation and layout
  cases with no design behind it. Revisit if a consumer asks.
