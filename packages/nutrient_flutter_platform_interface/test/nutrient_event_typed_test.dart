// Tests the typed annotation accessors on the event classes
// (AnnotationEventData.annotations, PageClickedEvent.annotation).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart'
    show AnnotationType;
import 'package:nutrient_flutter_platform_interface/src/events/nutrient_event.dart';
import 'package:nutrient_flutter_platform_interface/src/models/annotations/annotation_models.dart';

String _ink() => jsonEncode({
      'id': 'ink-1',
      'type': 'pspdfkit/ink',
      'bbox': [0.0, 0.0, 10.0, 10.0],
      'pageIndex': 0,
      'lines': {
        'points': [
          [
            [0.0, 0.0],
            [5.0, 5.0]
          ]
        ],
        'intensities': [
          [0.5, 0.5]
        ]
      },
      'lineWidth': 2.0,
    });

String _highlight() => jsonEncode({
      'id': 'hl-1',
      'type': 'pspdfkit/markup/highlight',
      'bbox': [0.0, 0.0, 10.0, 10.0],
      'pageIndex': 0,
      'rects': [
        [0.0, 0.0, 10.0, 10.0]
      ],
      'color': '#ffff00',
    });

void main() {
  test('AnnotationCreatedEvent.annotations parses typed models', () {
    final e = AnnotationCreatedEvent([_ink(), _highlight()]);
    expect(e.annotations, hasLength(2));
    expect(e.annotations[0], isA<InkAnnotation>());
    expect(e.annotations[1], isA<HighlightAnnotation>());
  });

  test('the mixin applies to all five annotation events', () {
    expect(AnnotationUpdatedEvent([_ink()]).annotations, hasLength(1));
    expect(AnnotationDeletedEvent([_ink()]).annotations, hasLength(1));
    expect(AnnotationSelectedEvent([_ink()]).annotations, hasLength(1));
    expect(AnnotationDeselectedEvent([_ink()]).annotations, hasLength(1));
  });

  test('unknown/malformed entries are skipped, not thrown', () {
    final e = AnnotationCreatedEvent([
      _ink(),
      jsonEncode({'id': 'u', 'type': 'pspdfkit/unknown'}),
      'not json',
    ]);
    expect(e.annotations, hasLength(1));
    expect(e.annotations.single, isA<InkAnnotation>());
  });

  test('types surfaces the AnnotationType of each parsed annotation', () {
    final e = AnnotationCreatedEvent([_ink(), _highlight()]);
    expect(e.types, [AnnotationType.ink, AnnotationType.highlight]);
  });

  test('types skips unparseable entries, matching annotations', () {
    final e = AnnotationCreatedEvent([_ink(), 'not json']);
    expect(e.types, [AnnotationType.ink]);
  });

  group('PageClickedEvent.annotation', () {
    test('parses the tapped annotation', () {
      final e = PageClickedEvent(0, annotationJson: _ink());
      expect(e.annotation, isA<InkAnnotation>());
    });

    test('is null when no annotation was tapped', () {
      expect(PageClickedEvent(0).annotation, isNull);
    });
  });
}
