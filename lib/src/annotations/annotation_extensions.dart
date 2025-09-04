///
///  Copyright 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart' hide BorderStyle, Action;
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Extension methods for annotation classes providing [copyWith] functionality
extension AnnotationExtensions on Annotation {
  /// Returns updated time as ISO 8601 string for the current moment
  static String _currentTimestamp() => DateTime.now().toIso8601String();
}

/// Extension on [AnnotationTool] to provide web-specific name conversions
extension AnnotationToolWebExtension on AnnotationTool {
  /// Returns the appropriate string name to use with PSPDFKit Web's interaction modes
  String toWebName([AnnotationToolVariant? variant]) {
    switch (this) {
      // Ink tools
      case AnnotationTool.inkPen:
      case AnnotationTool.inkMagic:
      case AnnotationTool.inkHighlighter:
        return 'inkPen';

      // Text markup tools
      case AnnotationTool.highlight:
        return 'highlight';
      case AnnotationTool.underline:
        return 'underline';
      case AnnotationTool.strikeOut:
        return 'strikeOut';
      case AnnotationTool.squiggly:
        return 'squiggly';

      // Text tools
      case AnnotationTool.freeText:
        return 'freeText';
      case AnnotationTool.freeTextCallOut:
        return 'freeTextCallOut';

      // Shape tools
      case AnnotationTool.square:
        return 'square';
      case AnnotationTool.circle:
        return 'circle';
      case AnnotationTool.polygon:
        return 'polygon';
      case AnnotationTool.polyline:
        return 'polyline';

      // Line tools
      case AnnotationTool.line:
        return 'line';
      case AnnotationTool.arrow:
        return 'arrow';

      // Other annotation tools
      case AnnotationTool.note:
        return 'note';
      case AnnotationTool.stamp:
        return 'stamp';
      case AnnotationTool.stampImage:
        return 'stampImage';
      case AnnotationTool.image:
        return 'image';
      case AnnotationTool.signature:
        return 'signature';
      case AnnotationTool.eraser:
        return 'eraser';
      case AnnotationTool.link:
        return 'link';

      // Widget annotation tools
      case AnnotationTool.widget:
        return 'widget';
      case AnnotationTool.file:
        return 'file';

      // Other annotation tools
      case AnnotationTool.caret:
        return 'caret';
      case AnnotationTool.redaction:
        return 'redaction';
      case AnnotationTool.sound:
        return 'sound';
      case AnnotationTool.richMedia:
        return 'richMedia';
      case AnnotationTool.screen:
        return 'screen';
      case AnnotationTool.cloudy:
        return 'cloudy';

      // Measurement tools
      case AnnotationTool.measurementDistance:
        return 'measurementDistance';
      case AnnotationTool.measurementPerimeter:
        return 'measurementPerimeter';
      case AnnotationTool.measurementAreaRect:
        return 'measurementAreaRect';
      case AnnotationTool.measurementAreaEllipse:
        return 'measurementAreaEllipse';
      case AnnotationTool.measurementAreaPolygon:
        return 'measurementAreaPolygon';

      // Default fallback
      default:
        return 'pan';
    }
  }

  /// Returns the appropriate PSPDFKit Web InteractionMode string
  String toWebInteractionMode([AnnotationToolVariant? variant]) {
    switch (this) {
      // Ink tools
      case AnnotationTool.inkPen:
      case AnnotationTool.inkMagic:
      case AnnotationTool.inkHighlighter:
        return 'INK';

      // Text markup tools
      case AnnotationTool.highlight:
        return 'TEXT_HIGHLIGHTER';
      case AnnotationTool.underline:
        return 'TEXT_UNDERLINE';
      case AnnotationTool.strikeOut:
        return 'TEXT_STRIKEOUT';
      case AnnotationTool.squiggly:
        return 'TEXT_SQUIGGLY';

      // Text tools
      case AnnotationTool.freeText:
        return 'TEXT';
      case AnnotationTool.freeTextCallOut:
        return 'CALLOUT';

      // Shape tools
      case AnnotationTool.square:
        return 'SHAPE_RECTANGLE';
      case AnnotationTool.circle:
        return 'SHAPE_ELLIPSE';
      case AnnotationTool.polygon:
        return 'SHAPE_POLYGON';
      case AnnotationTool.polyline:
        return 'SHAPE_POLYLINE';

      // Line tools
      case AnnotationTool.line:
        return 'SHAPE_LINE';
      case AnnotationTool.arrow:
        return 'ARROW';

      // Other annotation tools
      case AnnotationTool.note:
        return 'NOTE';
      case AnnotationTool.stamp:
        return 'STAMP_PICKER';
      case AnnotationTool.stampImage:
        return 'STAMP_CUSTOM';
      case AnnotationTool.image:
        return 'IMAGE';
      case AnnotationTool.signature:
        return 'SIGNATURE';
      case AnnotationTool.eraser:
        return 'INK_ERASER';
      case AnnotationTool.link:
        return 'LINK';

      // Widget annotation tools
      case AnnotationTool.widget:
        return 'FORM_CREATOR';
      case AnnotationTool.file:
        return 'DOCUMENT_EDITOR';

      // Other annotation tools
      case AnnotationTool.caret:
        return 'COMMENT_MARKER';
      case AnnotationTool.redaction:
        return 'REDACT_TEXT_HIGHLIGHTER';
      case AnnotationTool.sound:
        return 'NOTE'; // Sound annotations use note interaction mode
      case AnnotationTool.richMedia:
        return 'NOTE'; // Rich media annotations use note interaction mode
      case AnnotationTool.screen:
        return 'NOTE'; // Screen annotations use note interaction mode
      case AnnotationTool.cloudy:
        return 'SHAPE_RECTANGLE'; // Cloudy is a border style, not a separate interaction mode

      // Measurement tools
      case AnnotationTool.measurementDistance:
        return 'DISTANCE';
      case AnnotationTool.measurementPerimeter:
        return 'PERIMETER';
      case AnnotationTool.measurementAreaRect:
        return 'RECTANGLE_AREA';
      case AnnotationTool.measurementAreaEllipse:
        return 'ELLIPSE_AREA';
      case AnnotationTool.measurementAreaPolygon:
        return 'POLYGON_AREA';

      // Default fallback
      default:
        return 'PAN';
    }
  }
}

/// Extension methods for [SquareAnnotation]
extension SquareAnnotationExtensions on SquareAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  SquareAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    Color? strokeColor,
    double? strokeWidth,
    Color? fillColor,
    BorderStyle? borderStyle,
    List<double>? borderDashArray,
    double? cloudyBorderIntensity,
    List<double>? cloudyBorderInset,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
    String? note,
    MeasurementScale? measurementScale,
    MeasurementPrecision? measurementPrecision,
    List<double>? measurementBBox,
  }) {
    return SquareAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fillColor: fillColor ?? this.fillColor,
      borderStyle: borderStyle ?? this.borderStyle,
      borderDashArray: borderDashArray ?? this.borderDashArray,
      cloudyBorderIntensity:
          cloudyBorderIntensity ?? this.cloudyBorderIntensity,
      cloudyBorderInset: cloudyBorderInset ?? this.cloudyBorderInset,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
      note: note ?? this.note,
      measurementScale: measurementScale ?? this.measurementScale,
      measurementPrecision: measurementPrecision ?? this.measurementPrecision,
      measurementBBox: measurementBBox ?? this.measurementBBox,
    );
  }
}

/// Extension methods for [NoteAnnotation]
extension NoteAnnotationExtensions on NoteAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  NoteAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    Color? color,
    TextContent? text,
    NoteIcon? icon,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return NoteAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      color: color ?? this.color,
      text: text ?? this.text,
      icon: icon ?? this.icon,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [InkAnnotation]
extension InkAnnotationExtensions on InkAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  InkAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    Color? strokeColor,
    double? lineWidth,
    InkLines? lines,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return InkAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      lineWidth: lineWidth ?? this.lineWidth,
      lines: lines ?? this.lines,
      strokeColor: strokeColor ?? this.strokeColor,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [HighlightAnnotation]
extension HighlightAnnotationExtensions on HighlightAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  HighlightAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    Color? color,
    List<List<double>>? rects,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return HighlightAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      color: color ?? this.color,
      rects: rects ?? this.rects,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [FreeTextAnnotation]
extension FreeTextAnnotationExtensions on FreeTextAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  FreeTextAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? creatorName,
    TextContent? text,
    double? fontSize,
    Color? backgroundColor,
    String? font,
    HorizontalTextAlignment? horizontalTextAlign,
    VerticalAlignment? verticalAlign,
    Color? fontColor,
    bool? isFitting,
    bool? disableAutoReturn,
    Map<String, dynamic>? callout,
    BorderStyle? borderStyle,
    List<double>? borderDashArray,
    double? borderWidth,
    int? rotation,
    double? cloudyBorderIntensity,
    List<double>? cloudyBorderInset,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
    int? v,
  }) {
    return FreeTextAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      creatorName: creatorName ?? this.creatorName,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      font: font ?? this.font,
      horizontalTextAlign: horizontalTextAlign ?? this.horizontalTextAlign,
      verticalAlign: verticalAlign ?? this.verticalAlign,
      fontColor: fontColor ?? this.fontColor,
      isFitting: isFitting ?? this.isFitting,
      disableAutoReturn: disableAutoReturn ?? this.disableAutoReturn,
      callout: callout ?? this.callout,
      borderStyle: borderStyle ?? this.borderStyle,
      borderDashArray: borderDashArray ?? this.borderDashArray,
      borderWidth: borderWidth ?? this.borderWidth,
      rotation: rotation ?? this.rotation,
      cloudyBorderIntensity:
          cloudyBorderIntensity ?? this.cloudyBorderIntensity,
      cloudyBorderInset: cloudyBorderInset ?? this.cloudyBorderInset,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
      v: v ?? this.v,
    );
  }
}

/// Extension methods for [StampAnnotation]
extension StampAnnotationExtensions on StampAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  StampAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? title,
    String? name,
    StampType? stampType,
    Color? color,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? subject,
    bool? hidden,
  }) {
    return StampAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      title: title ?? this.title,
      name: name ?? this.name,
      stampType: stampType ?? this.stampType,
      color: color ?? this.color,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [LineAnnotation]
extension LineAnnotationExtensions on LineAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  LineAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    List<double>? startPoint,
    List<double>? endPoint,
    Color? strokeColor,
    double? strokeWidth,
    LineCaps? lineCaps,
    BorderStyle? borderStyle,
    List<double>? borderDashArray,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return LineAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      lineCaps: lineCaps ?? this.lineCaps,
      borderStyle: borderStyle ?? this.borderStyle,
      borderDashArray: borderDashArray ?? this.borderDashArray,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [CircleAnnotation]
extension CircleAnnotationExtensions on CircleAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  CircleAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    Color? strokeColor,
    double? strokeWidth,
    Color? fillColor,
    BorderStyle? borderStyle,
    List<double>? borderDashArray,
    double? cloudyBorderIntensity,
    List<double>? cloudyBorderInset,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
    String? note,
    MeasurementScale? measurementScale,
    MeasurementPrecision? measurementPrecision,
    List<double>? measurementBBox,
  }) {
    return CircleAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fillColor: fillColor ?? this.fillColor,
      borderStyle: borderStyle ?? this.borderStyle,
      borderDashArray: borderDashArray ?? this.borderDashArray,
      cloudyBorderIntensity:
          cloudyBorderIntensity ?? this.cloudyBorderIntensity,
      cloudyBorderInset: cloudyBorderInset ?? this.cloudyBorderInset,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
      note: note ?? this.note,
      measurementScale: measurementScale ?? this.measurementScale,
      measurementPrecision: measurementPrecision ?? this.measurementPrecision,
      measurementBBox: measurementBBox ?? this.measurementBBox,
    );
  }
}

/// Extension methods for [StrikeoutAnnotation]
extension StrikeoutAnnotationExtensions on StrikeoutAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  StrikeoutAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    List<List<double>>? rects,
    BlendMode? blendMode,
    Color? color,
    String? note,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return StrikeoutAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      rects: rects ?? this.rects,
      blendMode: blendMode ?? this.blendMode,
      color: color ?? this.color,
      note: note ?? this.note,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [UnderlineAnnotation]
extension UnderlineAnnotationExtensions on UnderlineAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  UnderlineAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    List<List<double>>? rects,
    BlendMode? blendMode,
    Color? color,
    String? note,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return UnderlineAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      rects: rects ?? this.rects,
      blendMode: blendMode ?? this.blendMode,
      color: color ?? this.color,
      note: note ?? this.note,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [SquigglyAnnotation]
extension SquigglyAnnotationExtensions on SquigglyAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  SquigglyAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    List<List<double>>? rects,
    BlendMode? blendMode,
    Color? color,
    String? note,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return SquigglyAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      rects: rects ?? this.rects,
      blendMode: blendMode ?? this.blendMode,
      color: color ?? this.color,
      note: note ?? this.note,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [PolygonAnnotation]
extension PolygonAnnotationExtensions on PolygonAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  PolygonAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    List<List<double>>? points,
    Color? strokeColor,
    double? strokeWidth,
    Color? fillColor,
    BorderStyle? borderStyle,
    List<double>? borderDashArray,
    double? cloudyBorderIntensity,
    List<double>? cloudyBorderInset,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
    String? note,
  }) {
    return PolygonAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      points: points ?? this.points,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fillColor: fillColor ?? this.fillColor,
      borderStyle: borderStyle ?? this.borderStyle,
      borderDashArray: borderDashArray ?? this.borderDashArray,
      cloudyBorderIntensity:
          cloudyBorderIntensity ?? this.cloudyBorderIntensity,
      cloudyBorderInset: cloudyBorderInset ?? this.cloudyBorderInset,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
      note: note ?? this.note,
    );
  }
}

/// Extension methods for [PolylineAnnotation]
extension PolylineAnnotationExtensions on PolylineAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  PolylineAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    List<List<double>>? points,
    Color? strokeColor,
    double? strokeWidth,
    BorderStyle? borderStyle,
    List<double>? borderDashArray,
    String? startStyle,
    String? endStyle,
    Color? fillColor,
    double? cloudyBorderIntensity,
    List<double>? cloudyBorderInset,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
    String? note,
    MeasurementScale? measurementScale,
    MeasurementPrecision? measurementPrecision,
    List<double>? measurementBBox,
  }) {
    return PolylineAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      points: points ?? this.points,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      borderStyle: borderStyle ?? this.borderStyle,
      borderDashArray: borderDashArray ?? this.borderDashArray,
      startStyle: startStyle ?? this.startStyle,
      endStyle: endStyle ?? this.endStyle,
      fillColor: fillColor ?? this.fillColor,
      cloudyBorderIntensity:
          cloudyBorderIntensity ?? this.cloudyBorderIntensity,
      cloudyBorderInset: cloudyBorderInset ?? this.cloudyBorderInset,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
      note: note ?? this.note,
      measurementScale: measurementScale ?? this.measurementScale,
      measurementPrecision: measurementPrecision ?? this.measurementPrecision,
      measurementBBox: measurementBBox ?? this.measurementBBox,
    );
  }
}

/// Extension methods for [FileAnnotation]
extension FileAnnotationExtensions on FileAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  FileAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    FileIconName? iconName,
    EmbeddedFile? embeddedFile,
    AnnotationAttachment? attachment,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return FileAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      iconName: iconName ?? this.iconName,
      embeddedFile: embeddedFile ?? this.embeddedFile,
      attachment: attachment ?? this.attachment,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [RedactionAnnotation]
extension RedactionAnnotationExtensions on RedactionAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  RedactionAnnotation copyWith({
    String? id,
    List<List<double>>? rects,
    String? createdAt,
    int? pageIndex,
    Color? fillColor,
    String? overlayText,
    double? fontSize,
    Color? fontColor,
    String? repeat,
    Color? outlineColor,
    bool? repeatOverlayText,
    double? rotation,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return RedactionAnnotation(
      id: id ?? this.id,
      rects: rects ?? this.rects,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      fillColor: fillColor ?? this.fillColor,
      overlayText: overlayText ?? this.overlayText,
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      repeat: repeat ?? this.repeat,
      outlineColor: outlineColor ?? this.outlineColor,
      repeatOverlayText: repeatOverlayText ?? this.repeatOverlayText,
      rotation: rotation ?? this.rotation,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [WidgetAnnotation]
extension WidgetAnnotationExtensions on WidgetAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  WidgetAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? fieldName,
    String? fieldType,
    dynamic value,
    List<String>? options,
    bool? readOnly,
    bool? required,
    bool? multiline,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return WidgetAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      value: value ?? this.value,
      options: options ?? this.options,
      readOnly: readOnly ?? this.readOnly,
      required: required ?? this.required,
      multiline: multiline ?? this.multiline,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [LinkAnnotation]
extension LinkAnnotationExtensions on LinkAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  LinkAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    Action? action,
    String? note,
    BorderStyle? borderStyle,
    double? borderWidth,
    Color? borderColor,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return LinkAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      action: action ?? this.action,
      note: note ?? this.note,
      borderStyle: borderStyle ?? this.borderStyle,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [SoundAnnotation]
extension SoundAnnotationExtensions on SoundAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  SoundAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? soundUrl,
    String? icon,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return SoundAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      soundUrl: soundUrl ?? this.soundUrl,
      icon: icon ?? this.icon,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [PopupAnnotation]
extension PopupAnnotationExtensions on PopupAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  PopupAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? contents,
    bool? open,
    String? parentId,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return PopupAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      contents: contents ?? this.contents,
      open: open ?? this.open,
      parentId: parentId ?? this.parentId,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [CaretAnnotation]
extension CaretAnnotationExtensions on CaretAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  CaretAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? contents,
    Color? color,
    String? symbol,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return CaretAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      contents: contents ?? this.contents,
      color: color ?? this.color,
      symbol: symbol ?? this.symbol,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [WatermarkAnnotation]
extension WatermarkAnnotationExtensions on WatermarkAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  WatermarkAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? text,
    double? rotation,
    String? fontFamily,
    double? fontSize,
    Color? color,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return WatermarkAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      text: text ?? this.text,
      rotation: rotation ?? this.rotation,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [RichMediaAnnotation]
extension RichMediaAnnotationExtensions on RichMediaAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  RichMediaAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? contentType,
    String? fileName,
    String? description,
    String? mediaAttachmentId,
    String? mediaSource,
    Map<String, dynamic>? encoding,
    String? mediaType,
    String? source,
    Map<String, dynamic>? params,
    AnnotationAttachment? attachment,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return RichMediaAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      contentType: contentType ?? this.contentType,
      fileName: fileName ?? this.fileName,
      description: description ?? this.description,
      mediaAttachmentId: mediaAttachmentId ?? this.mediaAttachmentId,
      mediaSource: mediaSource ?? this.mediaSource,
      encoding: encoding ?? this.encoding,
      mediaType: mediaType ?? this.mediaType,
      source: source ?? this.source,
      params: params ?? this.params,
      attachment: attachment ?? this.attachment,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [ScreenAnnotation]
extension ScreenAnnotationExtensions on ScreenAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  ScreenAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? mediaType,
    String? source,
    bool? autoplay,
    bool? showControls,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return ScreenAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      mediaType: mediaType ?? this.mediaType,
      source: source ?? this.source,
      autoplay: autoplay ?? this.autoplay,
      showControls: showControls ?? this.showControls,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}

/// Extension methods for [Type3DAnnotation]
extension Type3DAnnotationExtensions on Type3DAnnotation {
  /// Creates a copy of this annotation with the given fields replaced with the new values
  Type3DAnnotation copyWith({
    String? id,
    List<double>? bbox,
    String? createdAt,
    int? pageIndex,
    String? source,
    String? poster,
    Map<String, dynamic>? viewSettings,
    String? creatorName,
    double? opacity,
    int? pdfObjectId,
    List<AnnotationFlag>? flags,
    String? updatedAt,
    String? name,
    String? subject,
    bool? hidden,
  }) {
    return Type3DAnnotation(
      id: id ?? this.id,
      bbox: bbox ?? this.bbox,
      createdAt: createdAt ?? this.createdAt,
      pageIndex: pageIndex ?? this.pageIndex,
      source: source ?? this.source,
      poster: poster ?? this.poster,
      viewSettings: viewSettings ?? this.viewSettings,
      creatorName: creatorName ?? this.creatorName,
      opacity: opacity ?? this.opacity,
      pdfObjectId: pdfObjectId ?? this.pdfObjectId,
      flags: flags ?? this.flags,
      updatedAt: updatedAt ?? AnnotationExtensions._currentTimestamp(),
      name: name ?? this.name,
      subject: subject ?? this.subject,
      hidden: hidden ?? this.hidden,
    );
  }
}
