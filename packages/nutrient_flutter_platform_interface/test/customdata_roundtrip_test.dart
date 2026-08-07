import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

void main() {
  test('customData round-trips through fromJson/toInstantJsonOverrides', () {
    // READ: InstantJSON `customData` object -> model customDataJson string
    final r = AnnotationProperties.fromJson({
      'name': 'abc',
      'pageIndex': 0,
      'customData': {'foo': 'bar', 'n': 42},
    });
    expect(r.customDataJson, jsonEncode({'foo': 'bar', 'n': 42}));

    // READ fallback: pre-encoded string passes through
    final s = AnnotationProperties.fromJson({'customDataJson': '{"x":1}'});
    expect(s.customDataJson, '{"x":1}');

    // SAVE: model customDataJson string -> InstantJSON `customData` object
    final p = AnnotationProperties(
      annotationId: 'abc',
      pageIndex: 0,
      customDataJson: '{"foo":"bar","n":42}',
    );
    final ov = p.toInstantJsonOverrides();
    expect(ov['customData'], isA<Map>());
    expect((ov['customData'] as Map)['foo'], 'bar');
    expect(ov.containsKey('annotationId'), isFalse);
    expect(ov.containsKey('customDataJson'), isFalse);
  });

  test('flags round-trip through fromJson/toInstantJsonOverrides', () {
    // READ: InstantJSON `flags` array -> model flagsJson string
    final r = AnnotationProperties.fromJson({
      'name': 'abc',
      'pageIndex': 0,
      'flags': ['hidden', 'readOnly'],
    });
    expect(r.flagsJson, jsonEncode(['hidden', 'readOnly']));

    // READ fallback: pre-encoded flagsJson string passes through
    final s = AnnotationProperties.fromJson({'flagsJson': '["print"]'});
    expect(s.flagsJson, '["print"]');

    // SAVE: model flagsJson string -> InstantJSON `flags` array
    final p = AnnotationProperties(
      annotationId: 'abc',
      pageIndex: 0,
      flagsJson: jsonEncode(['hidden', 'noView']),
    );
    final ov = p.toInstantJsonOverrides();
    expect(ov['flags'], ['hidden', 'noView']);
    expect(ov.containsKey('flagsJson'), isFalse);

    // No flags -> no `flags` key in the overrides (untouched flags left alone).
    const none = AnnotationProperties(annotationId: 'abc', pageIndex: 0);
    expect(none.toInstantJsonOverrides().containsKey('flags'), isFalse);
  });
}
