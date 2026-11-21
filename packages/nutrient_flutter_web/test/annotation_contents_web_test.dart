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
import 'package:nutrient_flutter_web/src/web_platform_adapter.dart';

/// A stand-in for the parts of the Web SDK that `contents` uses. Each
/// annotation class is a Record like Immutable.js's: it declares a fixed set
/// of fields, `has()` reports them, and `set()` of any other field returns
/// the record unchanged. Like the Web SDK, setting `text` to anything but
/// `{format, value}` throws.
const _fakeSdk = r'''
(() => {
  const record = (declared) => {
    const fields = {id: null, pageIndex: 0, opacity: 1, note: null,
        ...declared};
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
        if (k === 'text' && !(v && typeof v === 'object' &&
            'format' in v && 'value' in v)) {
          throw new Error("Annotations: 'text' is not an object with " +
              "properties 'format' and 'value'");
        }
        return this.has(k) ? new Record({...this._values, [k]: v}) : this;
      }
    };
    return Record;
  };
  globalThis.NutrientViewer = {
    Annotations: {
      TextAnnotation: record({fontColor: null, text: null}),
      NoteAnnotation: record({color: null, text: null}),
      HighlightAnnotation: record({color: null}),
      toSerializableObject: (annotation) => ({...annotation._values}),
    },
  };
  // An instance whose page 0 holds [annotation] and that keeps it up to date
  // with update().
  return (annotation) => ({
    current: annotation,
    getAnnotations(pageIndex) {
      const current = this.current;
      return Promise.resolve({size: 1, get: (i) => current});
    },
    update(annotation) {
      this.current = annotation;
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

  /// A [className] annotation with id `a` and [values].
  JSObject annotation(String className, Map<String, Object?> values) {
    final sdk = globalContext['NutrientViewer'] as JSObject;
    return ((sdk['Annotations'] as JSObject)[className] as JSFunction)
        .callAsConstructor<JSObject>({'id': 'a', ...values}.jsify());
  }

  /// A manager for a document whose only annotation is [annotation], and
  /// the instance that holds it.
  (AnnotationManagerWeb, JSObject) managerFor(JSObject annotation) {
    final instance = makeInstance.callAsFunction(null, annotation) as JSObject;
    return (
      AnnotationManagerWeb(NutrientDocumentWeb.headless(
          NutrientWebAdapter(), instance as nutrient_web.Instance)),
      instance,
    );
  }

  /// The `text` of the annotation [instance] holds, as `{format, value}`.
  Map<String, Object?>? textOf(JSObject instance) {
    final current = instance['current'] as JSObject;
    final text = current.callMethod<JSAny?>('get'.toJS, 'text'.toJS);
    return (text.dartify() as Map?)?.cast<String, Object?>();
  }

  test('reads a note\'s text as contents', () async {
    final (manager, _) = managerFor(annotation('NoteAnnotation', {
      'text': {'format': 'plain', 'value': 'This is a yellow note'},
    }));
    final properties = await manager.getAnnotationProperties(0, 'a');
    expect(properties?.contents, 'This is a yellow note');
  });

  test('reads rich free text as its text without markup', () async {
    final (manager, _) = managerFor(annotation('TextAnnotation', {
      'text': {
        'format': 'xhtml',
        'value': '<p><span style="color: #ff0000">Hello &amp; bye</span></p>',
      },
    }));
    final properties = await manager.getAnnotationProperties(0, 'a');
    expect(properties?.contents, 'Hello & bye');
  });

  test('writes a note\'s contents as plain text', () async {
    final (manager, instance) = managerFor(annotation('NoteAnnotation', {
      'text': {'format': 'plain', 'value': 'Old'},
    }));
    final properties = await manager.getAnnotationProperties(0, 'a');
    await manager.saveAnnotationProperties(properties!.copyWith(
      contents: 'New',
    ));
    expect(textOf(instance), {'format': 'plain', 'value': 'New'});
    expect((await manager.getAnnotationProperties(0, 'a'))?.contents, 'New');
  });

  test('keeps a note\'s text when saving other properties', () async {
    final (manager, instance) = managerFor(annotation('NoteAnnotation', {
      'text': {'format': 'plain', 'value': 'Keep me'},
    }));
    final properties = await manager.getAnnotationProperties(0, 'a');
    await manager.saveAnnotationProperties(properties!.copyWith(opacity: 0.5));
    expect(textOf(instance), {'format': 'plain', 'value': 'Keep me'});
  });

  test('writes plain free text contents as plain text', () async {
    final (manager, instance) = managerFor(annotation('TextAnnotation', {
      'text': {'format': 'plain', 'value': 'Old'},
    }));
    final properties = await manager.getAnnotationProperties(0, 'a');
    await manager.saveAnnotationProperties(properties!.copyWith(
      contents: 'New',
    ));
    expect(textOf(instance), {'format': 'plain', 'value': 'New'});
  });

  group('rich free text', () {
    const xhtml = '<p><span style="color: #ff0000"><b>Bold</b> text</span>'
        '</p>';

    Future<(AnnotationManagerWeb, JSObject)> richText() async =>
        managerFor(annotation('TextAnnotation', {
          'text': {'format': 'xhtml', 'value': xhtml},
        }));

    test('keeps its markup when the contents are unchanged', () async {
      final (manager, instance) = await richText();
      final properties = await manager.getAnnotationProperties(0, 'a');
      await manager
          .saveAnnotationProperties(properties!.copyWith(opacity: 0.5));
      expect(textOf(instance), {'format': 'xhtml', 'value': xhtml});
    });

    test('becomes the new contents in the existing colour', () async {
      final (manager, instance) = await richText();
      final properties = await manager.getAnnotationProperties(0, 'a');
      await manager.saveAnnotationProperties(
          properties!.copyWith(contents: 'New <text>\nLine 2'));
      expect(textOf(instance), {
        'format': 'xhtml',
        'value': '<p><span style="color:#ff0000">New &lt;text&gt;</span></p>'
            '<p><span style="color:#ff0000">Line 2</span></p>',
      });
      expect((await manager.getAnnotationProperties(0, 'a'))?.contents,
          'New <text>\nLine 2');
    });
  });

  test('leaves annotations without text alone', () async {
    final highlight = annotation('HighlightAnnotation', {});
    final (_, instance) = managerFor(highlight);
    await NutrientAnnotationOperations(instance as nutrient_web.Instance)
        .updateAnnotationProperties(
            {'id': 'a', 'pageIndex': 0, 'contents': 'Ignored'});
    expect(textOf(instance), isNull);
  });
}
