///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

abstract class PdfDocument {
  final String documentId;

  PdfDocument({required this.documentId});

  /// Returns the page info for the given page index.
  /// pageIndex The index of the page. This is a zero-based index.
  Future<PageInfo> getPageInfo(int pageIndex);

  /// Exports the document as a PDF.
  /// options:[DocumentSaveOptions] The options to use when exporting the document.
  /// Returns a [Uint8List] containing the exported PDF data.
  Future<Uint8List> exportPdf({DocumentSaveOptions? options});

  /// Returns the form field with the given name.
  Future<PdfFormField> getFormField(String fieldName);

  /// Returns a list of all form fields in the document.
  Future<List<PdfFormField>> getFormFields();

  /// Sets the value of a form field by specifying its fully qualified field name.
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  Future<String?> getFormFieldValue(String fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  Future<bool?> applyInstantJson(String annotationsJson);

  /// Exports Instant document JSON from the presented document.
  Future<String?> exportInstantJson();

  /// Used to add multiple annotations at once. Does not trigger [annotationCreated] or [annotationUpdated] events.
  /// annotations A list of [Annotation] objects to add.
  /// Returns [Future] that completes when the annotations have been added.
  Future<void> addAnnotations(List<Annotation> annotations);

  /// Updates the given annotation model in the presented document.
  ///
  /// **DEPRECATED:** This method has a critical bug that causes data loss for annotations
  /// with attachments (FileAnnotation, ImageAnnotation) and customData. It uses a
  /// remove-then-add approach internally which loses all attachment data.
  ///
  /// Use the new annotation management methods instead:
  /// ```dart
  /// final properties = await document.getAnnotationProperties(pageIndex, annotationId);
  /// if (properties != null) {
  ///   final updated = properties.withColor(Colors.red);
  ///   await document.saveAnnotationProperties(updated);
  /// }
  /// ```
  ///
  /// This method will be removed in version 7.0.0.
  @Deprecated(
      'Use getAnnotationProperties/saveAnnotationProperties for safe property updates. '
      'This method causes data loss for annotations with attachments. '
      'Will be removed in version 7.0.0')
  Future<void> updateAnnotation(Annotation annotation);

  /// Adds an annotation to the presented document.
  ///
  /// This method accepts various types of input:
  /// - An [Annotation] object (will be converted to JSON using toJson())
  /// - A JSON string representing an annotation
  /// - A [Map] representing an annotation (will be converted to JSON)
  ///
  /// An optional [attachment] map can be provided for annotations that support attachments.
  /// The attachment will be passed separately to the native API.
  ///
  /// Returns true if the annotation was successfully added.
  Future<bool?> addAnnotation(dynamic annotation,
      [Map<String, dynamic>? attachment]);

  /// Removes an annotation from the presented document.
  ///
  /// This method accepts various types of input:
  /// - An [Annotation] object (will be converted to JSON using toJson())
  /// - A JSON string representing an annotation
  /// - A [Map] representing an annotation (will be converted to JSON)
  ///
  /// Returns true if the annotation was successfully removed.
  Future<bool?> removeAnnotation(dynamic annotation);

  /// Internal method to remove an annotation using JSON string

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  Future<List<Annotation>> getAnnotations(int pageIndex, AnnotationType type);

  /// Returns a JSON string for all the annotations of the given `type` on the given `pageIndex`.
  Future<dynamic> getAnnotationsAsJson(int pageIndex, AnnotationType type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @Deprecated('Use getUnsavedAnnotations instead')
  Future<Object> getAllUnsavedAnnotations();

  /// Returns a list of annotation models for all the unsaved annotations in the presented document.
  Future<List<Annotation>> getUnsavedAnnotations();

  /// Imports annotations from the XFDF file at the given path.
  Future<bool> importXfdf(String xfdfString);

  /// Exports annotations to the XFDF file at the given path.
  Future<bool> exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool> save({String? outputPath, DocumentSaveOptions? options});

  /// Get number of pages in the document.
  /// Returns the number of pages in the document.
  Future<int> getPageCount();

  // ============================
  // Annotation Management Methods
  // ============================
  // These methods provide safe annotation operations without data loss
  // for annotations with attachments or custom data.

  /// Gets annotation properties for modification.
  /// Returns null if the annotation doesn't exist.
  ///
  /// The returned [AnnotationProperties] can be modified using
  /// extension methods like `withColor()`, `withOpacity()`, etc.
  ///
  /// Example:
  /// ```dart
  /// final properties = await document.getAnnotationProperties(pageIndex, annotationId);
  /// if (properties != null) {
  ///   final updated = properties.withColor(Colors.red).withOpacity(0.7);
  ///   await document.saveAnnotationProperties(updated);
  /// }
  /// ```
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  );

  /// Saves modified annotation properties.
  /// Only non-null properties in [properties] will be updated.
  /// All other properties (including attachments and custom data) are preserved.
  ///
  /// Returns true if successfully saved, false otherwise.
  Future<bool> saveAnnotationProperties(AnnotationProperties properties);

  /// Searches for annotations containing specific text.
  ///
  /// [query] is the search term.
  /// [pageIndex] optionally limits the search to a specific page.
  Future<List<Annotation>> searchAnnotations(String query, [int? pageIndex]);

  // ============================
  // Annotation Processing Methods
  // ============================

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  ///
  /// This method can be used to:
  /// - Flatten annotations into the page content
  /// - Embed annotations into the PDF structure
  /// - Remove annotations from the document
  /// - Optimize annotations for printing
  ///
  /// **Example - Flatten all annotations:**
  /// ```dart
  /// await document.processAnnotations(
  ///   AnnotationType.all,
  ///   AnnotationProcessingMode.flatten,
  ///   '/path/to/output.pdf',
  /// );
  /// ```
  ///
  /// **Example - Remove ink annotations:**
  /// ```dart
  /// await document.processAnnotations(
  ///   AnnotationType.ink,
  ///   AnnotationProcessingMode.remove,
  ///   '/path/to/output.pdf',
  /// );
  /// ```
  ///
  /// @param type The type of annotations to process
  /// @param processingMode The processing mode to apply
  /// @param destinationPath Path where the processed PDF should be saved
  /// @return true if processing succeeded, false otherwise
  Future<bool> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  );

  // ============================
  // Document Lifecycle Methods
  // ============================

  /// Whether this document was opened in headless mode (without a viewer).
  ///
  /// Headless documents must be explicitly closed using [close] to release
  /// native resources. Viewer-bound documents are managed by the view lifecycle.
  bool get isHeadless;

  /// Closes the document and releases all native resources.
  ///
  /// This must be called when a headless document is no longer needed
  /// to free memory and file handles. For viewer-bound documents,
  /// this is a no-op as the view lifecycle manages the document.
  ///
  /// After calling close, the document instance should not be used anymore.
  /// Any subsequent calls to document methods may throw or return errors.
  ///
  /// **Example:**
  /// ```dart
  /// final document = await Nutrient.openDocument('/path/to/doc.pdf');
  /// try {
  ///   // Perform operations
  ///   final annotations = await document.getAnnotations(0, AnnotationType.all);
  /// } finally {
  ///   await document.close();
  /// }
  /// ```
  ///
  /// @return true if the document was closed successfully
  Future<bool> close();
  // Bookmark Methods
  // ============================
  // Methods for managing user-created bookmarks in the document.

  /// Gets all bookmarks in the document.
  ///
  /// Returns a list of all bookmarks, ordered by creation order or sort key.
  ///
  /// Example:
  /// ```dart
  /// final bookmarks = await document.getBookmarks();
  /// for (final bookmark in bookmarks) {
  ///   print('${bookmark.name}: Page ${bookmark.pageIndex}');
  /// }
  /// ```
  Future<List<Bookmark>> getBookmarks();

  /// Adds a new bookmark to the document.
  ///
  /// Use [BookmarkFactory.forPage] to easily create a bookmark for a specific page:
  /// ```dart
  /// final bookmark = BookmarkFactory.forPage(pageIndex: 5, name: 'Chapter 2');
  /// await document.addBookmark(bookmark);
  /// ```
  ///
  /// Returns the created bookmark with its assigned pdfBookmarkId.
  Future<Bookmark> addBookmark(Bookmark bookmark);

  /// Removes a bookmark from the document.
  ///
  /// The bookmark is identified by its page index (from the action) or name.
  ///
  /// Returns true if successfully removed, false if the bookmark was not found.
  Future<bool> removeBookmark(Bookmark bookmark);

  /// Updates an existing bookmark.
  ///
  /// The bookmark is identified by its pdfBookmarkId or page index.
  /// If the bookmark doesn't exist, it will be added.
  ///
  /// Returns true if successfully updated.
  Future<bool> updateBookmark(Bookmark bookmark);

  /// Gets bookmarks for a specific page.
  ///
  /// Returns a list of bookmarks pointing to the specified page.
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex);

  /// Checks if a bookmark exists for a specific page.
  ///
  /// Returns true if at least one bookmark exists for the page.
  Future<bool> hasBookmarkForPage(int pageIndex);

  // ============================
  // Document Dirty State - Cross-Platform
  // ============================

  /// Checks if the document has any unsaved changes.
  ///
  /// This is a cross-platform convenience method that works on all platforms.
  /// It provides a unified way to check for unsaved changes without needing
  /// platform-specific code.
  ///
  /// **Platform behavior:**
  /// - **iOS**: Returns `document.hasDirtyAnnotations`
  /// - **Android**: Returns true if any of annotation, form, or bookmark
  ///   providers have unsaved changes
  /// - **Web**: Returns `instance.hasUnsavedChanges()`
  ///
  /// For more granular control, use the platform-specific methods:
  /// - iOS: [iOSHasDirtyAnnotations], [iOSGetAnnotationIsDirty]
  /// - Android: [androidHasUnsavedAnnotationChanges], [androidHasUnsavedFormChanges],
  ///   [androidHasUnsavedBookmarkChanges]
  /// - Web: [webHasUnsavedChanges]
  ///
  /// Example:
  /// ```dart
  /// final hasChanges = await document.hasUnsavedChanges();
  /// if (hasChanges) {
  ///   await document.save();
  /// }
  /// ```
  Future<bool> hasUnsavedChanges();

  // ============================
  // Document Dirty State - iOS Specific
  // ============================
  // These methods are only available on iOS and match the iOS SDK APIs.

  /// **iOS only.** Checks if the document has any dirty (unsaved) annotations.
  ///
  /// This maps to `document.hasDirtyAnnotations` in the iOS SDK.
  /// Throws an error on Android and Web - use platform-specific alternatives.
  ///
  /// Example:
  /// ```dart
  /// if (Platform.isIOS) {
  ///   final hasDirty = await document.iOSHasDirtyAnnotations();
  ///   if (hasDirty) {
  ///     await document.save();
  ///   }
  /// }
  /// ```
  Future<bool> iOSHasDirtyAnnotations();

  /// **iOS only.** Gets the dirty state of a specific annotation.
  ///
  /// This maps to `annotation.isDirty` in the iOS SDK.
  /// Returns true if the annotation has been modified since last save.
  ///
  /// Throws an error on Android (no per-annotation dirty state) and Web.
  Future<bool> iOSGetAnnotationIsDirty(int pageIndex, String annotationId);

  /// **iOS only.** Sets the dirty state of a specific annotation.
  ///
  /// This maps to `annotation.isDirty = value` in the iOS SDK.
  /// Setting to false can prevent an annotation from being included in save operations.
  ///
  /// Throws an error on Android (no per-annotation dirty state) and Web.
  Future<bool> iOSSetAnnotationIsDirty(
      int pageIndex, String annotationId, bool isDirty);

  /// **iOS only.** Clears the dirty state on all annotations.
  ///
  /// This clears the dirty flag by setting `isDirty = false` on all annotations
  /// in the document. Useful after programmatic changes that shouldn't trigger
  /// a save prompt.
  ///
  /// Note: This achieves the same effect as `clearNeedsSaveFlag()` in the iOS SDK
  /// by clearing the dirty state on individual annotations.
  ///
  /// Throws an error on Android (cannot clear needs-save flag) and Web.
  Future<bool> iOSClearNeedsSaveFlag();

  // ============================
  // Document Dirty State - Android Specific
  // ============================
  // These methods are only available on Android and match the Android SDK APIs.

  /// **Android only.** Checks if the annotation provider has unsaved changes.
  ///
  /// This maps to `annotationProvider.hasUnsavedChanges()` in the Android SDK.
  /// Throws an error on iOS and Web - use platform-specific alternatives.
  ///
  /// Example:
  /// ```dart
  /// if (Platform.isAndroid) {
  ///   final hasChanges = await document.androidHasUnsavedAnnotationChanges();
  ///   if (hasChanges) {
  ///     await document.save();
  ///   }
  /// }
  /// ```
  Future<bool> androidHasUnsavedAnnotationChanges();

  /// **Android only.** Checks if the form provider has unsaved changes.
  ///
  /// This maps to `formProvider.hasUnsavedChanges()` in the Android SDK.
  /// Throws an error on iOS and Web.
  Future<bool> androidHasUnsavedFormChanges();

  /// **Android only.** Checks if the bookmark provider has unsaved changes.
  ///
  /// This maps to `bookmarkProvider.hasUnsavedChanges()` in the Android SDK.
  /// Throws an error on iOS and Web.
  Future<bool> androidHasUnsavedBookmarkChanges();

  /// **Android only.** Gets the dirty state of a specific bookmark.
  ///
  /// This maps to `bookmark.isDirty()` in the Android SDK.
  /// Returns true if the bookmark has been modified since last save.
  ///
  /// Throws an error on iOS and Web.
  Future<bool> androidGetBookmarkIsDirty(String bookmarkId);

  /// **Android only.** Clears the dirty state of a specific bookmark.
  ///
  /// This maps to `bookmark.clearDirty()` in the Android SDK.
  /// Useful after programmatic changes that shouldn't trigger a save prompt.
  ///
  /// Note: Android does NOT support clearing dirty state for annotations -
  /// only bookmarks can have their dirty state cleared.
  ///
  /// Throws an error on iOS and Web.
  Future<bool> androidClearBookmarkDirtyState(String bookmarkId);

  /// **Android only.** Gets the dirty state of a form field.
  ///
  /// This maps to `formField.isDirty()` in the Android SDK.
  /// Returns true if the form field has been modified since last save.
  ///
  /// Throws an error on iOS and Web.
  Future<bool> androidGetFormFieldIsDirty(String fullyQualifiedName);

  // ============================
  // Document Dirty State - Web Specific
  // ============================
  // These methods are only available on Web and match the Web SDK APIs.

  /// **Web only.** Checks if the instance has unsaved changes.
  ///
  /// This maps to `instance.hasUnsavedChanges()` in the Web SDK.
  /// Throws an error on iOS and Android - use platform-specific alternatives.
  ///
  /// Example:
  /// ```dart
  /// if (kIsWeb) {
  ///   final hasChanges = await document.webHasUnsavedChanges();
  ///   if (hasChanges) {
  ///     await document.save();
  ///   }
  /// }
  /// ```
  Future<bool> webHasUnsavedChanges();
}
