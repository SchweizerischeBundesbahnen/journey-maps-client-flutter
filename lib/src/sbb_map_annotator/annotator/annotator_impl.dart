import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

const _kSourceId = 'sbb_map_annotations';
const _kSymbolIdentifier = 'sbb_map_annotator_symbol';
const _kRokasIconIdentifier = 'sbb_map_annotator_rokas_icon';
const _kCircleIdentifier = 'sbb_map_annotator_circle';
const _kLineIdentifier = 'sbb_map_annotator_line';
const _kFillIdentifier = 'sbb_map_annotator_fill';

typedef Layer = ({String layerId, LayerProperties properties, List<Object>? filter});

class SBBMapAnnotatorImpl implements SBBMapAnnotator {
  final MapLibreMapController _controller;
  Map<String, SBBMapAnnotation> _idToAnnotation = {};
  final _addedLayers = <String, Layer>{};
  final _annotationTappedCallbacks = <String, dynamic>{};
  final _addedImages = <String, Uint8List>{};
  Completer<void>? _geoJsonAddingOperation;

  bool _isGeoJsonSourceAdded = false;

  SBBMapAnnotatorImpl({required MapLibreMapController controller}) : _controller = controller {
    _controller.onFeatureTapped.add(_delegateToAnnotationCallback());
  }

  @override
  Future<void> addImage({required String imageId, required Uint8List imageBytes}) {
    if (imageBytes.isEmpty) return Future.value();
    _addedImages[imageId] = imageBytes;

    return _controller.addImage(imageId, imageBytes);
  }

  @override
  Future<void> addAnnotation(SBBMapAnnotation annotation) async {
    return addAnnotations([annotation]);
  }

  @override
  Future<void> addAnnotations(Iterable<SBBMapAnnotation> annotations) async {
    final newAnnotations = annotations.where(_isNotKnown);
    if (newAnnotations.isEmpty) return;

    if (!_isGeoJsonSourceAdded) await _addGeoJsonSource();
    return _addAnnotationsToLayer(newAnnotations);
  }

  @override
  Future<void> updateAnnotation(SBBMapAnnotation annotation) async {
    return updateAnnotations([annotation]);
  }

  @override
  Future<void> updateAnnotations(Iterable<SBBMapAnnotation> annotations) async {
    final knownAnnotations = annotations.where(_isKnown);
    if (knownAnnotations.isEmpty) return;
    return _updateAll(knownAnnotations);
  }

  @override
  Future<void> removeAnnotation(SBBMapAnnotation annotation) async {
    return removeAnnotations([annotation]);
  }

  @override
  Future<void> removeAnnotations(Iterable<SBBMapAnnotation> annotations) async {
    final knownAnnotations = annotations.where(_isKnown);
    if (knownAnnotations.isEmpty) return;
    return _removeAll(annotations);
  }

  @override
  void onSymbolTapped(void Function(SBBMapSymbol)? function) {
    _addOrRemoveCallbacks(function, _kSymbolIdentifier);
  }

  @override
  void onRokasIconTapped(void Function(SBBRokasIcon)? function) {
    _addOrRemoveCallbacks(function, _kRokasIconIdentifier);
  }

  @override
  void onCircleTapped(void Function(SBBMapCircle)? function) {
    _addOrRemoveCallbacks(function, _kCircleIdentifier);
  }

  @override
  void onLineTapped(void Function(SBBMapLine)? function) {
    _addOrRemoveCallbacks(function, _kLineIdentifier);
  }

  @override
  void onFillTapped(void Function(SBBMapFill)? function) {
    _addOrRemoveCallbacks(function, _kFillIdentifier);
  }

  void _addOrRemoveCallbacks(dynamic function, String identifier) {
    if (function == null) {
      _annotationTappedCallbacks.remove(identifier);
    } else {
      _annotationTappedCallbacks[identifier] = function;
    }
  }

  /// Called by [SBBMap] when disposed.
  Future<void> dispose() async {
    // Workaround, since function equality
    // only works for static and top-level functions.
    // See https://dart.dev/language/functions#testing-functions-for-equality
    _controller.onFeatureTapped.clear();

    // the below methods ends in exceptions on Android
    // https://github.com/maplibre/flutter-maplibre-gl/issues/526
    if (Platform.isAndroid) return;

    if (_addedLayers.isNotEmpty) {
      for (final layerId in _addedLayers.keys) {
        await _controller.removeLayer(layerId);
      }
    }
    if (_isGeoJsonSourceAdded) {
      await _controller.removeSource(_kSourceId);
    }
  }

  // Called by [SBBMap] when style changes.
  Future<void> onStyleChanged() async {
    if (!_isGeoJsonSourceAdded && _addedImages.isEmpty) return;
    _geoJsonAddingOperation = null;
    await _addGeoJsonSource();
    await _reAddImages();
    await _reInsertLayers();
    return _updateAll([]);
  }

  Future<void> _addGeoJsonSource() async {
    if (_geoJsonAddingOperation != null) return _geoJsonAddingOperation!.future;

    _geoJsonAddingOperation = Completer<void>();
    return _controller
        .addGeoJsonSource(_kSourceId, buildFeatureCollection([]))
        .catchError(_throwAnnotatorException('Adding geoJsonSource $_kSourceId failed with exception: '))
        .then(_completeGeoJsonAdding());
  }

  Future<void> _addAnnotationsToLayer(Iterable<SBBMapAnnotation> annotations) async {
    await _addLayersIfNecessary(annotations);
    return _updateAll(annotations);
  }

  Future<void> _addLayersIfNecessary(Iterable<SBBMapAnnotation> annotations) async {
    for (final a in annotations) {
      final layerId = _getAnnotationIdentifier(a);
      if (_addedLayers.keys.contains(layerId)) continue;
      final Layer layer = (layerId: layerId, properties: _getLayerProperties(a), filter: a.annotationFilter);

      await _applyLayerToStyle(layer);
    }
  }

  Future<void> _applyLayerToStyle(Layer layer) {
    return _controller
        .addLayer(_kSourceId, layer.layerId, layer.properties, filter: layer.filter)
        .catchError(_throwAnnotatorException('Adding layer ${layer.layerId} failed with exception: '))
        .then((_) => _addedLayers[layer.layerId] = layer);
  }

  String _getAnnotationIdentifier(SBBMapAnnotation annotation) => switch (annotation) {
    SBBMapSymbol() => _kSymbolIdentifier,
    SBBRokasIcon() => _kRokasIconIdentifier,
    SBBMapCircle() => _kCircleIdentifier,
    SBBMapLine() => _kLineIdentifier,
    SBBMapFill() => _kFillIdentifier,
  };

  LayerProperties _getLayerProperties(SBBMapAnnotation annotation) => switch (annotation) {
    SBBMapSymbol() => SBBMapSymbolLayer().makeLayerExpressions(),
    SBBRokasIcon() => SBBMapSymbolLayer().makeLayerExpressions(),
    SBBMapCircle() => SBBMapCircleLayer().makeLayerExpressions(),
    SBBMapLine() => SBBMapLineLayer().makeLayerExpressions(),
    SBBMapFill() => SBBMapFillLayer().makeLayerExpressions(),
  };

  Future<void> _updateAll(Iterable<SBBMapAnnotation> updates) {
    final updatedIdToAnnotations = _applyUpdatesToCopiedMap(updates);
    return _applyFeaturesToGeoSource(updatedIdToAnnotations);
  }

  Future<void> _removeAll(Iterable<SBBMapAnnotation> deletions) {
    final updatedIdToAnnotations = _applyRemovalToCopiedMap(deletions);
    return _applyFeaturesToGeoSource(updatedIdToAnnotations);
  }

  Future<void> _applyFeaturesToGeoSource(Map<String, SBBMapAnnotation> updatedIdToAnnotations) {
    final annotationsAsFeatures = buildFeatureCollection([
      for (final a in updatedIdToAnnotations.values) a.toGeoJson(),
    ]);

    return _controller
        .setGeoJsonSource(_kSourceId, annotationsAsFeatures)
        .catchError(_throwAnnotatorException('Unexpected error applying changes to annotations: '))
        .then((_) => _idToAnnotation = updatedIdToAnnotations);
  }

  Never Function(dynamic e) _throwAnnotatorException(String msg) =>
      (e) => throw AnnotationException('$msg $e');

  bool _isKnown(SBBMapAnnotation annotation) {
    return _idToAnnotation.containsKey(annotation.id);
  }

  bool _isNotKnown(SBBMapAnnotation annotation) {
    return !_isKnown(annotation);
  }

  Map<String, SBBMapAnnotation> _applyUpdatesToCopiedMap(Iterable<SBBMapAnnotation> updates) {
    final copy = Map<String, SBBMapAnnotation>.from(_idToAnnotation);
    copy.addAll({for (final a in updates) a.id: a});
    return copy;
  }

  Map<String, SBBMapAnnotation> _applyRemovalToCopiedMap(Iterable<SBBMapAnnotation> removals) {
    final copy = Map<String, SBBMapAnnotation>.from(_idToAnnotation);
    final Iterable<String> idsToRemove = removals.map((a) => a.id);

    copy.removeWhere((k, v) => idsToRemove.contains(k));
    return copy;
  }

  Future<void> _reAddImages() async {
    for (final imageEntry in _addedImages.entries) {
      await _controller.addImage(imageEntry.key, imageEntry.value);
    }
  }

  Future<void> _reInsertLayers() async {
    final layerCopy = Map<String, Layer>.from(_addedLayers);
    for (var entry in layerCopy.values) {
      await _applyLayerToStyle(entry);
    }
  }

  OnFeatureInteractionCallback _delegateToAnnotationCallback() {
    return (point, coordinates, id, layerId, _) {
      if (_annotationTappedCallbacks.isEmpty) return; // no callbacks registered
      if (_idToAnnotation.isEmpty) return; // empty annotation cannot be clicked

      final annotation = _idToAnnotation[id];
      if (annotation == null) return; // unknown feature was clicked

      final key = _getAnnotationIdentifier(annotation);
      _annotationTappedCallbacks[key]?.call(annotation);
    };
  }

  FutureOr<void> Function(void value) _completeGeoJsonAdding() {
    return (_) {
      _geoJsonAddingOperation?.complete();
      _isGeoJsonSourceAdded = true;
    };
  }
}
