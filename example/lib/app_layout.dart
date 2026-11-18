import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import 'breakpoint.dart';
import 'feature_routes.dart';
import 'widgets/feature_list.dart';

const _kHeaderTitle = 'Maps Flutter';

/// Shows the feature list and the selected feature route, in the split layout
/// or the phone layout depending on [isSplitLayout].
///
/// The selection carries over when the app window crosses the breakpoint. The
/// feature route itself is rebuilt.
class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  /// The feature route in the right pane of the split layout, or the one open
  /// as a page in the phone layout. Null while the phone layout shows the
  /// feature list.
  FeatureRoute? _selected;
  late bool _isSplitLayout;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isSplitLayout = isSplitLayout(context);
    // The right pane always shows a feature route.
    if (_isSplitLayout) _selected ??= featureRoutes.first;
  }

  @override
  Widget build(BuildContext context) {
    return _isSplitLayout
        ? _SplitLayout(selected: _selected!, onSelected: _select)
        : _PhoneLayout(selected: _selected, onSelected: _select, onClosed: () => _select(null));
  }

  void _select(FeatureRoute? featureRoute) {
    if (featureRoute != _selected) setState(() => _selected = featureRoute);
  }
}

/// The feature list fills the window and the selected feature route opens as a
/// page over it, with its title and a back button in the header.
class _PhoneLayout extends StatefulWidget {
  const _PhoneLayout({required this.selected, required this.onSelected, required this.onClosed});

  final FeatureRoute? selected;
  final ValueChanged<FeatureRoute> onSelected;

  /// Called when the page of the selected feature route is popped.
  final VoidCallback onClosed;

  @override
  State<_PhoneLayout> createState() => _PhoneLayoutState();
}

class _PhoneLayoutState extends State<_PhoneLayout> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        pages: [
          MaterialPage(
            key: const ValueKey('feature-list'),
            child: Scaffold(
              appBar: const SBBHeader(titleText: _kHeaderTitle),
              body: FeatureList(onSelected: widget.onSelected),
            ),
          ),
          if (selected != null)
            MaterialPage(
              key: ValueKey(selected.title),
              child: Scaffold(
                appBar: SBBHeader(titleText: selected.title),
                body: Builder(builder: selected.builder),
              ),
            ),
        ],
        // The feature list is the first page, so only the feature route's page can be removed.
        onDidRemovePage: (_) => widget.onClosed(),
      ),
    );
  }
}

/// One header spans the window. Below it, the feature list takes the left
/// third and the selected feature route the remaining two thirds.
class _SplitLayout extends StatelessWidget {
  const _SplitLayout({required this.selected, required this.onSelected});

  final FeatureRoute selected;
  final ValueChanged<FeatureRoute> onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SBBHeader(titleText: _kHeaderTitle),
      body: Row(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeRight: true,
              child: SafeArea(
                top: false,
                child: FeatureList(selected: selected, onSelected: onSelected),
              ),
            ),
          ),
          const VerticalDivider(width: 1.0),
          Expanded(
            flex: 2,
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              // The key gives every selection a new pane, so the feature route starts fresh.
              child: _FeatureRoutePane(key: ValueKey(selected.title), featureRoute: selected),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hosts one feature route in a [Navigator] of its own, so the sheets the
/// feature route opens cover this pane only.
class _FeatureRoutePane extends StatefulWidget {
  const _FeatureRoutePane({super.key, required this.featureRoute});

  final FeatureRoute featureRoute;

  @override
  State<_FeatureRoutePane> createState() => _FeatureRoutePaneState();
}

class _FeatureRoutePaneState extends State<_FeatureRoutePane> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => Scaffold(body: Builder(builder: widget.featureRoute.builder)),
        ),
      ),
    );
  }
}
