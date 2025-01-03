import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import '../document/pdf_document_native.dart';

class PspdfkitFlutterWidgetControllerImpl
    implements
        PspdfkitWidgetController,
        PspdfkitWidgetCallbacks,
        NutrientEventsCallbacks {
  final PspdfkitWidgetControllerApi _pspdfkitWidgetControllerApi;
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;
  final PdfDocumentLoadFailedCallback? onPdfDocumentLoadFailed;
  final PageChangedCallback? onPdfPageChanged;
  final PdfDocumentSavedCallback? onPdfDocumentSaved;
  final PageClickedCallback? onPageClicked;
  final Map<NutrientEvent, Function(dynamic eventData)> _eventListeners = {};

  PspdfkitFlutterWidgetControllerImpl(
    this._pspdfkitWidgetControllerApi, {
    this.onPdfDocumentLoaded,
    this.onPdfDocumentLoadFailed,
    this.onPdfPageChanged,
    this.onPdfDocumentSaved,
    this.onPageClicked,
  });

  @override
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation) {
    return _pspdfkitWidgetControllerApi
        .addAnnotation(jsonEncode(jsonAnnotation));
  }

  @override
  Future<void> addEventListener(
      NutrientEvent event, Function(dynamic eventData) callback) {
    _eventListeners[event] = callback;
    return _pspdfkitWidgetControllerApi.addEventListener(event);
  }

  @override
  Future<void> removeEventListener(NutrientEvent event) {
    _eventListeners.remove(event);
    return _pspdfkitWidgetControllerApi.removeEventListener(event);
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    return _pspdfkitWidgetControllerApi.applyInstantJson(annotationsJson);
  }

  @override
  Future<String?> exportInstantJson() {
    return _pspdfkitWidgetControllerApi.exportInstantJson();
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) {
    return _pspdfkitWidgetControllerApi.exportXfdf(xfdfPath);
  }

  @override
  Future getAllUnsavedAnnotations() {
    return _pspdfkitWidgetControllerApi.getAllUnsavedAnnotations();
  }

  @override
  Future getAnnotations(int pageIndex, String type) {
    return _pspdfkitWidgetControllerApi.getAnnotations(pageIndex, type);
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return _pspdfkitWidgetControllerApi.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<Rect> getVisibleRect(int pageIndex) async {
    PdfRect rect = await _pspdfkitWidgetControllerApi.getVisibleRect(pageIndex);
    return Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height);
  }

  @override
  Future<double> getZoomScale(int pageIndex) {
    return _pspdfkitWidgetControllerApi.getZoomScale(pageIndex);
  }

  @override
  Future<bool?> importXfdf(String xfdfPath) {
    return _pspdfkitWidgetControllerApi.importXfdf(xfdfPath);
  }

  @override
  Future<bool?> processAnnotations(AnnotationType type,
      AnnotationProcessingMode processingMode, String destinationPath) {
    return _pspdfkitWidgetControllerApi.processAnnotations(
        type, processingMode, destinationPath);
  }

  @override
  Future<bool?> removeAnnotation(jsonAnnotation) {
    return _pspdfkitWidgetControllerApi.removeAnnotation(jsonAnnotation);
  }

  @override
  Future<bool?> save() {
    return _pspdfkitWidgetControllerApi.save();
  }

  @override
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations) {
    var config = configurations.map((key, value) {
      return MapEntry(key.name, value.toMap());
    });
    return _pspdfkitWidgetControllerApi.setAnnotationConfigurations(
        config.cast<String, Map<String, Object>>());
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _pspdfkitWidgetControllerApi.setFormFieldValue(
        value, fullyQualifiedName);
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) {
    return _pspdfkitWidgetControllerApi.zoomToRect(
        pageIndex,
        PdfRect(
            x: rect.left, y: rect.top, width: rect.width, height: rect.height),
        null,
        null);
  }

  @override
  void onDocumentError(String documentId, String error) {
    onPdfDocumentLoadFailed?.call(error);
  }

  @override
  void onDocumentLoaded(String documentId) {
    var methodChannel = MethodChannel('com.pspdfkit.document.$documentId');
    var api = PdfDocumentApi(
        binaryMessenger: methodChannel.binaryMessenger,
        messageChannelSuffix: documentId);

    onPdfDocumentLoaded
        ?.call(PdfDocumentNative(documentId: documentId, api: api));
  }

  @override
  void onPageChanged(String documentId, int pageIndex) {
    onPdfPageChanged?.call(pageIndex);
  }

  @override
  void onPageClick(
      String documentId, int pageIndex, PointF? point, Object? annotation) {
    onPageClicked?.call(documentId, pageIndex, point, annotation);
  }

  @override
  void onEvent(NutrientEvent event, Object? data) {
    if (_eventListeners.containsKey(event)) {
      _eventListeners[event]?.call(data);
    }
  }

  @override
  void onDocumentSaved(String documentId, String? path) {
    onPdfDocumentSaved?.call(documentId, path);
  }
}
