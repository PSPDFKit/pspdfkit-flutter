///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

/// Typed representation of annotation properties.
///
/// Used by [AnnotationManagerInterface.getAnnotationProperties] and
/// [AnnotationManagerInterface.saveAnnotationProperties].
class AnnotationProperties {
  /// Unique annotation identifier.
  final String? annotationId;

  /// Zero-based page index the annotation is on.
  final int? pageIndex;

  /// Stroke colour as an ARGB integer (e.g. `0xFFFF0000` for opaque red).
  final int? strokeColor;

  /// Fill colour as an ARGB integer.
  final int? fillColor;

  /// Opacity in the range 0.0–1.0.
  final double? opacity;

  /// Stroke/line width in PDF points.
  final double? lineWidth;

  /// JSON-encoded annotation flags array.
  final String? flagsJson;

  /// JSON-encoded custom data dictionary.
  final String? customDataJson;

  /// Text content of the annotation.
  final String? contents;

  /// Subject of the annotation.
  final String? subject;

  /// Creator/author of the annotation.
  final String? creator;

  /// JSON-encoded bounding box `{"x", "y", "width", "height"}`.
  final String? bboxJson;

  /// Popup/review note text.
  final String? note;

  /// JSON-encoded ink lines array.
  final String? inkLinesJson;

  /// Font name for free-text annotations.
  final String? fontName;

  /// Font size for free-text annotations.
  final double? fontSize;

  /// Icon name for note/stamp annotations.
  final String? iconName;

  const AnnotationProperties({
    this.annotationId,
    this.pageIndex,
    this.strokeColor,
    this.fillColor,
    this.opacity,
    this.lineWidth,
    this.flagsJson,
    this.customDataJson,
    this.contents,
    this.subject,
    this.creator,
    this.bboxJson,
    this.note,
    this.inkLinesJson,
    this.fontName,
    this.fontSize,
    this.iconName,
  });

  /// Creates [AnnotationProperties] from a JSON map.
  factory AnnotationProperties.fromJson(Map<String, dynamic> json) {
    return AnnotationProperties(
      annotationId: json['annotationId'] as String?,
      pageIndex: json['pageIndex'] as int?,
      strokeColor: _parseColor(json['strokeColor']),
      fillColor: _parseColor(json['fillColor']),
      opacity: (json['opacity'] as num?)?.toDouble(),
      lineWidth: (json['lineWidth'] as num?)?.toDouble(),
      flagsJson: _readFlags(json),
      // The model carries custom data as a JSON *string* (`customDataJson`),
      // but InstantJSON and the Web SDK key it as `customData` (an object).
      // Accept either: a pre-encoded `customDataJson` string, or a
      // `customData` object that we encode to a string here.
      customDataJson: _readCustomData(json),
      contents: json['contents'] as String?,
      subject: json['subject'] as String?,
      creator: json['creator'] as String?,
      bboxJson: json['bboxJson'] as String?,
      note: json['note'] as String?,
      inkLinesJson: json['inkLinesJson'] as String?,
      fontName: json['fontName'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      iconName: json['iconName'] as String?,
    );
  }

  static String? _readCustomData(Map<String, dynamic> json) {
    final raw = json['customDataJson'];
    if (raw is String) return raw;
    final obj = json['customData'];
    if (obj == null) return null;
    if (obj is String) return obj;
    try {
      return jsonEncode(obj);
    } catch (_) {
      return null;
    }
  }

  // The model carries flags as a JSON *string* (`flagsJson`), but InstantJSON
  // and the Web SDK key them as `flags` (an array of flag-name strings). Accept
  // either: a pre-encoded `flagsJson` string, or a `flags` array that we encode
  // to a string here — so `getAnnotationProperties` populates flags on read.
  static String? _readFlags(Map<String, dynamic> json) {
    final raw = json['flagsJson'];
    if (raw is String) return raw;
    final list = json['flags'];
    if (list is List) {
      try {
        return jsonEncode(list.map((e) => e.toString()).toList());
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Converts these properties to a JSON map, omitting null values.
  Map<String, dynamic> toJson() => {
        if (annotationId != null) 'annotationId': annotationId,
        if (pageIndex != null) 'pageIndex': pageIndex,
        if (strokeColor != null) 'strokeColor': strokeColor,
        if (fillColor != null) 'fillColor': fillColor,
        if (opacity != null) 'opacity': opacity,
        if (lineWidth != null) 'lineWidth': lineWidth,
        if (flagsJson != null) 'flagsJson': flagsJson,
        if (customDataJson != null) 'customDataJson': customDataJson,
        if (contents != null) 'contents': contents,
        if (subject != null) 'subject': subject,
        if (creator != null) 'creator': creator,
        if (bboxJson != null) 'bboxJson': bboxJson,
        if (note != null) 'note': note,
        if (inkLinesJson != null) 'inkLinesJson': inkLinesJson,
        if (fontName != null) 'fontName': fontName,
        if (fontSize != null) 'fontSize': fontSize,
        if (iconName != null) 'iconName': iconName,
      };

  /// The changed visual properties as **InstantJSON-shaped overrides**.
  ///
  /// Native `saveAnnotationProperties` implementations overlay these onto the
  /// annotation's existing InstantJSON. Unlike [toJson] (which uses the model's
  /// own vocabulary — ARGB-int colours, an `annotationId` key), this emits
  /// valid InstantJSON: colours as `"#RRGGBB"` hex strings, and no identity
  /// keys (`annotationId` / `pageIndex` aren't InstantJSON fields and would be
  /// rejected). Only the visually-editable fields are included; null (untouched)
  /// fields are omitted so unchanged properties are left alone.
  Map<String, dynamic> toInstantJsonOverrides() => {
        if (strokeColor != null) 'strokeColor': _argbToHex(strokeColor!),
        if (fillColor != null) 'fillColor': _argbToHex(fillColor!),
        if (opacity != null) 'opacity': opacity,
        if (lineWidth != null) 'lineWidth': lineWidth,
        if (contents != null) 'contents': contents,
        // InstantJSON keys flags as a `flags` array of flag-name strings; the
        // model stores them as a JSON string, so decode before merging. The
        // full set replaces the annotation's flags (callers send the complete
        // set), so untouched flags are preserved and cleared ones are removed.
        if (_flagsList() != null) 'flags': _flagsList(),
        // InstantJSON keys custom data as `customData` (an object); the model
        // stores it as a JSON string, so decode before merging. A non-JSON
        // string is dropped rather than corrupting the InstantJSON.
        if (_customDataObject() != null) 'customData': _customDataObject(),
      };

  Object? _customDataObject() {
    final raw = customDataJson;
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  List<String>? _flagsList() {
    final raw = flagsJson;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
    return null;
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// Platform `getAnnotationProperties` implementations build the result from
  /// the annotation's InstantJSON, which keys the identifier as `name` (not
  /// `annotationId`) and so leaves [annotationId] null. They use this to stamp
  /// the authoritative `annotationId` / `pageIndex` they were queried with back
  /// onto the result, so callers (and a subsequent `saveAnnotationProperties`)
  /// always have the id they looked the annotation up by.
  AnnotationProperties copyWith({
    String? annotationId,
    int? pageIndex,
    int? strokeColor,
    int? fillColor,
    double? opacity,
    double? lineWidth,
    String? flagsJson,
    String? customDataJson,
    String? contents,
    String? subject,
    String? creator,
    String? bboxJson,
    String? note,
    String? inkLinesJson,
    String? fontName,
    double? fontSize,
    String? iconName,
  }) =>
      AnnotationProperties(
        annotationId: annotationId ?? this.annotationId,
        pageIndex: pageIndex ?? this.pageIndex,
        strokeColor: strokeColor ?? this.strokeColor,
        fillColor: fillColor ?? this.fillColor,
        opacity: opacity ?? this.opacity,
        lineWidth: lineWidth ?? this.lineWidth,
        flagsJson: flagsJson ?? this.flagsJson,
        customDataJson: customDataJson ?? this.customDataJson,
        contents: contents ?? this.contents,
        subject: subject ?? this.subject,
        creator: creator ?? this.creator,
        bboxJson: bboxJson ?? this.bboxJson,
        note: note ?? this.note,
        inkLinesJson: inkLinesJson ?? this.inkLinesJson,
        fontName: fontName ?? this.fontName,
        fontSize: fontSize ?? this.fontSize,
        iconName: iconName ?? this.iconName,
      );

  /// Formats an ARGB int as an InstantJSON `"#RRGGBB"` hex string (alpha is
  /// carried separately as `opacity`).
  static String _argbToHex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  String toString() => 'AnnotationProperties(annotationId: $annotationId, '
      'pageIndex: $pageIndex)';
}

// Accepts an ARGB int (native platforms) or a CSS hex string like
// "#607d8b" / "#aarrggbb" (Web SDK, see NutrientAnnotationOperations).
int? _parseColor(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    var hex = value.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    return int.tryParse(hex, radix: 16);
  }
  return null;
}
