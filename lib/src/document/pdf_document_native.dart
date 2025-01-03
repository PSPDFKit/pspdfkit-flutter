///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PdfDocumentNative extends PdfDocument {
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
  Future<bool?> addAnnotation(String jsonAnnotation) {
    return _api.addAnnotation(jsonAnnotation);
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
  Future<Object> getAnnotations(int pageIndex, String type) {
    return _api.getAnnotations(pageIndex, type).then((results) {
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
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return _api.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool> importXfdf(String xfdfString) {
    return _api.importXfdf(xfdfString);
  }

  @override
  Future<bool?> removeAnnotation(String jsonAnnotation) {
    return _api.removeAnnotation(jsonAnnotation);
  }

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) {
    return _api.save(outputPath, options);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _api.setFormFieldValue(value, fullyQualifiedName);
  }
}
