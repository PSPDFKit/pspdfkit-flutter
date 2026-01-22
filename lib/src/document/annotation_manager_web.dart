///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:async';
import 'dart:convert';

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
            // Skip undefined or invalid annotation types
            final type = annotation['type'];
            if (type == null || type == '' || type == 'pspdfkit/undefined') {
              continue;
            }
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
      // Use extension getters to access decoded JSON fields
      final customData = properties.customData;
      if (customData != null) {
        updateData['customData'] = customData;
      }
      final flags = properties.flags;
      if (flags != null) {
        updateData['flags'] = flags;
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
            // Skip undefined or invalid annotation types
            final type = annotation['type'];
            if (type == null || type == '' || type == 'pspdfkit/undefined') {
              continue;
            }
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
          // Skip undefined or invalid annotation types
          final type = annotation['type'];
          if (type == null || type == '' || type == 'pspdfkit/undefined') {
            continue;
          }
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
              // Skip undefined or invalid annotation types
              final type = annotation['type'];
              if (type == null || type == '' || type == 'pspdfkit/undefined') {
                continue;
              }
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
    // For TextAnnotation (pspdfkit/text), the text color is stored in 'fontColor'
    // not 'strokeColor'. We need to use fontColor as strokeColor for text annotations.
    final annotationType = json['type']?.toString() ?? '';
    final isTextAnnotation = annotationType == 'pspdfkit/text';

    // Use fontColor for text annotations, strokeColor for others
    int? strokeColor;
    if (isTextAnnotation && json['fontColor'] != null) {
      strokeColor = _parseColor(json['fontColor']);
    } else {
      strokeColor = _parseColor(json['strokeColor']);
    }

    // Convert complex types to JSON strings for Pigeon transport
    final flagsJson = json['flags'] != null
        ? jsonEncode(_convertWebFlagsToFlutter(json['flags']))
        : null;
    final customDataJson = json['customData'] != null
        ? jsonEncode(json['customData'])
        : null;
    final bboxJson = json['bbox'] != null
        ? jsonEncode(List<double>.from(json['bbox']))
        : null;
    final inkLinesJson = json['inkLines'] != null
        ? jsonEncode(_parseInkLines(json['inkLines']))
        : null;

    return AnnotationProperties(
      annotationId: json['id']?.toString() ?? json['name']?.toString() ?? '',
      pageIndex: json['pageIndex'] ?? 0,
      strokeColor: strokeColor,
      fillColor: _parseColor(json['fillColor']),
      opacity: json['opacity']?.toDouble(),
      lineWidth: json['lineWidth']?.toDouble(),
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: json['contents']?.toString(),
      subject: json['subject']?.toString(),
      creator: json['creator']?.toString(),
      bboxJson: bboxJson,
      note: json['note']?.toString(),
      inkLinesJson: inkLinesJson,
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
    // Use extension getters to access decoded JSON fields
    final flags = properties.flags;
    if (flags != null) {
      json['flags'] = flags;
    }
    final customData = properties.customData;
    if (customData != null) {
      json['customData'] = customData;
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
    final bbox = properties.bbox;
    if (bbox != null) {
      json['bbox'] = bbox;
    }
    if (properties.note != null) {
      json['note'] = properties.note;
    }
    final inkLines = properties.inkLines;
    if (inkLines != null) {
      json['inkLines'] = inkLines;
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
        final hexValue = int.tryParse(color.substring(1), radix: 16);
        if (hexValue != null) {
          // If it's a 6-digit hex (RGB), add full alpha
          if (color.length == 7) {
            return 0xFF000000 | hexValue;
          }
          return hexValue;
        }
      }
    } else if (color is Map) {
      // Handle color objects with r, g, b, a properties
      final r = _parseColorComponent(color['r']) ?? 0;
      final g = _parseColorComponent(color['g']) ?? 0;
      final b = _parseColorComponent(color['b']) ?? 0;
      // Web SDK may return alpha as 0-1 float or 0-255 int
      int a = 255;
      if (color['a'] != null) {
        final aValue = color['a'];
        if (aValue is double) {
          // Alpha is a float 0-1, convert to 0-255
          a = (aValue * 255).round().clamp(0, 255);
        } else if (aValue is int) {
          // Integer alpha values are always in 0-255 range
          // (0-1 range uses double/float representation)
          a = aValue.clamp(0, 255);
        }
      }
      return (a << 24) | (r << 16) | (g << 8) | b;
    }

    return null;
  }

  /// Parse a color component (r, g, or b) which may be int or double.
  int? _parseColorComponent(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.clamp(0, 255);
    if (value is double) return value.round().clamp(0, 255);
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

  /// Parse ink lines from web format to typed list.
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

  /// Convert Web SDK flag names to Flutter AnnotationFlag names.
  /// The Web SDK uses inverted naming for some flags (e.g., 'noPrint' vs 'print').
  List<String> _convertWebFlagsToFlutter(List<dynamic> webFlags) {
    final flutterFlags = <String>[];

    // Web SDK to Flutter flag name mappings
    // Note: 'noPrint' in Web SDK means "don't print", which is the opposite of 'print' flag
    // When 'noPrint' is false, it means the annotation should be printed (i.e., 'print' flag is set)
    for (final flag in webFlags) {
      final flagStr = flag.toString();
      switch (flagStr) {
        case 'noPrint':
          // Skip noPrint - we only add 'print' if noPrint is NOT in the list
          // This is handled separately below
          break;
        case 'readOnly':
        case 'locked':
        case 'hidden':
        case 'invisible':
        case 'noView':
        case 'noZoom':
        case 'noRotate':
        case 'toggleNoView':
        case 'lockedContents':
          flutterFlags.add(flagStr);
          break;
        default:
          // Unknown flag, skip it
          break;
      }
    }

    // Handle 'print' flag: if 'noPrint' is NOT in webFlags, add 'print'
    // Because Web SDK uses inverted logic: noPrint=false means print is enabled
    if (!webFlags.contains('noPrint')) {
      flutterFlags.add('print');
    }

    return flutterFlags;
  }
}
