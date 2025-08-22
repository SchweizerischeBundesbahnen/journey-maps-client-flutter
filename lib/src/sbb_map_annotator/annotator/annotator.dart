// coverage:ignore-file
import 'package:flutter/foundation.dart';
import 'package:sbb_maps_flutter/sbb_maps_flutter.dart';

/// Annotate the [SBBMap] with [SBBMapAnnotation].
///
/// Be aware that the usage of [SBBRokasIcon] is restricted to being used while using a [SBBRokasMapStyler] style.
///
/// The annotations are added to different layers and are automatically re-added
/// if the style of the [SBBMap] changes.<br>Note that some annotations may not be available in a different style
/// since the are defined in the style's sprite sheet. These will be omitted.
abstract class SBBMapAnnotator {
  /// Allows using the image in the [SBBMapSymbol] annotations with the same
  /// id as [SBBMapSymbol.symbolURI].
  ///
  /// This must be called and awaited before adding the symbol using [addAnnotation].
  /// Calling this again with the same [imageId] will overwritte previously added images.
  ///
  /// For convenience, the image will be re-added when the style changes.
  ///
  /// Example: Adding an asset image and using it in a new symbol:
  /// ```dart
  /// Future<void> addImageFromAsset() async {
  ///   final ByteData bytes = await rootBundle.load("assets/someAssetImage.jpg");
  ///   final Uint8List list = bytes.buffer.asUint8List();
  ///   final String imageId = "myImageId"
  ///   await annotator.addImage(imageId: imageId, imageBytes: list);
  ///   final symbolAnnotation = SBBMapSymbol(symbolURI: imageId, coords: LatLng(0,0)))
  ///   await annotator.addAnnotation(symbolAnnotation)
  /// }
  /// ```
  ///
  /// Example: Adding a network image (with the http package) and using it in a new symbol:
  /// ```dart
  /// Future<void> addImageFromUrl() async{
  ///  var response = await get("https://example.com/image.png");
  ///  final String imageId = "myImageId"
  ///  await annotator.addImage(imageId, response.bodyBytes);
  ///  final symbolAnnotation = SBBMapSymbol(symbolURI: imageId, coords: LatLng(0,0)))
  ///  await annotator.addAnnotation(symbolAnnotation);
  /// }
  /// ```
  Future<void> addImage({required String imageId, required Uint8List imageBytes}) async {}

  /// Add an annotation to the [SBBMap].
  ///
  /// Use [addAnnotations] for adding large number of annotations.
  ///
  /// Will quietly fail if annotation is already added.<br>
  /// Use [updateAnnotation] to update added annotations.
  ///
  /// Should be awaited before interacting further with the map.
  Future<void> addAnnotation(SBBMapAnnotation annotation) async {}

  /// Add multiple annotations to the [SBBMap].
  ///
  /// For large number of annotations, this is much faster than calling
  /// [addAnnotation] individually.
  ///
  /// Will quietly fail if annotation is already added.<br>
  /// Use [updateAnnotation] to update added annotations.
  ///
  /// Should be awaited before interacting further with the map.
  Future<void> addAnnotations(Iterable<SBBMapAnnotation> annotations) async {}

  /// Update a [SBBMapAnnotation] in the [SBBMap].
  ///
  /// Will quietly fail if annotation has not been added.<br>
  /// Use [addAnnotation] to add the annotation first.
  ///
  /// Should be awaited before interacting further with the map.
  Future<void> updateAnnotation(SBBMapAnnotation annotation) async {}

  /// Update multiple [SBBMapAnnotation] in the [SBBMap].
  ///
  /// For large number of annotations, this is much faster than calling [updateAnnotation] individually.
  ///
  /// Will only update known annotations. Will quietly fail if all annotations are unknown.<br>
  /// Use [addAnnotation] to add the annotation first.
  ///
  /// Should be awaited before interacting further with the map.
  Future<void> updateAnnotations(Iterable<SBBMapAnnotation> annotations) async {}

  /// Remove a [SBBMapAnnotation] in the [SBBMap].
  ///
  /// Will quietly fail if annotation has not been added.<br>
  /// Use [addAnnotation] to add the annotation first.
  ///
  /// Should be awaited before interacting further with the map.
  Future<void> removeAnnotation(SBBMapAnnotation annotation) async {}

  /// Remove multiple [SBBMapAnnotation] in the [SBBMap].
  ///
  /// For large number of annotations, this is much faster than calling [removeAnnotation] individually.
  ///
  /// Will quietly fail for all unknown annotations.<br>
  /// Use [addAnnotation] to add the annotation first.
  ///
  /// Should be awaited before interacting further with the map.
  Future<void> removeAnnotations(Iterable<SBBMapAnnotation> annotation) async {}

  /// Register a callback for when a [SBBMapSymbol] is tapped.
  ///
  /// If null, it will remove the previously registered callback.
  void onSymbolTapped(void Function(SBBMapSymbol)? function) {}

  /// Register a callback for when a [SBBRokasIcon] is tapped.
  ///
  /// Note that this is not the ROKAS POIs which
  /// are embedded in the base ROKAS map style.<br>The callbacks
  /// are for [SBBRokasIcon] that were previously added with
  /// the [addAnnotations] or [addAnnotation] method.
  ///
  /// If null, it will remove the previously registered callback.
  void onRokasIconTapped(void Function(SBBRokasIcon)? function) {}

  /// Register a callback for when a [SBBMapCircle] is tapped.
  ///
  /// If null, it will remove the previously registered callback.
  void onCircleTapped(void Function(SBBMapCircle)? function) {}

  /// Register a callback for when a [SBBMapLine] is tapped.
  ///
  /// If null, it will remove the previously registered callback.
  void onLineTapped(void Function(SBBMapLine)? function) {}

  /// Register a callback for when a [SBBMapFill] is tapped.
  ///
  /// If null, it will remove the previously registered callback.
  void onFillTapped(void Function(SBBMapFill)? function) {}
}
