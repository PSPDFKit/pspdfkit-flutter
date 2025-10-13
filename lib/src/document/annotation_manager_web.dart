///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:async';

import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/web/nutrient_web_instance.dart';
import 'package:nutrient_flutter/src/web/nutrient_web_utils.dart';

/// Web implementation of AnnotationManager using dart:js interop.
/// This class provides annotation management functionality using the Nutrient Web SDK
/// through JavaScript interoperability.
class AnnotationManagerWeb extends AnnotationManager {
  late NutrientWebInstance _instance;

  AnnotationManagerWeb({required super.documentId});

  /// Sets the web instance for web platform.
  void setWebInstance(dynamic webInstance) {
    if (webInstance is NutrientWebInstance) {
      _instance = webInstance;
    }
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    try {
      // Get all annotations on the page using the public method
      final annotations =
          await _instance.getAnnotations(pageIndex, 'pspdfkit/all');

      if (annotations is List) {
        // Find the annotation with the specified ID
        for (final annotation in annotations) {
          if (annotation is Map<String, dynamic> &&
              annotation['id'] == annotationId) {
            // Convert to AnnotationProperties
            return _convertJsonToAnnotationProperties(annotation);
          }
        }
      }

      return null; // Annotation not found
    } catch (e) {
      throw Exception('Failed to get annotation properties: $e');
    }
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    try {
      // Prepare the update data with only the changed properties
      final updateData = <String, dynamic>{
        'id': properties.annotationId,
        'pageIndex': properties.pageIndex,
      };

      // Add only non-null properties to the update
      if (properties.strokeColor != null) {
        updateData['strokeColor'] = _colorToWebFormat(properties.strokeColor!);
      }
      if (properties.fillColor != null) {
        updateData['fillColor'] = _colorToWebFormat(properties.fillColor!);
      }
      if (properties.opacity != null) {
        updateData['opacity'] = properties.opacity;
      }
      if (properties.lineWidth != null) {
        updateData['lineWidth'] = properties.lineWidth;
      }
      if (properties.contents != null) {
        updateData['text'] =
            properties.contents; // Web SDK uses 'text' property
      }
      if (properties.subject != null) {
        updateData['subject'] = properties.subject;
      }
      if (properties.creator != null) {
        updateData['creatorName'] =
            properties.creator; // Web SDK uses 'creatorName'
      }
      if (properties.customData != null) {
        updateData['customData'] = properties.customData;
      }
      if (properties.flags != null) {
        updateData['flags'] = properties.flags;
      }

      // Use the new updateAnnotationProperties method
      await _instance.updateAnnotationProperties(updateData);

      return true;
    } catch (e) {
      throw Exception('Failed to save annotation properties: $e');
    }
  }

  @override
  Future<List<Annotation>> getAnnotations(
    int pageIndex, [
    AnnotationType type = AnnotationType.all,
  ]) async {
    try {
      // Convert annotation type to web format (e.g., "all" -> "pspdfkit/all")
      final webAnnotationType = type.name == 'all' ? 'pspdfkit/all' : type.name;

      final annotations =
          await _instance.getAnnotations(pageIndex, webAnnotationType);

      if (annotations is List) {
        List<Annotation> result = [];
        for (final annotation in annotations) {
          if (annotation is Map<String, dynamic>) {
            try {
              result.add(Annotation.fromJson(annotation));
            } catch (e) {
              // Skip annotations that can't be parsed
            }
          }
        }
        return result;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get annotations: $e');
    }
  }

  @override
  Future<String> addAnnotation(Annotation annotation) async {
    try {
      final annotationMap = annotation.toJson();

      // Handle attachment if provided
      Map<String, dynamic>? attachmentMap;
      if (annotation is FileAnnotation && annotation.attachment != null) {
        attachmentMap = annotation.attachment!.toJson();
      } else if (annotation is ImageAnnotation &&
          annotation.attachment != null) {
        attachmentMap = annotation.attachment!.toJson();
      }

      await _instance.addAnnotation(annotationMap, attachmentMap);

      // Return the annotation ID - in web SDK, we typically use the ID from the annotation
      return annotationMap['id'] ??
          annotationMap['name'] ??
          DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      throw Exception('Failed to add annotation: $e');
    }
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) async {
    try {
      // Get the annotation first to have the complete data for removal
      final annotationProperties =
          await getAnnotationProperties(pageIndex, annotationId);
      if (annotationProperties == null) {
        return false; // Annotation not found
      }

      // Convert to JSON format for removal
      final annotationJson =
          _convertAnnotationPropertiesToJson(annotationProperties);

      await _instance.removeAnnotation(annotationJson);
      return true;
    } catch (e) {
      throw Exception('Failed to remove annotation: $e');
    }
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query,
      [int? pageIndex]) async {
    try {
      // Get annotations from specified page or all pages
      List<dynamic> allAnnotations = [];

      if (pageIndex != null) {
        // Search specific page
        final pageAnnotations =
            await _instance.getAnnotations(pageIndex, 'pspdfkit/all');
        if (pageAnnotations is List) {
          allAnnotations.addAll(pageAnnotations);
        }
      } else {
        // Search all pages - get page count first
        final pageCount = await _instance.getPageCount();
        for (int i = 0; i < pageCount; i++) {
          final pageAnnotations =
              await _instance.getAnnotations(i, 'pspdfkit/all');
          if (pageAnnotations is List) {
            allAnnotations.addAll(pageAnnotations);
          }
        }
      }

      // Filter annotations that contain the search query
      final filteredAnnotations = <Annotation>[];
      final searchTerm = query.toLowerCase();

      for (final annotation in allAnnotations) {
        if (annotation is Map<String, dynamic>) {
          // Check text content fields
          final contents =
              annotation['contents']?.toString().toLowerCase() ?? '';
          final subject = annotation['subject']?.toString().toLowerCase() ?? '';
          final note = annotation['note']?.toString().toLowerCase() ?? '';

          if (contents.contains(searchTerm) ||
              subject.contains(searchTerm) ||
              note.contains(searchTerm)) {
            try {
              filteredAnnotations.add(Annotation.fromJson(annotation));
            } catch (e) {
              // Skip annotations that can't be parsed
            }
          }
        }
      }

      return filteredAnnotations;
    } catch (e) {
      throw Exception('Failed to search annotations: $e');
    }
  }

  @override
  Future<String> exportXFDF([int? pageIndex]) async {
    try {
      // The web SDK doesn't support page-specific XFDF export
      // So we'll export all and filter if needed (limitation noted)
      return await promiseToFuture(_instance.jsObject.callMethod('exportXFDF'));
    } catch (e) {
      throw Exception('Failed to export XFDF: $e');
    }
  }

  @override
  Future<bool> importXFDF(String xfdfString) async {
    try {
      await _instance.importXfdf(xfdfString);
      return true;
    } catch (e) {
      throw Exception('Failed to import XFDF: $e');
    }
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    try {
      // The web SDK doesn't track unsaved changes in the same way
      // We'll get all annotations and return them
      // This is a limitation of the web platform
      final allAnnotations = await _instance.getAllAnnotations();

      // Convert the instant JSON to a list of annotation maps
      if (allAnnotations is Map && allAnnotations.containsKey('annotations')) {
        final annotations = allAnnotations['annotations'];
        if (annotations is List) {
          List<Annotation> result = [];
          for (final annotation in annotations) {
            if (annotation is Map<String, dynamic>) {
              try {
                result.add(Annotation.fromJson(annotation));
              } catch (e) {
                // Skip annotations that can't be parsed
              }
            }
          }
          return result;
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get unsaved annotations: $e');
    }
  }

  /// Convert JSON annotation data to AnnotationProperties.
  AnnotationProperties _convertJsonToAnnotationProperties(
      Map<String, dynamic> json) {
    return AnnotationProperties(
      annotationId: json['id']?.toString() ?? json['name']?.toString() ?? '',
      pageIndex: json['pageIndex'] ?? 0,
      strokeColor: _parseColor(json['strokeColor']),
      fillColor: _parseColor(json['fillColor']),
      opacity: json['opacity']?.toDouble(),
      lineWidth: json['lineWidth']?.toDouble(),
      flags: json['flags'] != null ? List<String>.from(json['flags']) : null,
      customData: json['customData'] != null
          ? Map<String, Object?>.from(json['customData'])
          : null,
      contents: json['contents']?.toString(),
      subject: json['subject']?.toString(),
      creator: json['creator']?.toString(),
      bbox: json['bbox'] != null ? List<double>.from(json['bbox']) : null,
      note: json['note']?.toString(),
      inkLines: _parseInkLines(json['inkLines']),
      fontName: json['fontName']?.toString(),
      fontSize: json['fontSize']?.toDouble(),
      iconName: json['iconName']?.toString(),
    );
  }

  /// Convert AnnotationProperties to JSON format for the web SDK.
  Map<String, dynamic> _convertAnnotationPropertiesToJson(
      AnnotationProperties properties) {
    final json = <String, dynamic>{
      'id': properties.annotationId,
      'pageIndex': properties.pageIndex,
    };

    // Only include non-null values
    if (properties.strokeColor != null) {
      json['strokeColor'] = _colorToWebFormat(properties.strokeColor!);
    }
    if (properties.fillColor != null) {
      json['fillColor'] = _colorToWebFormat(properties.fillColor!);
    }
    if (properties.opacity != null) {
      json['opacity'] = properties.opacity;
    }
    if (properties.lineWidth != null) {
      json['lineWidth'] = properties.lineWidth;
    }
    if (properties.flags != null) {
      json['flags'] = properties.flags;
    }
    if (properties.customData != null) {
      json['customData'] = properties.customData;
    }
    if (properties.contents != null) {
      json['contents'] = properties.contents;
    }
    if (properties.subject != null) {
      json['subject'] = properties.subject;
    }
    if (properties.creator != null) {
      json['creator'] = properties.creator;
    }
    if (properties.bbox != null) {
      json['bbox'] = properties.bbox;
    }
    if (properties.note != null) {
      json['note'] = properties.note;
    }
    if (properties.inkLines != null) {
      json['inkLines'] = properties.inkLines;
    }
    if (properties.fontName != null) {
      json['fontName'] = properties.fontName;
    }
    if (properties.fontSize != null) {
      json['fontSize'] = properties.fontSize;
    }
    if (properties.iconName != null) {
      json['iconName'] = properties.iconName;
    }

    return json;
  }

  /// Parse color from various formats to ARGB integer.
  int? _parseColor(dynamic color) {
    if (color == null) return null;

    if (color is int) {
      return color;
    } else if (color is String) {
      // Handle hex color strings
      if (color.startsWith('#')) {
        return int.tryParse(color.substring(1), radix: 16);
      }
    } else if (color is Map) {
      // Handle color objects with r, g, b, a properties
      final r = (color['r'] ?? 0) as int;
      final g = (color['g'] ?? 0) as int;
      final b = (color['b'] ?? 0) as int;
      final a = (color['a'] ?? 255) as int;
      return (a << 24) | (r << 16) | (g << 8) | b;
    }

    return null;
  }

  /// Convert ARGB integer color to web-compatible format.
  dynamic _colorToWebFormat(int color) {
    final a = (color >> 24) & 0xFF;
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;

    return {
      'r': r,
      'g': g,
      'b': b,
      'a': a,
    };
  }

  /// Parse ink lines from JSON format.
  List<List<List<double>>>? _parseInkLines(dynamic inkLines) {
    if (inkLines == null) return null;

    if (inkLines is List) {
      return inkLines
          .map<List<List<double>>>((line) {
            if (line is List) {
              return line
                  .map<List<double>>((point) {
                    if (point is List && point.length >= 2) {
                      return <double>[
                        point[0].toDouble(),
                        point[1].toDouble(),
                        point.length > 2 ? point[2].toDouble() : 1.0,
                      ];
                    }
                    return <double>[];
                  })
                  .where((point) => point.isNotEmpty)
                  .toList();
            }
            return <List<double>>[];
          })
          .where((line) => line.isNotEmpty)
          .toList();
    }

    return null;
  }
}
