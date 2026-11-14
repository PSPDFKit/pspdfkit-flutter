///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// Runs with `flutter test --platform chrome`.
@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_web/src/document/annotation_manager_web.dart';
import 'package:nutrient_flutter_web/src/document/nutrient_document_web.dart';
import 'package:nutrient_flutter_web/src/generated/nutrient_web_bindings.g.dart'
    as nutrient_web;
import 'package:nutrient_flutter_web/src/operations/annotation_operations.dart';
import 'package:nutrient_flutter_web/src/utils/immutable_utils.dart';
import 'package:nutrient_flutter_web/src/web_platform_adapter.dart';

/// A stand-in for the parts of the Web SDK the colour mapping uses. Each
/// annotation class is a Record like Immutable.js's: it declares a fixed set
/// of fields, `has()` reports them, and `set()` of any other field returns
/// the record unchanged. Colour fields are those the Web SDK declares.
const _fakeSdk = r'''
(() => {
  class Color {
    constructor({r, g, b}) { this.r = r; this.g = g; this.b = b; }
  }
  const hex = (c) => '#' + [c.r, c.g, c.b]
      .map((v) => v.toString(16).padStart(2, '0')).join('').toUpperCase();
  const record = (declared) => {
    const fields = {id: null, pageIndex: 0, opacity: 1, ...declared};
    const Record = class {
      constructor(values) {
        this._values = {...fields, ...values};
        for (const k of Object.keys(fields)) {
          Object.defineProperty(this, k, {get: () => this._values[k]});
        }
      }
      has(k) { return Object.prototype.hasOwnProperty.call(fields, k); }
      get(k) { return this._values[k]; }
      set(k, v) {
        return this.has(k) ? new Record({...this._values, [k]: v}) : this;
      }
    };
    return Record;
  };
  globalThis.NutrientViewer = {
    Color,
    Annotations: {
      TextAnnotation: record({fontColor: null, backgroundColor: null,
          borderColor: null, text: null}),
      NoteAnnotation: record({color: null, text: null}),
      HighlightAnnotation: record({color: null, rects: null}),
      RectangleAnnotation: record({strokeColor: null, fillColor: null,
          strokeWidth: 1}),
      RedactionAnnotation: record({color: null, fillColor: null,
          outlineColor: null, overlayText: null}),
      StampAnnotation: record({color: null, stampType: null}),
      WidgetAnnotation: record({borderColor: null, backgroundColor: null,
          fontColor: null}),
      toSerializableObject: (annotation) => Object.fromEntries(
          Object.entries(annotation._values).map(([k, v]) =>
              [k, v instanceof Color ? hex(v) : v])),
    },
  };
  // An instance whose page 0 holds [annotations] and that keeps the last
  // record passed to update().
  return (annotations) => ({
    updated: null,
    getAnnotations(pageIndex) {
      return Promise.resolve(
          {size: annotations.length, get: (i) => annotations[i]});
    },
    update(annotation) {
      this.updated = annotation;
      return Promise.resolve(annotation);
    },
  });
})()
''';

void main() {
  late JSFunction makeInstance;

  setUpAll(() {
    makeInstance =
        globalContext.callMethod('eval'.toJS, _fakeSdk.toJS) as JSFunction;
  });

  tearDownAll(() => globalContext.delete('NutrientViewer'.toJS));

  JSObject sdk() => globalContext['NutrientViewer'] as JSObject;

  /// A [className] annotation with id `a` and [values], where an int value
  /// of a colour field is an RGB colour.
  JSObject annotation(String className, Map<String, Object?> values) {
    final jsValues = JSObject()..['id'] = 'a'.toJS;
    values.forEach((key, value) {
      jsValues[key] = key.toLowerCase().endsWith('color') && value is int
          ? (sdk()['Color'] as JSFunction).callAsConstructor<JSObject>({
              'r': (value >> 16) & 0xFF,
              'g': (value >> 8) & 0xFF,
              'b': value & 0xFF,
            }.jsify())
          : value.jsify();
    });
    return ((sdk()['Annotations'] as JSObject)[className] as JSFunction)
        .callAsConstructor<JSObject>(jsValues);
  }

  /// [field] of the record the last update() received, as `#RRGGBB`.
  String? updatedColor(JSObject instance, String field) {
    final updated = instance['updated'] as JSObject?;
    final value = updated?.callMethod<JSObject?>('get'.toJS, field.toJS);
    if (value == null) return null;
    final rgb = [value['r'], value['g'], value['b']]
        .map((c) => (c as JSNumber).toDartInt.toRadixString(16).padLeft(2, '0'))
        .join();
    return '#${rgb.toUpperCase()}';
  }

  JSObject instanceWith(JSObject annotation) =>
      makeInstance.callAsFunction(null, [annotation].jsify()) as JSObject;

  NutrientAnnotationOperations opsFor(JSObject instance) =>
      NutrientAnnotationOperations(instance as nutrient_web.Instance);

  group('ImmutableRecord.has', () {
    test('reports the fields a Record declares', () {
      final note = annotation('NoteAnnotation', {});
      expect(ImmutableRecord.has(note, 'color'), isTrue);
      expect(ImmutableRecord.has(note, 'strokeColor'), isFalse);
    });

    test('is false for objects that are not Records', () {
      expect(ImmutableRecord.has(JSObject(), 'color'), isFalse);
      final notBoolean = JSObject()
        ..['has'] = ((JSString key) => 'yes'.toJS).toJS;
      expect(ImmutableRecord.has(notBoolean, 'color'), isFalse);
    });
  });

  group('webAnnotationToPropertiesJson', () {
    Map<String, dynamic>? read(JSObject annotation) =>
        opsFor(instanceWith(annotation))
            .webAnnotationToPropertiesJson(annotation);

    test('reports color as strokeColor where there is no strokeColor field',
        () {
      expect(
          read(annotation('NoteAnnotation', {'color': 0xFF0000}))?[
              'strokeColor'],
          equalsIgnoringCase('#FF0000'));
      expect(
          read(annotation('HighlightAnnotation', {'color': 0x00FF00}))?[
              'strokeColor'],
          equalsIgnoringCase('#00FF00'));
      expect(
          read(annotation('StampAnnotation', {'color': 0x0000FF}))?[
              'strokeColor'],
          equalsIgnoringCase('#0000FF'));
      // A redaction's color is its overlay text colour, not its outline.
      final redaction = read(annotation('RedactionAnnotation',
          {'color': 0x112233, 'outlineColor': 0x445566}));
      expect(redaction?['strokeColor'], equalsIgnoringCase('#112233'));
      expect(redaction?['outlineColor'], equalsIgnoringCase('#445566'));
    });

    test('keeps strokeColor for shapes', () {
      final json =
          read(annotation('RectangleAnnotation', {'strokeColor': 0x123456}));
      expect(json?['strokeColor'], equalsIgnoringCase('#123456'));
    });

    test('reports a free text annotation\'s fontColor as strokeColor', () {
      final json = read(annotation('TextAnnotation', {'fontColor': 0xABCDEF}));
      expect(json?['strokeColor'], equalsIgnoringCase('#ABCDEF'));
    });

    test('adds no strokeColor to annotations without a colour field', () {
      final json = read(annotation('WidgetAnnotation', {}));
      expect(json, isNotNull);
      expect(json!.containsKey('strokeColor'), isFalse);
    });
  });

  group('updateAnnotationProperties', () {
    Future<JSObject> save(JSObject annotation, Object strokeColor) async {
      final instance = instanceWith(annotation);
      await opsFor(instance).updateAnnotationProperties(
          {'id': 'a', 'pageIndex': 0, 'strokeColor': strokeColor});
      return instance;
    }

    test('writes strokeColor to color where there is no strokeColor field',
        () async {
      // ARGB int, as AnnotationProperties.toJson() emits it.
      var instance = await save(
          annotation('NoteAnnotation', {'color': 0xFF0000}), 0xFF00FF00);
      expect(updatedColor(instance, 'color'), '#00FF00');
      // `{r,g,b}`, as NutrientView passes it.
      instance = await save(
          annotation('HighlightAnnotation', {'color': 0xFF0000}),
          {'r': 0, 'g': 0, 'b': 255});
      expect(updatedColor(instance, 'color'), '#0000FF');
      instance = await save(
          annotation('RedactionAnnotation',
              {'color': 0xFF0000, 'outlineColor': 0x445566}),
          0xFF00FF00);
      expect(updatedColor(instance, 'color'), '#00FF00');
      expect(updatedColor(instance, 'outlineColor'), '#445566');
    });

    test('writes strokeColor to strokeColor for shapes', () async {
      final instance = await save(
          annotation('RectangleAnnotation', {'strokeColor': 0xFF0000}),
          0xFF00FF00);
      expect(updatedColor(instance, 'strokeColor'), '#00FF00');
    });

    test('writes strokeColor to a plain free text annotation\'s fontColor',
        () async {
      var instance = await save(
          annotation('TextAnnotation', {'fontColor': 0xFF0000, 'text': 'Hi'}),
          0xFF00FF00);
      expect(updatedColor(instance, 'fontColor'), '#00FF00');
      instance = await save(
          annotation('TextAnnotation', {'fontColor': 0xFF0000, 'text': 'Hi'}),
          {'r': 0, 'g': 0, 'b': 255});
      expect(updatedColor(instance, 'fontColor'), '#0000FF');
    });
  });

  test('AnnotationManagerWeb round-trips strokeColor', () async {
    final instance =
        instanceWith(annotation('NoteAnnotation', {'color': 0xFF0000}));
    final manager = AnnotationManagerWeb(NutrientDocumentWeb.headless(
        NutrientWebAdapter(), instance as nutrient_web.Instance));

    final properties = await manager.getAnnotationProperties(0, 'a');
    expect(properties?.strokeColor, 0xFFFF0000);

    await manager.saveAnnotationProperties(
        properties!.copyWith(strokeColor: 0xFF00FF00));
    expect(updatedColor(instance, 'color'), '#00FF00');
  });
}
