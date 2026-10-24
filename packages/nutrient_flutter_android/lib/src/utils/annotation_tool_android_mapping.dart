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

import '../bindings/nutrient_android_sdk_bindings.dart' as android;

/// Names of the Android JNI `AnnotationTool` enum values that each PI
/// [iface.AnnotationTool] maps to, or `null` if the Android SDK has no
/// direct equivalent at this layer.
///
/// This is the unit-testable core of the mapping — it doesn't touch JNI,
/// so tests can run on the host without a JVM. [toAndroidAnnotationTool]
/// uses this to look up the corresponding Java enum value.
///
/// Mapping notes:
/// - `inkHighlighter` → `INK` (Android doesn't expose a separate
///   highlighter ink mode; the user gets the regular ink tool).
/// - `cloudy` → `null` (Android exposes cloudy as a border-style on
///   shape tools, not a separate tool).
/// - `caret`, `link`, `arrow`, `widget`, `file`, `richMedia`, `screen`,
///   `stampImage` → `null` (no direct Android equivalent at this layer).
String? androidAnnotationToolNameFor(iface.AnnotationTool tool) {
  switch (tool) {
    case iface.AnnotationTool.inkPen:
    case iface.AnnotationTool.inkHighlighter:
      return 'INK';
    case iface.AnnotationTool.inkMagic:
      return 'MAGIC_INK';

    case iface.AnnotationTool.highlight:
      return 'HIGHLIGHT';
    case iface.AnnotationTool.underline:
      return 'UNDERLINE';
    case iface.AnnotationTool.strikeOut:
      return 'STRIKEOUT';
    case iface.AnnotationTool.squiggly:
      return 'SQUIGGLY';

    case iface.AnnotationTool.freeText:
      return 'FREETEXT';
    case iface.AnnotationTool.freeTextCallOut:
      return 'FREETEXT_CALLOUT';

    case iface.AnnotationTool.line:
      return 'LINE';
    case iface.AnnotationTool.square:
      return 'SQUARE';
    case iface.AnnotationTool.circle:
      return 'CIRCLE';
    case iface.AnnotationTool.polygon:
      return 'POLYGON';
    case iface.AnnotationTool.polyline:
      return 'POLYLINE';

    case iface.AnnotationTool.note:
      return 'NOTE';
    case iface.AnnotationTool.signature:
      return 'SIGNATURE';
    case iface.AnnotationTool.stamp:
      return 'STAMP';
    case iface.AnnotationTool.image:
      return 'IMAGE';
    case iface.AnnotationTool.eraser:
      return 'ERASER';
    case iface.AnnotationTool.redaction:
      return 'REDACTION';
    case iface.AnnotationTool.sound:
      return 'SOUND';

    case iface.AnnotationTool.measurementDistance:
      return 'MEASUREMENT_DISTANCE';
    case iface.AnnotationTool.measurementPerimeter:
      return 'MEASUREMENT_PERIMETER';
    case iface.AnnotationTool.measurementAreaRect:
      return 'MEASUREMENT_AREA_RECT';
    case iface.AnnotationTool.measurementAreaEllipse:
      return 'MEASUREMENT_AREA_ELLIPSE';
    case iface.AnnotationTool.measurementAreaPolygon:
      return 'MEASUREMENT_AREA_POLYGON';

    // No direct Android equivalent at this layer.
    case iface.AnnotationTool.arrow:
    case iface.AnnotationTool.cloudy:
    case iface.AnnotationTool.link:
    case iface.AnnotationTool.caret:
    case iface.AnnotationTool.richMedia:
    case iface.AnnotationTool.screen:
    case iface.AnnotationTool.file:
    case iface.AnnotationTool.widget:
    case iface.AnnotationTool.stampImage:
      return null;
  }
}

/// Maps a platform-interface [iface.AnnotationTool] to its Android JNI
/// `AnnotationTool` enum equivalent.
///
/// Returns `null` when the Android SDK does not have a direct equivalent
/// — callers should treat that as an unsupported tool and report a
/// failure to the user code (typically `false` from
/// `enterAnnotationCreationMode`).
///
/// Touches the JNI bindings to look up the Java enum static field, so
/// this function cannot be invoked outside a running JVM. See
/// [androidAnnotationToolNameFor] for the testable name-only lookup.
android.AnnotationTool? toAndroidAnnotationTool(iface.AnnotationTool tool) {
  final name = androidAnnotationToolNameFor(tool);
  if (name == null) return null;
  switch (name) {
    case 'INK':
      return android.AnnotationTool.INK;
    case 'MAGIC_INK':
      return android.AnnotationTool.MAGIC_INK;
    case 'HIGHLIGHT':
      return android.AnnotationTool.HIGHLIGHT;
    case 'UNDERLINE':
      return android.AnnotationTool.UNDERLINE;
    case 'STRIKEOUT':
      return android.AnnotationTool.STRIKEOUT;
    case 'SQUIGGLY':
      return android.AnnotationTool.SQUIGGLY;
    case 'FREETEXT':
      return android.AnnotationTool.FREETEXT;
    case 'FREETEXT_CALLOUT':
      return android.AnnotationTool.FREETEXT_CALLOUT;
    case 'LINE':
      return android.AnnotationTool.LINE;
    case 'SQUARE':
      return android.AnnotationTool.SQUARE;
    case 'CIRCLE':
      return android.AnnotationTool.CIRCLE;
    case 'POLYGON':
      return android.AnnotationTool.POLYGON;
    case 'POLYLINE':
      return android.AnnotationTool.POLYLINE;
    case 'NOTE':
      return android.AnnotationTool.NOTE;
    case 'SIGNATURE':
      return android.AnnotationTool.SIGNATURE;
    case 'STAMP':
      return android.AnnotationTool.STAMP;
    case 'IMAGE':
      return android.AnnotationTool.IMAGE;
    case 'ERASER':
      return android.AnnotationTool.ERASER;
    case 'REDACTION':
      return android.AnnotationTool.REDACTION;
    case 'SOUND':
      return android.AnnotationTool.SOUND;
    case 'MEASUREMENT_DISTANCE':
      return android.AnnotationTool.MEASUREMENT_DISTANCE;
    case 'MEASUREMENT_PERIMETER':
      return android.AnnotationTool.MEASUREMENT_PERIMETER;
    case 'MEASUREMENT_AREA_RECT':
      return android.AnnotationTool.MEASUREMENT_AREA_RECT;
    case 'MEASUREMENT_AREA_ELLIPSE':
      return android.AnnotationTool.MEASUREMENT_AREA_ELLIPSE;
    case 'MEASUREMENT_AREA_POLYGON':
      return android.AnnotationTool.MEASUREMENT_AREA_POLYGON;
  }
  return null;
}
