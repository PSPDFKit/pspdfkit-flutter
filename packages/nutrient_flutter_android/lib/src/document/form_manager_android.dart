///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:jni/jni.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import '../bindings/nutrient_android_sdk_bindings.dart'
    hide Nutrient, DocumentSaveOptions, Bookmark;
import 'nutrient_document_android.dart';

/// Android implementation of [FormManagerInterface].
///
/// Uses JNI bindings to the Nutrient Android SDK's [FormProvider].
/// Obtained via `document.forms`.
class FormManagerAndroid implements FormManagerInterface {
  final NutrientDocumentAndroid document;

  FormManagerAndroid(this.document);

  FormProvider _requireProvider() =>
      document.requireDocument().getFormProvider();

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async {
    final provider = _requireProvider();
    final field = provider
        .getFormFieldWithFullyQualifiedName(fullyQualifiedName.toJString());
    if (field == null) return null;
    final elements = field.formElements;
    field.release();
    if (elements.isEmpty()) {
      elements.release();
      return null;
    }
    final element = elements.get(0);
    elements.release();
    if (element == null) return null;
    final value = getFormElementValue(element);
    element.release();
    return value;
  }

  @override
  Future<bool> setFormFieldValue(
      String value, String fullyQualifiedName) async {
    final provider = _requireProvider();
    final field = provider
        .getFormFieldWithFullyQualifiedName(fullyQualifiedName.toJString());
    if (field == null) return false;
    final elements = field.formElements;
    field.release();
    if (elements.isEmpty()) {
      elements.release();
      return false;
    }
    final element = elements.get(0);
    elements.release();
    if (element == null) return false;
    setFormElementValue(element, value);
    element.release();
    return true;
  }

  @override
  Future<String> getFormFieldsJson() async {
    final provider = _requireProvider();
    final fields = provider.getFormFields();
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < fields.size(); i++) {
      final f = fields.get(i);
      if (f == null) continue;
      result.add(formFieldToJson(f));
      f.release();
    }
    fields.release();
    return jsonEncode(result);
  }

  @override
  Future<String> getFormFieldJson(String fieldName) async {
    final provider = _requireProvider();
    final field =
        provider.getFormFieldWithFullyQualifiedName(fieldName.toJString());
    if (field == null) return jsonEncode(null);
    final json = formFieldToJson(field);
    field.release();
    return jsonEncode(json);
  }

  // ---------------------------------------------------------------------------
  // Static converters
  // ---------------------------------------------------------------------------

  /// Get the value of a form element as a string.
  static String? getFormElementValue(FormElement element) {
    final typeObj = element.type$1;
    final typeName = typeObj.toString();
    typeObj.release();

    if (typeName.contains('TEXT')) {
      final textEl = element.as(TextFormElement.type);
      final text = textEl.text?.toDartString(releaseOriginal: true);
      textEl.release();
      return text;
    }
    if (typeName.contains('CHECKBOX') || typeName.contains('RADIO')) {
      final btnEl = element.as(EditableButtonFormElement.type);
      final selected = btnEl.isSelected;
      btnEl.release();
      return selected ? 'true' : 'false';
    }
    if (typeName.contains('CHOICE') ||
        typeName.contains('LISTBOX') ||
        typeName.contains('COMBOBOX')) {
      final choiceEl = element.as(ChoiceFormElement.type);
      final indexes = choiceEl.selectedIndexes;
      final options = choiceEl.options;
      final values = <String>[];
      for (int i = 0; i < indexes.size(); i++) {
        final idx = indexes.get(i)?.intValue();
        if (idx != null && idx < options.size()) {
          final opt = options.get(idx);
          if (opt != null) {
            values.add(opt.toString());
            opt.release();
          }
        }
        indexes.get(i)?.release();
      }
      indexes.release();
      options.release();
      choiceEl.release();
      return values.join(', ');
    }
    return null;
  }

  /// Set the value of a form element from a string.
  static void setFormElementValue(FormElement element, String value) {
    final typeObj = element.type$1;
    final typeName = typeObj.toString();
    typeObj.release();

    if (typeName.contains('TEXT')) {
      final textEl = element.as(TextFormElement.type);
      textEl.setText(value.toJString());
      textEl.release();
    } else if (typeName.contains('CHECKBOX') || typeName.contains('RADIO')) {
      final btnEl = element.as(EditableButtonFormElement.type);
      if (value.toLowerCase() == 'true' || value == '1') {
        btnEl.select();
      } else {
        btnEl.deselect();
      }
      btnEl.release();
    }
  }

  /// Serialize a [FormField] to a JSON map.
  static Map<String, dynamic> formFieldToJson(FormField field) {
    final name = field.name.toDartString(releaseOriginal: true);
    final fqn = field.fullyQualifiedName.toDartString(releaseOriginal: true);
    final typeObj = field.type$1;
    final type = typeObj.toString();
    typeObj.release();
    final elements = field.formElements;
    String? value;
    if (!elements.isEmpty()) {
      final el = elements.get(0);
      if (el != null) {
        value = getFormElementValue(el);
        el.release();
      }
    }
    elements.release();
    return {
      'name': name,
      'fullyQualifiedName': fqn,
      'type': type,
      if (value != null) 'value': value,
    };
  }
}
