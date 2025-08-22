import 'dart:async';

import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const String _kRokasId = 'rokas_logo';
const String _kAbaId = 'app_bakery_logo';

const String _kCustomSymbols = 'custom_symbols';
const String _kRokasIcons = 'rokas_icons';
const String _kCircles = 'circles';
const String _kLines = 'lines';
const String _kFills = 'fills';

final Map<String, List<SBBMapAnnotation>> _annotations = {
  _kCustomSymbols: [
    SBBMapSymbol(symbolURI: _kRokasId, coords: const LatLng(46.96122, 7.44533)),
    SBBMapSymbol(symbolURI: _kAbaId, coords: const LatLng(46.96793, 7.46306)),
  ],
  _kRokasIcons: [
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.9639, 7.46434)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.96277, 7.46344)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.96214, 7.46539)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.96323, 7.46635)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.96274, 7.46601)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.9624, 7.46432)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.96344, 7.46373)),
    SBBMapSymbol(symbolURI: RokasIcons.trainBlack, coords: const LatLng(46.96365, 7.46533)),
  ],
  _kCircles: [
    SBBMapCircle(center: const LatLng(46.95263, 7.44336)),
    SBBMapCircle(center: const LatLng(46.95245, 7.44359)),
    SBBMapCircle(center: const LatLng(46.95225, 7.44387)),
    SBBMapCircle(center: const LatLng(46.95204, 7.44416)),
    SBBMapCircle(center: const LatLng(46.95192, 7.44439)),
    SBBMapCircle(center: const LatLng(46.9518, 7.44459)),
    SBBMapCircle(center: const LatLng(46.95165, 7.44478)),
    SBBMapCircle(center: const LatLng(46.95146, 7.44508)),
    SBBMapCircle(center: const LatLng(46.9513, 7.44533)),
  ],
  _kLines: [
    SBBMapLine(
      vertices: [
        const LatLng(46.94908, 7.43819),
        const LatLng(46.94773, 7.43034),
        const LatLng(46.9513, 7.42317),
        const LatLng(46.95186, 7.41924),
        const LatLng(46.95094, 7.41654),
        const LatLng(46.94399, 7.40602),
      ],
      style: const SBBMapLineStyle(lineColor: SBBColors.green, lineWidth: 5.0),
    ),
  ],
  _kFills: [
    SBBMapFill(
      coords: [
        [
          const LatLng(46.94549, 7.42021),
          const LatLng(46.94486, 7.42064),
          const LatLng(46.94515, 7.42233),
          const LatLng(46.94669, 7.42583),
          const LatLng(46.94757, 7.42845),
          const LatLng(46.9496, 7.42459),
          const LatLng(46.94685, 7.42126),
        ],
      ],
    ),
  ],
};

class DisplayAnnotationsRoute extends StatefulWidget {
  const DisplayAnnotationsRoute({super.key});

  @override
  State<DisplayAnnotationsRoute> createState() => _DisplayAnnotationsRouteState();
}

class _DisplayAnnotationsRouteState extends State<DisplayAnnotationsRoute> {
  _AnnotationVisibilitySettings properties = _AnnotationVisibilitySettings(
    isCustomSymbolVisible: true,
    isCircleVisible: false,
    isRokasIconVisible: false,
    isLineVisible: false,
    isFillVisible: false,
  );

  late SBBMapStyler _styler;
  final Completer<SBBMapAnnotator> _annotator = Completer();

  @override
  initState() {
    _addIconToAnnotator(_kRokasId, 'assets/custom_icons/rokasLogo.png');
    _addIconToAnnotator(_kAbaId, 'assets/custom_icons/appBakeryLogo.png');
    _loadAnnotationsFrom(properties);
    _styler = SBBRokasMapStyler.full(apiKey: Env.journeyMapsTilesApiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context).isDark ? _styler.toggleDarkMode() : null;
    return Scaffold(
      appBar: const SBBHeader(title: 'Display annotations'),
      body: SBBMap(
        initialCameraPosition: const SBBCameraPosition(
          target: LatLng(46.947456, 7.451123), // Bern
          zoom: 12.0,
        ),
        mapStyler: _styler,
        isMyLocationEnabled: false,
        isFloorSwitchingEnabled: true,
        onMapAnnotatorAvailable: (annotator) => !_annotator.isCompleted ? _annotator.complete(annotator) : null,
        builder:
            (context) => Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(sbbDefaultSpacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SBBMapStyleSwitcher(),
                    const SizedBox(height: sbbDefaultSpacing),
                    SBBMapIconButton(
                      onPressed: () {
                        showSBBModalSheet<_AnnotationVisibilitySettings>(
                          context: context,
                          title: 'Show Annotations',
                          child: _AnnotationVisibilitySettingModal(settings: properties),
                        ).then(_setStateWithProperties);
                      },
                      icon: SBBIcons.gears_small,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  void _setStateWithProperties(_AnnotationVisibilitySettings? properties) {
    setState(() {
      if (properties != null) {
        this.properties = properties;
        _loadAnnotationsFrom(properties);
      }
    });
  }

  Future<void> _addIconToAnnotator(String imageId, String imageURI) async {
    final ByteData bytes = await rootBundle.load(imageURI);
    final Uint8List imageBytes = bytes.buffer.asUint8List();
    _annotator.future.then((a) => a.addImage(imageId: imageId, imageBytes: imageBytes));
  }

  void _loadAnnotationsFrom(_AnnotationVisibilitySettings properties) {
    final toAddAnnotations = <SBBMapAnnotation>[];
    final toRemoveAnnotations = <SBBMapAnnotation>[];
    properties.isCustomSymbolVisible
        ? toAddAnnotations.addAll(_annotations[_kCustomSymbols]!)
        : toRemoveAnnotations.addAll(_annotations[_kCustomSymbols]!);
    properties.isRokasIconVisible
        ? toAddAnnotations.addAll(_annotations[_kRokasIcons]!)
        : toRemoveAnnotations.addAll(_annotations[_kRokasIcons]!);
    properties.isCircleVisible
        ? toAddAnnotations.addAll(_annotations[_kCircles]!)
        : toRemoveAnnotations.addAll(_annotations[_kCircles]!);
    properties.isLineVisible
        ? toAddAnnotations.addAll(_annotations[_kLines]!)
        : toRemoveAnnotations.addAll(_annotations[_kLines]!);
    properties.isFillVisible
        ? toAddAnnotations.addAll(_annotations[_kFills]!)
        : toRemoveAnnotations.addAll(_annotations[_kFills]!);

    _annotator.future.then((a) {
      a.addAnnotations(toAddAnnotations);
      a.removeAnnotations(toRemoveAnnotations);
    });
  }
}

class _AnnotationVisibilitySettingModal extends StatefulWidget {
  const _AnnotationVisibilitySettingModal({required this.settings});

  final _AnnotationVisibilitySettings settings;

  @override
  State<_AnnotationVisibilitySettingModal> createState() => _AnnotationVisibilitySettingModalState();
}

class _AnnotationVisibilitySettingModalState extends State<_AnnotationVisibilitySettingModal> {
  late _AnnotationVisibilitySettings settings;

  @override
  void initState() {
    settings = widget.settings;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SBBCheckboxListItem(
            value: settings.isCustomSymbolVisible,
            label: 'Show Symbols',
            secondaryLabel: 'Show custom symbol annotations around Bern.',
            onChanged:
                (v) => setState(() {
                  settings.isCustomSymbolVisible = !settings.isCustomSymbolVisible;
                }),
          ),
          SBBCheckboxListItem(
            value: settings.isRokasIconVisible,
            label: 'Show SBB Rokas Symbols',
            secondaryLabel: 'Show SBB Rokas symbols around Wankdorf stadium.',
            onChanged:
                (v) => setState(() {
                  settings.isRokasIconVisible = !settings.isRokasIconVisible;
                }),
          ),
          SBBCheckboxListItem(
            value: settings.isCircleVisible,
            label: 'Show Circles',
            secondaryLabel: 'Display circle annotations between Lorrainebrücke and Kornhausbrücke.',
            onChanged:
                (v) => setState(() {
                  settings.isCircleVisible = !settings.isCircleVisible;
                }),
          ),
          SBBCheckboxListItem(
            value: settings.isLineVisible,
            label: 'Show Lines',
            secondaryLabel: 'Display line annotations between Bern Bahnhof and Bern Europaplatz.',
            onChanged:
                (v) => setState(() {
                  settings.isLineVisible = !settings.isLineVisible;
                }),
          ),
          SBBCheckboxListItem(
            value: settings.isFillVisible,
            label: 'Show Fills',
            secondaryLabel: 'Display fill annotation at Bern Inselspital.',
            onChanged:
                (v) => setState(() {
                  settings.isFillVisible = !settings.isFillVisible;
                }),
            isLastElement: true,
          ),
          const SizedBox(height: sbbDefaultSpacing),
          SBBPrimaryButton(label: 'Apply Changes', onPressed: () => Navigator.pop(context, settings)),
          const SizedBox(height: sbbDefaultSpacing),
        ],
      ),
    );
  }
}

class _AnnotationVisibilitySettings {
  bool isCustomSymbolVisible;
  bool isRokasIconVisible;
  bool isCircleVisible;
  bool isLineVisible;
  bool isFillVisible;

  _AnnotationVisibilitySettings({
    required this.isCustomSymbolVisible,
    required this.isRokasIconVisible,
    required this.isCircleVisible,
    required this.isLineVisible,
    required this.isFillVisible,
  });
}
