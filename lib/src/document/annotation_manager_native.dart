///  Copyright © 2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Native implementation of AnnotationManager for iOS and Android platforms.
class AnnotationManagerNative extends AnnotationManager {
  late final AnnotationManagerApi _api;

  AnnotationManagerNative({required super.documentId}) {
    // Create API instance with channel based on documentId
    _api = AnnotationManagerApi(
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      messageChannelSuffix: '${documentId}_annotation_manager',
    );
    _api.initialize(documentId);
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    return _api.getAnnotationProperties(pageIndex, annotationId);
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    return _api.saveAnnotationProperties(properties);
  }

  @override
  Future<List<Annotation>> getAnnotations(
    int pageIndex, [
    AnnotationType type = AnnotationType.all,
  ]) async {
    var results = await _api.getAnnotations(pageIndex, type.name);

    if (results is List) {
      List<Annotation> annotations = [];

      for (var element in results) {
        if (element is Map) {
          if (element['type'] == null ||
              element['type'] == '' ||
              element['type'] == 'pspdfkit/undefined') {
            continue;
          }
          var annotationJSON = element.cast<String, dynamic>();
          try {
            annotations.add(Annotation.fromJson(annotationJSON));
          } catch (e) {
            // Skip annotations that can't be parsed
            // Skip annotations that can't be parsed
          }
        } else if (element is String) {
          var annotationJSON = jsonDecode(element);
          if (annotationJSON == null ||
              annotationJSON['type'] == null ||
              annotationJSON['type'] == '' ||
              annotationJSON['type'] == 'pspdfkit/undefined') {
            continue;
          }
          try {
            annotations.add(Annotation.fromJson(annotationJSON));
          } catch (e) {
            // Skip annotations that can't be parsed
            // Skip annotations that can't be parsed
          }
        } else {
          throw Exception('Invalid annotation type: $element');
        }
      }

      return annotations;
    }
    return [];
  }

  @override
  Future<String> addAnnotation(Annotation annotation) async {
    String? attachmentJson;

    // Handle attachments for annotations that support them
    if (annotation is FileAnnotation && annotation.attachment != null) {
      attachmentJson = jsonEncode(annotation.attachment!.toJson());
    } else if (annotation is ImageAnnotation && annotation.attachment != null) {
      attachmentJson = jsonEncode(annotation.attachment!.toJson());
    }

    return _api.addAnnotation(
      jsonEncode(annotation.toJson()),
      attachmentJson,
    );
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) {
    return _api.removeAnnotation(pageIndex, annotationId);
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query,
      [int? pageIndex]) async {
    var results = await _api.searchAnnotations(query, pageIndex);

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
  Future<String> exportXFDF([int? pageIndex]) {
    return _api.exportXFDF(pageIndex);
  }

  @override
  Future<bool> importXFDF(String xfdfString) {
    return _api.importXFDF(xfdfString);
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    var results = await _api.getUnsavedAnnotations();

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
}
