import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/corporate_ui/sbb_map_branding.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/sbb_map_ui_container/sbb_map_ui_container.dart';

/// The same duration the floor tiles of the vertical switcher already animate
/// with.
const _kAnimationDuration = Duration(milliseconds: 300);
const _kElevation = 4.0;

/// The geometry that separates [SBBMapHorizontalFloorSwitcher] from
/// [SBBMapHorizontalFloorSwitcherSmall]. Nothing else about the two differs.
class HorizontalFloorSwitcherMetrics {
  const HorizontalFloorSwitcherMetrics({
    required this.controlSize,
    required this.tilePadding,
    required this.tileRadius,
    required this.labelGutter,
    required this.labelStyle,
    required this.selectedLabelStyle,
  });

  /// Matches the 44 px map icon buttons and the vertical floor switcher.
  static const standard = HorizontalFloorSwitcherMetrics(
    controlSize: 44.0,
    tilePadding: EdgeInsets.all(6.0),
    tileRadius: 8.0,
    labelGutter: 4.0,
    labelStyle: SBBMapTextStyles.mediumLight,
    selectedLabelStyle: SBBMapTextStyles.mediumBold,
  );

  /// Matches the compact 32 px map controls.
  static const compact = HorizontalFloorSwitcherMetrics(
    controlSize: 32.0,
    tilePadding: EdgeInsets.all(4.0),
    tileRadius: 6.0,
    labelGutter: 2.0,
    labelStyle: SBBMapTextStyles.extraSmallLight,
    selectedLabelStyle: SBBMapTextStyles.extraSmallBold,
  );

  /// The height of the pill, and the diameter of the collapsed circle.
  final double controlSize;

  /// The inset between a floor tile's edge and its filled selection shape.
  final EdgeInsets tilePadding;

  /// The corner radius of a floor tile's filled selection shape.
  final double tileRadius;

  /// Breathing room either side of a floor label wider than its tile.
  final double labelGutter;

  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;

  /// The side of a floor tile's filled selection shape.
  double get tileInnerSize => controlSize - tilePadding.vertical;
}

/// The horizontal, collapsible floor switcher, in whichever size [metrics]
/// describes.
///
/// Collapsed it is a single circular control; expanded it is a stadium-shaped
/// pill anchored to its right edge and grown leftwards, so the close icon ends
/// up exactly where the collapsed circle was and the control expands out from
/// the point of touch.
class HorizontalFloorSwitcherBody extends StatefulWidget {
  const HorizontalFloorSwitcherBody({
    super.key,
    required this.metrics,
    required this.floorLabelBuilder,
    this.style,
  });

  final HorizontalFloorSwitcherMetrics metrics;
  final SBBMapFloorLabelBuilder floorLabelBuilder;
  final SBBMapFloorSwitcherStyle? style;

  @override
  State<HorizontalFloorSwitcherBody> createState() => _HorizontalFloorSwitcherBodyState();
}

class _HorizontalFloorSwitcherBodyState extends State<HorizontalFloorSwitcherBody> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _expansion;

  SBBMapFloorController? _floorController;

  /// The floors last seen. The controller recomputes its list on every camera
  /// idle and emits a single, undifferentiated change notification for both
  /// floor set and selection changes, so the comparison has to happen here —
  /// and it has to be by value, or an equal but rebuilt list would collapse
  /// the control under a traveller mid-interaction.
  List<int> _knownFloors = const <int>[];

  /// Whether any part of the pill is on screen — open, or still animating in
  /// either direction. The end cap follows this rather than the intent behind
  /// it, so it stays a close icon for the whole collapse: were it to revert the
  /// moment a floor was picked, that floor would appear twice at once, once on
  /// the cap and once on the tile still shrinking beside it.
  bool get _isPillShowing => !_expansion.isDismissed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kAnimationDuration);
    _expansion = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final floorController = SBBMapUiContainer.of(context).mapFloorController;
    if (identical(floorController, _floorController)) return;
    _floorController?.removeListener(_reactToFloorChange);
    _floorController = floorController..addListener(_reactToFloorChange);
    _knownFloors = List<int>.of(floorController.availableFloors);
  }

  @override
  void dispose() {
    _floorController?.removeListener(_reactToFloorChange);
    _expansion.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _reactToFloorChange() {
    final floors = _floorController!.availableFloors;
    if (!listEquals(floors, _knownFloors)) {
      _knownFloors = List<int>.of(floors);
      // Nothing renders without floors, so there is no collapse to animate —
      // but the expansion state still has to reset, or the control reappears
      // already open once floors come back.
      _collapse(animate: floors.isNotEmpty);
    }
    setState(() {});
  }

  void _expand() => _controller.forward();

  void _collapse({bool animate = true}) {
    if (animate) {
      _controller.reverse();
    } else {
      _controller.value = 0.0;
    }
  }

  /// Switches to [floor], or deselects it when it is already the current one,
  /// which resets the map to its default floor.
  void _selectFloor(int floor) {
    final floorController = _floorController!;
    floorController.switchFloor(floorController.currentFloor == floor ? null : floor);
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    if (_floorController!.availableFloors.isEmpty) return const SizedBox.shrink();

    final style = _resolveStyleWithInherited(context);
    return Material(
      elevation: _kElevation,
      shadowColor: style.shadowColor,
      color: style.backgroundColor,
      shape: StadiumBorder(side: style.borderSide ?? BorderSide.none),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: widget.metrics.controlSize,
        child: AnimatedBuilder(
          animation: _expansion,
          builder: (context, _) => Row(
            mainAxisSize: .min,
            children: [
              // Anchoring the floors to their right edge and shrinking the box
              // from the left is what makes the pill grow leftwards out of the
              // end cap. The floors are clipped by the pill rather than faded,
              // because a fade over a width tween reads as two competing
              // animations.
              if (_isPillShowing)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: _expansion.value,
                    child: _floorRow(style),
                  ),
                ),
              _endCap(style),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floorRow(SBBMapFloorSwitcherStyle style) {
    final floorController = _floorController!;
    // The controller lists floors descending; a traveller reads them ascending.
    final floors = floorController.availableFloors.reversed;
    return Row(
      mainAxisSize: .min,
      children: [
        for (final floor in floors)
          _FloorTile(
            label: widget.floorLabelBuilder(floor),
            isSelected: floorController.currentFloor == floor,
            onPressed: () => _selectFloor(floor),
            metrics: widget.metrics,
            style: style,
          ),
      ],
    );
  }

  /// The right-hand element: a close icon while expanded, and while collapsed
  /// either the current floor or — with nothing selected — the floors icon.
  Widget _endCap(SBBMapFloorSwitcherStyle style) {
    final glyphColor = style.iconColor ?? style.textColor;
    if (_isPillShowing) {
      return _EndCap(
        onPressed: _collapse,
        metrics: widget.metrics,
        style: style,
        child: Icon(SBBMapIcons.cross_small, size: sbbIconSizeSmall, color: glyphColor),
      );
    }

    final currentFloor = _floorController!.currentFloor;
    if (currentFloor == null) {
      return _EndCap(
        onPressed: _expand,
        metrics: widget.metrics,
        style: style,
        child: Icon(SBBMapIcons.layers_with_arrows_small, size: sbbIconSizeSmall, color: glyphColor),
      );
    }

    return _EndCap(
      onPressed: _expand,
      isFilled: true,
      metrics: widget.metrics,
      style: style,
      child: Text(
        widget.floorLabelBuilder(currentFloor),
        maxLines: 1,
        style: widget.metrics.selectedLabelStyle.copyWith(color: style.selectedTextColor),
      ),
    );
  }

  SBBMapFloorSwitcherStyle _resolveStyleWithInherited(BuildContext context) {
    final inheritedStyle = Theme.of(context).extension<SBBMapFloorSwitcherStyle>()!;
    return inheritedStyle.merge(widget.style);
  }
}

/// One pickable floor inside the expanded pill.
class _FloorTile extends StatelessWidget {
  const _FloorTile({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.metrics,
    required this.style,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final HorizontalFloorSwitcherMetrics metrics;
  final SBBMapFloorSwitcherStyle style;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      containedInkWell: true,
      highlightColor: style.pressedColor,
      splashColor: style.pressedColor,
      onTap: onPressed,
      child: Padding(
        padding: metrics.tilePadding,
        child: Container(
          constraints: BoxConstraints(minWidth: metrics.tileInnerSize, minHeight: metrics.tileInnerSize),
          padding: EdgeInsets.symmetric(horizontal: metrics.labelGutter),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(metrics.tileRadius),
            color: isSelected ? style.selectedBackgroundColor : style.backgroundColor,
          ),
          child: Text(
            label,
            maxLines: 1,
            style: (isSelected ? metrics.selectedLabelStyle : metrics.labelStyle).copyWith(
              color: isSelected ? style.selectedTextColor : style.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular cap at the right of the control.
///
/// It is a full-height circle matching the map icon buttons rather than a
/// floor tile, so its tap target stays the full height of the control.
class _EndCap extends StatelessWidget {
  const _EndCap({
    required this.child,
    required this.onPressed,
    required this.metrics,
    required this.style,
    this.isFilled = false,
  });

  final Widget child;
  final VoidCallback onPressed;
  final HorizontalFloorSwitcherMetrics metrics;
  final SBBMapFloorSwitcherStyle style;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      containedInkWell: true,
      customBorder: const CircleBorder(),
      highlightColor: style.pressedColor,
      splashColor: style.pressedColor,
      onTap: onPressed,
      child: Container(
        width: metrics.controlSize,
        height: metrics.controlSize,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: isFilled ? style.selectedBackgroundColor : style.backgroundColor,
        ),
        child: child,
      ),
    );
  }
}
