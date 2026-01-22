///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/annotations/annotation_utils.dart';

/// Tests to verify that annotation model parsing works correctly with various
/// input types that might come from native code through Pigeon.
///
/// The core issue being tested: Pigeon's .cast<>() method creates lazy CastList/CastMap
/// wrappers that fail in release mode (AOT) when the underlying types are incompatible.
/// Our fix uses Map<String, dynamic>.from() which creates an eager copy with proper types.
void main() {
  const testTime = '2025-01-04T12:15:40.000Z';

  group('Annotation casting fixes - simulating native code input', () {
    group('InkAnnotation with Map<Object?, Object?> nested data', () {
      test('parses lines when nested map has Object? keys', () {
        // Simulate what Pigeon might return: Map<Object?, Object?> instead of Map<String, dynamic>
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_ink',
          'type': 'pspdfkit/ink',
          'bbox': <Object?>[90.0, 90.0, 410.0, 210.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'lineWidth': 2.0,
          'isDrawnNaturally': true,
          // Nested map with Object? keys - this is what causes issues with .cast<>()
          'lines': <Object?, Object?>{
            'intensities': <Object?>[
              <Object?>[1.0, 0.8, 1.0],
            ],
            'points': <Object?>[
              <Object?>[
                <Object?>[100.0, 100.0],
                <Object?>[150.0, 150.0],
              ],
            ],
          },
        };

        // Convert to Map<String, dynamic> as our code does
        final json = Map<String, dynamic>.from(nativeStyleJson);

        // This should work without throwing
        final annotation = InkAnnotation.fromJson(json);

        expect(annotation.id, 'test_ink');
        expect(annotation.lines.intensities.length, 1);
        expect(annotation.lines.points.length, 1);
      });

      test('parses lines from JSON string (standard path)', () {
        const jsonStr = '''{
          "id": "test_ink",
          "type": "pspdfkit/ink",
          "bbox": [90.0, 90.0, 410.0, 210.0],
          "createdAt": "$testTime",
          "pageIndex": 0,
          "lineWidth": 2.0,
          "isDrawnNaturally": true,
          "lines": {
            "intensities": [[1.0, 0.8, 1.0]],
            "points": [[[100.0, 100.0], [150.0, 150.0]]]
          }
        }''';

        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final annotation = InkAnnotation.fromJson(json);

        expect(annotation.id, 'test_ink');
        expect(annotation.lines.intensities[0], [1.0, 0.8, 1.0]);
      });
    });

    group('NoteAnnotation with Map<Object?, Object?> text content', () {
      test('parses text when nested map has Object? keys', () {
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_note',
          'type': 'pspdfkit/note',
          'bbox': <Object?>[100.0, 100.0, 120.0, 120.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'icon': 'comment',
          // Nested text map with Object? keys
          'text': <Object?, Object?>{
            'format': 'plain',
            'value': 'Note content',
          },
        };

        final json = Map<String, dynamic>.from(nativeStyleJson);
        final annotation = NoteAnnotation.fromJson(json);

        expect(annotation.id, 'test_note');
        expect(annotation.text.value, 'Note content');
        expect(annotation.text.format, TextFormat.plain);
      });
    });

    group('FreeTextAnnotation with Map<Object?, Object?> text content', () {
      test('parses text when nested map has Object? keys', () {
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_freetext',
          'type': 'pspdfkit/text',
          'bbox': <Object?>[100.0, 100.0, 300.0, 150.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'fontSize': 12.0,
          'font': 'sans-serif',
          // Nested text map with Object? keys
          'text': <Object?, Object?>{
            'format': 'plain',
            'value': 'Free text content',
          },
        };

        final json = Map<String, dynamic>.from(nativeStyleJson);
        final annotation = FreeTextAnnotation.fromJson(json);

        expect(annotation.id, 'test_freetext');
        expect(annotation.text.value, 'Free text content');
      });
    });

    group('LineAnnotation with Map<Object?, Object?> lineCaps', () {
      test('parses lineCaps when nested map has Object? keys', () {
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_line',
          'type': 'pspdfkit/shape/line',
          'bbox': <Object?>[100.0, 100.0, 300.0, 300.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'startPoint': <Object?>[100.0, 100.0],
          'endPoint': <Object?>[300.0, 300.0],
          'strokeWidth': 2.0,
          // Nested lineCaps map with Object? keys
          'lineCaps': <Object?, Object?>{
            'start': 'openArrow',
            'end': 'closedArrow',
          },
        };

        final json = Map<String, dynamic>.from(nativeStyleJson);
        final annotation = LineAnnotation.fromJson(json);

        expect(annotation.id, 'test_line');
        expect(annotation.lineCaps?.start, LineCapType.openArrow);
        expect(annotation.lineCaps?.end, LineCapType.closedArrow);
      });

      test('handles null lineCaps correctly', () {
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_line',
          'type': 'pspdfkit/shape/line',
          'bbox': <Object?>[100.0, 100.0, 300.0, 300.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'startPoint': <Object?>[100.0, 100.0],
          'endPoint': <Object?>[300.0, 300.0],
          'strokeWidth': 2.0,
          // No lineCaps
        };

        final json = Map<String, dynamic>.from(nativeStyleJson);
        final annotation = LineAnnotation.fromJson(json);

        expect(annotation.lineCaps, isNull);
      });
    });

    group('LinkAnnotation with Map<Object?, Object?> action', () {
      test('parses action when nested map has Object? keys', () {
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_link',
          'type': 'pspdfkit/link',
          'bbox': <Object?>[100.0, 100.0, 200.0, 120.0],
          'createdAt': testTime,
          'pageIndex': 0,
          // Nested action map with Object? keys
          'action': <Object?, Object?>{
            'type': 'goTo',
            'pageIndex': 5,
            'destinationType': 'fitPage',
          },
        };

        final json = Map<String, dynamic>.from(nativeStyleJson);
        final annotation = LinkAnnotation.fromJson(json);

        expect(annotation.id, 'test_link');
        expect(annotation.action, isA<GoToAction>());
        expect((annotation.action as GoToAction).pageIndex, 5);
      });

      test('parses URI action correctly', () {
        final nativeStyleJson = <Object?, Object?>{
          'id': 'test_link',
          'type': 'pspdfkit/link',
          'bbox': <Object?>[100.0, 100.0, 200.0, 120.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'action': <Object?, Object?>{
            'type': 'uri',
            'uri': 'https://example.com',
          },
        };

        final json = Map<String, dynamic>.from(nativeStyleJson);
        final annotation = LinkAnnotation.fromJson(json);

        expect(annotation.action, isA<UriAction>());
        expect((annotation.action as UriAction).uri, 'https://example.com');
      });
    });
  });

  group('AnnotationUtils.annotationsFromInstantJSON', () {
    test('parses annotations with Map<Object?, Object?> attachments', () {
      final instantJson = <String, dynamic>{
        'annotations': [
          {
            'id': 'test_ink',
            'type': 'pspdfkit/ink',
            'bbox': [90.0, 90.0, 410.0, 210.0],
            'createdAt': testTime,
            'pageIndex': 0,
            'lineWidth': 2.0,
            'isDrawnNaturally': true,
            'lines': {
              'intensities': [
                [1.0, 0.8, 1.0]
              ],
              'points': [
                [
                  [100.0, 100.0],
                  [150.0, 150.0]
                ]
              ],
            },
          },
        ],
        // Attachments with nested maps
        'attachments': <Object?, Object?>{
          'attachment1': <Object?, Object?>{
            'contentType': 'image/png',
            'binary': 'base64data...',
          },
        },
      };

      final annotations = AnnotationUtils.annotationsFromInstantJSON(instantJson);

      expect(annotations.length, 1);
      expect(annotations[0], isA<InkAnnotation>());
    });

    test('handles null attachments correctly', () {
      final instantJson = <String, dynamic>{
        'annotations': [
          {
            'id': 'test_ink',
            'type': 'pspdfkit/ink',
            'bbox': [90.0, 90.0, 410.0, 210.0],
            'createdAt': testTime,
            'pageIndex': 0,
            'lineWidth': 2.0,
            'lines': {
              'intensities': [
                [1.0]
              ],
              'points': [
                [
                  [100.0, 100.0]
                ]
              ],
            },
          },
        ],
        // No attachments
      };

      final annotations = AnnotationUtils.annotationsFromInstantJSON(instantJson);

      expect(annotations.length, 1);
    });

    test('handles empty annotations list', () {
      final instantJson = <String, dynamic>{
        'annotations': [],
      };

      final annotations = AnnotationUtils.annotationsFromInstantJSON(instantJson);

      expect(annotations, isEmpty);
    });

    test('handles missing annotations key', () {
      final instantJson = <String, dynamic>{};

      final annotations = AnnotationUtils.annotationsFromInstantJSON(instantJson);

      expect(annotations, isEmpty);
    });
  });

  group('Annotation.fromJson factory with various input types', () {
    test('correctly dispatches to InkAnnotation', () {
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/ink',
        'bbox': [0.0, 0.0, 100.0, 100.0],
        'createdAt': testTime,
        'pageIndex': 0,
        'lineWidth': 1.0,
        'lines': {'intensities': [], 'points': []},
      };

      final annotation = Annotation.fromJson(json);
      expect(annotation, isA<InkAnnotation>());
    });

    test('correctly dispatches to NoteAnnotation', () {
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/note',
        'bbox': [0.0, 0.0, 20.0, 20.0],
        'createdAt': testTime,
        'pageIndex': 0,
        'text': {'format': 'plain', 'value': 'note'},
      };

      final annotation = Annotation.fromJson(json);
      expect(annotation, isA<NoteAnnotation>());
    });

    test('correctly dispatches to LinkAnnotation', () {
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/link',
        'bbox': [0.0, 0.0, 100.0, 20.0],
        'createdAt': testTime,
        'pageIndex': 0,
        'action': {'type': 'goTo', 'pageIndex': 0, 'destinationType': 'fitPage'},
      };

      final annotation = Annotation.fromJson(json);
      expect(annotation, isA<LinkAnnotation>());
    });

    test('correctly dispatches to FreeTextAnnotation', () {
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/text',
        'bbox': [0.0, 0.0, 200.0, 50.0],
        'createdAt': testTime,
        'pageIndex': 0,
        'text': {'format': 'plain', 'value': 'text'},
        'fontSize': 12.0,
        'font': 'sans-serif',
      };

      final annotation = Annotation.fromJson(json);
      expect(annotation, isA<FreeTextAnnotation>());
    });

    test('correctly dispatches to LineAnnotation', () {
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/shape/line',
        'bbox': [0.0, 0.0, 100.0, 100.0],
        'createdAt': testTime,
        'pageIndex': 0,
        'startPoint': [0.0, 0.0],
        'endPoint': [100.0, 100.0],
        'strokeWidth': 1.0,
      };

      final annotation = Annotation.fromJson(json);
      expect(annotation, isA<LineAnnotation>());
    });
  });

  group('Edge cases and error handling', () {
    test('InkAnnotation handles integer values in bbox', () {
      // Native code might return integers instead of doubles
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/ink',
        'bbox': [90, 90, 410, 210], // integers, not doubles
        'createdAt': testTime,
        'pageIndex': 0,
        'lineWidth': 2, // integer
        'lines': {
          'intensities': [
            [1, 0, 1]
          ], // integers
          'points': [
            [
              [100, 100],
              [150, 150]
            ]
          ], // integers
        },
      };

      final annotation = InkAnnotation.fromJson(json);

      expect(annotation.bbox, [90.0, 90.0, 410.0, 210.0]);
      expect(annotation.lineWidth, 2.0);
    });

    test('LineAnnotation handles missing optional lineCaps', () {
      final json = <String, dynamic>{
        'id': 'test',
        'type': 'pspdfkit/shape/line',
        'bbox': [0.0, 0.0, 100.0, 100.0],
        'createdAt': testTime,
        'pageIndex': 0,
        'startPoint': [0.0, 0.0],
        'endPoint': [100.0, 100.0],
        'strokeWidth': 1.0,
        // lineCaps not provided
      };

      final annotation = LineAnnotation.fromJson(json);
      expect(annotation.lineCaps, isNull);
    });

    test('NoteAnnotation handles all NoteIcon types', () {
      for (final icon in NoteIcon.values) {
        final json = <String, dynamic>{
          'id': 'test',
          'type': 'pspdfkit/note',
          'bbox': [0.0, 0.0, 20.0, 20.0],
          'createdAt': testTime,
          'pageIndex': 0,
          'icon': icon.toString().split('.').last,
          'text': {'format': 'plain', 'value': 'note'},
        };

        final annotation = NoteAnnotation.fromJson(json);
        expect(annotation.icon, icon);
      }
    });
  });

  group('Round-trip serialization tests', () {
    test('InkAnnotation round-trip preserves data', () {
      final original = InkAnnotation(
        id: 'test_ink',
        bbox: [90.0, 90.0, 410.0, 210.0],
        createdAt: testTime,
        pageIndex: 0,
        lineWidth: 2.5,
        isDrawnNaturally: true,
        lines: InkLines(
          intensities: [
            [1.0, 0.8, 0.9]
          ],
          points: [
            [
              [100.0, 100.0],
              [150.0, 150.0],
              [200.0, 200.0]
            ]
          ],
        ),
      );

      final json = original.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = InkAnnotation.fromJson(decoded);

      expect(restored.id, original.id);
      expect(restored.lineWidth, original.lineWidth);
      expect(restored.isDrawnNaturally, original.isDrawnNaturally);
      expect(restored.lines.intensities, original.lines.intensities);
      expect(restored.lines.points, original.lines.points);
    });

    test('NoteAnnotation round-trip preserves data', () {
      final original = NoteAnnotation(
        id: 'test_note',
        bbox: [100.0, 100.0, 120.0, 120.0],
        createdAt: testTime,
        pageIndex: 0,
        icon: NoteIcon.star,
        text: TextContent(format: TextFormat.plain, value: 'Important note'),
      );

      final json = original.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = NoteAnnotation.fromJson(decoded);

      expect(restored.id, original.id);
      expect(restored.icon, original.icon);
      expect(restored.text.value, original.text.value);
    });

    test('LinkAnnotation round-trip preserves data', () {
      final original = LinkAnnotation(
        id: 'test_link',
        bbox: [100.0, 100.0, 200.0, 120.0],
        createdAt: testTime,
        pageIndex: 0,
        action: UriAction(uri: 'https://nutrient.io'),
      );

      final json = original.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = LinkAnnotation.fromJson(decoded);

      expect(restored.id, original.id);
      expect(restored.action, isA<UriAction>());
      expect((restored.action as UriAction).uri, (original.action as UriAction).uri);
    });

    test('LineAnnotation round-trip preserves lineCaps', () {
      final original = LineAnnotation(
        id: 'test_line',
        bbox: [100.0, 100.0, 300.0, 300.0],
        createdAt: testTime,
        pageIndex: 0,
        startPoint: [100.0, 100.0],
        endPoint: [300.0, 300.0],
        strokeColor: const Color(0xFF0000FF),
        strokeWidth: 2.0,
        lineCaps: const LineCaps(
          start: LineCapType.diamond,
          end: LineCapType.openArrow,
        ),
      );

      final json = original.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = LineAnnotation.fromJson(decoded);

      expect(restored.lineCaps?.start, original.lineCaps?.start);
      expect(restored.lineCaps?.end, original.lineCaps?.end);
    });

    test('FreeTextAnnotation round-trip preserves text content', () {
      final original = FreeTextAnnotation(
        id: 'test_freetext',
        bbox: [100.0, 100.0, 300.0, 150.0],
        createdAt: testTime,
        pageIndex: 0,
        text: TextContent(format: TextFormat.plain, value: 'Hello World'),
        fontSize: 14.0,
        horizontalTextAlign: HorizontalTextAlignment.center,
      );

      final json = original.toJson();
      final jsonStr = jsonEncode(json);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = FreeTextAnnotation.fromJson(decoded);

      expect(restored.text.value, original.text.value);
      expect(restored.text.format, original.text.format);
      expect(restored.fontSize, original.fontSize);
      expect(restored.horizontalTextAlign, original.horizontalTextAlign);
    });
  });
}
