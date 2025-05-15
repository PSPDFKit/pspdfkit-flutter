///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/foundation.dart';

import '../../pspdfkit.dart';

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

  Future<bool> addBookmark(String name, int pageIndex);
}
