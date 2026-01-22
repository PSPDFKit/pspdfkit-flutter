///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Encodes inkLines to JSON string for platform channel transport.
String? _encodeInkLines(List<List<List<double>>>? inkLines) {
  if (inkLines == null) return null;
  return jsonEncode(inkLines);
}

/// Decodes inkLines from JSON string.
List<List<List<double>>>? _decodeInkLines(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((line) {
      final lineList = line as List<dynamic>;
      return lineList.map((point) {
        final pointList = point as List<dynamic>;
        return pointList.map((v) => (v as num).toDouble()).toList();
      }).toList();
    }).toList();
  } catch (e) {
    return null;
  }
}

/// Encodes customData to JSON string for platform channel transport.
String? _encodeCustomData(Map<String, Object?>? customData) {
  if (customData == null) return null;
  return jsonEncode(customData);
}

/// Decodes customData from JSON string.
Map<String, Object?>? _decodeCustomData(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final decoded = jsonDecode(json);
    if (decoded is Map) {
      return Map<String, Object?>.from(decoded);
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// Encodes bbox to JSON string for platform channel transport.
String? _encodeBbox(List<double>? bbox) {
  if (bbox == null) return null;
  return jsonEncode(bbox);
}

/// Decodes bbox from JSON string.
List<double>? _decodeBbox(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((v) => (v as num).toDouble()).toList();
  } catch (e) {
    return null;
  }
}

/// Encodes flags to JSON string for platform channel transport.
String? _encodeFlags(List<String>? flags) {
  if (flags == null) return null;
  return jsonEncode(flags);
}

/// Decodes flags from JSON string.
List<String>? _decodeFlags(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((v) => v as String).toList();
  } catch (e) {
    return null;
  }
}

/// Extension to add modification methods to AnnotationProperties.
/// These methods create new instances with updated values, following
/// an immutable pattern.

extension AnnotationPropertiesModification on AnnotationProperties {
  /// Creates a modified copy with updated stroke color.
  AnnotationProperties withColor(Color color) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: color.toARGB32(),
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated fill color.
  AnnotationProperties withFillColor(Color color) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: color.toARGB32(),
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated opacity.
  AnnotationProperties withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0,
        'Opacity must be between 0.0 and 1.0');
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated line width.
  AnnotationProperties withLineWidth(double lineWidth) {
    assert(lineWidth > 0, 'Line width must be positive');
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated flags.
  AnnotationProperties withFlags(Set<AnnotationFlag> flags) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: _encodeFlags(flags.map((f) => f.name).toList()),
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated custom data.
  AnnotationProperties withCustomData(Map<String, Object?> customData) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: _encodeCustomData(customData),
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated contents.
  AnnotationProperties withContents(String contents) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated subject.
  AnnotationProperties withSubject(String subject) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated creator.
  AnnotationProperties withCreator(String creator) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated bounding box.
  AnnotationProperties withBoundingBox(Rect bbox) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: _encodeBbox([bbox.left, bbox.top, bbox.width, bbox.height]),
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated note.
  AnnotationProperties withNote(String note) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with multiple updates.
  AnnotationProperties withUpdates({
    Color? color,
    Color? fillColor,
    double? opacity,
    double? lineWidth,
    Set<AnnotationFlag>? flags,
    Map<String, Object?>? customData,
    String? contents,
    String? subject,
    String? creator,
    Rect? boundingBox,
    String? note,
  }) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: color?.toARGB32() ?? strokeColor,
      fillColor: fillColor?.toARGB32() ?? this.fillColor,
      opacity: opacity ?? this.opacity,
      lineWidth: lineWidth ?? this.lineWidth,
      flagsJson: flags != null
          ? _encodeFlags(flags.map((f) => f.name).toList())
          : flagsJson,
      customDataJson: customData != null
          ? _encodeCustomData(customData)
          : customDataJson,
      contents: contents ?? this.contents,
      subject: subject ?? this.subject,
      creator: creator ?? this.creator,
      bboxJson: boundingBox != null
          ? _encodeBbox([
              boundingBox.left,
              boundingBox.top,
              boundingBox.width,
              boundingBox.height
            ])
          : bboxJson,
      note: note ?? this.note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }
}

/// Extension for convenient getters on AnnotationProperties.
extension AnnotationPropertiesGetters on AnnotationProperties {
  /// Gets the stroke color as a Flutter Color object.
  Color? get color => strokeColor != null ? Color(strokeColor!) : null;

  /// Gets the fill color as a Flutter Color object.
  Color? get fillColorValue => fillColor != null ? Color(fillColor!) : null;

  /// Gets the flags as a Set of AnnotationFlag enums.
  /// Decodes from the internal JSON string representation.
  Set<AnnotationFlag>? get flagsSet {
    final flags = _decodeFlags(flagsJson);
    if (flags == null) return null;
    return flags.map((name) => AnnotationFlag.values.byName(name)).toSet();
  }

  /// Gets the flags as a list of strings.
  /// Decodes from the internal JSON string representation.
  List<String>? get flags => _decodeFlags(flagsJson);

  /// Gets the bounding box as a Flutter Rect object.
  /// Decodes from the internal JSON string representation.
  Rect? get boundingBox {
    final bbox = _decodeBbox(bboxJson);
    if (bbox == null || bbox.length != 4) return null;
    return Rect.fromLTWH(bbox[0], bbox[1], bbox[2], bbox[3]);
  }

  /// Gets the bounding box as a list of doubles [x, y, width, height].
  /// Decodes from the internal JSON string representation.
  List<double>? get bbox => _decodeBbox(bboxJson);

  /// Gets the custom data as a typed Map.
  /// Decodes from the internal JSON string representation.
  Map<String, Object?>? get customData => _decodeCustomData(customDataJson);

  /// Gets the ink lines as a typed nested list.
  /// Decodes from the internal JSON string representation.
  /// Format: [[[x, y, pressure], ...], ...]
  List<List<List<double>>>? get inkLines => _decodeInkLines(inkLinesJson);
}

/// Extension for ink annotation property updates.
extension InkAnnotationProperties on AnnotationProperties {
  /// Creates a modified copy with updated ink lines.
  /// Accepts a list of lines where each line is a list of Offset points.
  /// Points are converted to [x, y, pressure] format with default pressure of 1.0.
  AnnotationProperties withInkLines(List<List<Offset>> lines) {
    final serializedLines = lines.map((line) {
      return line.map((point) {
        return [point.dx, point.dy, 1.0]; // x, y, pressure (default to 1.0)
      }).toList();
    }).toList();

    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: _encodeInkLines(serializedLines),
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }

  /// Creates a modified copy with updated raw ink lines.
  /// Accepts ink lines in the native format: [[[x, y, pressure], ...], ...]
  AnnotationProperties withRawInkLines(List<List<List<double>>> inkLines) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: _encodeInkLines(inkLines),
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }
}

/// Extension for free text annotation properties.
extension FreeTextAnnotationProperties on AnnotationProperties {
  /// Creates a modified copy with updated font.
  AnnotationProperties withFont(String fontName, double fontSize) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName,
    );
  }
}

/// Extension for note annotation properties.
extension NoteAnnotationProperties on AnnotationProperties {
  /// Creates a modified copy with updated icon.
  AnnotationProperties withIcon(NoteIcon iconName) {
    return AnnotationProperties(
      annotationId: annotationId,
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: fillColor,
      opacity: opacity,
      lineWidth: lineWidth,
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: contents,
      subject: subject,
      creator: creator,
      bboxJson: bboxJson,
      note: note,
      inkLinesJson: inkLinesJson,
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName.name,
    );
  }
}
