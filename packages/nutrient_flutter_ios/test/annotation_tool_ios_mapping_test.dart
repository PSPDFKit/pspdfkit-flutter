///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// Tests target the host-runnable, FFI-free [iosAnnotationStringNameFor]
// helper. Do NOT exercise [iosAnnotationStringFor] from these tests —
// it dereferences the iOS SDK's NSString globals via FFI, which require
// the iOS runtime to be loaded.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_ios/src/utils/annotation_tool_ios_mapping.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

void main() {
  group('iosAnnotationStringNameFor', () {
    test(
      'maps every supported tool to the documented PSPDFAnnotationString',
      () {
        const expected = <AnnotationTool, String>{
          AnnotationTool.inkPen: 'Ink',
          AnnotationTool.inkMagic: 'Ink',
          AnnotationTool.inkHighlighter: 'Ink',
          AnnotationTool.highlight: 'Highlight',
          AnnotationTool.underline: 'Underline',
          AnnotationTool.strikeOut: 'StrikeOut',
          AnnotationTool.squiggly: 'Squiggly',
          AnnotationTool.freeText: 'FreeText',
          AnnotationTool.freeTextCallOut: 'FreeText',
          AnnotationTool.line: 'Line',
          AnnotationTool.arrow: 'Line',
          AnnotationTool.square: 'Square',
          AnnotationTool.cloudy: 'Square',
          AnnotationTool.circle: 'Circle',
          AnnotationTool.polygon: 'Polygon',
          AnnotationTool.polyline: 'PolyLine',
          AnnotationTool.note: 'Note',
          AnnotationTool.signature: 'Signature',
          AnnotationTool.stamp: 'Stamp',
          AnnotationTool.image: 'Stamp',
          AnnotationTool.stampImage: 'Stamp',
          AnnotationTool.eraser: 'Eraser',
          AnnotationTool.redaction: 'Redaction',
          AnnotationTool.sound: 'Sound',
          AnnotationTool.link: 'Link',
          AnnotationTool.caret: 'Caret',
          AnnotationTool.richMedia: 'RichMedia',
          AnnotationTool.screen: 'Screen',
          AnnotationTool.file: 'File',
          // Measurement tools are the base shape state; the measurement
          // behaviour comes from the variant (iosAnnotationVariantFor).
          AnnotationTool.measurementDistance: 'Line',
          AnnotationTool.measurementPerimeter: 'PolyLine',
          AnnotationTool.measurementAreaRect: 'Square',
          AnnotationTool.measurementAreaEllipse: 'Circle',
          AnnotationTool.measurementAreaPolygon: 'Polygon',
        };
        for (final entry in expected.entries) {
          expect(
            iosAnnotationStringNameFor(entry.key),
            entry.value,
            reason: '${entry.key} should map to ${entry.value}',
          );
        }
      },
    );

    test('returns null for tools without an iOS equivalent', () {
      const unsupported = <AnnotationTool>{AnnotationTool.widget};
      for (final tool in unsupported) {
        expect(
          iosAnnotationStringNameFor(tool),
          isNull,
          reason: '$tool should not map to a PSPDFAnnotationString',
        );
      }
    });

    test('covers every AnnotationTool value (no enum drift)', () {
      // If a new value is added to AnnotationTool, this test fails until the
      // mapping is updated, preventing silent un-mapped tools.
      for (final tool in AnnotationTool.values) {
        expect(
          () => iosAnnotationStringNameFor(tool),
          returnsNormally,
          reason:
              '$tool needs to be added to the switch in '
              'iosAnnotationStringNameFor',
        );
      }
    });

    test('every non-null name is a valid Objective-C identifier', () {
      // PSPDFAnnotationString constants are PascalCase suffixes appended to
      // the "PSPDFAnnotationString" prefix (e.g. PSPDFAnnotationStringInk).
      final identifierPattern = RegExp(r'^[A-Z][A-Za-z0-9]*$');
      for (final tool in AnnotationTool.values) {
        final name = iosAnnotationStringNameFor(tool);
        if (name == null) continue;
        expect(
          identifierPattern.hasMatch(name),
          isTrue,
          reason:
              '$tool maps to "$name" which is not a valid '
              'PSPDFAnnotationString suffix',
        );
      }
    });

    test('all four ink tools collapse to Ink (no variants surfaced yet)', () {
      // The PI distinguishes inkPen/inkMagic/inkHighlighter; the iOS SDK
      // uses an AnnotationToolVariant to differentiate, which we don't
      // surface yet. Until we do, all three should map to the same
      // PSPDFAnnotationString.
      expect(iosAnnotationStringNameFor(AnnotationTool.inkPen), 'Ink');
      expect(iosAnnotationStringNameFor(AnnotationTool.inkMagic), 'Ink');
      expect(iosAnnotationStringNameFor(AnnotationTool.inkHighlighter), 'Ink');
    });

    test('arrow shares the Line interaction with line', () {
      // iOS arrows are line annotations with end-line caps configured via
      // the style manager — they share PSPDFAnnotationStringLine.
      expect(iosAnnotationStringNameFor(AnnotationTool.line), 'Line');
      expect(iosAnnotationStringNameFor(AnnotationTool.arrow), 'Line');
    });

    test('cloudy shares the Square shape', () {
      // iOS exposes "cloudy" as a border style on shape tools, not a
      // separate annotation type — it shares PSPDFAnnotationStringSquare.
      expect(iosAnnotationStringNameFor(AnnotationTool.square), 'Square');
      expect(iosAnnotationStringNameFor(AnnotationTool.cloudy), 'Square');
    });
  });
}
