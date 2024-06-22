///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:pspdfkit_flutter/src/forms/button_form_field.dart';
import 'package:pspdfkit_flutter/src/forms/form_field_type.dart';
import 'package:pspdfkit_flutter/src/forms/listbox_form_field.dart';
import 'package:pspdfkit_flutter/src/forms/radio_button_form_field.dart';

import 'checkbox_form_field.dart';
import 'combobox_form_field.dart';
import 'signature_form_field.dart';
import 'text_form_field.dart';

abstract class PdfFormField {
  late String _name;
  late String? _alternativeFieldName;
  late String? _fullyQualifiedName;
  late PdfFormFieldTypes _type;
  List<dynamic>? _annotations;
  late bool? _isReadOnly;
  late bool? _isRequired;
  late bool? _isExported;
  late bool? _isDirty;

  PdfFormField();

  factory PdfFormField.fromMap(dynamic map) {
    final PdfFormFieldTypes type = PdfFormFieldTypes.values.firstWhere(
        (element) =>
            (element.nativeName == map['type'] || element.name == map['type']));
    switch (type) {
      case PdfFormFieldTypes.text:
        return PdfTextFormField.fromMap(map)..populateCommonFields(map);
      case PdfFormFieldTypes.signature:
        return SignatureFormField()..populateCommonFields(map);
      case PdfFormFieldTypes.checkbox:
        return CheckBoxFormField.fromMap(map)..populateCommonFields(map);
      case PdfFormFieldTypes.comboBox:
        return ComboBoxFormField.fromMap(map)..populateCommonFields(map);
      case PdfFormFieldTypes.listBox:
        return ListBoxFormField.fromMap(map)..populateCommonFields(map);
      case PdfFormFieldTypes.button:
        return ButtonFormField.fromMap(map)..populateCommonFields(map);
      case PdfFormFieldTypes.radioButton:
        return RadioButtonFormField.fromMap(map)..populateCommonFields(map);
      default:
        throw Exception('Unknown form field type: $type');
    }
  }

  void populateCommonFields(dynamic map) {
    _type = PdfFormFieldTypes.values.firstWhere((element) =>
        element.nativeName == map['type'] || element.name == map['type']);
    _name = map['name'];
    _alternativeFieldName = map['alternateFieldName'] ?? map['label'];
    _fullyQualifiedName = map['fullyQualifiedName'] ?? map['name'];
    _isReadOnly = map['isReadOnly'] ?? map['readOnly'];
    _isRequired = map['isRequired'] ?? map['required'];
    _isExported = map['isNoExport'] ?? map['noExport'];
    _isDirty = map['isDirty'] ?? false;
  }

  void populateWebCommonFields(dynamic map) {
    _type = PdfFormFieldTypes.values.firstWhere((element) =>
        element.nativeName == map['type'] || element.name == map['type']);
    _name = map['name'];
    _alternativeFieldName = map['label'];
    _isReadOnly = map['readOnly'];
    _isRequired = map['required'];
    _isExported = map['noExport'];
  }

  String? get name => _name;

  String? get alternativeFieldName => _alternativeFieldName;

  String? get fullyQualifiedName => _fullyQualifiedName;

  PdfFormFieldTypes get type => _type;

  List<dynamic>? get annotations => _annotations;

  bool? get isReadOnly => _isReadOnly;

  bool? get isRequired => _isRequired;

  bool? get isNoExport => _isExported;

  bool? get isDirty => _isDirty;

  @override
  String toString() {
    return 'Name: $_name, Alternative Field Name: $_alternativeFieldName, Fully Qualified Name: $_fullyQualifiedName, Type: $_type, Is Read Only: $_isReadOnly, Is Required: $_isRequired, Is Exported: $_isExported, Is Dirty: $_isDirty';
  }
}
