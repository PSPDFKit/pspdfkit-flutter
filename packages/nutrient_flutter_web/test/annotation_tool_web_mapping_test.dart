///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_web/src/utils/annotation_tool_web_mapping.dart';

void main() {
  group('webInteractionModeFor', () {
    test('returns the documented Web SDK constant for each tool', () {
      // Mirrors what the legacy AnnotationToolWebExtension produced.
      const expected = <AnnotationTool, String>{
        AnnotationTool.inkPen: 'INK',
        AnnotationTool.inkMagic: 'INK',
        AnnotationTool.inkHighlighter: 'INK',
        AnnotationTool.highlight: 'TEXT_HIGHLIGHTER',
        AnnotationTool.underline: 'TEXT_HIGHLIGHTER',
        AnnotationTool.strikeOut: 'TEXT_HIGHLIGHTER',
        AnnotationTool.squiggly: 'TEXT_HIGHLIGHTER',
        AnnotationTool.freeText: 'TEXT',
        AnnotationTool.freeTextCallOut: 'CALLOUT',
        AnnotationTool.square: 'SHAPE_RECTANGLE',
        AnnotationTool.circle: 'SHAPE_ELLIPSE',
        AnnotationTool.polygon: 'SHAPE_POLYGON',
        AnnotationTool.polyline: 'SHAPE_POLYLINE',
        AnnotationTool.line: 'SHAPE_LINE',
        AnnotationTool.arrow: 'SHAPE_LINE',
        AnnotationTool.note: 'NOTE',
        AnnotationTool.stamp: 'STAMP_PICKER',
        AnnotationTool.stampImage: 'STAMP_CUSTOM',
        AnnotationTool.image: 'STAMP_CUSTOM',
        AnnotationTool.signature: 'SIGNATURE',
        AnnotationTool.eraser: 'INK_ERASER',
        AnnotationTool.link: 'LINK',
        AnnotationTool.widget: 'FORM_CREATOR',
        AnnotationTool.file: 'DOCUMENT_EDITOR',
        AnnotationTool.caret: 'COMMENT_MARKER',
        AnnotationTool.redaction: 'REDACT_TEXT_HIGHLIGHTER',
        AnnotationTool.sound: 'NOTE',
        AnnotationTool.richMedia: 'NOTE',
        AnnotationTool.screen: 'NOTE',
        AnnotationTool.cloudy: 'SHAPE_RECTANGLE',
        AnnotationTool.measurementDistance: 'DISTANCE',
        AnnotationTool.measurementPerimeter: 'PERIMETER',
        AnnotationTool.measurementAreaRect: 'RECTANGLE_AREA',
        AnnotationTool.measurementAreaEllipse: 'ELLIPSE_AREA',
        AnnotationTool.measurementAreaPolygon: 'POLYGON_AREA',
      };
      for (final entry in expected.entries) {
        expect(
          webInteractionModeFor(entry.key),
          entry.value,
          reason: '${entry.key} should map to ${entry.value}',
        );
      }
    });

    test('covers every AnnotationTool value (no enum drift)', () {
      for (final tool in AnnotationTool.values) {
        expect(
          () => webInteractionModeFor(tool),
          returnsNormally,
          reason: '$tool needs to be added to the switch in '
              'webInteractionModeFor',
        );
      }
    });

    test('every returned mode is a SCREAMING_SNAKE_CASE identifier', () {
      // Web SDK PSPDFKit.InteractionMode values are SCREAMING_SNAKE_CASE.
      final identifierPattern = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final tool in AnnotationTool.values) {
        final mode = webInteractionModeFor(tool);
        expect(
          identifierPattern.hasMatch(mode),
          isTrue,
          reason: '$tool maps to "$mode" which is not a valid InteractionMode '
              'identifier',
        );
      }
    });

    test('text-markup tools all share the TEXT_HIGHLIGHTER mode', () {
      // Web SDK has a single TEXT_HIGHLIGHTER interaction mode for all
      // text-markup variants; the specific style is selected via the
      // annotation preset. This invariant is what makes
      // annotationPresetForTextMarkupTool meaningful.
      const textMarkup = <AnnotationTool>[
        AnnotationTool.highlight,
        AnnotationTool.underline,
        AnnotationTool.strikeOut,
        AnnotationTool.squiggly,
      ];
      for (final tool in textMarkup) {
        expect(webInteractionModeFor(tool), 'TEXT_HIGHLIGHTER');
      }
    });
  });

  group('annotationPresetForTextMarkupTool', () {
    test('returns the right preset id for each text-markup tool', () {
      expect(annotationPresetForTextMarkupTool(AnnotationTool.highlight),
          'highlight');
      expect(annotationPresetForTextMarkupTool(AnnotationTool.underline),
          'underline');
      expect(annotationPresetForTextMarkupTool(AnnotationTool.strikeOut),
          'strikeout');
      expect(annotationPresetForTextMarkupTool(AnnotationTool.squiggly),
          'squiggly');
    });

    test('returns null for non-text-markup tools', () {
      // Spot-check a representative set; an exhaustive sweep is the
      // "covers every value" test below.
      const nonMarkup = <AnnotationTool>[
        AnnotationTool.inkPen,
        AnnotationTool.freeText,
        AnnotationTool.square,
        AnnotationTool.note,
        AnnotationTool.signature,
        AnnotationTool.measurementDistance,
        AnnotationTool.eraser,
      ];
      for (final tool in nonMarkup) {
        expect(annotationPresetForTextMarkupTool(tool), isNull,
            reason: '$tool should not produce a preset id');
      }
    });

    test('covers every AnnotationTool value (no enum drift)', () {
      for (final tool in AnnotationTool.values) {
        expect(
          () => annotationPresetForTextMarkupTool(tool),
          returnsNormally,
          reason: '$tool needs to be handled in '
              'annotationPresetForTextMarkupTool',
        );
      }
    });

    test('exactly the four text-markup tools return non-null', () {
      final withPreset = AnnotationTool.values
          .where((t) => annotationPresetForTextMarkupTool(t) != null)
          .toSet();
      expect(
        withPreset,
        equals({
          AnnotationTool.highlight,
          AnnotationTool.underline,
          AnnotationTool.strikeOut,
          AnnotationTool.squiggly,
        }),
      );
    });
  });
}
