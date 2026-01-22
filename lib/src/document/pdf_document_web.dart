///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/document/annotation_json_converter.dart';
import 'package:nutrient_flutter/src/document/annotation_manager_web.dart';

import '../annotations/annotation_utils.dart';
import '../web/nutrient_web_instance.dart';

class PdfDocumentWeb extends PdfDocument with AnnotationJsonConverter {
  final NutrientWebInstance _instance;
  AnnotationManagerWeb? _annotationManagerInstance;

  PdfDocumentWeb(
      {required super.documentId, required NutrientWebInstance instance})
      : _instance = instance;

  AnnotationManagerWeb get _annotationManager {
    if (_annotationManagerInstance == null) {
      _annotationManagerInstance = AnnotationManagerWeb(documentId: documentId);
      _annotationManagerInstance!.setWebInstance(_instance);
    }
    return _annotationManagerInstance!;
  }

  @override
  Future<PageInfo> getPageInfo(int pageIndex) {
    return _instance.getPageInfo(pageIndex);
  }

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) {
    return _instance.exportPdf(options: options);
  }

  @override
  Future<PdfFormField> getFormField(String fieldName) {
    throw UnimplementedError();
  }

  @override
  Future<List<PdfFormField>> getFormFields() {
    return _instance.getFormFields();
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    return _instance
        .applyInstantJson(jsonDecode(annotationsJson))
        .then((value) => true);
  }

  @override
  Future<String?> exportInstantJson() {
    return _instance.exportInstantJson().then((value) => jsonEncode(value));
  }

  @override
  Future<bool> exportXfdf(String xfdfPath) {
    return _instance.exportXfdf(xfdfPath).then((value) => true);
  }

  @Deprecated('User getUnsavedAnnotations instead.')
  @override
  Future<Object> getAllUnsavedAnnotations() async {
    var instantJSON = await _instance.getAllAnnotations();
    return instantJSON;
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    var annotationsJSON =
        await _instance.getAnnotations(pageIndex, type.fullName);
    List<Annotation> annotations = [];
    if (annotationsJSON is List) {
      for (var i = 0; i < annotationsJSON.length; i++) {
        annotations.add(Annotation.fromJson(annotationsJSON[i]));
      }
    }
    return annotations;
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return _instance.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool> importXfdf(String xfdfString) {
    return _instance.importXfdf(xfdfString).then((value) => true);
  }

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) {
    return _instance.save().then((value) => true);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _instance
        .setFormFieldValue(value, fullyQualifiedName)
        .then((value) => true);
  }

  @override
  @override
  Future<bool?> updateAnnotation(Annotation annotation) {
    return _instance
        .updateAnnotation(annotation.toJson())
        .then((value) => true);
  }

  @override
  Future<bool?> addAnnotations(List<Annotation> annotations) {
    var annotationJSON = annotationsToInstantJSON(annotations);
    return _instance.applyInstantJson(annotationJSON).then((value) => true);
  }

  @override
  Future getAnnotationsAsJson(int pageIndex, AnnotationType type) async {
    return _instance
        .getAnnotations(pageIndex, type.fullName)
        .then((value) => value);
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    var instantJSON = await _instance.getAllAnnotations();

    /// This returns instant JSON, so parse it into a list of annotations using
    /// [AnnotationUtils.annotationsFromInstantJSON].
    return AnnotationUtils.annotationsFromInstantJSON(instantJSON);
  }

  @override
  Future<bool?> removeAnnotation(dynamic annotation) {
    return _instance
        .removeAnnotation(convertAnnotationToJson(annotation))
        .then((value) => true);
  }

  @override
  Future<bool?> addAnnotation(annotation, [Map<String, dynamic>? attachment]) {
    return _instance
        .addAnnotation(
            jsonDecode(convertAnnotationToJson(jsonDecode(annotation))),
            attachment)
        .then((value) => true);
  }

  @override
  Future<int> getPageCount() {
    return _instance.getPageCount();
  }

  // ============================
  // Annotation Management Methods
  // ============================

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    return _annotationManager.getAnnotationProperties(pageIndex, annotationId);
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    return _annotationManager.saveAnnotationProperties(properties);
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query,
      [int? pageIndex]) async {
    return _annotationManager.searchAnnotations(query, pageIndex);
  }

  // ============================
  // Annotation Processing Methods
  // ============================

  @override
  Future<bool> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) async {
    // Web platform annotation processing is not fully supported in headless mode.
    // For viewer-bound documents, use the NutrientViewController.processAnnotations method.
    throw UnimplementedError(
        'processAnnotations is not yet supported on web platform in headless mode');
  }

  // ============================
  // Document Lifecycle Methods
  // ============================

  @override
  bool get isHeadless => false;

  @override
  Future<bool> close() async {
    // For viewer-bound web documents, lifecycle is managed by the view.
    // This is a no-op for compatibility.
    return true;
    // Bookmark Methods
    // ============================
  }

  @override
  Future<List<Bookmark>> getBookmarks() {
    return _instance.getBookmarks();
  }

  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) {
    return _instance.addBookmark(bookmark);
  }

  @override
  Future<bool> removeBookmark(Bookmark bookmark) {
    return _instance.removeBookmark(bookmark);
  }

  @override
  Future<bool> updateBookmark(Bookmark bookmark) {
    return _instance.updateBookmark(bookmark);
  }

  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) {
    return _instance.getBookmarksForPage(pageIndex);
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) {
    return _instance.hasBookmarkForPage(pageIndex);
  }

  // ============================
  // Document Dirty State - Cross-Platform
  // ============================

  @override
  Future<bool> hasUnsavedChanges() {
    return _instance.hasUnsavedChanges();
  }

  // ============================
  // Document Dirty State - iOS Specific (Not supported on Web)
  // ============================

  @override
  Future<bool> iOSHasDirtyAnnotations() {
    throw UnsupportedError(
        'iOSHasDirtyAnnotations is only available on iOS. Use webHasUnsavedChanges() on Web.');
  }

  @override
  Future<bool> iOSGetAnnotationIsDirty(int pageIndex, String annotationId) {
    throw UnsupportedError(
        'iOSGetAnnotationIsDirty is only available on iOS. Web does not support per-annotation dirty state.');
  }

  @override
  Future<bool> iOSSetAnnotationIsDirty(
      int pageIndex, String annotationId, bool isDirty) {
    throw UnsupportedError(
        'iOSSetAnnotationIsDirty is only available on iOS. Web does not support per-annotation dirty state.');
  }

  @override
  Future<bool> iOSClearNeedsSaveFlag() {
    throw UnsupportedError(
        'iOSClearNeedsSaveFlag is only available on iOS. Web does not support clearing the needs-save flag.');
  }

  // ============================
  // Document Dirty State - Android Specific (Not supported on Web)
  // ============================

  @override
  Future<bool> androidHasUnsavedAnnotationChanges() {
    throw UnsupportedError(
        'androidHasUnsavedAnnotationChanges is only available on Android. Use webHasUnsavedChanges() on Web.');
  }

  @override
  Future<bool> androidHasUnsavedFormChanges() {
    throw UnsupportedError(
        'androidHasUnsavedFormChanges is only available on Android. Use webHasUnsavedChanges() on Web.');
  }

  @override
  Future<bool> androidHasUnsavedBookmarkChanges() {
    throw UnsupportedError(
        'androidHasUnsavedBookmarkChanges is only available on Android. Use webHasUnsavedChanges() on Web.');
  }

  @override
  Future<bool> androidGetBookmarkIsDirty(String bookmarkId) {
    throw UnsupportedError(
        'androidGetBookmarkIsDirty is only available on Android. Web does not support per-bookmark dirty state.');
  }

  @override
  Future<bool> androidClearBookmarkDirtyState(String bookmarkId) {
    throw UnsupportedError(
        'androidClearBookmarkDirtyState is only available on Android. Web does not support clearing bookmark dirty state.');
  }

  @override
  Future<bool> androidGetFormFieldIsDirty(String fullyQualifiedName) {
    throw UnsupportedError(
        'androidGetFormFieldIsDirty is only available on Android. Web does not support per-field dirty state.');
  }

  // ============================
  // Document Dirty State - Web Specific
  // ============================

  @override
  Future<bool> webHasUnsavedChanges() {
    return _instance.hasUnsavedChanges();
  }
}
