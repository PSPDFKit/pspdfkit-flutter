///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('AnnotationProperties Extensions', () {
    late AnnotationProperties baseProperties;

    setUp(() {
      baseProperties = AnnotationProperties(
        annotationId: 'test-annotation-id',
        pageIndex: 0,
        strokeColor: Colors.blue.toARGB32(),
        fillColor: Colors.red.toARGB32(),
        opacity: 1.0,
        lineWidth: 2.0,
        flagsJson: jsonEncode(['print']),
        customDataJson: jsonEncode({'existingKey': 'existingValue'}),
        contents: 'Test contents',
        subject: 'Test subject',
        creator: 'Test creator',
        bboxJson: jsonEncode([0.0, 0.0, 100.0, 100.0]),
        note: 'Test note',
        inkLinesJson: null,
        fontName: 'Helvetica',
        fontSize: 12.0,
        iconName: 'comment',
      );
    });

    group('withCustomData', () {
      test('updates custom data correctly', () {
        final customData = {
          'type': 'abc',
          'data': {
            'name': 'abc',
            'type': 4,
          },
        };

        final updated = baseProperties.withCustomData(customData);

        expect(updated.customData, customData);
        expect(updated.annotationId, baseProperties.annotationId);
        expect(updated.pageIndex, baseProperties.pageIndex);
        expect(updated.strokeColor, baseProperties.strokeColor);
      });

      test('handles nested custom data correctly', () {
        final nestedCustomData = <String, Object?>{
          'type': 'abc',
          'data': {
            'name': 'abc',
            'type': 4,
          },
          'metadata': {
            'source': 'flutter_sdk',
            'version': '1.0.0',
            'nested': {
              'level1': {
                'level2': 'deep_value',
              },
            },
          },
        };

        final updated = baseProperties.withCustomData(nestedCustomData);

        expect(updated.customData, nestedCustomData);
        expect((updated.customData!['metadata'] as Map)['nested'], isA<Map>());
        expect(
            ((updated.customData!['metadata'] as Map)['nested']
                as Map)['level1'],
            isA<Map>());
      });

      test('preserves other properties when updating custom data', () {
        final updated = baseProperties.withCustomData({'newKey': 'newValue'});

        expect(updated.annotationId, baseProperties.annotationId);
        expect(updated.pageIndex, baseProperties.pageIndex);
        expect(updated.strokeColor, baseProperties.strokeColor);
        expect(updated.fillColor, baseProperties.fillColor);
        expect(updated.opacity, baseProperties.opacity);
        expect(updated.lineWidth, baseProperties.lineWidth);
        expect(updated.flags, baseProperties.flags);
        expect(updated.contents, baseProperties.contents);
        expect(updated.subject, baseProperties.subject);
        expect(updated.creator, baseProperties.creator);
        expect(updated.bbox, baseProperties.bbox);
        expect(updated.note, baseProperties.note);
        expect(updated.fontName, baseProperties.fontName);
        expect(updated.fontSize, baseProperties.fontSize);
        expect(updated.iconName, baseProperties.iconName);
      });

      test('JSON-based customData avoids CastList issues', () {
        // With JSON strings, we no longer have CastList issues
        // The data comes as a String and is decoded on demand
        final customDataJson = jsonEncode({
          'additionalData': {'type': 3, 'id': '12123'},
          'id': 'r34newnke',
        });

        final propertiesFromPigeon = AnnotationProperties(
          annotationId: 'test-from-pigeon',
          pageIndex: 0,
          customDataJson: customDataJson,
        );

        // This should NOT throw an exception
        final newCustomData = <String, Object?>{
          'additionalData': {'type': 5, 'id': 'new-id'},
          'id': 'updated-id',
        };

        final updated = propertiesFromPigeon.withCustomData(newCustomData);

        expect(updated.customData, isNotNull);
        expect(updated.customData!['id'], 'updated-id');
        expect(
            (updated.customData!['additionalData'] as Map)['type'], equals(5));
      });
    });

    group('withColor', () {
      test('updates stroke color correctly', () {
        final updated = baseProperties.withColor(Colors.green);

        expect(updated.strokeColor, Colors.green.toARGB32());
        expect(updated.fillColor, baseProperties.fillColor);
      });
    });

    group('withOpacity', () {
      test('updates opacity correctly', () {
        final updated = baseProperties.withOpacity(0.5);

        expect(updated.opacity, 0.5);
      });

      test('throws assertion error for invalid opacity', () {
        expect(
          () => baseProperties.withOpacity(1.5),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => baseProperties.withOpacity(-0.1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('withLineWidth', () {
      test('updates line width correctly', () {
        final updated = baseProperties.withLineWidth(5.0);

        expect(updated.lineWidth, 5.0);
      });

      test('throws assertion error for invalid line width', () {
        expect(
          () => baseProperties.withLineWidth(0.0),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => baseProperties.withLineWidth(-1.0),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('withFlags', () {
      test('updates flags correctly', () {
        final newFlags = {AnnotationFlag.hidden, AnnotationFlag.locked};
        final updated = baseProperties.withFlags(newFlags);

        expect(updated.flags, containsAll(['hidden', 'locked']));
      });
    });

    group('withBoundingBox', () {
      test('updates bounding box correctly', () {
        final newBbox = const Rect.fromLTWH(10.0, 20.0, 200.0, 150.0);
        final updated = baseProperties.withBoundingBox(newBbox);

        expect(updated.bbox, [10.0, 20.0, 200.0, 150.0]);
      });
    });
  });

  group('AnnotationProperties Getters', () {
    test('color getter returns correct Flutter Color', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        strokeColor: Colors.blue.toARGB32(),
      );

      expect(properties.color?.toARGB32(), Colors.blue.toARGB32());
    });

    test('flagsSet getter returns correct Set of AnnotationFlag', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        flagsJson: jsonEncode(['print', 'hidden', 'locked']),
      );

      expect(properties.flagsSet, {
        AnnotationFlag.print,
        AnnotationFlag.hidden,
        AnnotationFlag.locked,
      });
    });

    test('flags getter returns correct list of strings', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        flagsJson: jsonEncode(['print', 'hidden', 'locked']),
      );

      expect(properties.flags, ['print', 'hidden', 'locked']);
    });

    test('boundingBox getter returns correct Rect', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        bboxJson: jsonEncode([10.0, 20.0, 100.0, 50.0]),
      );

      expect(
          properties.boundingBox, const Rect.fromLTWH(10.0, 20.0, 100.0, 50.0));
    });

    test('bbox getter returns correct list of doubles', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        bboxJson: jsonEncode([10.0, 20.0, 100.0, 50.0]),
      );

      expect(properties.bbox, [10.0, 20.0, 100.0, 50.0]);
    });

    test('boundingBox returns null for invalid bbox', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        bboxJson: jsonEncode([10.0, 20.0]), // Invalid - only 2 elements
      );

      expect(properties.boundingBox, isNull);
    });

    test('flags returns null for null or empty JSON', () {
      final properties1 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        flagsJson: null,
      );
      expect(properties1.flags, isNull);

      final properties2 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        flagsJson: '',
      );
      expect(properties2.flags, isNull);
    });

    test('bbox returns null for null or empty JSON', () {
      final properties1 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        bboxJson: null,
      );
      expect(properties1.bbox, isNull);

      final properties2 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        bboxJson: '',
      );
      expect(properties2.bbox, isNull);
    });

    test('customData getter decodes JSON correctly', () {
      final customData = {'key': 'value', 'nested': {'inner': 42}};
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        customDataJson: jsonEncode(customData),
      );

      expect(properties.customData, customData);
      expect(properties.customData!['key'], 'value');
      expect((properties.customData!['nested'] as Map)['inner'], 42);
    });

    test('customData returns null for null or empty JSON', () {
      final properties1 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        customDataJson: null,
      );
      expect(properties1.customData, isNull);

      final properties2 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        customDataJson: '',
      );
      expect(properties2.customData, isNull);
    });

    test('inkLines getter decodes JSON correctly', () {
      final inkLines = [
        [
          [100.0, 100.0, 1.0],
          [150.0, 150.0, 0.8]
        ],
        [
          [200.0, 200.0, 1.0]
        ]
      ];
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        inkLinesJson: jsonEncode(inkLines),
      );

      expect(properties.inkLines, isNotNull);
      expect(properties.inkLines!.length, 2);
      expect(properties.inkLines![0].length, 2);
      expect(properties.inkLines![0][0], [100.0, 100.0, 1.0]);
      expect(properties.inkLines![0][1], [150.0, 150.0, 0.8]);
      expect(properties.inkLines![1].length, 1);
      expect(properties.inkLines![1][0], [200.0, 200.0, 1.0]);
    });

    test('inkLines returns null for null or empty JSON', () {
      final properties1 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        inkLinesJson: null,
      );
      expect(properties1.inkLines, isNull);

      final properties2 = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        inkLinesJson: '',
      );
      expect(properties2.inkLines, isNull);
    });
  });

  group('InkAnnotationProperties Extension', () {
    test('withInkLines converts Offset to typed list correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
      );

      final lines = [
        [const Offset(100.0, 100.0), const Offset(150.0, 150.0)],
        [const Offset(200.0, 200.0)],
      ];

      final updated = properties.withInkLines(lines);

      expect(updated.inkLines, isNotNull);
      expect(updated.inkLines!.length, 2);
      expect(updated.inkLines![0][0][0], 100.0); // x
      expect(updated.inkLines![0][0][1], 100.0); // y
      expect(updated.inkLines![0][0][2], 1.0); // pressure (default)
    });

    test('withRawInkLines preserves ink lines correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
      );

      final inkLines = [
        [
          [100.0, 100.0, 1.0],
          [150.0, 150.0, 0.8],
        ],
        [
          [200.0, 200.0, 1.0],
        ],
      ];

      final updated = properties.withRawInkLines(inkLines);

      expect(updated.inkLines, isNotNull);
      expect(updated.inkLines!.length, 2);
      expect(updated.inkLines![0].length, 2);
      expect(updated.inkLines![0][0], [100.0, 100.0, 1.0]);
      expect(updated.inkLines![0][1], [150.0, 150.0, 0.8]);
      expect(updated.inkLines![1].length, 1);
      expect(updated.inkLines![1][0], [200.0, 200.0, 1.0]);
    });

    test('preserves inkLines when calling withCustomData', () {
      // Create properties with inkLines as JSON
      final inkLinesJson = jsonEncode([
        [
          [100.0, 100.0, 1.0],
          [150.0, 150.0, 0.8],
        ],
        [
          [200.0, 200.0, 1.0],
        ],
      ]);

      final propertiesFromPigeon = AnnotationProperties(
        annotationId: 'test-ink-from-pigeon',
        pageIndex: 0,
        inkLinesJson: inkLinesJson,
      );

      // This should NOT throw an exception when calling withCustomData
      final newCustomData = <String, Object?>{
        'someKey': 'someValue',
      };

      final updated = propertiesFromPigeon.withCustomData(newCustomData);

      // Verify customData was updated
      expect(updated.customData, isNotNull);
      expect(updated.customData!['someKey'], 'someValue');

      // Verify inkLines are preserved with correct values
      expect(updated.inkLines, isNotNull);
      expect(updated.inkLines!.length, 2);
      expect(updated.inkLines![0].length, 2);
      expect(updated.inkLines![0][0], [100.0, 100.0, 1.0]);
      expect(updated.inkLines![0][1], [150.0, 150.0, 0.8]);
      expect(updated.inkLines![1].length, 1);
      expect(updated.inkLines![1][0], [200.0, 200.0, 1.0]);
    });

    test('JSON-based inkLines avoids CastList issues completely', () {
      // With JSON strings, there's no CastList issue at all
      // The data is just a String that gets parsed on demand
      final inkLinesJson = jsonEncode([
        [
          [100.0, 100.0, 1.0],
          [150.0, 150.0, 0.8],
        ],
        [
          [200.0, 200.0, 1.0],
        ],
      ]);

      // Create properties with the JSON string (simulating Pigeon decode)
      final propertiesFromPigeon = AnnotationProperties(
        annotationId: 'test-ink-json',
        pageIndex: 0,
        inkLinesJson: inkLinesJson,
      );

      // The user's exact scenario: get properties and update custom data
      // This no longer throws because inkLinesJson is just a String
      final annotCustomData = <String, Object?>{
        'additionalData': {'type': 3, 'id': '12123'},
        'id': 'r34newnke',
      };

      // This should NOT throw an exception
      final updated = propertiesFromPigeon.withCustomData(annotCustomData);

      // Verify customData was updated
      expect(updated.customData, isNotNull);
      expect(updated.customData!['id'], 'r34newnke');
      expect((updated.customData!['additionalData'] as Map)['type'], 3);

      // Verify inkLines are preserved with correct values
      expect(updated.inkLines, isNotNull);
      expect(updated.inkLines!.length, 2);
      expect(updated.inkLines![0].length, 2);
      expect(updated.inkLines![0][0], [100.0, 100.0, 1.0]);
      expect(updated.inkLines![0][1], [150.0, 150.0, 0.8]);
      expect(updated.inkLines![1].length, 1);
      expect(updated.inkLines![1][0], [200.0, 200.0, 1.0]);
    });
  });

  group('FreeTextAnnotationProperties Extension', () {
    test('withFont updates font name and size correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        fontName: 'Helvetica',
        fontSize: 12.0,
      );

      final updated = properties.withFont('Arial', 16.0);

      expect(updated.fontName, 'Arial');
      expect(updated.fontSize, 16.0);
    });
  });

  group('NoteAnnotationProperties Extension', () {
    test('withIcon updates icon name correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        iconName: 'Comment',
      );

      final updated = properties.withIcon(NoteIcon.key);

      // NoteIcon.key.name returns 'Key' (capitalized per NoteIconExtension)
      expect(updated.iconName, 'Key');
    });
  });
}
