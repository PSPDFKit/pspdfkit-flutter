///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/annotations/annotation_utils.dart';
import 'package:nutrient_flutter/src/bookmarks/bookmark_manager_native.dart';
import 'package:nutrient_flutter/src/document/annotation_json_converter.dart';
import 'package:nutrient_flutter/src/document/annotation_manager_native.dart';

class PdfDocumentNative extends PdfDocument with AnnotationJsonConverter {
  late final PdfDocumentApi _api;
  AnnotationManagerNative? _annotationManagerInstance;
  BookmarkManagerNative? _bookmarkManagerInstance;

  PdfDocumentNative({required super.documentId, required PdfDocumentApi api}) {
    _api = api;
  }

  AnnotationManagerNative get _annotationManager {
    _annotationManagerInstance ??=
        AnnotationManagerNative(documentId: documentId);
    return _annotationManagerInstance!;
  }

  BookmarkManagerNative get _bookmarkManager {
    _bookmarkManagerInstance ??= BookmarkManagerNative(documentId: documentId);
    return _bookmarkManagerInstance!;
  }

  @override
  Future<PageInfo> getPageInfo(int pageIndex) {
    try {
      return _api.getPageInfo(pageIndex);
    } catch (e) {
      debugPrint('Error getting page info: $e');
      throw Exception('Error getting page info: $e');
    }
  }

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) {
    try {
      return _api.exportPdf(options);
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      throw Exception('Error exporting PDF: $e');
    }
  }

  @override
  Future<PdfFormField> getFormField(String fieldName) {
    return _api.getFormFieldJson(fieldName).then((jsonString) {
      final result = jsonDecode(jsonString) as Map<String, dynamic>;
      return PdfFormField.fromMap(result);
    }).catchError((error) {
      throw Exception('Error getting form field: $error');
    });
  }

  @override
  Future<List<PdfFormField>> getFormFields() {
    return _api.getFormFieldsJson().then((jsonString) {
      final results = jsonDecode(jsonString) as List<dynamic>;
      return results
          .map((result) =>
              PdfFormField.fromMap(Map<String, dynamic>.from(result as Map)))
          .toList();
    }).catchError((error) {
      throw Exception('Error getting form fields: $error');
    });
  }

  @override
  Future<bool?> addAnnotation(dynamic annotation,
      [Map<String, dynamic>? attachment]) {
    var jsonAnnotation = jsonEncode(annotation);
    Map<String, dynamic>? jsonAttachment;

    if (annotation is Annotation && annotation is HasAttachment) {
      jsonAttachment = (annotation as HasAttachment).attachment?.toJson();
    }

    // Only encode attachment if it's not null, otherwise pass null directly
    final attachmentParam =
        jsonAttachment != null ? jsonEncode(jsonAttachment) : null;
    return _api.addAnnotation(jsonAnnotation, attachmentParam);
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    return _api.applyInstantJson(annotationsJson);
  }

  @override
  Future<String?> exportInstantJson() {
    return _api.exportInstantJson();
  }

  @override
  Future<bool> exportXfdf(String xfdfPath) {
    return _api.exportXfdf(xfdfPath);
  }

  @override
  Future<Object> getAllUnsavedAnnotations() {
    return _api.getAllUnsavedAnnotationsJson();
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    var jsonString = await _api.getAnnotationsJson(pageIndex, type.fullName);
    var results = jsonDecode(jsonString) as List<dynamic>;

    List<Annotation> annotations = [];
    for (var element in results) {
      if (element is Map) {
        if (element['type'] == null || element['type'] == '') {
          continue;
        }
        var annotationJSON = Map<String, dynamic>.from(element);
        annotations.add(Annotation.fromJson(annotationJSON));
      }
    }
    return annotations;
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return _api.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool> importXfdf(String xfdfString) {
    return _api.importXfdf(xfdfString);
  }

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) {
    return _api.save(outputPath, options);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _api.setFormFieldValue(value, fullyQualifiedName);
  }

  @override
  Future<bool?> updateAnnotation(Annotation annotation) {
    var annotationJSON = jsonEncode(annotation.toJson());
    return _api.updateAnnotation(annotationJSON);
  }

  @override
  Future<bool?> addAnnotations(List<Annotation> annotations) {
    var annotationJSON = annotationsToInstantJSON(annotations);
    return _api.applyInstantJson(annotationJSON);
  }

  @override
  Future getAnnotationsAsJson(int pageIndex, AnnotationType type) {
    return _api.getAnnotationsJson(pageIndex, type.fullName).then((jsonString) {
      var results = jsonDecode(jsonString) as List<dynamic>;
      return results.map((result) {
        return Map<String, dynamic>.from(result as Map);
      }).toList();
    }).catchError((error) {
      throw Exception('Error getting annotations: $error');
    });
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() {
    return _api.getAllUnsavedAnnotationsJson().then((jsonString) {
      var results = jsonDecode(jsonString);
      if (results is Map) {
        return AnnotationUtils.annotationsFromInstantJSON(
            Map<String, dynamic>.from(results));
      } else {
        return [];
      }
    });
  }

  @override
  Future<bool?> removeAnnotation(annotation) async {
    var annotationJSON = convertAnnotationToJson(annotation);
    return _api.removeAnnotation(annotationJSON);
  }

  @override
  Future<int> getPageCount() {
    return _api.getPageCount();
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
    try {
      return await _api.processAnnotations(
          type, processingMode, destinationPath);
    } catch (e) {
      debugPrint('Error processing annotations: $e');
      throw Exception('Error processing annotations: $e');
    }
  }

  // ============================
  // Document Lifecycle Methods
  // ============================

  @override
  bool get isHeadless => false;

  @override
  Future<bool> close() async {
    // For viewer-bound documents, lifecycle is managed by the view.
    // This is a no-op for compatibility.
    return true;
    // Bookmark Methods
    // ============================
  }

  @override
  Future<List<Bookmark>> getBookmarks() async {
    return _bookmarkManager.getBookmarks();
  }

  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    return _bookmarkManager.addBookmark(bookmark);
  }

  @override
  Future<bool> removeBookmark(Bookmark bookmark) async {
    return _bookmarkManager.removeBookmark(bookmark);
  }

  @override
  Future<bool> updateBookmark(Bookmark bookmark) async {
    return _bookmarkManager.updateBookmark(bookmark);
  }

  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    return _bookmarkManager.getBookmarksForPage(pageIndex);
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    return _bookmarkManager.hasBookmarkForPage(pageIndex);
  }

  // ============================
  // Document Dirty State - Cross-Platform
  // ============================

  @override
  Future<bool> hasUnsavedChanges() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iOSHasDirtyAnnotations();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final annotationChanges = await androidHasUnsavedAnnotationChanges();
      final formChanges = await androidHasUnsavedFormChanges();
      final bookmarkChanges = await androidHasUnsavedBookmarkChanges();
      return annotationChanges || formChanges || bookmarkChanges;
    }
    return false;
  }

  // ============================
  // Document Dirty State - iOS Specific
  // ============================

  @override
  Future<bool> iOSHasDirtyAnnotations() {
    return _api.iOSHasDirtyAnnotations();
  }

  @override
  Future<bool> iOSGetAnnotationIsDirty(int pageIndex, String annotationId) {
    return _api.iOSGetAnnotationIsDirty(pageIndex, annotationId);
  }

  @override
  Future<bool> iOSSetAnnotationIsDirty(
      int pageIndex, String annotationId, bool isDirty) {
    return _api.iOSSetAnnotationIsDirty(pageIndex, annotationId, isDirty);
  }

  @override
  Future<bool> iOSClearNeedsSaveFlag() {
    return _api.iOSClearNeedsSaveFlag();
  }

  // ============================
  // Document Dirty State - Android Specific
  // ============================

  @override
  Future<bool> androidHasUnsavedAnnotationChanges() {
    return _api.androidHasUnsavedAnnotationChanges();
  }

  @override
  Future<bool> androidHasUnsavedFormChanges() {
    return _api.androidHasUnsavedFormChanges();
  }

  @override
  Future<bool> androidHasUnsavedBookmarkChanges() {
    return _api.androidHasUnsavedBookmarkChanges();
  }

  @override
  Future<bool> androidGetBookmarkIsDirty(String bookmarkId) {
    return _api.androidGetBookmarkIsDirty(bookmarkId);
  }

  @override
  Future<bool> androidClearBookmarkDirtyState(String bookmarkId) {
    return _api.androidClearBookmarkDirtyState(bookmarkId);
  }

  @override
  Future<bool> androidGetFormFieldIsDirty(String fullyQualifiedName) {
    return _api.androidGetFormFieldIsDirty(fullyQualifiedName);
  }

  // ============================
  // Document Dirty State - Web Specific
  // ============================

  @override
  Future<bool> webHasUnsavedChanges() {
    return _api.webHasUnsavedChanges();
  }
}
