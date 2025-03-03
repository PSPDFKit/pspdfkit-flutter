///  Copyright 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import '../annotations/annotation_attachment.dart';
import '../annotations/annotation_models.dart';

/// A mixin that provides JSON conversion functionality for annotations.
mixin AnnotationJsonConverter {
  /// Converts an annotation to a JSON string.
  ///
  /// This method accepts various types of input:
  /// - An [Annotation] object (will be converted to JSON using toJson())
  /// - A JSON string representing an annotation
  /// - A [Map] representing an annotation (will be converted to JSON)
  ///
  /// Throws [ArgumentError] if the input is null or of an unsupported type.
  /// Throws [FormatException] if the JSON string is invalid.
  String convertAnnotationToJson(dynamic annotation) {
    if (annotation == null) {
      throw ArgumentError.notNull('annotation');
    }

    try {
      if (annotation is Annotation) {
        return json.encode(annotation.toJson());
      } else if (annotation is Map<String, dynamic>) {
        return json.encode(annotation);
      } else if (annotation is String) {
        // Validate JSON string
        json.decode(annotation);
        return annotation;
      } else {
        throw ArgumentError(
            'Unsupported annotation format. Must be an Annotation, JSON string, or Map');
      }
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Converts a JSON string representing an annotation to an [Annotation] object.
  ///
  /// This method accepts various types of input:
  /// - A JSON string representing an annotation
  /// - A [Map] representing an annotation (will be converted to JSON)
  /// - An [Annotation] object (will be converted to JSON using toJson())
  ///
  /// Throws [ArgumentError] if the input is null or of an unsupported type.
  /// Throws [FormatException] if the JSON string is invalid.
  Annotation convertJsonToAnnotation(dynamic json) {
    if (json == null) {
      throw ArgumentError.notNull('json');
    }

    try {
      return Annotation.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Converts a list of annotations to a JSON string in the Instant JSON format.
  ///
  /// This method accepts various types of input:
  /// - A list of [Annotation] objects (will be converted to JSON using toJson())
  /// - A list of JSON strings representing annotations
  /// - A list of [Map] representing annotations (will be converted to JSON)
  ///
  /// Throws [ArgumentError] if the input is null or of an unsupported type.
  /// Throws [FormatException] if the JSON string is invalid.
  String annotationsToInstantJSON(List<Annotation> annotations) {
    var annotationData = annotations.map((a) => a.toJson()).toList();

    var attachments = annotations
        .map((a) {
          if (a is HasAttachment) {
            return (a as HasAttachment).attachment;
          }
          return null;
        })
        .where((a) => a != null)
        .toList();

    var annotationJSON = {
      'annotations': annotationData,
      'attachments':
          Map.fromEntries(attachments.map((a) => MapEntry(a!.id, a.toJson()))),
      'format': 'https://pspdfkit.com/instant-json/v1',
      'v': 1
    };
    return jsonEncode(annotationJSON);
  }
}
