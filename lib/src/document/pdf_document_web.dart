///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:pspdfkit_flutter/src/document/annotation_json_converter.dart';

import '../../pspdfkit.dart';
import '../annotations/annotation_utils.dart';
import '../web/pspdfkit_web_instance.dart';

class PdfDocumentWeb extends PdfDocument with AnnotationJsonConverter {
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
}
