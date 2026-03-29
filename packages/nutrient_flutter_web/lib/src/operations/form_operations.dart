///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../nutrient_web_bindings.dart';
import '../utils/immutable_utils.dart';
import '../utils/namespace_utils.dart';

/// Map of Web SDK form field class names to their type strings.
const formFieldTypeMap = <String, String>{
  'TextFormField': 'text',
  'SignatureFormField': 'signature',
  'CheckBoxFormField': 'checkbox',
  'RadioButtonFormField': 'radioButton',
  'ComboBoxFormField': 'comboBox',
  'ListBoxFormField': 'listBox',
  'ButtonFormField': 'button',
};

/// Provides form field operations on a Nutrient Web SDK instance.
///
/// Accessible via [NutrientWebAdapter.formOperations] after the instance
/// is loaded.
class NutrientFormOperations {
  final NutrientWebInstance _instance;

  NutrientFormOperations(this._instance);

  /// Gets all form fields as Dart JSON maps.
  ///
  /// Each map includes a `type` field determined via `instanceof` checks.
  Future<List<Map<String, dynamic>>> getFormFields() async {
    final result = await _instance.getFormFields().toDart;
    if (result == null) return [];

    final items = ImmutableList.toListViaIterator(result);
    final formFields = <Map<String, dynamic>>[];

    for (final item in items) {
      final fieldMap = _formFieldToMap(item);
      fieldMap['type'] = _getFormFieldType(item);
      formFields.add(fieldMap);
    }

    return formFields;
  }

  /// Gets a specific form field by its fully qualified name.
  ///
  /// Returns null if no form field with the given name is found.
  Future<Map<String, dynamic>?> getFormField(String fullyQualifiedName) async {
    final fields = await getFormFields();
    for (final field in fields) {
      if (field['name'] == fullyQualifiedName ||
          field['fullyQualifiedName'] == fullyQualifiedName) {
        return field;
      }
    }
    return null;
  }

  /// Gets form field values as a map of field names to values.
  Map<String, dynamic>? getFormFieldValues() {
    final result = _instance.getFormFieldValues();
    final dartified = result.dartify();
    if (dartified is Map<String, dynamic>) return dartified;
    if (dartified is Map) return Map<String, dynamic>.from(dartified);
    return null;
  }

  /// Gets the value of a specific form field.
  String? getFormFieldValue(String fullyQualifiedName) {
    final values = getFormFieldValues();
    if (values == null) return null;
    final value = values[fullyQualifiedName];
    return value?.toString();
  }

  /// Sets form field values.
  ///
  /// The [values] map keys are fully qualified field names.
  Future<void> setFormFieldValues(Map<String, dynamic> values) async {
    await _instance.setFormFieldValues(values.jsify()!).toDart;
  }

  /// Sets a single form field value.
  Future<void> setFormFieldValue(
    String fullyQualifiedName,
    String value,
  ) async {
    await setFormFieldValues({fullyQualifiedName: value});
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts a Web SDK form field JS object to a Dart map.
  Map<String, dynamic> _formFieldToMap(JSObject field) {
    // Use JSON.stringify to convert the Immutable.js Record
    final jsonNs = globalContext['JSON'] as JSObject?;
    if (jsonNs == null) return {};

    final jsonStr = jsonNs.callMethod('stringify'.toJS, field) as JSString?;
    if (jsonStr == null) return {};

    final decoded = jsonStr.toDart;
    if (decoded.isEmpty) return {};

    try {
      final parsed = jsonDecode(decoded);
      if (parsed is Map<String, dynamic>) return parsed;
      if (parsed is Map) return Map<String, dynamic>.from(parsed);
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Determines the form field type using `instanceof` checks.
  String _getFormFieldType(JSObject field) {
    final ns = NutrientNamespace.getAsJSObject();
    final formFieldsNs = ns['FormFields'] as JSObject?;
    if (formFieldsNs == null) return 'unknown';

    for (final entry in formFieldTypeMap.entries) {
      final className = entry.key;
      final typeName = entry.value;

      final fieldClass = formFieldsNs[className];
      if (fieldClass == null) continue;

      if (field.instanceof(fieldClass as JSFunction)) {
        return typeName;
      }
    }

    return 'unknown';
  }
}
