# SBB Maps Flutter

A Flutter map client for SBB. It wraps MapLibre and drives published SBB vector
map styles, adding floor switching, points of interest, routing overlays and
annotations on top of them.

## Language

### Styles

**Style Family**:
A versioned set of map styles published together by SBB DSRV GIS / geOps. Two
exist: the Legacy Journey Maps family and the SBB Maps family.
_Avoid_: style set, style version, style generation

**Legacy Journey Maps style family**:
The `journey_maps_bright_v1`, `journey_maps_dark_v1` and `journey_maps_aerial_v1`
styles, removed from the production CDN on 2026-12-31.
_Avoid_: ROKAS styles, old styles, v1 styles

**SBB Maps style family**:
The `sbbmaps_bright`, `sbbmaps_dark` and `sbbmaps_aerial` styles that replace the
Legacy Journey Maps family.
_Avoid_: new styles, v2 styles, sbbmaps styles

**ROKAS**:
The SBB geodata platform, and the prefix on the layers it contributes to a style.
Not a name for any one style family — ROKAS layers appear in both.
_Avoid_: using ROKAS to mean the Legacy Journey Maps family

### Layers

**ROKAS overlay layer**:
A layer this library drives directly, prefixed `rokas-`, `journey-pois-` or
`vnext-`. Identical across both style families.
_Avoid_: feature layer, overlay

**Basemap layer**:
Any layer in a style that is not a ROKAS overlay layer. Specific to one style
family and not addressed by id from this library.
_Avoid_: base layer, background layer

**Level Filter Idiom**:
The shape of the expression inside a layer's filter that encodes which floor is
visible. Each style family uses its own; a layer is floor-dependent if and only
if its id ends in `-lvl`.
_Avoid_: level filter, floor filter, filter dialect

**Floor**:
The storey a user has selected, as exposed by `SBBMapFloorController`. Rendered
into a style's Level Filter Idiom to decide what draws.
_Avoid_: level, storey — except when quoting a style's own `level` property
