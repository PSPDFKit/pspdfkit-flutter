///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
// ignore_for_file: deprecated_member_use_from_same_package

library pspdfkit_widget_web;

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

@Deprecated('Use NutrientView instead')
class PspdfkitWidget extends StatelessWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;
  final PdfDocumentLoadFailedCallback? onPdfDocumentLoadFailure;
  final PageChangedCallback? onPageChanged;
  final PageClickedCallback? onPageClicked;
  final PdfDocumentSavedCallback? onPdfDocumentSaved;
  final List<CustomToolbarItem> customToolbarItems;
  final OnCustomToolbarItemTappedCallback? onCustomToolbarItemTapped;

  const PspdfkitWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onPspdfkitWidgetCreated,
    this.onPdfDocumentLoaded,
    this.onPdfDocumentLoadFailure,
    this.onPageChanged,
    this.onPageClicked,
    this.onPdfDocumentSaved,
    this.customToolbarItems = const [],
    this.onCustomToolbarItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NutrientView(
      documentPath: documentPath,
      configuration: configuration,
      onViewCreated: onPspdfkitWidgetCreated != null
          ? (controller) {
              onPspdfkitWidgetCreated!
                  .call(_LegacyControllerWrapper(controller));
            }
          : null,
      onDocumentLoaded: onPdfDocumentLoaded,
      onDocumentError: onPdfDocumentLoadFailure,
      onPageChanged: onPageChanged,
      onPageClicked: onPageClicked,
      onDocumentSaved: onPdfDocumentSaved,
      customToolbarItems: customToolbarItems,
      onCustomToolbarItemTapped: onCustomToolbarItemTapped,
    );
  }
}

/// Wraps a [NutrientViewController] to present the legacy
/// [PspdfkitWidgetController] interface.
@Deprecated('Use NutrientViewController instead')
class _LegacyControllerWrapper extends PspdfkitWidgetController {
  final NutrientViewController _delegate;

  _LegacyControllerWrapper(this._delegate);

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) =>
      throw UnimplementedError('Use PdfDocument.setFormFieldValue instead.');

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) =>
      throw UnimplementedError('Use PdfDocument.getFormFieldValue instead.');

  @override
  Future<bool?> applyInstantJson(String annotationsJson) =>
      throw UnimplementedError('Use PdfDocument.applyInstantJson instead.');

  @override
  Future<String?> exportInstantJson() =>
      throw UnimplementedError('Use PdfDocument.exportInstantJson instead.');

  @override
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation) =>
      throw UnimplementedError('Use PdfDocument.addAnnotation instead.');

  @override
  Future<bool?> removeAnnotation(dynamic jsonAnnotation) =>
      throw UnimplementedError('Use PdfDocument.removeAnnotation instead.');

  @override
  Future<dynamic> getAnnotations(int pageIndex, String type) =>
      throw UnimplementedError('Use PdfDocument.getAnnotations instead.');

  @override
  Future<dynamic> getAllUnsavedAnnotations() => throw UnimplementedError(
      'Use PdfDocument.getAllUnsavedAnnotations instead.');

  @override
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) =>
      _delegate.processAnnotations(type, processingMode, destinationPath);

  @override
  Future<bool?> importXfdf(String xfdfPath) => _delegate.importXfdf(xfdfPath);

  @override
  Future<bool?> exportXfdf(String xfdfPath) => _delegate.exportXfdf(xfdfPath);

  @override
  Future<bool?> save() => _delegate.save();

  @override
  Future<bool?> setAnnotationConfigurations(
    Map<AnnotationTool, AnnotationConfiguration> configurations,
  ) =>
      _delegate.setAnnotationConfigurations(configurations);

  @override
  Future<Rect> getVisibleRect(int pageIndex) =>
      _delegate.getVisibleRect(pageIndex);

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) =>
      _delegate.zoomToRect(pageIndex, rect);

  @override
  Future<double> getZoomScale(int pageIndex) =>
      _delegate.getZoomScale(pageIndex);

  @override
  Future<bool?> enterAnnotationCreationMode([AnnotationTool? annotationTool]) =>
      _delegate.enterAnnotationCreationMode(annotationTool);

  @override
  Future<bool?> exitAnnotationCreationMode() =>
      _delegate.exitAnnotationCreationMode();

  @override
  Future<void> addEventListener(
          NutrientEvent event, Function(dynamic) callback) =>
      _delegate.addEventListener(event, callback);

  @override
  Future<void> removeEventListener(NutrientEvent event) =>
      _delegate.removeEventListener(event);

  @override
  void addWebEventListener(
          NutrientWebEvent event, Function(dynamic) callback) =>
      _delegate.addWebEventListener(event, callback);

  @override
  void removeWebEventListener(
          NutrientWebEvent event, Function(dynamic) callback) =>
      _delegate.removeWebEventListener(event, callback);
}
