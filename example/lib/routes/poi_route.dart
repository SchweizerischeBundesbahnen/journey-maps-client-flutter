import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sbb_maps_example/env.dart';
import 'package:sbb_maps_example/theme_provider.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

class POIRoute extends StatefulWidget {
  const POIRoute({super.key});

  @override
  State<POIRoute> createState() => _POIRouteState();
}

class _POIRouteState extends State<POIRoute> {
  final Completer<SBBRokasPOIController> _poiController = Completer();

  // State for UI controls
  bool _baseLayerVisible = true;
  bool _highlightedVisible = false;
  bool _interactable = true;
  SBBPoiCategoryType? _selectedCategory;
  List<SBBPoiCategoryType> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    // When controller is available, fetch categories
    _poiController.future.then((controller) {
      setState(() {
        _availableCategories = controller.availablePOICategories;
      });
    });
  }

  void _toggleBaseLayer(bool value) async {
    final controller = await _poiController.future;
    setState(() => _baseLayerVisible = value);
    if (value) {
      controller.showPointsOfInterest(
        layer: SBBRokasPoiLayer.baseWithFloor,
        categories: _selectedCategory != null ? [_selectedCategory!] : null,
      );
    } else {
      controller.hidePointsOfInterest(layer: SBBRokasPoiLayer.baseWithFloor);
    }
  }

  void _toggleHighlightedLayer(bool value) async {
    final controller = await _poiController.future;
    setState(() => _highlightedVisible = value);
    if (value) {
      controller.showPointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
    } else {
      controller.hidePointsOfInterest(layer: SBBRokasPoiLayer.highlighted);
    }
  }

  void _onCategorySelected(SBBPoiCategoryType? category) async {
    final controller = await _poiController.future;
    setState(() => _selectedCategory = category);
    if (_baseLayerVisible) {
      controller.showPointsOfInterest(
        layer: SBBRokasPoiLayer.baseWithFloor,
        categories: category != null ? [category] : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapStyler = SBBRokasMapStyler.full(
      apiKey: Env.journeyMapsTilesApiKey,
      isDarkMode: Provider.of<ThemeProvider>(context).isDark,
    );
    return Scaffold(
      appBar: const SBBHeader(title: 'POI'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Base Layer'),
                    Switch(
                      value: _baseLayerVisible,
                      onChanged: _toggleBaseLayer,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Highlighted'),
                    Switch(
                      value: _highlightedVisible,
                      onChanged: _toggleHighlightedLayer,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Interactable'),
                    Switch(
                      value: _interactable,
                      onChanged: (v) => setState(() => _interactable = v),
                    ),
                  ],
                ),
                DropdownButton<SBBPoiCategoryType>(
                  hint: const Text('Category'),
                  value: _selectedCategory,
                  items: [
                    const DropdownMenuItem<SBBPoiCategoryType>(
                      value: null,
                      child: Text('All'),
                    ),
                    ..._availableCategories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        )),
                  ],
                  onChanged: _onCategorySelected,
                ),
              ],
            ),
          ),
          Expanded(
            child: SBBMap(
              initialCameraPosition: const SBBCameraPosition(
                target: LatLng(46.947456, 7.451123), // Bern
                zoom: 15.0,
              ),
              isMyLocationEnabled: true,
              mapStyler: mapStyler,
              poiSettings: SBBMapPOISettings(
                onPoiControllerAvailable: (poiController) {
                  if (!_poiController.isCompleted) _poiController.complete(poiController);
                  poiController.showPointsOfInterest();
                  setState(() {
                    _availableCategories = poiController.availablePOICategories;
                  });
                },
                onPoiSelected: _interactable
                    ? (poi) => showSBBModalSheet(
                          context: context,
                          title: poi.name,
                          child: const SizedBox(height: 64),
                        ).then((_) => _poiController.future.then((c) => c.deselectPointOfInterest()))
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
