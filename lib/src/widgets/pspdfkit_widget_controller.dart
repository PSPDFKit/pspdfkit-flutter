///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/painting.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// A controller for a PSPDFKit widget.
///
/// @deprecated Use [NutrientViewController] instead.
@Deprecated('Use NutrientViewController instead')
abstract class PspdfkitWidgetController {
  /// Sets the value of a form field by specifying its fully qualified field name.
  @Deprecated('Use [PdfDocument.setFormFieldValue] instead.')
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  @Deprecated('Use [PdfDocument.getFormFieldValue] instead.')
  Future<String?> getFormFieldValue(String fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  @Deprecated('Use [PdfDocument.applyInstantJson] instead.')
  Future<bool?> applyInstantJson(String annotationsJson);

  /// Exports Instant document JSON from the presented document.
  @Deprecated('Use [PdfDocument.exportInstantJson] instead.')
  Future<String?> exportInstantJson();

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @Deprecated('Use [PdfDocument.addAnnotation] instead.')
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @Deprecated('Use [PdfDocument.removeAnnotation] instead.')
  Future<bool?> removeAnnotation(dynamic jsonAnnotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  @Deprecated('Use [PdfDocument.getAnnotations] instead.')
  Future<dynamic> getAnnotations(int pageIndex, String type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @Deprecated('Use [PdfDocument.getAllUnsavedAnnotations] instead.')
  Future<dynamic> getAllUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  );

  /// Imports annotations from the XFDF file at the given path.
  @Deprecated('Use [PdfDocument.importXfdf] instead.')
  Future<bool?> importXfdf(String xfdfPath);

  /// Exports annotations to the XFDF file at the given path.
  @Deprecated('Use [PdfDocument.exportXfdf] instead.')
  Future<bool?> exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  @Deprecated('Use [PdfDocument.save] instead.')
  Future<bool?> save();

  /// Sets the annotation preset configurations for the given annotation tools.
  /// @param configurations A map of annotation tools and their corresponding configurations.
  /// @param modifyAssociatedAnnotations Whether to modify the annotations associated with the old configuration. Only used for Android.
  /// @return True if the configurations were set successfully, false otherwise.
  Future<bool?> setAnnotationConfigurations(
    Map<AnnotationTool, AnnotationConfiguration> configurations,
  );

  /// Adds an event listener for the given event.
  /// @param event. The event to listen for.
  Future<void> addEventListener(
      NutrientEvent event, Function(dynamic) callback);

  /// This method allow you to support all events from the Nutrient Web SDK. See the [NutrientWebEvent] enum for a list of available events.
  /// Also check out the web events API reference for more information: https://www.nutrient.io/guides/web/events/
  /// @param event. The event to listen for.
  /// @param callback. The callback to be called when the event is triggered.
  void addWebEventListener(NutrientWebEvent event, Function(dynamic) callback);

  /// Removes an event listener for the given event.
  /// @param event. The event to remove the listener for.
  Future<void> removeEventListener(NutrientEvent event);

  /// Removes a web event listener for the given event.
  /// @param event. The event to remove the listener for.
  /// @param callback. The callback function that was originally added.
  void removeWebEventListener(
      NutrientWebEvent event, Function(dynamic) callback);

  /// Gets the visible rect of the given page.
  /// pageIndex The index of the page. This is a zero-based index.
  /// Returns a [Future] that completes with the visible rect of the given page.
  Future<Rect> getVisibleRect(int pageIndex);

  /// Zooms to the given rect on the given page.
  /// pageIndex The index of the page. This is a zero-based index.
  /// rect The rect to zoom to.
  /// Returns a [Future] that completes when the zoom operation is done.
  Future<void> zoomToRect(int pageIndex, Rect rect);

  /// Gets the zoom scale of the given page.
  /// pageIndex The index of the page. This is a zero-based index.
  /// Returns a [Future] that completes with the zoom scale of the given page.
  Future<double> getZoomScale(int pageIndex);

  /// Enters annotation creation mode.
  ///
  /// If [annotationTool] is provided, that specific tool will be activated.
  /// If no tool is provided, the default annotation tool will be used.
  ///
  /// Returns a [Future] that completes with a boolean indicating whether
  /// entering annotation creation mode was successful.
  Future<bool?> enterAnnotationCreationMode([AnnotationTool? annotationTool]);

  /// Exits annotation creation mode.
  ///
  /// Returns a [Future] that completes with a boolean indicating whether
  /// exiting annotation creation mode was successful.
  Future<bool?> exitAnnotationCreationMode();
}
