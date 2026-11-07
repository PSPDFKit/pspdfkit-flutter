///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import '../operations/annotation_operations.dart';
import 'nutrient_document_web.dart';

/// Web implementation of [AnnotationManagerInterface].
///
/// Delegates to [NutrientAnnotationOperations] accessed via the adapter.
/// Obtained via `document.annotations`.
class AnnotationManagerWeb implements AnnotationManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentWeb document;

  AnnotationManagerWeb(this.document);

  NutrientAnnotationOperations get _ops {
    final ops = document.internalAnnotationOperations;
    if (ops == null) {
      throw StateError(
        'AnnotationManagerWeb: instance not loaded — is onInstanceLoaded called?',
      );
    }
    return ops;
  }

  @override
  Future<String> getAnnotationsJson(int pageIndex, String type) async {
    final annotations = await _ops.getAnnotations(
      pageIndex,
      type == 'all' ? null : type,
    );
    return jsonEncode(annotations);
  }

  @override
  Future<String> getUnsavedAnnotationsJson() async {
    // Web SDK does not distinguish unsaved annotations — return empty list.
    return jsonEncode([]);
  }

  @override
  Future<String> addAnnotationJson(String jsonAnnotation,
      {String? attachment}) async {
    final Map<String, dynamic> annotationMap =
        jsonDecode(jsonAnnotation) as Map<String, dynamic>;
    await _ops.addAnnotation(annotationMap, attachment: attachment);
    return jsonAnnotation;
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) async {
    await _ops.removeAnnotation({
      'id': annotationId,
      'pageIndex': pageIndex,
    });
    return true;
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    final raw = await _ops.findAnnotation(annotationId, pageIndex);
    if (raw == null) return null;
    final json = _ops.webAnnotationToJson(raw);
    if (json == null) return null;
    // The Web SDK's serializable shape keys the id as `name`/`id`, not
    // `annotationId`, so fromJson leaves annotationId null. Stamp the
    // authoritative id/page we were queried with so the caller can round-trip
    // into saveAnnotationProperties.
    return AnnotationProperties.fromJson(json).copyWith(
      annotationId: annotationId,
      pageIndex: pageIndex,
    );
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    final map = properties.toJson();
    // The Web SDK op applies annotation flags from a `flags` array, but the
    // model serialises them as the `flagsJson` string. Translate so flag edits
    // actually apply (mirrors the `customData` handling in the op).
    final flagsJson = properties.flagsJson;
    if (flagsJson != null) {
      try {
        map['flags'] = List<String>.from(jsonDecode(flagsJson) as List);
        map.remove('flagsJson');
      } catch (_) {}
    }
    await _ops.updateAnnotationProperties(map);
    return true;
  }

  @override
  Future<String> searchAnnotationsJson(String query, {int? pageIndex}) async {
    // Web SDK does not expose a search-annotations API.
    // Return empty list to satisfy the interface.
    return jsonEncode([]);
  }

  @override
  Future<String> exportXfdf({int? pageIndex}) async {
    final result = await document.internalDocumentOperations?.exportXfdf();
    return result ?? '';
  }

  @override
  Future<bool> importXfdf(String xfdfString) async {
    try {
      await document.internalDocumentOperations?.importXfdf(xfdfString);
      return true;
    } catch (_) {
      return false;
    }
  }
}
