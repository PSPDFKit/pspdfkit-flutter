///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Maps an [AnnotationTool] to the corresponding PSPDFKit Web SDK
/// `InteractionMode` constant name.
///
/// Some annotation tools don't have a 1:1 Web SDK equivalent:
/// - underline / strikeOut / squiggly: Web SDK exposes only TEXT_HIGHLIGHTER;
///   the specific text-markup style is selected via the annotation preset
///   (see [annotationPresetForTextMarkupTool]).
/// - arrow: Web SDK uses SHAPE_LINE with end-line caps configured separately.
/// - image: Web SDK uses STAMP_CUSTOM; images are stamp annotations.
String webInteractionModeFor(AnnotationTool tool) {
  switch (tool) {
    case AnnotationTool.inkPen:
    case AnnotationTool.inkMagic:
    case AnnotationTool.inkHighlighter:
      return 'INK';

    case AnnotationTool.highlight:
    case AnnotationTool.underline:
    case AnnotationTool.strikeOut:
    case AnnotationTool.squiggly:
      return 'TEXT_HIGHLIGHTER';

    case AnnotationTool.freeText:
      return 'TEXT';
    case AnnotationTool.freeTextCallOut:
      return 'CALLOUT';

    case AnnotationTool.square:
      return 'SHAPE_RECTANGLE';
    case AnnotationTool.circle:
      return 'SHAPE_ELLIPSE';
    case AnnotationTool.polygon:
      return 'SHAPE_POLYGON';
    case AnnotationTool.polyline:
      return 'SHAPE_POLYLINE';

    case AnnotationTool.line:
    case AnnotationTool.arrow:
      return 'SHAPE_LINE';

    case AnnotationTool.note:
      return 'NOTE';
    case AnnotationTool.stamp:
      return 'STAMP_PICKER';
    case AnnotationTool.stampImage:
    case AnnotationTool.image:
      return 'STAMP_CUSTOM';
    case AnnotationTool.signature:
      return 'SIGNATURE';
    case AnnotationTool.eraser:
      return 'INK_ERASER';
    case AnnotationTool.link:
      return 'LINK';

    case AnnotationTool.widget:
      return 'FORM_CREATOR';
    case AnnotationTool.file:
      return 'DOCUMENT_EDITOR';

    case AnnotationTool.caret:
      return 'COMMENT_MARKER';
    case AnnotationTool.redaction:
      return 'REDACT_TEXT_HIGHLIGHTER';
    // Sound, rich-media, screen all use the note interaction mode on web.
    case AnnotationTool.sound:
    case AnnotationTool.richMedia:
    case AnnotationTool.screen:
      return 'NOTE';
    // Cloudy is a border style, surfaced via the rectangle shape mode.
    case AnnotationTool.cloudy:
      return 'SHAPE_RECTANGLE';

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
  }
}

/// Returns the annotation preset id that disambiguates a text-markup tool
/// when the underlying interaction mode is `TEXT_HIGHLIGHTER`.
///
/// Returns `null` for tools that don't need a preset.
String? annotationPresetForTextMarkupTool(AnnotationTool tool) {
  switch (tool) {
    case AnnotationTool.highlight:
      return 'highlight';
    case AnnotationTool.underline:
      return 'underline';
    case AnnotationTool.strikeOut:
      return 'strikeout';
    case AnnotationTool.squiggly:
      return 'squiggly';
    default:
      return null;
  }
}
