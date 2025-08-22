import 'package:flutter/material.dart';
import 'package:sbb_maps_flutter/src/sbb_map_ui/styles/styles.dart';

/// A container that extends the theme above the [child]
/// with the styles for the SBB Map UI.
///
/// These are:
///
/// - [SBBMapIconButtonStyle]
/// - [SBBMapFloorSelectorStyle]
///
class SBBMapStyleContainer extends StatelessWidget {
  const SBBMapStyleContainer({super.key, required this.child});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Theme(data: _addSBBMapDefaultStyles(context), child: child);
  }

  _addSBBMapDefaultStyles(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = SBBMapBaseStyle(brightness: theme.brightness);
    final parentExtensions = theme.extensions.values.toList();
    return theme.copyWith(
      extensions:
          parentExtensions
            ..add(SBBMapIconButtonStyle.$default(baseStyle: baseStyle))
            ..add(SBBMapFloorSelectorStyle.$default(baseStyle: baseStyle)),
    );
  }
}
