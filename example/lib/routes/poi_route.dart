import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_example/widgets/theme_segmented_button.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// P+Rail Zürich Tiefenbrunnen. The SBB Maps styles show only P+Rail car parks
/// as Highlighted POIs, so this place has both Base POIs and a Highlighted POI.
const _tiefenbrunnen = SBBCameraPosition(target: LatLng(47.34917, 8.56204), zoom: 16.0);

class POIRoute extends StatefulWidget {
  const POIRoute({super.key});

  @override
  State<POIRoute> createState() => _POIRouteState();
}

class _POIRouteState extends State<POIRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _PoiSettings _settings = const _PoiSettings();
  SBBRokasPOIController? _poiController;
  PersistentBottomSheetController? _detailsSheet;
  late RokasPOI _detailsPoi;

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBMapsMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    final isClickable = _settings.type != .nonClickable;

    return Scaffold(
      key: _scaffoldKey,
      appBar: const SBBHeader(titleText: 'POI'),
      body: SBBMap(
        initialCameraPosition: _tiefenbrunnen,
        mapStyler: mapStyler,
        isMyLocationEnabled: false,
        poiSettings: SBBMapPOISettings(
          onPoiControllerAvailable: _onPoiControllerAvailable,
          onPoiSelected: isClickable ? _showPoiDetails : null,
          onPoiDeselected: isClickable ? _closePoiDetails : null,
        ),
        builder: (context) => Stack(
          children: [
            const Align(
              alignment: .topCenter,
              // Keeps clear of the 44 px map buttons on the right.
              child: Padding(padding: .fromLTRB(64.0, SBBSpacing.medium, 64.0, 0), child: ThemeSegmentedButton()),
            ),
            Align(
              alignment: .topRight,
              child: Padding(
                padding: const .fromLTRB(0, SBBSpacing.medium, SBBSpacing.xSmall, 0),
                child: Column(
                  crossAxisAlignment: .end,
                  children: [
                    SBBMapIconButton(onPressed: _openSettings, icon: SBBIcons.gears_small),
                    const SizedBox(height: SBBSpacing.medium),
                    const SBBMapHorizontalFloorSwitcher(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPoiControllerAvailable(SBBRokasPOIController poiController) {
    _poiController = poiController;
    poiController.showPointsOfInterest(layer: _settings.poiLayer, categories: _settings.categoryFilter);
  }

  Future<void> _openSettings() async {
    final settings = await showSBBBottomSheet<_PoiSettings>(
      context: context,
      titleText: 'POI',
      body: _PoiSettingsModalBody(settings: _settings),
    );
    if (settings != null) await _applySettings(settings);
  }

  Future<void> _applySettings(_PoiSettings settings) async {
    final poiController = _poiController;
    if (poiController != null) {
      final selected = poiController.selectedPointOfInterest;
      if (selected != null && !settings.keepsSelectable(selected)) await poiController.deselectPointOfInterest();
      if (settings.poiLayer != _settings.poiLayer) await poiController.hidePointsOfInterest(layer: _settings.poiLayer);
      await poiController.showPointsOfInterest(layer: settings.poiLayer, categories: settings.categoryFilter);
    }
    if (mounted) setState(() => _settings = settings);
  }

  void _showPoiDetails(RokasPOI poi) {
    _detailsPoi = poi;
    final openSheet = _detailsSheet;
    if (openSheet != null) {
      openSheet.setState!(() {});
      return;
    }

    final sheet = _scaffoldKey.currentState!.showBottomSheet(
      (context) => _PoiDetailsSheet(poi: _detailsPoi),
      shape: const RoundedRectangleBorder(borderRadius: .vertical(top: .circular(SBBSpacing.medium))),
      clipBehavior: .antiAlias,
    );
    _detailsSheet = sheet;
    sheet.closed.then((_) {
      _detailsSheet = null;
      _poiController?.deselectPointOfInterest();
    });
  }

  void _closePoiDetails(RokasPOI _) => _detailsSheet?.close();
}

enum _PoiType { clickable, nonClickable, highlighted }

class _PoiSettings {
  const _PoiSettings({this.type = .clickable, this.categories = SBBPoiCategoryType.values});

  final _PoiType type;
  final List<SBBPoiCategoryType> categories;

  bool get _isEveryCategory => categories.length == SBBPoiCategoryType.values.length;

  SBBRokasPoiLayer get poiLayer => type == .highlighted ? .highlighted : .base;

  List<SBBPoiCategoryType>? get categoryFilter => _isEveryCategory ? null : categories;

  bool keepsSelectable(RokasPOI poi) =>
      type != .nonClickable && (_isEveryCategory || categories.any((c) => c.name == poi.subCategory));

  _PoiSettings copyWith({_PoiType? type, List<SBBPoiCategoryType>? categories}) =>
      _PoiSettings(type: type ?? this.type, categories: categories ?? this.categories);
}

class _PoiSettingsModalBody extends StatefulWidget {
  const _PoiSettingsModalBody({required this.settings});

  final _PoiSettings settings;

  @override
  State<_PoiSettingsModalBody> createState() => _PoiSettingsModalBodyState();
}

class _PoiSettingsModalBodyState extends State<_PoiSettingsModalBody> {
  late _PoiSettings _settings;

  @override
  void initState() {
    _settings = widget.settings;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        const Text('POI type'),
        const SizedBox(height: SBBSpacing.small),
        SBBSegmentedButton<_PoiType>(
          segments: const [
            SBBButtonSegment(value: .clickable, labelText: 'Clickable POIs'),
            SBBButtonSegment(value: .nonClickable, labelText: 'Non-clickable POIs'),
            SBBButtonSegment(value: .highlighted, labelText: 'Highlighted POIs'),
          ],
          selected: _settings.type,
          onSelectionChanged: (value) => _setModalStateWithSettings(_settings.copyWith(type: value)),
        ),
        const SizedBox(height: SBBSpacing.medium),
        SBBMultiDropdown<SBBPoiCategoryType>(
          triggerDecoration: const SBBInputDecoration(labelText: 'Categories', placeholderText: 'None'),
          sheetTitleText: 'Categories',
          selectedItems: _settings.categories,
          items: [
            for (final category in SBBPoiCategoryType.values) SBBDropdownItem(value: category, label: category.name),
          ],
          onChanged: (value) => _setModalStateWithSettings(_settings.copyWith(categories: value)),
        ),
        const SizedBox(height: SBBSpacing.medium),
        SBBPrimaryButton(labelText: 'Apply Changes', onPressed: () => Navigator.pop(context, _settings)),
      ],
    );
  }

  void _setModalStateWithSettings(_PoiSettings settings) {
    setState(() {
      _settings = settings;
    });
  }
}

class _PoiDetailsSheet extends StatelessWidget {
  const _PoiDetailsSheet({required this.poi});

  final RokasPOI poi;

  @override
  Widget build(BuildContext context) {
    final coordinates = poi.coordinates;
    return SBBBottomSheet(
      titleText: poi.name,
      body: SafeArea(
        top: false,
        child: Table(
          columnWidths: const {0: IntrinsicColumnWidth()},
          children: [
            _row('Category', poi.category),
            _row('Sub-category', poi.subCategory),
            _row('Operator', poi.operator),
            _row('SBB id', poi.sbbId),
            _row('Icon', poi.icon),
            _row(
              'Coordinates',
              '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}',
            ),
          ],
        ),
      ),
    );
  }

  TableRow _row(String label, String value) => TableRow(
    children: [
      Padding(
        padding: const .only(right: SBBSpacing.medium, bottom: SBBSpacing.xSmall),
        child: Text(label),
      ),
      Text(value),
    ],
  );
}
