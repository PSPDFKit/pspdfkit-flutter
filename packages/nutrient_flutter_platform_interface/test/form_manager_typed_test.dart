// Tests the typed forms layer (FormManagerTyped extension) + the typed
// FormFieldUpdatedEvent.formField accessor.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/src/events/nutrient_event.dart';
import 'package:nutrient_flutter_platform_interface/src/interfaces/form_manager_interface.dart';
import 'package:nutrient_flutter_platform_interface/src/models/forms/text_form_field.dart';

class _FakeForms implements FormManagerInterface {
  String fieldsJson = '[]';
  @override
  Future<String> getFormFieldsJson() async => fieldsJson;
  @override
  Future<String> getFormFieldJson(String fieldName) async => fieldsJson;
  @override
  Future<String?> getFormFieldValue(String fqn) async => null;
  @override
  Future<bool> setFormFieldValue(String value, String fqn) async => true;
}

Map<String, dynamic> _text(String name) => {
      'type': 'text',
      'name': name,
      'fullyQualifiedName': name,
      'text': 'hello',
      'defaultValue': '',
    };

void main() {
  late _FakeForms mgr;
  setUp(() => mgr = _FakeForms());

  test('getFormFields parses a bare array into typed PdfFormFields', () async {
    mgr.fieldsJson = jsonEncode([_text('a'), _text('b')]);
    final fields = await mgr.getFormFields();
    expect(fields, hasLength(2));
    expect(fields[0], isA<PdfTextFormField>());
    expect(fields[0].name, 'a');
  });

  test('getFormFields skips fields of an unrecognized type', () async {
    mgr.fieldsJson = jsonEncode([
      _text('a'),
      {'type': 'not-a-real-type', 'name': 'x'},
    ]);
    expect(await mgr.getFormFields(), hasLength(1));
  });

  test('getFormField parses a single field object', () async {
    mgr.fieldsJson = jsonEncode(_text('only'));
    final field = await mgr.getFormField('only');
    expect(field, isA<PdfTextFormField>());
    expect(field!.name, 'only');
  });

  test('empty payload yields an empty list', () async {
    mgr.fieldsJson = '';
    expect(await mgr.getFormFields(), isEmpty);
  });

  test('FormFieldUpdatedEvent.formField parses the typed field', () {
    final e = FormFieldUpdatedEvent(jsonEncode(_text('changed')));
    expect(e.formField, isA<PdfTextFormField>());
    expect(e.formField!.name, 'changed');
  });
}
