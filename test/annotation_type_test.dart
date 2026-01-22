///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('AnnotationType Instant JSON Format', () {
    group('fullName getter returns correct Instant JSON format', () {
      test('ink annotation type', () {
        expect(AnnotationType.ink.fullName, 'pspdfkit/ink');
      });

      test('freeText annotation type (text)', () {
        expect(AnnotationType.freeText.fullName, 'pspdfkit/text');
      });

      test('highlight annotation type (markup)', () {
        expect(AnnotationType.highlight.fullName, 'pspdfkit/markup/highlight');
      });

      test('strikeout annotation type (markup)', () {
        expect(AnnotationType.strikeout.fullName, 'pspdfkit/markup/strikeout');
      });

      test('underline annotation type (markup)', () {
        expect(AnnotationType.underline.fullName, 'pspdfkit/markup/underline');
      });

      test('squiggly annotation type (markup)', () {
        expect(AnnotationType.squiggly.fullName, 'pspdfkit/markup/squiggly');
      });

      test('square annotation type (shape/rectangle)', () {
        expect(AnnotationType.square.fullName, 'pspdfkit/shape/rectangle');
      });

      test('circle annotation type (shape/ellipse)', () {
        expect(AnnotationType.circle.fullName, 'pspdfkit/shape/ellipse');
      });

      test('line annotation type (shape/line)', () {
        expect(AnnotationType.line.fullName, 'pspdfkit/shape/line');
      });

      test('polygon annotation type (shape/polygon)', () {
        expect(AnnotationType.polygon.fullName, 'pspdfkit/shape/polygon');
      });

      test('polyline annotation type (shape/polyline)', () {
        expect(AnnotationType.polyline.fullName, 'pspdfkit/shape/polyline');
      });

      test('note annotation type', () {
        expect(AnnotationType.note.fullName, 'pspdfkit/note');
      });

      test('stamp annotation type', () {
        expect(AnnotationType.stamp.fullName, 'pspdfkit/stamp');
      });

      test('link annotation type', () {
        expect(AnnotationType.link.fullName, 'pspdfkit/link');
      });

      test('redact annotation type (markup/redaction)', () {
        expect(AnnotationType.redact.fullName, 'pspdfkit/markup/redaction');
      });

      test('widget annotation type', () {
        expect(AnnotationType.widget.fullName, 'pspdfkit/widget');
      });

      test('file annotation type', () {
        expect(AnnotationType.file.fullName, 'pspdfkit/file');
      });

      test('sound annotation type', () {
        expect(AnnotationType.sound.fullName, 'pspdfkit/sound');
      });

      test('caret annotation type', () {
        expect(AnnotationType.caret.fullName, 'pspdfkit/caret');
      });

      test('popup annotation type', () {
        expect(AnnotationType.popup.fullName, 'pspdfkit/popup');
      });

      test('screen annotation type', () {
        expect(AnnotationType.screen.fullName, 'pspdfkit/screen');
      });

      test('media annotation type', () {
        expect(AnnotationType.media.fullName, 'pspdfkit/media');
      });

      test('image annotation type', () {
        expect(AnnotationType.image.fullName, 'pspdfkit/image');
      });

      test('watermark annotation type', () {
        expect(AnnotationType.watermark.fullName, 'pspdfkit/watermark');
      });

      test('type3d annotation type', () {
        expect(AnnotationType.type3d.fullName, 'pspdfkit/3d');
      });

      test('trapNet annotation type', () {
        expect(AnnotationType.trapNet.fullName, 'pspdfkit/trapnet');
      });

      test('undefined annotation type', () {
        expect(AnnotationType.undefined.fullName, 'pspdfkit/undefined');
      });

      test('none annotation type', () {
        expect(AnnotationType.none.fullName, 'pspdfkit/none');
      });

      test('all annotation type', () {
        expect(AnnotationType.all.fullName, 'pspdfkit/all');
      });
    });

    group('annotationTypeFromString parses Instant JSON format correctly', () {
      test('parses pspdfkit/ink', () {
        expect(annotationTypeFromString('pspdfkit/ink'), AnnotationType.ink);
      });

      test('parses pspdfkit/text (freeText)', () {
        expect(
            annotationTypeFromString('pspdfkit/text'), AnnotationType.freeText);
      });

      test('parses pspdfkit/markup/highlight', () {
        expect(annotationTypeFromString('pspdfkit/markup/highlight'),
            AnnotationType.highlight);
      });

      test('parses pspdfkit/markup/strikeout', () {
        expect(annotationTypeFromString('pspdfkit/markup/strikeout'),
            AnnotationType.strikeout);
      });

      test('parses pspdfkit/markup/underline', () {
        expect(annotationTypeFromString('pspdfkit/markup/underline'),
            AnnotationType.underline);
      });

      test('parses pspdfkit/markup/squiggly', () {
        expect(annotationTypeFromString('pspdfkit/markup/squiggly'),
            AnnotationType.squiggly);
      });

      test('parses pspdfkit/shape/rectangle (square)', () {
        expect(annotationTypeFromString('pspdfkit/shape/rectangle'),
            AnnotationType.square);
      });

      test('parses pspdfkit/shape/ellipse (circle)', () {
        expect(annotationTypeFromString('pspdfkit/shape/ellipse'),
            AnnotationType.circle);
      });

      test('parses pspdfkit/shape/line', () {
        expect(annotationTypeFromString('pspdfkit/shape/line'),
            AnnotationType.line);
      });

      test('parses pspdfkit/shape/polygon', () {
        expect(annotationTypeFromString('pspdfkit/shape/polygon'),
            AnnotationType.polygon);
      });

      test('parses pspdfkit/shape/polyline', () {
        expect(annotationTypeFromString('pspdfkit/shape/polyline'),
            AnnotationType.polyline);
      });

      test('parses pspdfkit/note', () {
        expect(annotationTypeFromString('pspdfkit/note'), AnnotationType.note);
      });

      test('parses pspdfkit/stamp', () {
        expect(
            annotationTypeFromString('pspdfkit/stamp'), AnnotationType.stamp);
      });

      test('parses pspdfkit/link', () {
        expect(annotationTypeFromString('pspdfkit/link'), AnnotationType.link);
      });

      test('parses pspdfkit/markup/redaction', () {
        expect(annotationTypeFromString('pspdfkit/markup/redaction'),
            AnnotationType.redact);
      });

      test('parses pspdfkit/widget', () {
        expect(
            annotationTypeFromString('pspdfkit/widget'), AnnotationType.widget);
      });

      test('parses pspdfkit/file', () {
        expect(annotationTypeFromString('pspdfkit/file'), AnnotationType.file);
      });

      test('parses pspdfkit/sound', () {
        expect(
            annotationTypeFromString('pspdfkit/sound'), AnnotationType.sound);
      });

      test('parses pspdfkit/caret', () {
        expect(
            annotationTypeFromString('pspdfkit/caret'), AnnotationType.caret);
      });

      test('parses pspdfkit/popup', () {
        expect(
            annotationTypeFromString('pspdfkit/popup'), AnnotationType.popup);
      });

      test('parses pspdfkit/screen', () {
        expect(
            annotationTypeFromString('pspdfkit/screen'), AnnotationType.screen);
      });

      test('parses pspdfkit/media', () {
        expect(
            annotationTypeFromString('pspdfkit/media'), AnnotationType.media);
      });

      test('parses pspdfkit/image', () {
        expect(
            annotationTypeFromString('pspdfkit/image'), AnnotationType.image);
      });

      test('parses pspdfkit/watermark', () {
        expect(annotationTypeFromString('pspdfkit/watermark'),
            AnnotationType.watermark);
      });

      test('parses pspdfkit/3d', () {
        expect(annotationTypeFromString('pspdfkit/3d'), AnnotationType.type3d);
      });

      test('parses pspdfkit/trapnet', () {
        expect(annotationTypeFromString('pspdfkit/trapnet'),
            AnnotationType.trapNet);
      });

      test('parses pspdfkit/undefined', () {
        expect(annotationTypeFromString('pspdfkit/undefined'),
            AnnotationType.undefined);
      });

      test('parses pspdfkit/none', () {
        expect(annotationTypeFromString('pspdfkit/none'), AnnotationType.none);
      });

      test('parses pspdfkit/all', () {
        expect(annotationTypeFromString('pspdfkit/all'), AnnotationType.all);
      });

      test('returns none for unknown type', () {
        expect(annotationTypeFromString('unknown/type'), AnnotationType.none);
      });
    });

    group('Round-trip conversion', () {
      test('all annotation types can be round-tripped', () {
        for (final type in AnnotationType.values) {
          final typeString = type.fullName;
          final parsed = annotationTypeFromString(typeString);
          expect(parsed, type,
              reason: 'Failed to round-trip $type (string: $typeString)');
        }
      });
    });
  });

  group('Annotation fromJson type parsing', () {
    test('parses FreeTextAnnotation from pspdfkit/text type', () {
      final json = {
        'id': 'test-freetext',
        'type': 'pspdfkit/text',
        'bbox': [100.0, 100.0, 200.0, 150.0],
        'pageIndex': 0,
        'createdAt': '2025-01-04T12:00:00.000Z',
        'text': {'format': 'plain', 'value': 'Test'},
        'fontSize': 12.0,
        'font': 'Helvetica',
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation, isA<FreeTextAnnotation>());
      expect(annotation.type, AnnotationType.freeText);
    });

    test('parses HighlightAnnotation from pspdfkit/markup/highlight type', () {
      final json = {
        'id': 'test-highlight',
        'type': 'pspdfkit/markup/highlight',
        'bbox': [100.0, 100.0, 200.0, 120.0],
        'pageIndex': 0,
        'createdAt': '2025-01-04T12:00:00.000Z',
        'rects': [
          [100.0, 100.0, 200.0, 20.0]
        ],
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation, isA<HighlightAnnotation>());
      expect(annotation.type, AnnotationType.highlight);
    });

    test('parses SquareAnnotation from pspdfkit/shape/rectangle type', () {
      final json = {
        'id': 'test-square',
        'type': 'pspdfkit/shape/rectangle',
        'bbox': [100.0, 100.0, 200.0, 200.0],
        'pageIndex': 0,
        'createdAt': '2025-01-04T12:00:00.000Z',
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation, isA<SquareAnnotation>());
      expect(annotation.type, AnnotationType.square);
    });

    test('parses CircleAnnotation from pspdfkit/shape/ellipse type', () {
      final json = {
        'id': 'test-circle',
        'type': 'pspdfkit/shape/ellipse',
        'bbox': [100.0, 100.0, 200.0, 200.0],
        'pageIndex': 0,
        'createdAt': '2025-01-04T12:00:00.000Z',
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation, isA<CircleAnnotation>());
      expect(annotation.type, AnnotationType.circle);
    });

    test('parses LineAnnotation from pspdfkit/shape/line type', () {
      final json = {
        'id': 'test-line',
        'type': 'pspdfkit/shape/line',
        'bbox': [100.0, 100.0, 300.0, 300.0],
        'pageIndex': 0,
        'createdAt': '2025-01-04T12:00:00.000Z',
        'startPoint': [100.0, 100.0],
        'endPoint': [300.0, 300.0],
      };

      final annotation = Annotation.fromJson(json);

      expect(annotation, isA<LineAnnotation>());
      expect(annotation.type, AnnotationType.line);
    });

    test('throws for pspdfkit/undefined type', () {
      final json = {
        'id': 'test-undefined',
        'type': 'pspdfkit/undefined',
        'bbox': [100.0, 100.0, 200.0, 200.0],
        'pageIndex': 0,
        'createdAt': '2025-01-04T12:00:00.000Z',
      };

      expect(
        () => Annotation.fromJson(json),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
