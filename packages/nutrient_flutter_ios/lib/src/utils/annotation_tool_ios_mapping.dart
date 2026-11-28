///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as iface;

import '../bindings/nutrient_ios_bindings.dart' as ios;

/// Names of the iOS `PSPDFAnnotationString` constants that each PI
/// [iface.AnnotationTool] maps to, or `null` if the iOS SDK has no
/// direct equivalent at this layer.
///
/// This is the unit-testable core of the mapping — no FFI symbol
/// resolution happens here, so tests can run on the host without a
/// running iOS SDK. [iosAnnotationStringFor] uses this to look up the
/// corresponding `PSPDFAnnotationString*` global constant.
///
/// Mapping notes:
/// - `inkPen` / `inkMagic` / `inkHighlighter` all collapse to the iOS
///   `Ink` string; the SDK uses an `AnnotationToolVariant` to
///   differentiate, which we don't surface yet.
/// - `arrow` → `Line` (iOS arrows are line annotations with end-line
///   caps configured via the style manager).
/// - `cloudy` → `Square` (iOS exposes cloudy as a border-style on shape
///   tools, not a separate tool).
/// - `measurement*` → the base shape string (`Line`, `PolyLine`,
///   `Square`, `Circle`, `Polygon`) combined with the matching
///   `PSPDFAnnotationVariantString*Measurement` variant from
///   [iosAnnotationVariantFor].
/// - `freeTextCallOut` → `FreeText` + the `FreeTextCallout` variant.
/// - `widget` → `null` (no direct `PSPDFAnnotationString` equivalent at this
///   layer).
String? iosAnnotationStringNameFor(iface.AnnotationTool tool) {
  switch (tool) {
    case iface.AnnotationTool.inkPen:
    case iface.AnnotationTool.inkMagic:
    case iface.AnnotationTool.inkHighlighter:
      return 'Ink';

    case iface.AnnotationTool.highlight:
      return 'Highlight';
    case iface.AnnotationTool.underline:
      return 'Underline';
    case iface.AnnotationTool.strikeOut:
      return 'StrikeOut';
    case iface.AnnotationTool.squiggly:
      return 'Squiggly';

    case iface.AnnotationTool.freeText:
      return 'FreeText';

    case iface.AnnotationTool.line:
    case iface.AnnotationTool.arrow:
      return 'Line';
    case iface.AnnotationTool.square:
    case iface.AnnotationTool.cloudy:
      return 'Square';
    case iface.AnnotationTool.circle:
      return 'Circle';
    case iface.AnnotationTool.polygon:
      return 'Polygon';
    case iface.AnnotationTool.polyline:
      return 'PolyLine';

    case iface.AnnotationTool.note:
      return 'Note';
    case iface.AnnotationTool.signature:
      return 'Signature';
    case iface.AnnotationTool.stamp:
    case iface.AnnotationTool.image:
    case iface.AnnotationTool.stampImage:
      return 'Stamp';
    case iface.AnnotationTool.eraser:
      return 'Eraser';
    case iface.AnnotationTool.redaction:
      return 'Redaction';
    case iface.AnnotationTool.sound:
      return 'Sound';
    case iface.AnnotationTool.link:
      return 'Link';
    case iface.AnnotationTool.caret:
      return 'Caret';
    case iface.AnnotationTool.richMedia:
      return 'RichMedia';
    case iface.AnnotationTool.screen:
      return 'Screen';
    case iface.AnnotationTool.file:
      return 'File';

    // Measurement tools are the base shape state plus a measurement
    // variant — the annotation state manager differentiates by
    // (state, variant), matching how the SDK's own toolbar buttons work
    // (see iosAnnotationVariantFor).
    case iface.AnnotationTool.measurementDistance:
      return 'Line';
    case iface.AnnotationTool.measurementPerimeter:
      return 'PolyLine';
    case iface.AnnotationTool.measurementAreaRect:
      return 'Square';
    case iface.AnnotationTool.measurementAreaEllipse:
      return 'Circle';
    case iface.AnnotationTool.measurementAreaPolygon:
      return 'Polygon';

    // Free-text callout is a FreeText annotation with the callout variant
    // (see iosAnnotationVariantFor).
    case iface.AnnotationTool.freeTextCallOut:
      return 'FreeText';

    // No direct iOS PSPDFAnnotationString equivalent at this layer.
    case iface.AnnotationTool.widget:
      return null;
  }
}

/// Resolves the iOS `PSPDFAnnotationString*` global constant for [tool],
/// or `null` if the iOS SDK has no direct equivalent.
///
/// Touches the FFI bindings to read the iOS SDK's NSString globals, so
/// this function cannot be invoked outside a running iOS process. See
/// [iosAnnotationStringNameFor] for the testable name-only lookup.
ios.DartPSPDFAnnotationString? iosAnnotationStringFor(
  iface.AnnotationTool tool,
) {
  final name = iosAnnotationStringNameFor(tool);
  if (name == null) return null;
  switch (name) {
    case 'Ink':
      return ios.PSPDFAnnotationStringInk;
    case 'Highlight':
      return ios.PSPDFAnnotationStringHighlight;
    case 'Underline':
      return ios.PSPDFAnnotationStringUnderline;
    case 'StrikeOut':
      return ios.PSPDFAnnotationStringStrikeOut;
    case 'Squiggly':
      return ios.PSPDFAnnotationStringSquiggly;
    case 'FreeText':
      return ios.PSPDFAnnotationStringFreeText;
    case 'Line':
      return ios.PSPDFAnnotationStringLine;
    case 'Square':
      return ios.PSPDFAnnotationStringSquare;
    case 'Circle':
      return ios.PSPDFAnnotationStringCircle;
    case 'Polygon':
      return ios.PSPDFAnnotationStringPolygon;
    case 'PolyLine':
      return ios.PSPDFAnnotationStringPolyLine;
    case 'Note':
      return ios.PSPDFAnnotationStringNote;
    case 'Signature':
      return ios.PSPDFAnnotationStringSignature;
    case 'Stamp':
      return ios.PSPDFAnnotationStringStamp;
    case 'Eraser':
      return ios.PSPDFAnnotationStringEraser;
    case 'Redaction':
      return ios.PSPDFAnnotationStringRedaction;
    case 'Sound':
      return ios.PSPDFAnnotationStringSound;
    case 'Link':
      return ios.PSPDFAnnotationStringLink;
    case 'Caret':
      return ios.PSPDFAnnotationStringCaret;
    case 'RichMedia':
      return ios.PSPDFAnnotationStringRichMedia;
    case 'Screen':
      return ios.PSPDFAnnotationStringScreen;
    case 'File':
      return ios.PSPDFAnnotationStringFile;
  }
  return null;
}

/// Resolves the iOS `PSPDFAnnotationVariantString*` constant for [tool], or
/// `null` when the tool has no associated variant.
///
/// The annotation toolbar identifies its buttons by (state, **variant**), so
/// entering a state without the matching variant leaves the button
/// un-highlighted. This matters most for the `Ink` state, which the pen /
/// highlighter / magic tools all share and differ only by variant — setting
/// the state on its own resets the variant to nil (see
/// `PSPDFAnnotationStateManager.setState(_:variant:)`).
///
/// Touches the FFI bindings to read the iOS SDK's NSString globals, so this
/// cannot be invoked outside a running iOS process.
ios.DartPSPDFAnnotationVariantString? iosAnnotationVariantFor(
  iface.AnnotationTool tool,
) {
  switch (tool) {
    case iface.AnnotationTool.inkPen:
      return ios.PSPDFAnnotationVariantStringInkPen;
    case iface.AnnotationTool.inkHighlighter:
      return ios.PSPDFAnnotationVariantStringInkHighlighter;
    case iface.AnnotationTool.inkMagic:
      return ios.PSPDFAnnotationVariantStringInkMagic;
    case iface.AnnotationTool.arrow:
      return ios.PSPDFAnnotationVariantStringLineArrow;
    case iface.AnnotationTool.freeTextCallOut:
      return ios.PSPDFAnnotationVariantStringFreeTextCallout;
    case iface.AnnotationTool.measurementDistance:
      return ios.PSPDFAnnotationVariantStringDistanceMeasurement;
    case iface.AnnotationTool.measurementPerimeter:
      return ios.PSPDFAnnotationVariantStringPerimeterMeasurement;
    case iface.AnnotationTool.measurementAreaRect:
      return ios.PSPDFAnnotationVariantStringRectangularAreaMeasurement;
    case iface.AnnotationTool.measurementAreaEllipse:
      return ios.PSPDFAnnotationVariantStringEllipticalAreaMeasurement;
    case iface.AnnotationTool.measurementAreaPolygon:
      return ios.PSPDFAnnotationVariantStringPolygonalAreaMeasurement;
    default:
      return null;
  }
}
