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
import 'package:nutrient_flutter/src/document/annotation_json_converter.dart';
import 'package:nutrient_flutter/src/document/annotation_manager_native.dart';
import 'package:nutrient_flutter/src/bookmarks/bookmark_manager_native.dart';

/// A headless PDF document implementation that doesn't require a viewer.
///
/// This class provides programmatic access to PDF documents for operations like:
/// - Reading and modifying annotations
/// - Processing annotations (flatten, embed, remove)
/// - Copying annotations between documents
/// - Exporting/importing XFDF
/// - Form field manipulation
///
/// Documents created through this class must be explicitly closed using [close]
/// to release native resources.
class HeadlessPdfDocumentNative extends PdfDocument
    with AnnotationJsonConverter {
  final PdfDocumentApi _api;
  AnnotationManagerNative? _annotationManagerInstance;
  BookmarkManagerNative? _bookmarkManagerInstance;
  bool _isClosed = false;

  HeadlessPdfDocumentNative({
    required super.documentId,
    required PdfDocumentApi api,
  }) : _api = api;

  AnnotationManagerNative get _annotationManager {
    _annotationManagerInstance ??=
        AnnotationManagerNative(documentId: documentId);
    return _annotationManagerInstance!;
  }

  BookmarkManagerNative get _bookmarkManager {
    _bookmarkManagerInstance ??= BookmarkManagerNative(documentId: documentId);
    return _bookmarkManagerInstance!;
  }

  void _ensureNotClosed() {
    if (_isClosed) {
      throw StateError(
          'Document has been closed. Create a new document instance to continue.');
    }
  }

  @override
  bool get isHeadless => true;

  @override
  Future<PageInfo> getPageInfo(int pageIndex) {
    _ensureNotClosed();
    try {
      return _api.getPageInfo(pageIndex);
    } catch (e) {
      debugPrint('Error getting page info: $e');
      throw Exception('Error getting page info: $e');
    }
  }

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) {
    _ensureNotClosed();
    try {
      return _api.exportPdf(options);
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      throw Exception('Error exporting PDF: $e');
    }
  }

  @override
  Future<PdfFormField> getFormField(String fieldName) {
    _ensureNotClosed();
    return _api.getFormFieldJson(fieldName).then((jsonString) {
      final result = jsonDecode(jsonString) as Map<String, dynamic>;
      return PdfFormField.fromMap(result);
    }).catchError((error) {
      throw Exception('Error getting form field: $error');
    });
  }

  @override
  Future<List<PdfFormField>> getFormFields() {
    _ensureNotClosed();
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
    _ensureNotClosed();
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
    _ensureNotClosed();
    return _api.applyInstantJson(annotationsJson);
  }

  @override
  Future<String?> exportInstantJson() {
    _ensureNotClosed();
    return _api.exportInstantJson();
  }

  @override
  Future<bool> exportXfdf(String xfdfPath) {
    _ensureNotClosed();
    return _api.exportXfdf(xfdfPath);
  }

  @override
  Future<Object> getAllUnsavedAnnotations() {
    _ensureNotClosed();
    return _api.getAllUnsavedAnnotationsJson();
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    _ensureNotClosed();
    var jsonString = await _api.getAnnotationsJson(pageIndex, type.fullName);
    var results = jsonDecode(jsonString) as List<dynamic>;

    List<Annotation> annotations = [];
    for (var element in results) {
      try {
        if (element is Map) {
          if (element['type'] == null || element['type'] == '') {
            continue;
          }
          var annotationJSON = Map<String, dynamic>.from(element);
          annotations.add(Annotation.fromJson(annotationJSON));
        }
      } catch (e) {
        // Skip annotations that can't be parsed - this can happen if the
        // native SDK returns incomplete JSON for certain annotation types
        debugPrint('Failed to parse annotation: $e');
      }
    }
    return annotations;
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    _ensureNotClosed();
    return _api.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool> importXfdf(String xfdfString) {
    _ensureNotClosed();
    return _api.importXfdf(xfdfString);
  }

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) {
    _ensureNotClosed();
    return _api.save(outputPath, options);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    _ensureNotClosed();
    return _api.setFormFieldValue(value, fullyQualifiedName);
  }

  @override
  Future<bool?> updateAnnotation(Annotation annotation) {
    _ensureNotClosed();
    var annotationJSON = jsonEncode(annotation.toJson());
    return _api.updateAnnotation(annotationJSON);
  }

  @override
  Future<bool?> addAnnotations(List<Annotation> annotations) {
    _ensureNotClosed();
    var annotationJSON = annotationsToInstantJSON(annotations);
    return _api.applyInstantJson(annotationJSON);
  }

  @override
  Future getAnnotationsAsJson(int pageIndex, AnnotationType type) {
    _ensureNotClosed();
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
    _ensureNotClosed();
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
  Future<bool?> removeAnnotation(annotation) {
    _ensureNotClosed();
    var annotationJSON = convertAnnotationToJson(annotation);
    return _api.removeAnnotation(annotationJSON);
  }

  @override
  Future<int> getPageCount() {
    _ensureNotClosed();
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
    _ensureNotClosed();
    return _annotationManager.getAnnotationProperties(pageIndex, annotationId);
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    _ensureNotClosed();
    return _annotationManager.saveAnnotationProperties(properties);
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query,
      [int? pageIndex]) async {
    _ensureNotClosed();
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
    _ensureNotClosed();
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
  Future<bool> close() async {
    if (_isClosed) {
      return true;
    }

    try {
      final result = await _api.closeDocument();
      _isClosed = true;
      return result;
    } catch (e) {
      debugPrint('Error closing document: $e');
      _isClosed = true; // Mark as closed even if there was an error
      return false;
    }
  }

  // Uses annotationsToInstantJSON from AnnotationJsonConverter mixin
  // which properly handles attachments for image/file annotations.

  // ============================
  // Bookmark Methods
  // ============================

  @override
  Future<List<Bookmark>> getBookmarks() async {
    _ensureNotClosed();
    return _bookmarkManager.getBookmarks();
  }

  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    _ensureNotClosed();
    return _bookmarkManager.addBookmark(bookmark);
  }

  @override
  Future<bool> removeBookmark(Bookmark bookmark) async {
    _ensureNotClosed();
    return _bookmarkManager.removeBookmark(bookmark);
  }

  @override
  Future<bool> updateBookmark(Bookmark bookmark) async {
    _ensureNotClosed();
    return _bookmarkManager.updateBookmark(bookmark);
  }

  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    _ensureNotClosed();
    return _bookmarkManager.getBookmarksForPage(pageIndex);
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    _ensureNotClosed();
    return _bookmarkManager.hasBookmarkForPage(pageIndex);
  }

  // ============================
  // Document Dirty State - Cross-Platform
  // ============================

  @override
  Future<bool> hasUnsavedChanges() async {
    _ensureNotClosed();
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
    _ensureNotClosed();
    return _api.iOSHasDirtyAnnotations();
  }

  @override
  Future<bool> iOSGetAnnotationIsDirty(int pageIndex, String annotationId) {
    _ensureNotClosed();
    return _api.iOSGetAnnotationIsDirty(pageIndex, annotationId);
  }

  @override
  Future<bool> iOSSetAnnotationIsDirty(
      int pageIndex, String annotationId, bool isDirty) {
    _ensureNotClosed();
    return _api.iOSSetAnnotationIsDirty(pageIndex, annotationId, isDirty);
  }

  @override
  Future<bool> iOSClearNeedsSaveFlag() {
    _ensureNotClosed();
    return _api.iOSClearNeedsSaveFlag();
  }

  // ============================
  // Document Dirty State - Android Specific
  // ============================

  @override
  Future<bool> androidHasUnsavedAnnotationChanges() {
    _ensureNotClosed();
    return _api.androidHasUnsavedAnnotationChanges();
  }

  @override
  Future<bool> androidHasUnsavedFormChanges() {
    _ensureNotClosed();
    return _api.androidHasUnsavedFormChanges();
  }

  @override
  Future<bool> androidHasUnsavedBookmarkChanges() {
    _ensureNotClosed();
    return _api.androidHasUnsavedBookmarkChanges();
  }

  @override
  Future<bool> androidGetBookmarkIsDirty(String bookmarkId) {
    _ensureNotClosed();
    return _api.androidGetBookmarkIsDirty(bookmarkId);
  }

  @override
  Future<bool> androidClearBookmarkDirtyState(String bookmarkId) {
    _ensureNotClosed();
    return _api.androidClearBookmarkDirtyState(bookmarkId);
  }

  @override
  Future<bool> androidGetFormFieldIsDirty(String fullyQualifiedName) {
    _ensureNotClosed();
    return _api.androidGetFormFieldIsDirty(fullyQualifiedName);
  }

  // ============================
  // Document Dirty State - Web Specific
  // ============================

  @override
  Future<bool> webHasUnsavedChanges() {
    _ensureNotClosed();
    return _api.webHasUnsavedChanges();
  }
}
