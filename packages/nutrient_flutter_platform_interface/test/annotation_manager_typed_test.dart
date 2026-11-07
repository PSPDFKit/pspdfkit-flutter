// Tests the typed convenience layer (AnnotationManagerTyped extension) that
// wraps the JSON transport on AnnotationManagerInterface.
// See documentation/typed-annotations-cross-platform.md.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart'
    show AnnotationType;
import 'package:nutrient_flutter_platform_interface/src/interfaces/annotation_manager_interface.dart';
import 'package:nutrient_flutter_platform_interface/src/models/annotation_properties.dart';
import 'package:nutrient_flutter_platform_interface/src/models/annotations/annotation_models.dart';

class _FakeManager implements AnnotationManagerInterface {
  String annotationsJson = '[]';
  String? lastAddedJson;

  @override
  Future<String> getAnnotationsJson(int pageIndex, String type) async =>
      annotationsJson;

  @override
  Future<String> getUnsavedAnnotationsJson() async => annotationsJson;

  @override
  Future<String> searchAnnotationsJson(String query, {int? pageIndex}) async =>
      annotationsJson;

  @override
  Future<String> addAnnotationJson(String jsonAnnotation,
      {String? attachment}) async {
    lastAddedJson = jsonAnnotation;
    return jsonAnnotation; // echo back as the "created" annotation
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) async =>
      true;
  @override
  Future<AnnotationProperties?> getAnnotationProperties(
          int pageIndex, String annotationId) async =>
      null;
  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties p) async => true;
  @override
  Future<String> exportXfdf({int? pageIndex}) async => '';
  @override
  Future<bool> importXfdf(String xfdfString) async => true;
}

const _ink = {
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
};
const _highlight = {
  'id': 'hl-1',
  'type': 'pspdfkit/markup/highlight',
  'bbox': [0.0, 0.0, 10.0, 10.0],
  'pageIndex': 0,
  'rects': [
    [0.0, 0.0, 10.0, 10.0]
  ],
  'color': '#ffff00',
};
const _unknown = {
  'id': 'unk-1',
  'type': 'pspdfkit/unknown',
  'bbox': [0.0, 0.0, 10.0, 10.0],
  'pageIndex': 0,
};

void main() {
  late _FakeManager mgr;
  setUp(() => mgr = _FakeManager());

  group('getAnnotations', () {
    test('parses a bare Instant JSON array into typed models', () async {
      mgr.annotationsJson = jsonEncode([_ink, _highlight]);
      final result = await mgr.getAnnotations(0);
      expect(result, hasLength(2));
      expect(result[0], isA<InkAnnotation>());
      expect(result[1], isA<HighlightAnnotation>());
    });

    test('also handles the {"annotations": [...]} envelope form', () async {
      mgr.annotationsJson = jsonEncode({
        'annotations': [_ink]
      });
      expect(await mgr.getAnnotations(0), hasLength(1));
    });

    test('skips unknown/malformed entries instead of throwing', () async {
      mgr.annotationsJson = jsonEncode([_ink, _unknown]);
      final result = await mgr.getAnnotations(0);
      expect(result, hasLength(1));
      expect(result.single, isA<InkAnnotation>());
    });

    test('filters by type on the parsed model (platform-consistent)', () async {
      mgr.annotationsJson = jsonEncode([_ink, _highlight]);
      final inks = await mgr.getAnnotations(0, AnnotationType.ink);
      expect(inks, hasLength(1));
      expect(inks.single.type, AnnotationType.ink);
    });

    test('empty payload yields an empty list', () async {
      mgr.annotationsJson = '';
      expect(await mgr.getAnnotations(0), isEmpty);
    });
  });

  test('addAnnotation serializes the typed model and parses the result',
      () async {
    final note = Annotation.fromJson(const {
      'type': 'pspdfkit/note',
      'bbox': [0.0, 0.0, 20.0, 20.0],
      'pageIndex': 0,
      'text': {'format': 'plain', 'value': 'hi'},
      'icon': 'note',
    });
    final created = await mgr.addAnnotation(note);
    expect(created, isA<NoteAnnotation>());
    expect(mgr.lastAddedJson, contains('pspdfkit/note'));
  });

  test('getUnsavedAnnotations / searchAnnotations parse typed results',
      () async {
    mgr.annotationsJson = jsonEncode([_highlight]);
    expect(await mgr.getUnsavedAnnotations(), hasLength(1));
    expect(await mgr.searchAnnotations('q'), hasLength(1));
  });
}
