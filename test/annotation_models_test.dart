import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

void main() {
  const testTime = '2025-01-04T12:15:40.000Z';

  group('InkAnnotation', () {
    test('serializes to JSON correctly', () {
      final lines = InkLines(
        intensities: [
          [1.0, 0.8, 1.0],
          [0.9, 1.0, 0.7],
        ],
        points: [
          [
            [100.0, 100.0],
            [150.0, 150.0],
            [200.0, 200.0],
          ],
          [
            [300.0, 100.0],
            [350.0, 150.0],
            [400.0, 200.0],
          ],
        ],
      );

      final annotation = InkAnnotation(
          id: 'test_ink',
          bbox: [90.0, 90.0, 410.0, 210.0],
          createdAt: testTime,
          creatorName: 'Test User',
          lineWidth: 2.0,
          isDrawnNaturally: true,
          lines: lines,
          strokeColor: const Color(0xFF000000),
          pageIndex: 0);

      final json = annotation.toJson();
      expect(json['id'], 'test_ink');
      expect(json['type'], 'pspdfkit/ink');
      expect(json['bbox'], [90.0, 90.0, 410.0, 210.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'Test User');
      expect(json['lineWidth'], 2.0);
      expect(json['isDrawnNaturally'], true);
      expect(json['lines']['intensities'], [
        [1.0, 0.8, 1.0],
        [0.9, 1.0, 0.7],
      ]);
      expect(json['lines']['points'], [
        [
          [100.0, 100.0],
          [150.0, 150.0],
          [200.0, 200.0],
        ],
        [
          [300.0, 100.0],
          [350.0, 150.0],
          [400.0, 200.0],
        ],
      ]);
    });

    test('deserializes from JSON correctly', () {
      const jsonStr = '''{
        "id": "test_ink",
        "type": "pspdfkit/ink",
        "bbox": [90.0, 90.0, 410.0, 210.0],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "pageIndex": 0,
        "lineWidth": 2.0,
        "isDrawnNaturally": true,
        "lines": {
          "intensities": [
            [1.0, 0.8, 1.0],
            [0.9, 1.0, 0.7]
          ],
          "points": [
            [
              [100.0, 100.0],
              [150.0, 150.0],
              [200.0, 200.0]
            ],
            [
              [300.0, 100.0],
              [350.0, 150.0],
              [400.0, 200.0]
            ]
          ]
        }
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = InkAnnotation.fromJson(json);

      expect(annotation.id, 'test_ink');
      expect(annotation.type.fullName, 'pspdfkit/ink');
      expect(annotation.bbox, [90.0, 90.0, 410.0, 210.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'Test User');
      expect(annotation.lineWidth, 2.0);
      expect(annotation.isDrawnNaturally, true);
      expect(annotation.lines.intensities, [
        [1.0, 0.8, 1.0],
        [0.9, 1.0, 0.7],
      ]);
      expect(annotation.lines.points, [
        [
          [100.0, 100.0],
          [150.0, 150.0],
          [200.0, 200.0],
        ],
        [
          [300.0, 100.0],
          [350.0, 150.0],
          [400.0, 200.0],
        ],
      ]);
    });
  });

  group('TextMarkupAnnotation', () {
    test('serializes highlight annotation correctly', () {
      final annotation = HighlightAnnotation(
          id: 'test_highlight',
          bbox: [100.0, 100.0, 300.0, 120.0],
          createdAt: testTime,
          creatorName: 'Test User',
          color: const Color(0xFFFFFF00),
          rects: [
            [100.0, 100.0, 200.0, 20.0],
          ],
          pageIndex: 0);

      final json = annotation.toJson();
      expect(json['id'], 'test_highlight');
      expect(json['type'], 'pspdfkit/markup/highlight');
      expect(json['bbox'], [100.0, 100.0, 300.0, 120.0]);
      expect(json['color'], '#ffff00');
      expect(json['rects'], [
        [100.0, 100.0, 200.0, 20.0]
      ]);
    });

    test('deserializes highlight annotation correctly', () {
      const jsonStr = '''{
        "id": "test_highlight",
        "type": "pspdfkit/markup/highlight",
        "bbox": [100.0, 100.0, 300.0, 120.0],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "color": "#ffff00",
        "rects": [
          [100.0, 100.0, 200.0, 20.0]
        ],
        "pageIndex": 0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = HighlightAnnotation.fromJson(json);

      expect(annotation.id, 'test_highlight');
      expect(annotation.type.fullName, 'pspdfkit/markup/highlight');
      expect(annotation.bbox, [100.0, 100.0, 300.0, 120.0]);
      expect(annotation.color, const Color(0xFFFFFF00));
      expect(annotation.rects, [
        [100.0, 100.0, 200.0, 20.0]
      ]);
    });
  });

  group('ShapeAnnotation', () {
    test('serializes square annotation correctly', () {
      final annotation = SquareAnnotation(
          id: 'test_square',
          bbox: [100.0, 100.0, 200.0, 200.0],
          createdAt: testTime,
          creatorName: 'Test User',
          strokeColor: const Color(0xFF0000FF),
          strokeWidth: 2.0,
          fillColor: const Color(0xFFFF0000),
          pageIndex: 0);

      final json = annotation.toJson();

      expect(json['id'], 'test_square');
      expect(json['type'], 'pspdfkit/shape/rectangle');
      expect(json['bbox'], [100.0, 100.0, 200.0, 200.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'Test User');
      expect(json['strokeColor'], '#0000ff');
      expect(json['strokeWidth'], 2.0);
      expect(json['fillColor'], '#ff0000');
    });

    test('deserializes square annotation correctly', () {
      const jsonStr = '''{
        "id": "test_square",
        "type": "pspdfkit/shape/rectangle",
        "bbox": [100.0, 100.0, 200.0, 200.0],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "strokeColor": "#ff0000ff",
        "strokeWidth": 2.0,
        "fillColor": "#ffff0000",
        "pageIndex": 0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = SquareAnnotation.fromJson(json);

      expect(annotation.id, 'test_square');
      expect(annotation.type, AnnotationType.square);
      expect(annotation.bbox, [100.0, 100.0, 200.0, 200.0]);
      expect(annotation.strokeColor, const Color(0xFF0000FF));
      expect(annotation.strokeWidth, 2.0);
      expect(annotation.fillColor, const Color(0xFFFF0000));
    });
  });

  group('StampAnnotation', () {
    const base64Image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='; // 1x1 transparent PNG

    test('serializes stamp annotation with attachment correctly', () {
      final annotation = StampAnnotation(
          id: 'test_stamp',
          bbox: [100.0, 100.0, 200.0, 200.0],
          createdAt: testTime,
          creatorName: 'Test User',
          stampType: StampType.approved,
          attachment: base64Image,
          rotation: 45.0,
          pageIndex: 0);

      final json = annotation.toJson();
      expect(json['id'], 'test_stamp');
      expect(json['type'], 'pspdfkit/stamp');
      expect(json['bbox'], [100.0, 100.0, 200.0, 200.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'Test User');
      expect(json['stampType'], 'Approved');
      expect(json['attachment'], base64Image);
      expect(json['rotation'], 45.0);
    });

    test('serializes stamp annotation without attachment correctly', () {
      final annotation = StampAnnotation(
          id: 'test_stamp',
          bbox: [100.0, 100.0, 200.0, 200.0],
          createdAt: testTime,
          creatorName: 'Test User',
          stampType: StampType.approved,
          rotation: 0.0,
          pageIndex: 0);

      final json = annotation.toJson();
      expect(json['id'], 'test_stamp');
      expect(json['type'], 'pspdfkit/stamp');
      expect(json['bbox'], [100.0, 100.0, 200.0, 200.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'Test User');
      expect(json['stampType'], 'Approved');
      expect(json['attachment'], isNull);
      expect(json.containsKey('rotation'),
          false); // rotation is default, should be omitted
    });

    test('deserializes stamp annotation with attachment correctly', () {
      const jsonStr = '''{
        "id": "test_stamp",
        "type": "pspdfkit/stamp",
        "bbox": [100.0, 100.0, 200.0, 200.0],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "stampType": "Approved",
        "attachment": "$base64Image",
        "rotation": 45.0,
        "pageIndex": 0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = StampAnnotation.fromJson(json);

      expect(annotation.id, 'test_stamp');
      expect(annotation.type.fullName, 'pspdfkit/stamp');
      expect(annotation.bbox, [100.0, 100.0, 200.0, 200.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'Test User');
      expect(annotation.stampType.name, 'Approved');
      expect(annotation.attachment, base64Image);
      expect(annotation.rotation, 45.0);
    });

    test('deserializes stamp annotation without attachment correctly', () {
      const jsonStr = '''{
        "id": "test_stamp",
        "type": "pspdfkit/stamp",
        "bbox": [100.0, 100.0, 200.0, 200.0],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "stampType": "approved",
        "pageIndex": 0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = StampAnnotation.fromJson(json);

      expect(annotation.id, 'test_stamp');
      expect(annotation.type.fullName, 'pspdfkit/stamp');
      expect(annotation.bbox, [100.0, 100.0, 200.0, 200.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'Test User');
      expect(annotation.stampType.name, 'Approved');
      expect(annotation.attachment, isNull);
      expect(annotation.rotation, 0.0); // default rotation
    });
  });

  group('AnnotationCollection', () {
    test('serializes and deserializes collection correctly', () {
      final annotations = [
        InkAnnotation(
            id: 'test_ink',
            bbox: [90.0, 90.0, 410.0, 210.0],
            createdAt: testTime,
            lineWidth: 2.0,
            isDrawnNaturally: true,
            lines: InkLines(
              intensities: [
                [1.0, 0.8, 1.0],
              ],
              points: [
                [
                  [100.0, 100.0],
                  [150.0, 150.0],
                  [200.0, 200.0],
                ],
              ],
            ),
            strokeColor: const Color(0xFFFF0000),
            pageIndex: 0),
        HighlightAnnotation(
            id: 'test_highlight',
            bbox: [100.0, 100.0, 300.0, 120.0],
            createdAt: testTime,
            color: const Color(0xFFFFFF00),
            rects: [
              [100.0, 100.0, 200.0, 20.0],
            ],
            pageIndex: 0),
      ];

      final collection = AnnotationCollection(annotations: annotations);
      final jsonStr = collection.toJson();

      final deserializedCollection = AnnotationCollection.fromJson(jsonStr);
      expect(deserializedCollection.annotations.length, 2);
      expect(deserializedCollection.annotations[0] is InkAnnotation, true);
      expect(
          deserializedCollection.annotations[1] is HighlightAnnotation, true);
    });
  });

  group('FileAnnotation', () {
    test('toJson() includes all properties', () {
      final embeddedFile = EmbeddedFile(
        filePath: '/path/to/file.pdf',
        description: 'Test File',
        contentType: 'application/pdf',
      );

      final annotation = FileAnnotation(
        id: 'test-id',
        bbox: [100.0, 100.0, 200.0, 200.0],
        createdAt: testTime,
        creatorName: 'Test User',
        iconName: FileIconName.graph,
        embeddedFile: embeddedFile,
        pageIndex: 0,
        opacity: 0.8,
      );

      final json = annotation.toJson();

      expect(json['id'], 'test-id');
      expect(json['type'], 'pspdfkit/file');
      expect(json['bbox'], [100.0, 100.0, 200.0, 200.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'Test User');
      expect(json['iconName'], 'Graph');
      expect(json['pageIndex'], 0);
      expect(json['opacity'], 0.8);

      final embeddedFileJson = json['embeddedFile'] as Map<String, dynamic>;
      expect(embeddedFileJson['filePath'], '/path/to/file.pdf');
      expect(embeddedFileJson['description'], 'Test File');
      expect(embeddedFileJson['contentType'], 'application/pdf');
    });

    test('toJson() omits optional properties', () {
      final annotation = FileAnnotation(
          id: 'test-id',
          bbox: [100.0, 100.0, 200.0, 200.0],
          createdAt: testTime,
          pageIndex: 0);

      final json = annotation.toJson();

      expect(json['id'], 'test-id');
      expect(json['type'], 'pspdfkit/file');
      expect(json['bbox'], [100.0, 100.0, 200.0, 200.0]);
      expect(json['createdAt'], testTime);
      expect(json.containsKey('iconName'), false);
      expect(json.containsKey('embeddedFile'), false);
      expect(json.containsKey('pageIndex'), true);
      expect(json['opacity'], 1.0); // default opacity
    });

    test('fromJson() creates instance with all properties', () {
      const jsonStr = '''
      {
        "id": "test-id",
        "type": "pspdfkit/file",
        "bbox": [100.0, 100.0, 200.0, 200.0],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "iconName": "Graph",
        "pageIndex": 0,
        "opacity": 0.8,
        "embeddedFile": {
          "filePath": "/path/to/file.pdf",
          "description": "Test File",
          "contentType": "application/pdf"
        }
      }''';

      final annotation = FileAnnotation.fromJson(
        json.decode(jsonStr) as Map<String, dynamic>,
      );

      expect(annotation.id, 'test-id');
      expect(annotation.type, AnnotationType.file);
      expect(annotation.bbox, [100.0, 100.0, 200.0, 200.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'Test User');
      expect(annotation.iconName, FileIconName.graph);
      expect(annotation.pageIndex, 0);
      expect(annotation.opacity, 0.8);
      expect(annotation.embeddedFile?.filePath, '/path/to/file.pdf');
      expect(annotation.embeddedFile?.description, 'Test File');
      expect(annotation.embeddedFile?.contentType, 'application/pdf');
    });

    test('fromJson() creates instance with minimal properties', () {
      const jsonStr = '''
      {
        "id": "test-id",
        "type": "pspdfkit/file",
        "bbox": [100.0, 100.0, 200.0, 200.0],
        "createdAt": "$testTime",
        "pageIndex": 0
      }''';

      final annotation = FileAnnotation.fromJson(
        json.decode(jsonStr) as Map<String, dynamic>,
      );

      expect(annotation.id, 'test-id');
      expect(annotation.type, AnnotationType.file);
      expect(annotation.bbox, [100.0, 100.0, 200.0, 200.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, isNull);
      expect(annotation.iconName, isNull);
      expect(annotation.embeddedFile, isNull);
      expect(annotation.pageIndex, 0);
      expect(annotation.opacity, 1.0); // default opacity
    });
  });

  group('FileIconName', () {
    test('name returns correct string value', () {
      expect(FileIconName.pushPin.name, 'PushPin');
      expect(FileIconName.paperClip.name, 'PaperClip');
      expect(FileIconName.graph.name, 'Graph');
      expect(FileIconName.tag.name, 'Tag');
    });
  });

  group('EmbeddedFile', () {
    test('toJson() includes all properties', () {
      final embeddedFile = EmbeddedFile(
        filePath: '/path/to/file.pdf',
        description: 'Test File',
        contentType: 'application/pdf',
      );

      final json = embeddedFile.toJson();

      expect(json['filePath'], '/path/to/file.pdf');
      expect(json['description'], 'Test File');
      expect(json['contentType'], 'application/pdf');
    });

    test('toJson() omits optional properties', () {
      final embeddedFile = EmbeddedFile(
        filePath: '/path/to/file.pdf',
      );

      final json = embeddedFile.toJson();

      expect(json['filePath'], '/path/to/file.pdf');
      expect(json.containsKey('description'), false);
      expect(json.containsKey('contentType'), false);
    });

    test('fromJson() creates instance with all properties', () {
      const jsonStr = '''
      {
        "filePath": "/path/to/file.pdf",
        "description": "Test File",
        "contentType": "application/pdf"
      }''';

      final embeddedFile = EmbeddedFile.fromJson(
        json.decode(jsonStr) as Map<String, dynamic>,
      );

      expect(embeddedFile.filePath, '/path/to/file.pdf');
      expect(embeddedFile.description, 'Test File');
      expect(embeddedFile.contentType, 'application/pdf');
    });

    test('fromJson() creates instance with minimal properties', () {
      const jsonStr = '''
      {
        "filePath": "/path/to/file.pdf"
      }''';

      final embeddedFile = EmbeddedFile.fromJson(
        json.decode(jsonStr) as Map<String, dynamic>,
      );

      expect(embeddedFile.filePath, '/path/to/file.pdf');
      expect(embeddedFile.description, isNull);
      expect(embeddedFile.contentType, isNull);
    });
  });

  group('ImageAnnotation', () {
    test('serializes image annotation correctly', () {
      final annotation = ImageAnnotation(
        id: 'test_image',
        bbox: [15.0, 25.0, 90.0, 60.0],
        createdAt: testTime,
        creatorName: 'John Doe',
        pageIndex: 3,
        description: 'Company logo',
        contentType: 'image/jpeg',
        imageAttachmentId: '800',
        rotation: 0,
      );

      final json = annotation.toJson();

      expect(json['id'], 'test_image');
      expect(json['type'], 'pspdfkit/image');
      expect(json['bbox'], [15.0, 25.0, 90.0, 60.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'John Doe');
      expect(json['pageIndex'], 3);
      expect(json['description'], 'Company logo');
      expect(json['contentType'], 'image/jpeg');
      expect(json['imageAttachmentId'], '800');
      expect(json['rotation'], 0);
      expect(json['opacity'], 1.0);
    });

    test('deserializes image annotation correctly', () {
      const jsonStr = '''{
        "id": "test_image",
        "type": "pspdfkit/image",
        "bbox": [15.0, 25.0, 90.0, 60.0],
        "createdAt": "$testTime",
        "creatorName": "John Doe",
        "pageIndex": 3,
        "description": "Company logo",
        "contentType": "image/jpeg",
        "imageAttachmentId": "800",
        "rotation": 0,
        "opacity": 1.0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = ImageAnnotation.fromJson(json);

      expect(annotation.id, 'test_image');
      expect(annotation.type, AnnotationType.image);
      expect(annotation.bbox, [15.0, 25.0, 90.0, 60.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'John Doe');
      expect(annotation.pageIndex, 3);
      expect(annotation.description, 'Company logo');
      expect(annotation.contentType, 'image/jpeg');
      expect(annotation.imageAttachmentId, '800');
      expect(annotation.rotation, 0);
      expect(annotation.opacity, 1.0);
    });
  });

  group('LineAnnotation', () {
    test('serializes line annotation correctly', () {
      final annotation = LineAnnotation(
          id: 'test_line',
          bbox: [195.0, 215.0, 325.0, 427.0],
          createdAt: testTime,
          creatorName: 'John Doe',
          strokeColor: const Color(0xFF0000FF),
          strokeWidth: 5.0,
          fillColor: const Color(0xFFFFFFFF),
          startPoint: [40.0, 60.0],
          endPoint: [100.0, 200.0],
          lineCaps: const LineCaps(start: LineCapType.openArrow),
          pageIndex: 0);

      final json = annotation.toJson();

      expect(json['id'], 'test_line');
      expect(json['type'], 'pspdfkit/shape/line');
      expect(json['bbox'], [195.0, 215.0, 325.0, 427.0]);
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'John Doe');
      expect(json['strokeColor'], '#0000ff');
      expect(json['strokeWidth'], 5.0);
      expect(json['fillColor'], '#ffffff');
      expect(json['startPoint'], [40.0, 60.0]);
      expect(json['endPoint'], [100.0, 200.0]);
      expect(json['lineCaps'], {'start': 'openArrow'});
      expect(json['opacity'], 1.0);
    });

    test('deserializes line annotation correctly', () {
      const jsonStr = '''{
        "id": "test_line",
        "type": "pspdfkit/shape/line",
        "bbox": [195.0, 215.0, 325.0, 427.0],
        "createdAt": "$testTime",
        "creatorName": "John Doe",
        "strokeColor": "#0000ff",
        "strokeWidth": 5.0,
        "fillColor": "#ffffff",
        "startPoint": [40.0, 60.0],
        "endPoint": [100.0, 200.0],
        "lineCaps": {"start": "openArrow"},
        "opacity": 1.0,
        "pageIndex": 0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = LineAnnotation.fromJson(json);

      expect(annotation.id, 'test_line');
      expect(annotation.type, AnnotationType.line);
      expect(annotation.bbox, [195.0, 215.0, 325.0, 427.0]);
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'John Doe');
      expect(annotation.strokeColor, const Color(0xFF0000FF));
      expect(annotation.strokeWidth, 5.0);
      expect(annotation.fillColor, const Color(0xFFFFFFFF));
      expect(annotation.startPoint, [40.0, 60.0]);
      expect(annotation.endPoint, [100.0, 200.0]);
      expect(annotation.lineCaps?.start, LineCapType.openArrow);
      expect(annotation.opacity, 1.0);
    });
  });

  group('RedactionAnnotation', () {
    test('serializes redaction annotation correctly', () {
      final annotation = RedactionAnnotation(
        id: 'test_redaction',
        rects: [
          [250.0, 700.0, 400.0, 730.0],
          [250.0, 750.0, 400.0, 780.0]
        ],
        createdAt: testTime,
        creatorName: 'Test User',
        fillColor: const Color(0xFFE57373),
        overlayText: 'REDACTED',
        fontSize: 12.0,
        fontColor: const Color(0xFF000000),
        repeat: 'always',
        pageIndex: 0,
      );

      final json = annotation.toJson();
      expect(json['id'], 'test_redaction');
      expect(json['type'], 'pspdfkit/markup/redaction');
      expect(json['rects'], [
        [250.0, 700.0, 400.0, 730.0],
        [250.0, 750.0, 400.0, 780.0]
      ]);
      expect(json['bbox'],
          [250.0, 700.0, 400.0, 730.0]); // First rect used as bbox
      expect(json['createdAt'], testTime);
      expect(json['creatorName'], 'Test User');
      expect(json['fillColor'], '#e57373');
      expect(json['overlayText'], 'REDACTED');
      expect(json['fontSize'], 12.0);
      expect(json['fontColor'], '#000000');
      expect(json['repeat'], 'always');
    });

    test('deserializes redaction annotation correctly', () {
      const jsonStr = '''{
        "id": "test_redaction",
        "type": "pspdfkit/redact",
        "rects": [
          [250.0, 700.0, 400.0, 730.0],
          [250.0, 750.0, 400.0, 780.0]
        ],
        "createdAt": "$testTime",
        "creatorName": "Test User",
        "fillColor": "#e57373",
        "overlayText": "REDACTED",
        "fontSize": 12.0,
        "fontColor": "#000000",
        "repeat": "always",
        "pageIndex": 0
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = RedactionAnnotation.fromJson(json);

      expect(annotation.id, 'test_redaction');
      expect(annotation.type, AnnotationType.redact);
      expect(annotation.rects, [
        [250.0, 700.0, 400.0, 730.0],
        [250.0, 750.0, 400.0, 780.0]
      ]);
      expect(annotation.bbox,
          [250.0, 700.0, 400.0, 730.0]); // First rect used as bbox
      expect(annotation.createdAt, testTime);
      expect(annotation.creatorName, 'Test User');
      expect(annotation.fillColor, const Color(0xFFE57373));
      expect(annotation.overlayText, 'REDACTED');
      expect(annotation.fontSize, 12.0);
      expect(annotation.fontColor, const Color(0xFF000000));
      expect(annotation.repeat, 'always');
    });

    test('handles optional properties correctly', () {
      final annotation = RedactionAnnotation(
        id: 'test_redaction',
        rects: [
          [250.0, 700.0, 400.0, 730.0]
        ],
        createdAt: testTime,
        pageIndex: 0,
      );

      final json = annotation.toJson();
      expect(json['overlayText'], isNull);
      expect(json['fontSize'], isNull);
      expect(json['fontColor'], isNull);
      expect(json['repeat'], isNull);
    });
  });

  group('FreeTextAnnotation', () {
    test('serializes with all properties correctly', () {
      final annotation = FreeTextAnnotation(
        id: 'test_freetext',
        bbox: [100.0, 100.0, 300.0, 150.0],
        createdAt: testTime,
        creatorName: 'Test User',
        pageIndex: 0,
        text: TextContent(format: TextFormat.plain, value: 'Test text'),
        fontSize: 12.0,
        fontColor: const Color(0xFF000000),
        backgroundColor: const Color(0xFFFFFFFF),
        horizontalTextAlign: HorizontalTextAlignment.left,
      );

      final json = annotation.toJson();
      expect(json['id'], 'test_freetext');
      expect(json['type'], 'pspdfkit/text');
      expect(json['text']['format'], 'plain');
      expect(json['text']['value'], 'Test text');
      expect(json['fontSize'], 12.0);
      expect(json['fontColor'], '#000000');
      expect(json['backgroundColor'], '#ffffff');
      expect(json['horizontalAlign'], 'left');
      expect(json['font'], 'sans-serif'); // Default font
    });

    test('deserializes with default values correctly', () {
      const jsonStr = '''{
        "id": "test_freetext",
        "type": "pspdfkit/text",
        "bbox": [100.0, 100.0, 300.0, 150.0],
        "createdAt": "$testTime",
        "pageIndex": 0,
        "text": {
          "format": "plain",
          "value": "Test text"
        },
        "fontSize": 12.0,
        "font": "sans-serif"
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = FreeTextAnnotation.fromJson(json);

      expect(annotation.id, 'test_freetext');
      expect(annotation.fontSize, 12.0);
      expect(annotation.fontColor, Colors.black); // Default color
      expect(annotation.horizontalTextAlign, null); // Optional property
      expect(annotation.font, 'sans-serif');
    });

    test('handles optional properties correctly', () {
      final annotation = FreeTextAnnotation(
        id: 'test_freetext',
        bbox: [100.0, 100.0, 300.0, 150.0],
        createdAt: testTime,
        pageIndex: 0,
        text: TextContent(format: TextFormat.plain, value: 'Test text'),
        fontSize: 12.0,
      );

      final json = annotation.toJson();
      expect(json['fontColor'], '#000000');
      expect(json['backgroundColor'], isNull);
      expect(json['horizontalAlign'], isNull);
      expect(json['verticalAlign'], isNull);
      expect(json['creatorName'], isNull);
      expect(json['font'], 'sans-serif'); // Default font
    });
  });

  group('NoteAnnotation', () {
    test('serializes with icon and text correctly', () {
      final annotation = NoteAnnotation(
        id: 'test_note',
        bbox: [100.0, 100.0, 120.0, 120.0],
        createdAt: testTime,
        creatorName: 'Test User',
        pageIndex: 0,
        icon: NoteIcon.comment,
        text: TextContent(format: TextFormat.plain, value: 'Note comment'),
        color: const Color(0xFFFFFF00),
      );

      final json = annotation.toJson();
      expect(json['id'], 'test_note');
      expect(json['type'], 'pspdfkit/note');
      expect(json['icon'], 'comment');
      expect(json['text']['value'], 'Note comment');
      expect(json['color'], '#ffff00');
    });

    test('deserializes with custom icon correctly', () {
      const jsonStr = '''{
        "id": "test_note",
        "type": "pspdfkit/note",
        "bbox": [100.0, 100.0, 120.0, 120.0],
        "createdAt": "$testTime",
        "pageIndex": 0,
        "icon": "rightPointer",
        "text": {
          "format": "plain",
          "value": "Custom note"
        },
        "color": "#ff0000"
      }''';

      final json = jsonDecode(jsonStr);
      final annotation = NoteAnnotation.fromJson(json);

      expect(annotation.icon, NoteIcon.rightPointer);
      expect(annotation.text.value, 'Custom note');
      expect(annotation.color, const Color(0xFFFF0000));
    });
  });

  group('LineAnnotation', () {
    test('serializes with line caps correctly', () {
      final annotation = LineAnnotation(
        id: 'test_line',
        bbox: [100.0, 100.0, 300.0, 300.0],
        createdAt: testTime,
        creatorName: 'Test User',
        pageIndex: 0,
        startPoint: [100.0, 100.0],
        endPoint: [300.0, 300.0],
        strokeColor: const Color(0xFF0000FF),
        strokeWidth: 2.0,
        lineCaps: const LineCaps(
          start: LineCapType.square,
          end: LineCapType.circle,
        ),
      );

      final json = annotation.toJson();
      expect(json['id'], 'test_line');
      expect(json['type'], 'pspdfkit/shape/line');
      expect(json['startPoint'], [100.0, 100.0]);
      expect(json['endPoint'], [300.0, 300.0]);
      expect(json['strokeColor'], '#0000ff');
      expect(json['strokeWidth'], 2.0);
      expect(json['lineCaps']['start'], 'square');
      expect(json['lineCaps']['end'], 'circle');
    });
  });

  group('Annotation base class', () {
    test('handles null optional properties correctly', () {
      final annotation = InkAnnotation(
        id: 'test_ink',
        bbox: [90.0, 90.0, 410.0, 210.0],
        createdAt: testTime,
        pageIndex: 0,
        lines: InkLines(points: [], intensities: []),
        lineWidth: 1.0,
      );

      final json = annotation.toJson();
      expect(json.containsKey('creatorName'), false);
      expect(json.containsKey('flags'), false);
      expect(json.containsKey('name'), false);
      expect(json.containsKey('subject'), false);
    });

    test('handles annotation flags correctly', () {
      final annotation = InkAnnotation(
        id: 'test_ink',
        bbox: [90.0, 90.0, 410.0, 210.0],
        createdAt: testTime,
        pageIndex: 0,
        lines: InkLines(points: [], intensities: []),
        lineWidth: 1.0,
        flags: [AnnotationFlag.print, AnnotationFlag.noZoom],
      );

      final json = annotation.toJson();
      expect(json['flags'], ['print', 'noZoom']);
    });

    test('handles customData field correctly', () {
      final customData = {
        'string': 'test string',
        'number': 42,
        'boolean': true,
        'array': [1, 2, 3],
        'object': {'key': 'value'}
      };

      final annotation = InkAnnotation(
        id: 'test_ink',
        bbox: [90.0, 90.0, 410.0, 210.0],
        createdAt: testTime,
        pageIndex: 0,
        lines: InkLines(points: [], intensities: []),
        lineWidth: 1.0,
        customData: customData,
      );

      // Test serialization
      final json = annotation.toJson();
      expect(json['customData'], customData);

      // Test deserialization
      final jsonStr = jsonEncode(json);
      final decodedJson = jsonDecode(jsonStr) as Map<String, dynamic>;
      final deserializedAnnotation = InkAnnotation.fromJson(decodedJson);
      expect(deserializedAnnotation.customData, customData);
    });
  });
}
