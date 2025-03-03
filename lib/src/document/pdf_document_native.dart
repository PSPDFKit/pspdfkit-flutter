///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/src/annotations/annotation_utils.dart';
import 'package:pspdfkit_flutter/src/document/annotation_json_converter.dart';

class PdfDocumentNative extends PdfDocument with AnnotationJsonConverter {
  late final PdfDocumentApi _api;

  PdfDocumentNative({required super.documentId, required PdfDocumentApi api}) {
    _api = api;
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
    return _api.getFormField(fieldName).then((result) {
      return PdfFormField.fromMap(result.cast<String, dynamic>());
    }).catchError((error) {
      throw Exception('Error getting form field: $error');
    });
  }

  @override
  Future<List<PdfFormField>> getFormFields() {
    return _api.getFormFields().then((results) {
      return results
          .map((result) => PdfFormField.fromMap(result.cast<String, dynamic>()))
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

    return _api.addAnnotation(jsonAnnotation, jsonEncode(jsonAttachment));
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
    return _api.getAllUnsavedAnnotations();
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    var results = await _api.getAnnotations(pageIndex, type.fullName);

    if (results is List) {
      List<Annotation> annotations = [];

      for (var element in results) {
        if (element is Map) {
          if (element['type'] == null || element['type'] == '') {
            continue;
          }
          var annotationJSON = element.cast<String, dynamic>();
          annotations.add(Annotation.fromJson(annotationJSON));
        } else if (element is String) {
          var annotationJSON = jsonDecode(element);
          if (annotationJSON == null ||
              annotationJSON['type'] == null ||
              annotationJSON['type'] == '') {
            continue;
          }
          annotations.add(Annotation.fromJson(annotationJSON));
        } else {
          throw Exception('Invalid annotation type: $element');
        }
      }

      return annotations;
    }
    return [];
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
    return _api.getAnnotations(pageIndex, type.fullName).then((results) {
      if (results is List) {
        return results.map((result) {
          if (result is Map) {
            return result;
          } else if (result is String) {
            // Convert string to map
            return jsonDecode(result);
          } else {
            throw Exception('Invalid annotation type: $result');
          }
        }).toList();
      } else {
        throw Exception('Invalid annotations type: $results');
      }
    }).catchError((error) {
      throw Exception('Error getting annotations: $error');
    });
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() {
    return _api.getAllUnsavedAnnotations().then((results) {
      if (results is String) {
        results = jsonDecode(results);
        results = results as Map<String, dynamic>;
        return AnnotationUtils.annotationsFromInstantJSON(results);
      } else if (results is Map) {
        return AnnotationUtils.annotationsFromInstantJSON(
            results.cast<String, dynamic>());
      } else {
        return [];
      }
    });
  }

  @override
  Future<bool?> removeAnnotation(annotation) {
    var annotationJSON = convertAnnotationToJson(annotation);
    return _api.removeAnnotation(annotationJSON);
  }

  @override
  Future<int> getPageCount() {
    return _api.getPageCount();
  }
}
