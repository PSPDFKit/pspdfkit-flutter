///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// Tests target the host-runnable, JNI-free [androidAnnotationToolNameFor]
// helper. Do NOT exercise [toAndroidAnnotationTool] from these tests —
// it touches the generated JNI bindings (`android.AnnotationTool.INK`
// etc.), which require a running JVM.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_android/src/utils/annotation_tool_android_mapping.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

void main() {
  group('androidAnnotationToolNameFor', () {
    test('maps every supported tool to a non-empty Android enum name', () {
      const expected = <AnnotationTool, String>{
        AnnotationTool.inkPen: 'INK',
        AnnotationTool.inkHighlighter: 'INK',
        AnnotationTool.inkMagic: 'MAGIC_INK',
        AnnotationTool.highlight: 'HIGHLIGHT',
        AnnotationTool.underline: 'UNDERLINE',
        AnnotationTool.strikeOut: 'STRIKEOUT',
        AnnotationTool.squiggly: 'SQUIGGLY',
        AnnotationTool.freeText: 'FREETEXT',
        AnnotationTool.freeTextCallOut: 'FREETEXT_CALLOUT',
        AnnotationTool.line: 'LINE',
        AnnotationTool.square: 'SQUARE',
        AnnotationTool.circle: 'CIRCLE',
        AnnotationTool.polygon: 'POLYGON',
        AnnotationTool.polyline: 'POLYLINE',
        AnnotationTool.note: 'NOTE',
        AnnotationTool.signature: 'SIGNATURE',
        AnnotationTool.stamp: 'STAMP',
        AnnotationTool.image: 'IMAGE',
        AnnotationTool.eraser: 'ERASER',
        AnnotationTool.redaction: 'REDACTION',
        AnnotationTool.sound: 'SOUND',
        AnnotationTool.measurementDistance: 'MEASUREMENT_DISTANCE',
        AnnotationTool.measurementPerimeter: 'MEASUREMENT_PERIMETER',
        AnnotationTool.measurementAreaRect: 'MEASUREMENT_AREA_RECT',
        AnnotationTool.measurementAreaEllipse: 'MEASUREMENT_AREA_ELLIPSE',
        AnnotationTool.measurementAreaPolygon: 'MEASUREMENT_AREA_POLYGON',
      };
      for (final entry in expected.entries) {
        expect(
          androidAnnotationToolNameFor(entry.key),
          entry.value,
          reason: '${entry.key} should map to ${entry.value}',
        );
      }
    });

    test('returns null for tools without an Android equivalent', () {
      const unsupported = <AnnotationTool>{
        AnnotationTool.arrow,
        AnnotationTool.cloudy,
        AnnotationTool.link,
        AnnotationTool.caret,
        AnnotationTool.richMedia,
        AnnotationTool.screen,
        AnnotationTool.file,
        AnnotationTool.widget,
        AnnotationTool.stampImage,
      };
      for (final tool in unsupported) {
        expect(
          androidAnnotationToolNameFor(tool),
          isNull,
          reason: '$tool should not map to a Java enum value',
        );
      }
    });

    test('covers every AnnotationTool value (no enum drift)', () {
      // If a new value is added to AnnotationTool, this test fails until the
      // mapping is updated, preventing silent un-mapped tools.
      for (final tool in AnnotationTool.values) {
        expect(
          () => androidAnnotationToolNameFor(tool),
          returnsNormally,
          reason: '$tool needs to be added to the switch in '
              'androidAnnotationToolNameFor',
        );
      }
    });

    test('every non-null name is a valid Java enum identifier', () {
      // Java enum constants are SCREAMING_SNAKE_CASE: uppercase letters,
      // digits, and underscores only.
      final identifierPattern = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final tool in AnnotationTool.values) {
        final name = androidAnnotationToolNameFor(tool);
        if (name == null) continue;
        expect(
          identifierPattern.hasMatch(name),
          isTrue,
          reason: '$tool maps to "$name" which is not a valid Java enum '
              'identifier',
        );
      }
    });
  });
}
