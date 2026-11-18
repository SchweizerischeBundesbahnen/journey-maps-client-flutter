import 'package:flutter/widgets.dart';

const _kSplitLayoutShortestSide = 600.0;

/// Whether the app window is large enough for the split layout, which shows
/// the feature list next to the selected feature route.
///
/// Measures the window and not the device, so a narrow window on a tablet gets
/// the phone layout. Rotating the device does not change the result.
bool isSplitLayout(BuildContext context) => MediaQuery.sizeOf(context).shortestSide >= _kSplitLayoutShortestSide;
