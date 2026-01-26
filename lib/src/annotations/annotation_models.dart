import 'dart:convert';
import 'package:flutter/material.dart' hide BorderStyle, Action;
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Base class for all Nutrient annotations
abstract class Annotation {
  final String? id;
  final AnnotationType type;
  final List<double> bbox;
  final String? createdAt;
  final String? creatorName;
  final int? pdfObjectId;
  final String? name;
  final String? subject;
  final bool hidden;
  final int v;
  final String? updatedAt;
  final int pageIndex;
  final double opacity;
  final Map<String, dynamic>? customData;
  final List<AnnotationFlag>? flags;

  Annotation({
    this.id,
    required this.type,
    required this.bbox,
    required this.pageIndex,
    this.creatorName,
    this.createdAt,
    this.opacity = 1.0,
    this.pdfObjectId,
    this.flags,
    this.updatedAt,
    this.name,
    this.subject,
    this.hidden = false,
    this.v = 2,
    this.customData,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.fullName,
      'bbox': bbox,
      'createdAt': createdAt,
      if (creatorName != null) 'creatorName': creatorName,
      'pageIndex': pageIndex,
      'opacity': opacity,
      if (pdfObjectId != null) 'pdfObjectId': pdfObjectId,
      if (flags != null && flags!.isNotEmpty)
        'flags': flags!.map((f) => f.name).toList(),
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (name != null) 'name': name,
      if (subject != null) 'subject': subject,
      if (customData != null) 'customData': customData,
      'hidden': hidden,
      'v': v,
    };
  }

  /// Helper method to convert a Color to hex string
  static String? _colorToHex(Color? color) {
    // Remove alpha channel
    return color?.toHex();
  }

  /// Helper method to convert a hex string to Color
  static Color? _hexToColor(String? hex) {
    return hex?.toColor(); // Add full opacity
  }

  /// Helper method to convert a list of strings to a list of AnnotationFlags
  static List<AnnotationFlag>? _stringsToFlags(List<dynamic>? strings) {
    if (strings == null) return null;
    return strings
        .map((s) => AnnotationFlagExtension.fromString(s as String))
        .whereType<AnnotationFlag>()
        .toList();
  }

  /// Helper method to safely convert a numeric value to double
  static double _toDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    throw FormatException('Cannot convert $value to double');
  }

  /// Helper method to convert a list of numeric values to a list of doubles
  static List<double> _toDoubleList(List<dynamic> list) {
    return list.map((e) => _toDouble(e)).toList();
  }

  factory Annotation.fromJson(Map<String, dynamic> json,
      [Map<String, dynamic>? attachments]) {
    final type = AnnotationType.values.firstWhere(
      (e) => e.fullName == json['type'] as String?,
      orElse: () => AnnotationType.undefined,
    );

    switch (type) {
      case AnnotationType.ink:
        return InkAnnotation.fromJson(json);
      case AnnotationType.highlight:
        return HighlightAnnotation.fromJson(json);
      case AnnotationType.note:
        return NoteAnnotation.fromJson(json);
      case AnnotationType.square:
        return SquareAnnotation.fromJson(json);
      case AnnotationType.circle:
        return CircleAnnotation.fromJson(json);
      case AnnotationType.line:
        return LineAnnotation.fromJson(json);
      case AnnotationType.freeText:
        return FreeTextAnnotation.fromJson(json);
      case AnnotationType.stamp:
        return StampAnnotation.fromJson(json);
      case AnnotationType.redact:
        return RedactionAnnotation.fromJson(json);
      case AnnotationType.widget:
        return WidgetAnnotation.fromJson(json);
      case AnnotationType.sound:
        return SoundAnnotation.fromJson(json);
      case AnnotationType.file:
        return FileAnnotation.fromJson(json);
      case AnnotationType.strikeout:
        return StrikeoutAnnotation.fromJson(json);
      case AnnotationType.underline:
        return UnderlineAnnotation.fromJson(json);
      case AnnotationType.squiggly:
        return SquigglyAnnotation.fromJson(json);
      case AnnotationType.link:
        return LinkAnnotation.fromJson(json);
      case AnnotationType.polygon:
        return PolygonAnnotation.fromJson(json);
      case AnnotationType.polyline:
        return PolylineAnnotation.fromJson(json);
      case AnnotationType.popup:
        return PopupAnnotation.fromJson(json);
      case AnnotationType.caret:
        return CaretAnnotation.fromJson(json);
      case AnnotationType.media:
        return RichMediaAnnotation.fromJson(json, attachments);
      case AnnotationType.screen:
        return ScreenAnnotation.fromJson(json);
      case AnnotationType.watermark:
        return WatermarkAnnotation.fromJson(json);
      case AnnotationType.type3d:
        return Type3DAnnotation.fromJson(json);
      case AnnotationType.image:
        return ImageAnnotation.fromJson(
          json,
          attachments,
        );
      default:
        throw UnimplementedError(
            'Annotation type ${type.fullName} is not implemented');
    }
  }
}

/// Represents an ink annotation in PSPDFKit
class InkAnnotation extends Annotation {
  final InkLines lines; // Contains points and intensities
  final double lineWidth;
  final bool isDrawnNaturally;
  final bool? isSignature;
  final Color? strokeColor;
  final Color? backgroundColor;
  final BlendMode? blendMode;
  final String? note;

  InkAnnotation({
    super.id,
    required this.lines,
    required this.lineWidth,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    this.isDrawnNaturally = false,
    this.isSignature,
    this.strokeColor,
    this.backgroundColor,
    this.blendMode,
    this.note,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden = false,
    super.customData,
  }) : super(type: AnnotationType.ink);

  factory InkAnnotation.fromJson(Map<String, dynamic> json) {
    return InkAnnotation(
      id: json['id'] as String?,
      lines: InkLines.fromJson(Map<String, dynamic>.from(json['lines'] as Map)),
      lineWidth: Annotation._toDouble(json['lineWidth']),
      isDrawnNaturally: json['isDrawnNaturally'] as bool? ?? false,
      isSignature: json['isSignature'] as bool?,
      strokeColor: Annotation._hexToColor(json['strokeColor'] as String?),
      backgroundColor:
          Annotation._hexToColor(json['backgroundColor'] as String?),
      blendMode: json['blendMode'] != null
          ? BlendMode.values.firstWhere(
              (e) => e.name == json['blendMode'] as String,
              orElse: () => BlendMode.normal,
            )
          : null,
      note: json['note'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'lines': lines.toJson(),
      'lineWidth': lineWidth,
      'isDrawnNaturally': isDrawnNaturally,
      if (isSignature != null) 'isSignature': isSignature,
      if (strokeColor != null)
        'strokeColor': Annotation._colorToHex(strokeColor!),
      if (backgroundColor != null)
        'backgroundColor': Annotation._colorToHex(backgroundColor!),
      if (blendMode != null) 'blendMode': blendMode!.name,
      if (note != null) 'note': note,
    };
  }
}

/// Represents the lines data in an ink annotation
class InkLines {
  final List<List<double>> intensities;
  final List<List<List<double>>> points;

  InkLines({
    required this.intensities,
    required this.points,
  });

  factory InkLines.fromJson(Map<String, dynamic> json) {
    return InkLines(
      intensities: (json['intensities'] as List<dynamic>)
          .map((e) => Annotation._toDoubleList(e as List<dynamic>))
          .toList(),
      points: (json['points'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((p) => Annotation._toDoubleList(p as List<dynamic>))
              .toList())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intensities': intensities,
      'points': points,
    };
  }
}

/// Represents a highlight annotation in PSPDFKit
class HighlightAnnotation extends TextMarkupAnnotation {
  HighlightAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required super.color,
    required super.rects,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.highlight);

  factory HighlightAnnotation.fromJson(Map<String, dynamic> json) {
    return HighlightAnnotation(
        id: json['id'] as String?,
        bbox: Annotation._toDoubleList(json['bbox'] as List),
        createdAt: json['createdAt'] as String,
        creatorName: json['creatorName'] as String?,
        color: Annotation._hexToColor(json['color'] as String?),
        rects: (json['rects'] as List)
            .map((line) => Annotation._toDoubleList(line as List))
            .toList(),
        pageIndex: json['pageIndex'] as int,
        opacity: json['opacity'] != null
            ? Annotation._toDouble(json['opacity'])
            : 1.0,
        pdfObjectId: json['pdfObjectId'] as int?,
        flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
        updatedAt: json['updatedAt'] as String?,
        name: json['name'] as String?,
        subject: json['subject'] as String?,
        hidden: json['hidden'] as bool? ?? false,
        v: json['v'] as int? ?? 2,
        customData: json['customData'] != null
            ? Map<String, dynamic>.from(json['customData'])
            : null);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (color != null) 'color': Annotation._colorToHex(color!),
      'rects': rects,
    };
  }
}

/// Represents a note annotation in PSPDFKit
class NoteAnnotation extends Annotation {
  final TextContent text;
  final NoteIcon? icon;
  final Color? color;

  NoteAnnotation({
    super.id,
    required this.text,
    this.color,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    this.icon = NoteIcon.note,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden = false,
    super.customData,
  }) : super(type: AnnotationType.note);

  factory NoteAnnotation.fromJson(Map<String, dynamic> json) {
    return NoteAnnotation(
      id: json['id'] as String?,
      text:
          TextContent.fromJson(Map<String, dynamic>.from(json['text'] as Map)),
      icon: NoteIcon.values.firstWhere(
        (e) => e.toString().split('.').last == json['icon'],
        orElse: () => NoteIcon.note,
      ),
      color: Annotation._hexToColor(json['color'] as String?),
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'text': text.toJson(),
      'icon': icon.toString().split('.').last,
      'color': Annotation._colorToHex(color),
    };
  }
}

/// Note icon types
enum NoteIcon {
  /// Comment icon
  comment,

  /// Right pointer icon
  rightPointer,

  /// Right arrow icon
  rightArrow,

  /// Check icon
  check,

  /// Circle icon
  circle,

  /// Cross icon
  cross,

  /// Insert icon
  insert,

  /// New paragraph icon
  newParagraph,

  /// Note icon
  note,

  /// Paragraph icon
  paragraph,

  /// Help icon
  help,

  /// Star icon
  star,

  /// Key icon
  key,
}

extension NoteIconExtension on NoteIcon {
  String get name {
    switch (this) {
      case NoteIcon.comment:
        return 'Comment';
      case NoteIcon.rightPointer:
        return 'RightPointer';
      case NoteIcon.rightArrow:
        return 'RightArrow';
      case NoteIcon.check:
        return 'Check';
      case NoteIcon.circle:
        return 'Circle';
      case NoteIcon.cross:
        return 'Cross';
      case NoteIcon.insert:
        return 'Insert';
      case NoteIcon.newParagraph:
        return 'NewParagraph';
      case NoteIcon.note:
        return 'Note';
      case NoteIcon.paragraph:
        return 'Paragraph';
      case NoteIcon.help:
        return 'Help';
      case NoteIcon.star:
        return 'Star';
      case NoteIcon.key:
        return 'Key';
    }
  }
}

/// Shape annotation base class for square, circle, and polygon annotations
abstract class ShapeAnnotation extends Annotation {
  final Color? strokeColor;
  final double? strokeWidth;
  final Color? fillColor;
  final BorderStyle? borderStyle;
  final List<double>? borderDashArray;
  final double? cloudyBorderIntensity;
  final List<double>? cloudyBorderInset;
  final String? note; // Added note property
  final MeasurementScale? measurementScale; // Added measurement properties
  final MeasurementPrecision? measurementPrecision;
  final List<double>? measurementBBox;

  ShapeAnnotation({
    super.id,
    required this.strokeColor,
    required this.strokeWidth,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    required AnnotationType type,
    this.fillColor,
    this.borderStyle,
    this.borderDashArray,
    this.cloudyBorderIntensity,
    this.cloudyBorderInset,
    this.note,
    this.measurementScale,
    this.measurementPrecision,
    this.measurementBBox,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden = false,
    super.customData,
  }) : super(type: type);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (strokeColor != null)
        'strokeColor': Annotation._colorToHex(strokeColor),
      if (strokeWidth != null) 'strokeWidth': strokeWidth,
      if (fillColor != null) 'fillColor': Annotation._colorToHex(fillColor!),
      if (borderStyle != null) 'borderStyle': borderStyle!.name,
      if (borderDashArray != null) 'borderDashArray': borderDashArray,
      if (cloudyBorderIntensity != null)
        'cloudyBorderIntensity': cloudyBorderIntensity,
      if (cloudyBorderInset != null) 'cloudyBorderInset': cloudyBorderInset,
      if (note != null) 'note': note, // Added to toJson
      if (measurementScale != null) 'measurementScale': measurementScale,
      if (measurementPrecision != null)
        'measurementPrecision': measurementPrecision,
      if (measurementBBox != null) 'measurementBBox': measurementBBox,
    };
  }
}

/// Square annotation
class SquareAnnotation extends ShapeAnnotation {
  SquareAnnotation({
    super.id,
    required super.bbox,
    super.createdAt,
    required super.pageIndex,
    super.strokeColor,
    super.strokeWidth,
    super.fillColor,
    super.borderStyle,
    super.borderDashArray,
    super.cloudyBorderIntensity,
    super.cloudyBorderInset,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.note,
    super.measurementScale,
    super.measurementPrecision,
    super.measurementBBox,
    super.customData,
  }) : super(type: AnnotationType.square);

  factory SquareAnnotation.fromJson(Map<String, dynamic> json) {
    return SquareAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      strokeColor: Annotation._hexToColor(json['strokeColor'] as String?),
      strokeWidth: Annotation._toDouble(json['strokeWidth']),
      fillColor: Annotation._hexToColor(json['fillColor'] as String?),
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderDashArray:
          (json['borderDashArray'] as List?)?.map((e) => e as double).toList(),
      cloudyBorderIntensity: json['cloudyBorderIntensity'] as double?,
      cloudyBorderInset: json['cloudyBorderInset'] is List<dynamic>
          ? Annotation._toDoubleList(json['cloudyBorderInset'] as List<dynamic>)
          : null,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      note: json['note'] as String?, // Added to fromJson
      measurementScale: json['measurementScale'] as MeasurementScale?,
      measurementPrecision:
          json['measurementPrecision'] as MeasurementPrecision?,
      measurementBBox: json['measurementBBox'] != null
          ? Annotation._toDoubleList(json['measurementBBox'] as List<dynamic>)
          : null,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }
}

/// Circle annotation
class CircleAnnotation extends ShapeAnnotation {
  CircleAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    required super.strokeColor,
    required super.strokeWidth,
    super.fillColor,
    super.borderStyle,
    super.borderDashArray,
    super.cloudyBorderIntensity,
    super.cloudyBorderInset,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.note,
    super.measurementScale,
    super.measurementPrecision,
    super.measurementBBox,
    super.customData,
  }) : super(type: AnnotationType.circle);

  factory CircleAnnotation.fromJson(Map<String, dynamic> json) {
    return CircleAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      strokeColor: Annotation._hexToColor(json['strokeColor'] as String?),
      strokeWidth: Annotation._toDouble(json['strokeWidth']),
      fillColor: Annotation._hexToColor(json['fillColor'] as String?),
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderDashArray: json['borderDashArray'] != null
          ? Annotation._toDoubleList(json['borderDashArray'] as List<dynamic>)
          : null,
      cloudyBorderIntensity: json['cloudyBorderIntensity'] != null
          ? Annotation._toDouble(json['cloudyBorderIntensity'])
          : null,
      cloudyBorderInset: json['cloudyBorderInset'] is List<dynamic>
          ? Annotation._toDoubleList(json['cloudyBorderInset'] as List<dynamic>)
          : null,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      note: json['note'] as String?, // Added to fromJson
      measurementScale: json['measurementScale'] as MeasurementScale?,
      measurementPrecision:
          json['measurementPrecision'] as MeasurementPrecision?,
      measurementBBox: json['measurementBBox'] != null
          ? Annotation._toDoubleList(json['measurementBBox'] as List<dynamic>)
          : null,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (strokeColor != null)
        'strokeColor': Annotation._colorToHex(strokeColor),
      if (strokeWidth != null) 'strokeWidth': strokeWidth,
      if (fillColor != null) 'fillColor': Annotation._colorToHex(fillColor!),
      if (borderStyle != null) 'borderStyle': borderStyle!.name,
      if (borderDashArray != null) 'borderDashArray': borderDashArray,
      if (cloudyBorderIntensity != null)
        'cloudyBorderIntensity': cloudyBorderIntensity,
      if (cloudyBorderInset != null) 'cloudyBorderInset': cloudyBorderInset,
      if (measurementScale != null) 'measurementScale': measurementScale,
      if (measurementPrecision != null)
        'measurementPrecision': measurementPrecision,
      if (measurementBBox != null) 'measurementBBox': measurementBBox,
    };
  }
}

/// Line cap type for line annotations
enum LineCapType {
  none,
  square,
  circle,
  diamond,
  openArrow,
  closedArrow,
  butt,
  reverseOpenArrow,
  reverseClosedArrow,
  slash,
}

/// Line caps for line annotations
class LineCaps {
  final LineCapType? start;
  final LineCapType? end;

  const LineCaps({this.start, this.end});

  Map<String, String> toJson() {
    final json = <String, String>{};
    if (start != null) json['start'] = start!.name;
    if (end != null) json['end'] = end!.name;
    return json;
  }

  factory LineCaps.fromJson(Map<String, dynamic> json) {
    return LineCaps(
      start: json['start'] != null
          ? LineCapType.values.firstWhere(
              (e) => e.name == json['start'] as String,
              orElse: () => LineCapType.none,
            )
          : null,
      end: json['end'] != null
          ? LineCapType.values.firstWhere(
              (e) => e.name == json['end'] as String,
              orElse: () => LineCapType.none,
            )
          : null,
    );
  }
}

/// Line annotation for drawing straight lines on a page
class LineAnnotation extends ShapeAnnotation {
  final List<double> startPoint;
  final List<double> endPoint;
  final LineCaps? lineCaps;

  LineAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    required super.strokeColor,
    required super.strokeWidth,
    required this.startPoint,
    required this.endPoint,
    this.lineCaps,
    super.fillColor,
    super.borderStyle,
    super.borderDashArray,
    super.cloudyBorderIntensity,
    super.cloudyBorderInset,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.note,
    super.measurementScale,
    super.measurementPrecision,
    super.measurementBBox,
    super.customData,
  }) : super(type: AnnotationType.line);

  factory LineAnnotation.fromJson(Map<String, dynamic> json) {
    return LineAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      strokeColor: Annotation._hexToColor(json['strokeColor'] as String?),
      strokeWidth: Annotation._toDouble(json['strokeWidth']),
      startPoint: Annotation._toDoubleList(json['startPoint'] as List<dynamic>),
      endPoint: Annotation._toDoubleList(json['endPoint'] as List<dynamic>),
      lineCaps: json['lineCaps'] != null
          ? LineCaps.fromJson(
              Map<String, dynamic>.from(json['lineCaps'] as Map))
          : null,
      fillColor: Annotation._hexToColor(json['fillColor'] as String?),
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderDashArray: json['borderDashArray'] != null
          ? Annotation._toDoubleList(json['borderDashArray'] as List<dynamic>)
          : null,
      cloudyBorderIntensity: json['cloudyBorderIntensity'] != null
          ? Annotation._toDouble(json['cloudyBorderIntensity'])
          : null,
      cloudyBorderInset: json['cloudyBorderInset'] is List<dynamic>
          ? Annotation._toDoubleList(json['cloudyBorderInset'] as List<dynamic>)
          : null,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      note: json['note'] as String?, // Added to fromJson
      measurementScale: json['measurementScale'] as MeasurementScale?,
      measurementPrecision:
          json['measurementPrecision'] as MeasurementPrecision?,
      measurementBBox: json['measurementBBox'] != null
          ? Annotation._toDoubleList(json['measurementBBox'] as List<dynamic>)
          : null,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'startPoint': startPoint,
      'endPoint': endPoint,
      if (lineCaps != null) 'lineCaps': lineCaps!.toJson(),
      if (fillColor != null) 'fillColor': Annotation._colorToHex(fillColor!),
      if (borderStyle != null) 'borderStyle': borderStyle!.name,
      if (borderDashArray != null) 'borderDashArray': borderDashArray,
      if (cloudyBorderIntensity != null)
        'cloudyBorderIntensity': cloudyBorderIntensity,
      if (cloudyBorderInset != null) 'cloudyBorderInset': cloudyBorderInset,
      if (measurementScale != null) 'measurementScale': measurementScale,
      if (measurementPrecision != null)
        'measurementPrecision': measurementPrecision,
      if (measurementBBox != null) 'measurementBBox': measurementBBox,
    };
  }
}

/// Text format for annotations
enum TextFormat {
  plain,
  xhtml, // Changed from 'richText' to match spec
}

/// Text content for annotations
class TextContent {
  final TextFormat format;
  final String value;

  TextContent({
    required this.format,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'format': format.toString().split('.').last,
        'value': value,
      };

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      format: TextFormat.values.firstWhere(
        (e) => e.toString().split('.').last == json['format'],
        orElse: () => TextFormat.plain,
      ),
      value: json['value'] as String,
    );
  }
}

/// Text alignment options for free text annotations
enum HorizontalTextAlignment {
  left,
  center,
  right,
}

/// Vertical alignment options for free text annotations
enum VerticalAlignment {
  top,
  center,
  bottom,
}

/// Free text annotation
class FreeTextAnnotation extends Annotation {
  final TextContent text;
  final Color? backgroundColor;
  final double fontSize;
  final String font;
  final HorizontalTextAlignment? horizontalTextAlign;
  final VerticalAlignment? verticalAlign;
  final Color fontColor;
  final bool? isFitting;
  final bool? disableAutoReturn;
  final Map<String, dynamic>?
      callout; // Contains start, knee?, end points and other properties
  final BorderStyle? borderStyle;
  final List<double>? borderDashArray;
  final double? borderWidth;
  final int rotation;
  final double? cloudyBorderIntensity;
  final List<double>? cloudyBorderInset;

  FreeTextAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.text,
    required this.fontSize,
    this.backgroundColor,
    this.font = 'sans-serif',
    this.horizontalTextAlign,
    this.verticalAlign,
    this.fontColor = Colors.black,
    this.isFitting,
    this.disableAutoReturn,
    this.callout,
    this.borderStyle,
    this.borderDashArray,
    this.borderWidth,
    this.rotation = 0,
    this.cloudyBorderIntensity,
    this.cloudyBorderInset,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.freeText);

  factory FreeTextAnnotation.fromJson(Map<String, dynamic> json) {
    return FreeTextAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      text:
          TextContent.fromJson(Map<String, dynamic>.from(json['text'] as Map)),
      backgroundColor:
          Annotation._hexToColor(json['backgroundColor'] as String?),
      fontSize: Annotation._toDouble(json['fontSize']),
      font: json['font'] as String,
      horizontalTextAlign: json['horizontalAlign'] != null
          ? HorizontalTextAlignment.values.firstWhere(
              (e) => e.name == json['horizontalAlign'] as String,
              orElse: () => HorizontalTextAlignment.left,
            )
          : null,
      verticalAlign: json['verticalAlign'] != null
          ? VerticalAlignment.values.firstWhere(
              (e) => e.name == json['verticalAlign'] as String,
              orElse: () => VerticalAlignment.top,
            )
          : null,
      fontColor:
          Annotation._hexToColor(json['fontColor'] as String?) ?? Colors.black,
      isFitting: json['isFitting'] as bool?,
      disableAutoReturn: json['disableAutoReturn'] as bool?,
      callout: json['callout'] as Map<String, dynamic>?,
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderDashArray: json['borderDashArray'] != null
          ? Annotation._toDoubleList(json['borderDashArray'] as List<dynamic>)
          : null,
      borderWidth: json['borderWidth'] != null
          ? Annotation._toDouble(json['borderWidth'])
          : null,
      rotation: json['rotation'] as int? ?? 0,
      cloudyBorderIntensity: json['cloudyBorderIntensity'] != null
          ? Annotation._toDouble(json['cloudyBorderIntensity'])
          : null,
      cloudyBorderInset: json['cloudyBorderInset'] is List<dynamic>
          ? Annotation._toDoubleList(json['cloudyBorderInset'] as List<dynamic>)
          : null,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'text': text.toJson(),
      'fontSize': fontSize,
      'font': font,
      if (backgroundColor != null)
        'backgroundColor': Annotation._colorToHex(backgroundColor!),
      if (horizontalTextAlign != null)
        'horizontalAlign': horizontalTextAlign!.name,
      if (verticalAlign != null) 'verticalAlign': verticalAlign!.name,
      'fontColor': Annotation._colorToHex(fontColor),
      if (isFitting != null) 'isFitting': isFitting,
      if (disableAutoReturn != null) 'disableAutoReturn': disableAutoReturn,
      if (callout != null) 'callout': callout,
      if (borderStyle != null) 'borderStyle': borderStyle!.name,
      if (borderDashArray != null) 'borderDashArray': borderDashArray,
      if (borderWidth != null) 'borderWidth': borderWidth,
      if (rotation != 0) 'rotation': rotation,
      if (cloudyBorderIntensity != null)
        'cloudyBorderIntensity': cloudyBorderIntensity,
      if (cloudyBorderInset != null) 'cloudyBorderInset': cloudyBorderInset,
    };
  }
}

/// Stamp annotation
class StampAnnotation extends Annotation {
  final StampType stampType;
  final String? attachment; // base64 encoded image data
  final double rotation;
  final String? title;
  final Color? color;
  final String? subtitle;

  StampAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.stampType,
    this.attachment,
    this.rotation = 0.0,
    this.title,
    this.color,
    this.subtitle,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.stamp);

  factory StampAnnotation.fromJson(Map<String, dynamic> json) {
    // Handle attachment - can be either a string (existing format) or an object (from native getAnnotations)
    String? attachmentData;
    if (json['attachment'] is String) {
      attachmentData = json['attachment'] as String;
    } else if (json['attachment'] is Map) {
      // Extract binary data from the attachment object
      // Use Map.from to handle platform channel maps (_Map<Object?, Object?>)
      final attachmentObj =
          Map<String, dynamic>.from(json['attachment'] as Map);
      attachmentData = attachmentObj['binary'] as String?;
    }

    return StampAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      stampType: StampType.values.firstWhere(
        (e) => e.name == json['stampType'] as String,
        orElse: () => StampType.approved,
      ),
      attachment: attachmentData,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String?,
      color: Annotation._hexToColor(json['color'] as String?),
      subtitle: json['subtitle'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'stampType': stampType.name,
      if (attachment != null) 'attachment': attachment,
      if (rotation != 0.0) 'rotation': rotation,
      if (title != null) 'title': title,
      if (color != null) 'color': Annotation._colorToHex(color!),
      if (subtitle != null) 'subtitle': subtitle,
    };
  }
}

/// Image annotation
class ImageAnnotation extends Annotation with HasAttachment {
  final double rotation;
  final String? description;
  final String? fileName;
  final String? contentType;
  final String? imageAttachmentId;
  final String? note;
  @override
  final AnnotationAttachment? attachment;
  final bool? isSignature;

  ImageAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    super.creatorName,
    this.attachment,
    this.rotation = 0.0,
    this.description,
    this.fileName,
    this.contentType,
    this.imageAttachmentId,
    this.note,
    this.isSignature, // Added to constructor
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.image);

  factory ImageAnnotation.fromJson(Map<String, dynamic> json,
      [Map<String, dynamic>? attachments]) {
    final String imageAttachmentId = json['imageAttachmentId'] as String? ?? '';

    // Parse attachment - first check for inline attachment (from native getAnnotations),
    // then fall back to attachments map (from Instant JSON)
    AnnotationAttachment? attachment;
    if (json['attachment'] != null) {
      // Use Map.from to handle platform channel maps (_Map<Object?, Object?>)
      final inlineAttachment =
          Map<String, dynamic>.from(json['attachment'] as Map);
      attachment = AnnotationAttachment.fromJson(
        inlineAttachment['id'] as String,
        inlineAttachment,
      );
    } else if (attachments != null && imageAttachmentId.isNotEmpty) {
      final attachmentData = attachments[imageAttachmentId];
      if (attachmentData != null) {
        attachment = AnnotationAttachment.fromJson(
          imageAttachmentId,
          Map<String, dynamic>.from(attachmentData as Map),
        );
      }
    }

    return ImageAnnotation(
        id: json['id'] as String?,
        bbox: Annotation._toDoubleList(json['bbox'] as List),
        createdAt: json['createdAt'] as String,
        creatorName: json['creatorName'] as String?,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String?,
        fileName: json['fileName'] as String?,
        contentType: json['contentType'] as String?,
        imageAttachmentId: imageAttachmentId,
        note: json['note'] as String?,
        pageIndex: json['pageIndex'] as int,
        opacity: json['opacity'] != null
            ? Annotation._toDouble(json['opacity'])
            : 1.0,
        pdfObjectId: json['pdfObjectId'] as int?,
        flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
        updatedAt: json['updatedAt'] as String?,
        name: json['name'] as String?,
        subject: json['subject'] as String?,
        hidden: json['hidden'] as bool? ?? false,
        v: json['v'] as int? ?? 2,
        isSignature: json['isSignature'] as bool?,
        customData: json['customData'] != null
            ? Map<String, dynamic>.from(json['customData'])
            : null,
        attachment: attachment);
  }

  @override
  Map<String, dynamic> toJson() {
    final String attachmentId = attachment?.id ?? imageAttachmentId ?? '';

    return {
      ...super.toJson(),
      'rotation': rotation,
      if (description != null) 'description': description,
      if (fileName != null) 'fileName': fileName,
      if (contentType != null) 'contentType': contentType,
      if (attachmentId.isNotEmpty) 'imageAttachmentId': attachmentId,
      if (note != null) 'note': note,
      if (isSignature != null) 'isSignature': isSignature, // Added to toJson
    };
  }
}

/// Represents an embedded file that can be attached to a [FileAnnotation]
class EmbeddedFile {
  /// The path to the file to be embedded
  final String filePath;

  /// Optional description of the file
  final String? description;

  /// Optional MIME type of the file
  final String? contentType;

  /// Creates an [EmbeddedFile] instance
  EmbeddedFile({
    required this.filePath,
    this.description,
    this.contentType,
  });

  /// Creates an [EmbeddedFile] from a JSON map
  factory EmbeddedFile.fromJson(Map<String, dynamic> json) {
    return EmbeddedFile(
      filePath: json['filePath'] as String,
      description: json['description'] as String?,
      contentType: json['contentType'] as String?,
    );
  }

  /// Converts the [EmbeddedFile] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      if (description != null) 'description': description,
      if (contentType != null) 'contentType': contentType,
    };
  }
}

enum FileIconName {
  /// Document icon
  pushPin,
  paperClip,
  graph,
  tag,
}

extension FileIconNameExtension on FileIconName {
  String get name {
    switch (this) {
      case FileIconName.pushPin:
        return 'PushPin';
      case FileIconName.paperClip:
        return 'PaperClip';
      case FileIconName.graph:
        return 'Graph';
      case FileIconName.tag:
        return 'Tag';
    }
  }
}

/// File attachment annotation
class FileAnnotation extends Annotation {
  /// The icon name for the file annotation
  final FileIconName? iconName;

  /// The embedded file associated with this annotation
  final EmbeddedFile? embeddedFile;

  final AnnotationAttachment? attachment;

  String? get fileAttachmentId => attachment?.id;

  /// Creates a [FileAnnotation] instance
  FileAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    this.iconName,
    this.embeddedFile,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    this.attachment,
    super.customData,
  }) : super(type: AnnotationType.file);

  /// Creates a [FileAnnotation] from a JSON map
  factory FileAnnotation.fromJson(Map<String, dynamic> json) {
    // Parse inline attachment if present (from native getAnnotations)
    AnnotationAttachment? attachment;
    if (json['attachment'] != null) {
      // Use Map.from to handle platform channel maps (_Map<Object?, Object?>)
      final inlineAttachment =
          Map<String, dynamic>.from(json['attachment'] as Map);
      attachment = AnnotationAttachment.fromJson(
        inlineAttachment['id'] as String,
        inlineAttachment,
      );
    }

    return FileAnnotation(
      id: json['id'] as String?,
      bbox: List<double>.from(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      iconName: json['iconName'] != null
          ? FileIconName.values.firstWhere(
              (e) => e.name == json['iconName'] as String,
              orElse: () => FileIconName.pushPin,
            )
          : null,
      embeddedFile: json['embeddedFile'] != null
          ? EmbeddedFile.fromJson(
              Map<String, dynamic>.from(json['embeddedFile'] as Map))
          : null,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
      attachment: attachment,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (iconName != null) 'iconName': iconName?.name,
      if (embeddedFile != null) 'embeddedFile': embeddedFile!.toJson(),
    };
  }
}

/// Redaction annotation
class RedactionAnnotation extends Annotation {
  final Color? fillColor;
  final String? overlayText;
  final double? fontSize;
  final Color? fontColor;
  final String? repeat;
  final List<List<double>> rects;
  final Color? outlineColor;
  final bool? repeatOverlayText;
  final double rotation;

  RedactionAnnotation({
    super.id,
    required this.rects,
    required super.createdAt,
    super.creatorName,
    this.fillColor,
    this.overlayText,
    this.fontSize,
    this.fontColor,
    this.repeat,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    this.outlineColor,
    this.repeatOverlayText,
    this.rotation = 0.0,
    super.customData,
  }) : super(type: AnnotationType.redact, bbox: rects.first);

  factory RedactionAnnotation.fromJson(Map<String, dynamic> json) {
    return RedactionAnnotation(
      id: json['id'] as String?,
      rects: (json['rects'] as List<dynamic>)
          .map((rect) => Annotation._toDoubleList(rect as List<dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      fillColor: Annotation._hexToColor(json['fillColor'] as String?),
      overlayText: json['overlayText'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontColor: Annotation._hexToColor(json['fontColor'] as String?),
      repeat: json['repeat'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      outlineColor: Annotation._hexToColor(json['outlineColor'] as String?),
      repeatOverlayText: json['repeatOverlayText'] as bool?,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'rects': rects,
      if (fillColor != null) 'fillColor': Annotation._colorToHex(fillColor!),
      if (overlayText != null) 'overlayText': overlayText,
      if (fontSize != null) 'fontSize': fontSize,
      if (fontColor != null) 'fontColor': Annotation._colorToHex(fontColor!),
      if (repeat != null) 'repeat': repeat,
      if (outlineColor != null)
        'outlineColor': Annotation._colorToHex(outlineColor!),
      if (repeatOverlayText != null) 'repeatOverlayText': repeatOverlayText,
      'rotation': rotation,
    };
  }
}

/// Widget annotation (form fields)
class WidgetAnnotation extends Annotation {
  final String fieldType;
  final String? fieldName;
  final dynamic value;
  final List<String>? options;
  final bool? readOnly;
  final bool? required;
  final bool? multiline;

  WidgetAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.fieldType,
    this.fieldName,
    this.value,
    this.options,
    this.readOnly,
    this.required,
    this.multiline,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.widget);

  factory WidgetAnnotation.fromJson(Map<String, dynamic> json) {
    return WidgetAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      fieldType: (json['fieldType'] as String?) ?? '',
      fieldName: json['fieldName'] as String?,
      value: json['value'],
      options: (json['options'] as List?)?.map((e) => e as String).toList(),
      readOnly: json['readOnly'] as bool?,
      required: json['required'] as bool?,
      multiline: json['multiline'] as bool?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fieldType': fieldType,
      if (fieldName != null) 'fieldName': fieldName,
      if (value != null) 'value': value,
      if (options != null) 'options': options,
      if (readOnly != null) 'readOnly': readOnly,
      if (required != null) 'required': required,
      if (multiline != null) 'multiline': multiline,
    };
  }
}

/// Sound annotation
class SoundAnnotation extends Annotation {
  final String soundUrl;
  final String? icon;

  SoundAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.soundUrl,
    this.icon,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.sound);

  factory SoundAnnotation.fromJson(Map<String, dynamic> json) {
    return SoundAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      soundUrl: json['soundUrl'] as String,
      icon: json['icon'] as String?,
      name: json['name'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'soundUrl': soundUrl,
      if (icon != null) 'icon': icon,
    };
  }
}

/// Base class for text markup annotations (highlight, underline, strikeout, squiggly)
abstract class TextMarkupAnnotation extends Annotation {
  final List<List<double>> rects;
  final BlendMode? blendMode; // Add documentation mentioning supported values
  final Color? color;
  final String? note;

  // Add static const for supported blend modes from spec:
  // normal, multiply, screen, overlay, darken, lighten, colorDodge,
  // colorBurn, hardLight, softLight, difference, exclusion

  TextMarkupAnnotation({
    super.id,
    required super.type,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.rects,
    this.blendMode,
    required this.color,
    this.note,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'rects': rects,
      if (blendMode != null) 'blendMode': blendMode!.name,
      'color': Annotation._colorToHex(color),
      if (note != null) 'note': note,
    };
  }
}

/// Strikeout annotation
class StrikeoutAnnotation extends TextMarkupAnnotation {
  StrikeoutAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required super.rects,
    super.blendMode,
    required super.color,
    super.note,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.strikeout);

  factory StrikeoutAnnotation.fromJson(Map<String, dynamic> json) {
    return StrikeoutAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      rects: (json['rects'] as List)
          .map((e) => Annotation._toDoubleList(e as List))
          .toList(),
      blendMode: json['blendMode'] != null
          ? BlendMode.values.firstWhere(
              (e) => e.name == json['blendMode'] as String,
              orElse: () => BlendMode.normal,
            )
          : null,
      color: Annotation._hexToColor(json['color'] as String?),
      note: json['note'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }
}

/// Underline annotation
class UnderlineAnnotation extends TextMarkupAnnotation {
  UnderlineAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required super.rects,
    super.blendMode,
    required super.color,
    super.note,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.underline);

  factory UnderlineAnnotation.fromJson(Map<String, dynamic> json) {
    return UnderlineAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      rects: (json['rects'] as List)
          .map((e) => Annotation._toDoubleList(e as List))
          .toList(),
      blendMode: json['blendMode'] != null
          ? BlendMode.values.firstWhere(
              (e) => e.name == json['blendMode'] as String,
              orElse: () => BlendMode.normal,
            )
          : null,
      color: Annotation._hexToColor(json['color'] as String?),
      note: json['note'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }
}

/// Squiggly annotation
class SquigglyAnnotation extends TextMarkupAnnotation {
  SquigglyAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required super.rects,
    super.blendMode,
    required super.color,
    super.note,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.squiggly);

  factory SquigglyAnnotation.fromJson(Map<String, dynamic> json) {
    return SquigglyAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      rects: (json['rects'] as List)
          .map((e) => Annotation._toDoubleList(e as List))
          .toList(),
      blendMode: json['blendMode'] != null
          ? BlendMode.values.firstWhere(
              (e) => e.name == json['blendMode'] as String,
              orElse: () => BlendMode.normal,
            )
          : null,
      color: Annotation._hexToColor(json['color'] as String?),
      note: json['note'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }
}

/// Link annotation
class LinkAnnotation extends Annotation {
  final Action action;
  final String? note;
  final BorderStyle? borderStyle;
  final double? borderWidth;
  final Color? borderColor;

  LinkAnnotation({
    super.id,
    required this.action,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    this.note,
    this.borderStyle,
    this.borderWidth,
    this.borderColor,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden = false,
    super.customData,
  }) : super(type: AnnotationType.link);

  factory LinkAnnotation.fromJson(Map<String, dynamic> json) {
    return LinkAnnotation(
      id: json['id'] as String?,
      action: Action.fromJson(Map<String, dynamic>.from(json['action'] as Map)),
      note: json['note'] as String?,
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderWidth: json['borderWidth'] != null
          ? Annotation._toDouble(json['borderWidth'])
          : null,
      borderColor: Annotation._hexToColor(json['borderColor'] as String?),
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'action': action.toJson(),
      if (note != null) 'note': note,
      if (borderStyle != null) 'borderStyle': borderStyle!.name,
      if (borderWidth != null) 'borderWidth': borderWidth,
      if (borderColor != null)
        'borderColor': Annotation._colorToHex(borderColor!),
    };
  }
}

/// Polygon annotation
class PolygonAnnotation extends ShapeAnnotation {
  final List<List<double>> points;

  PolygonAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    required super.strokeColor,
    required super.strokeWidth,
    required this.points,
    super.fillColor,
    super.borderStyle,
    super.borderDashArray,
    super.cloudyBorderIntensity,
    super.cloudyBorderInset,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.note,
    super.measurementScale,
    super.measurementPrecision,
    super.measurementBBox,
    super.customData,
  }) : super(type: AnnotationType.polygon);

  factory PolygonAnnotation.fromJson(Map<String, dynamic> json) {
    return PolygonAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      strokeColor: Annotation._hexToColor(json['strokeColor'] as String?),
      strokeWidth: Annotation._toDouble(json['strokeWidth']),
      points: (json['points'] as List)
          .map((e) => Annotation._toDoubleList(e as List))
          .toList(),
      fillColor: Annotation._hexToColor(json['fillColor'] as String?),
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderDashArray: json['borderDashArray'] != null
          ? Annotation._toDoubleList(json['borderDashArray'] as List<dynamic>)
          : null,
      cloudyBorderIntensity: json['cloudyBorderIntensity'] != null
          ? Annotation._toDouble(json['cloudyBorderIntensity'])
          : null,
      cloudyBorderInset: json['cloudyBorderInset'] is List<dynamic>
          ? Annotation._toDoubleList(json['cloudyBorderInset'] as List<dynamic>)
          : null,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      note: json['note'] as String?, // Added to fromJson
      measurementScale: json['measurementScale'] as MeasurementScale?,
      measurementPrecision:
          json['measurementPrecision'] as MeasurementPrecision?,
      measurementBBox: json['measurementBBox'] != null
          ? Annotation._toDoubleList(json['measurementBBox'] as List<dynamic>)
          : null,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'points': points,
    };
  }
}

/// Polyline annotation
class PolylineAnnotation extends ShapeAnnotation {
  final List<List<double>> points;
  final String? startStyle;
  final String? endStyle;

  PolylineAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    required super.pageIndex,
    required super.strokeColor,
    required super.strokeWidth,
    required this.points,
    this.startStyle,
    this.endStyle,
    super.fillColor,
    super.borderStyle,
    super.borderDashArray,
    super.cloudyBorderIntensity,
    super.cloudyBorderInset,
    super.creatorName,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.note,
    super.measurementScale,
    super.measurementPrecision,
    super.measurementBBox,
    super.customData,
  }) : super(type: AnnotationType.polyline);

  factory PolylineAnnotation.fromJson(Map<String, dynamic> json) {
    return PolylineAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      pageIndex: json['pageIndex'] as int,
      strokeColor: Annotation._hexToColor(json['strokeColor'] as String?),
      strokeWidth: Annotation._toDouble(json['strokeWidth']),
      points: (json['points'] as List)
          .map((e) => Annotation._toDoubleList(e as List))
          .toList(),
      startStyle: json['startStyle'] as String?,
      endStyle: json['endStyle'] as String?,
      fillColor: Annotation._hexToColor(json['fillColor'] as String?),
      borderStyle: json['borderStyle'] != null
          ? BorderStyle.values.firstWhere(
              (e) => e.name == json['borderStyle'] as String,
              orElse: () => BorderStyle.solid,
            )
          : null,
      borderDashArray: json['borderDashArray'] != null
          ? Annotation._toDoubleList(json['borderDashArray'] as List<dynamic>)
          : null,
      cloudyBorderIntensity: json['cloudyBorderIntensity'] != null
          ? Annotation._toDouble(json['cloudyBorderIntensity'])
          : null,
      cloudyBorderInset: json['cloudyBorderInset'] is List<dynamic>
          ? Annotation._toDoubleList(json['cloudyBorderInset'] as List<dynamic>)
          : null,
      creatorName: json['creatorName'] as String?,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      note: json['note'] as String?, // Added to fromJson
      measurementScale: json['measurementScale'] as MeasurementScale?,
      measurementPrecision:
          json['measurementPrecision'] as MeasurementPrecision?,
      measurementBBox: json['measurementBBox'] != null
          ? Annotation._toDoubleList(json['measurementBBox'] as List<dynamic>)
          : null,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'points': points,
      if (startStyle != null) 'startStyle': startStyle,
      if (endStyle != null) 'endStyle': endStyle,
    };
  }
}

/// Popup annotation
class PopupAnnotation extends Annotation {
  final String? contents;
  final bool open;
  final String? parentId;

  PopupAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    this.contents,
    this.open = false,
    this.parentId,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.popup);

  factory PopupAnnotation.fromJson(Map<String, dynamic> json) {
    return PopupAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      contents: json['contents'] as String?,
      open: json['open'] as bool? ?? false,
      parentId: json['parentId'] as String?,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (contents != null) 'contents': contents,
      'open': open,
      if (parentId != null) 'parentId': parentId,
    };
  }
}

/// Caret annotation
class CaretAnnotation extends Annotation {
  final String? contents;
  final Color? color;
  final String? symbol;

  CaretAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    this.contents,
    required this.color,
    this.symbol,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.caret);

  factory CaretAnnotation.fromJson(Map<String, dynamic> json) {
    return CaretAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
      creatorName: json['creatorName'] as String?,
      contents: json['contents'] as String?,
      color: Annotation._hexToColor(json['color'] as String?),
      symbol: json['symbol'] as String?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (contents != null) 'contents': contents,
      if (color != null) 'color': Annotation._colorToHex(color!),
      if (symbol != null) 'symbol': symbol,
    };
  }
}

/// Rich media annotation
class RichMediaAnnotation extends Annotation with HasAttachment {
  final String? contentType; // mime-type
  final String? fileName;
  final String? description;
  final String mediaAttachmentId;
  final String mediaSource; // "richMedia" or "sound"
  final Map<String, dynamic>?
      encoding; // Used when the media annotation represents a sound annotation
  final String? mediaType; // Keeping for backward compatibility
  final String? source; // Keeping for backward compatibility
  final Map<String, dynamic>? params; // Keeping for backward compatibility
  @override
  final AnnotationAttachment? attachment;

  RichMediaAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    this.contentType,
    this.fileName,
    this.description,
    required this.mediaAttachmentId,
    this.mediaSource = 'richMedia',
    this.encoding,
    this.mediaType,
    this.source,
    this.params,
    this.attachment,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.customData,
    super.v,
  }) : super(type: AnnotationType.media);

  factory RichMediaAnnotation.fromJson(Map<String, dynamic> json,
      [Map<String, dynamic>? attachments]) {
    final String mediaAttachmentId = json['mediaAttachmentId'] as String? ?? '';

    return RichMediaAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      contentType: json['contentType'] as String?,
      fileName: json['fileName'] as String?,
      description: json['description'] as String?,
      mediaAttachmentId: mediaAttachmentId,
      mediaSource: json['mediaSource'] as String? ?? 'richMedia',
      encoding: json['encoding'] != null
          ? Map<String, dynamic>.from(json['encoding'] as Map)
          : null,
      mediaType: json['mediaType'] as String?,
      source: json['source'] as String?,
      params: json['params'] != null
          ? Map<String, dynamic>.from(json['params'] as Map)
          : null,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
      attachment: attachments != null && mediaAttachmentId.isNotEmpty
          ? AnnotationAttachment.fromJson(
              mediaAttachmentId,
              attachments[mediaAttachmentId],
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final String attachmentId = attachment?.id ?? mediaAttachmentId;

    return {
      ...super.toJson(),
      if (contentType != null) 'contentType': contentType,
      if (fileName != null) 'fileName': fileName,
      if (description != null) 'description': description,
      'mediaAttachmentId': attachmentId,
      'mediaSource': mediaSource,
      if (encoding != null) 'encoding': encoding,
      if (mediaType != null) 'mediaType': mediaType,
      if (source != null) 'source': source,
      if (params != null) 'params': params,
    };
  }
}

/// Screen annotation
class ScreenAnnotation extends Annotation {
  final String mediaType;
  final String source;
  final bool? autoplay;
  final bool? showControls;

  ScreenAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.mediaType,
    required this.source,
    this.autoplay,
    this.showControls,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.screen);

  factory ScreenAnnotation.fromJson(Map<String, dynamic> json) {
    return ScreenAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      mediaType: json['mediaType'] as String,
      source: json['source'] as String,
      autoplay: json['autoplay'] as bool?,
      showControls: json['showControls'] as bool?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'mediaType': mediaType,
      'source': source,
      if (autoplay != null) 'autoplay': autoplay,
      if (showControls != null) 'showControls': showControls,
    };
  }
}

/// Watermark annotation
class WatermarkAnnotation extends Annotation {
  final String text;
  final double rotation;
  final String? fontFamily;
  final double? fontSize;
  final Color? color;

  WatermarkAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.text,
    required this.rotation,
    this.fontFamily,
    this.fontSize,
    this.color,
    required super.pageIndex,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.opacity,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.watermark);

  factory WatermarkAnnotation.fromJson(Map<String, dynamic> json) {
    return WatermarkAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      text: json['text'] as String,
      opacity: (json['opacity'] as num).toDouble(),
      rotation: Annotation._toDouble(json['rotation']),
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      color: Annotation._hexToColor(json['color'] as String?),
      pageIndex: json['pageIndex'] as int,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'text': text,
      'opacity': opacity,
      'rotation': rotation,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontSize != null) 'fontSize': fontSize,
      if (color != null) 'color': Annotation._colorToHex(color!),
    };
  }
}

/// 3D annotation
class Type3DAnnotation extends Annotation {
  final String source;
  final String? poster;
  final Map<String, dynamic>? viewSettings;

  Type3DAnnotation({
    super.id,
    required super.bbox,
    required super.createdAt,
    super.creatorName,
    required this.source,
    this.poster,
    this.viewSettings,
    required super.pageIndex,
    super.opacity,
    super.pdfObjectId,
    super.flags,
    super.updatedAt,
    super.name,
    super.subject,
    super.hidden,
    super.v,
    super.customData,
  }) : super(type: AnnotationType.type3d);

  factory Type3DAnnotation.fromJson(Map<String, dynamic> json) {
    return Type3DAnnotation(
      id: json['id'] as String?,
      bbox: Annotation._toDoubleList(json['bbox'] as List),
      createdAt: json['createdAt'] as String,
      creatorName: json['creatorName'] as String?,
      source: json['source'] as String,
      poster: json['poster'] as String?,
      viewSettings: json['viewSettings'] as Map<String, dynamic>?,
      pageIndex: json['pageIndex'] as int,
      opacity:
          json['opacity'] != null ? Annotation._toDouble(json['opacity']) : 1.0,
      pdfObjectId: json['pdfObjectId'] as int?,
      flags: Annotation._stringsToFlags(json['flags'] as List<dynamic>?),
      updatedAt: json['updatedAt'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      v: json['v'] as int? ?? 2,
      customData: json['customData'] != null
          ? Map<String, dynamic>.from(json['customData'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'source': source,
      if (poster != null) 'poster': poster,
      if (viewSettings != null) 'viewSettings': viewSettings,
    };
  }
}

/// Flags that control the behavior and appearance of annotations.
/// See the PDF Reference for details.
enum AnnotationFlag {
  /// If set, ignore annotation AP stream if there is no handler available.
  invisible,

  /// If set, do not display or print the annotation or allow it to interact with the user.
  hidden,

  /// If set, print the annotation when the page is printed. Default value.
  print,

  /// If set, don't scale the annotation's appearance to match the magnification of the page.
  /// Note: Supported only for FILE and STAMP annotations.
  /// Note: NOTE annotations are treated as if they had this flag enabled by default.
  noZoom,

  /// [Not supported] If set, don't rotate the annotation's appearance to match the rotation of the page.
  noRotate,

  /// If set, don't display the annotation on the screen. (But printing might be allowed)
  noView,

  /// If set, don't allow the annotation to interact with the user. Ignored for Widget.
  readOnly,

  /// If set, don't allow the annotation to be deleted or properties modified (except contents)
  locked,

  /// [Not supported] If set, invert the interpretation of the NoView flag for certain events.
  toggleNoView,

  /// If set, don't allow the annotation contents to be modified
  lockedContents,
}

/// Extension on AnnotationFlag to convert between enum values and strings.
extension AnnotationFlagExtension on AnnotationFlag {
  /// Creates an AnnotationFlag from a string value.
  static AnnotationFlag? fromString(String value) {
    switch (value) {
      case 'invisible':
        return AnnotationFlag.invisible;
      case 'hidden':
        return AnnotationFlag.hidden;
      case 'print':
        return AnnotationFlag.print;
      case 'noZoom':
        return AnnotationFlag.noZoom;
      case 'noRotate':
        return AnnotationFlag.noRotate;
      case 'noView':
        return AnnotationFlag.noView;
      case 'readOnly':
        return AnnotationFlag.readOnly;
      case 'locked':
        return AnnotationFlag.locked;
      case 'toggleNoView':
        return AnnotationFlag.toggleNoView;
      case 'lockedContents':
        return AnnotationFlag.lockedContents;
      default:
        return null;
    }
  }
}

/// Helper class to handle collections of annotations
class AnnotationCollection {
  final List<Annotation> annotations;

  AnnotationCollection({required this.annotations});

  factory AnnotationCollection.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final annotationsList = json['annotations'] as List;
    return AnnotationCollection(
      annotations: annotationsList
          .map((e) => Annotation.fromJson(e as Map<String, dynamic>,
              json['metadata'] as Map<String, dynamic>?))
          .toList(),
    );
  }

  String toJson() {
    return jsonEncode({
      'annotations': annotations.map((e) => e.toJson()).toList(),
    });
  }
}
