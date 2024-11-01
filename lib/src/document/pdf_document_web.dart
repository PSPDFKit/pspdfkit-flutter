///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';
import 'dart:typed_data';

import '../../pspdfkit.dart';
import '../web/pspdfkit_web_instance.dart';

class PdfDocumentWeb extends PdfDocument {
  final PspdfkitWebInstance _instance;

  PdfDocumentWeb(
      {required super.documentId, required PspdfkitWebInstance instance})
      : _instance = instance;

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
  Future<bool?> addAnnotation(String jsonAnnotation) {
    return _instance
        .addAnnotation(jsonDecode(jsonAnnotation))
        .then((value) => true);
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

  @override
  Future<Object> getAllUnsavedAnnotations() {
    return _instance.getAllAnnotations();
  }

  @override
  Future<Object> getAnnotations(int pageIndex, String type) {
    return _instance.getAnnotations(pageIndex, type).then((value) => value);
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
  Future<bool?> removeAnnotation(Object jsonAnnotation) {
    return _instance
        .removeAnnotation(jsonDecode(jsonAnnotation.toString()))
        .then((value) => true);
  }

  @override
  Future<bool> save(String? outputPath, DocumentSaveOptions? options) {
    return _instance.save().then((value) => true);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _instance
        .setFormFieldValue(value, fullyQualifiedName)
        .then((value) => true);
  }
}
