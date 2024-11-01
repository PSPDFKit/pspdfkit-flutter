///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:typed_data';

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

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> addAnnotation(String jsonAnnotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> removeAnnotation(String jsonAnnotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  Future<Object> getAnnotations(int pageIndex, String type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  Future<Object> getAllUnsavedAnnotations();

  /// Imports annotations from the XFDF file at the given path.
  Future<bool> importXfdf(String xfdfString);

  /// Exports annotations to the XFDF file at the given path.
  Future<bool> exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool> save(String? outputPath, DocumentSaveOptions? options);
}
