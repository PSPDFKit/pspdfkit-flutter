///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Extension to add modification methods to AnnotationProperties.
/// These methods create new instances with updated values, following
/// an immutable pattern.
/// Helper function to safely cast a single coordinate to double
double _castCoordinate(dynamic coord) {
  if (coord is double) return coord;
  if (coord is num) return coord.toDouble();
  throw FormatException('Invalid coordinate type: ${coord.runtimeType}');
}

/// Helper function to cast a single point (list of coordinates)
List<double> _castPoint(dynamic point) {
  if (point is! List) return <double>[];

  try {
    return point.map((coord) => _castCoordinate(coord)).toList();
  } catch (_) {
    return <double>[];
  }
}

/// Helper function to cast a single line (list of points)
List<List<double>> _castLine(dynamic line) {
  if (line is! List) return <List<double>>[];

  try {
    return line.map((point) => _castPoint(point)).toList();
  } catch (_) {
    return <List<double>>[];
  }
}

/// Helper function to safely cast inkLines from Object? to the expected type
///
/// This function handles the conversion of ink line data which represents
/// drawing strokes. The structure is:
/// - Outer list: Multiple strokes/lines
/// - Middle list: Points within each stroke
/// - Inner list: Coordinates for each point [x, y, pressure]
List<List<List<double>>>? _castInkLines(Object? inkLines) {
  if (inkLines == null) return null;

  // Fast path: already in the correct format
  if (inkLines is List<List<List<double>>>) return inkLines;

  // Needs casting from generic List
  if (inkLines is! List) return null;

  try {
    return inkLines.map((line) => _castLine(line)).toList();
  } catch (e) {
    // If casting fails, return null to avoid crashes
    return null;
  }
}

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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags.map((f) => f.name).toList(),
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: [bbox.left, bbox.top, bbox.width, bbox.height],
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags?.map((f) => f.name).toList() ?? this.flags,
      customData: customData ?? this.customData,
      contents: contents ?? this.contents,
      subject: subject ?? this.subject,
      creator: creator ?? this.creator,
      bbox: boundingBox != null
          ? [
              boundingBox.left,
              boundingBox.top,
              boundingBox.width,
              boundingBox.height
            ]
          : bbox,
      note: note ?? this.note,
      inkLines: _castInkLines(inkLines),
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
  Set<AnnotationFlag>? get flagsSet {
    if (flags == null) return null;
    return flags!.map((name) => AnnotationFlag.values.byName(name)).toSet();
  }

  /// Gets the bounding box as a Flutter Rect object.
  Rect? get boundingBox {
    if (bbox == null || bbox!.length != 4) return null;
    return Rect.fromLTWH(bbox![0], bbox![1], bbox![2], bbox![3]);
  }
}

/// Extension for type-specific property updates.
extension InkAnnotationProperties on AnnotationProperties {
  /// Creates a modified copy with updated ink lines.
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: serializedLines,
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
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
      flags: flags,
      customData: customData,
      contents: contents,
      subject: subject,
      creator: creator,
      bbox: bbox,
      note: note,
      inkLines: _castInkLines(inkLines),
      fontName: fontName,
      fontSize: fontSize,
      iconName: iconName.name,
    );
  }
}
