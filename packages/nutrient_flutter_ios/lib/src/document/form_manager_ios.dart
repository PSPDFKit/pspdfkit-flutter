///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:objective_c/objective_c.dart' as objc;

import '../bindings/nutrient_ios_bindings.dart';
import 'nutrient_document_ios.dart';

/// iOS implementation of [FormManagerInterface].
///
/// Uses FFI bindings to the Nutrient iOS SDK's [PSPDFFormParser].
/// Obtained via `document.forms`.
class FormManagerIOS implements FormManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentIOS document;

  FormManagerIOS(this.document);

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async {
    final doc = document.requireDocument();
    final formParser = doc.formParser;
    if (formParser == null) return null;
    final element = formParser.findAnnotationWithFieldName(
      fullyQualifiedName.toNSString(),
    );
    if (element == null) return null;
    final value = element.value;
    if (value == null) return null;
    // value is typically an NSString for text fields.
    return objc.NSString.as(value).toDartString();
  }

  @override
  Future<bool> setFormFieldValue(
    String value,
    String fullyQualifiedName,
  ) async {
    final doc = document.requireDocument();
    final formParser = doc.formParser;
    if (formParser == null) return false;
    final element = formParser.findAnnotationWithFieldName(
      fullyQualifiedName.toNSString(),
    );
    if (element == null) return false;
    element.value = value.toNSString();
    return true;
  }

  @override
  Future<String> getFormFieldsJson() async {
    final doc = document.requireDocument();
    final formParser = doc.formParser;
    if (formParser == null) return jsonEncode([]);
    final fields = formParser.formFields;
    if (fields == null) return jsonEncode([]);
    final result = <Map<String, dynamic>>[];
    for (final item in fields.asDart()) {
      final field = PSPDFFormField.as(item);
      result.add({
        'name': field.name?.toDartString(),
        'fullyQualifiedName': field.fullyQualifiedName?.toDartString(),
      });
    }
    return jsonEncode(result);
  }

  @override
  Future<String> getFormFieldJson(String fieldName) async {
    final doc = document.requireDocument();
    final formParser = doc.formParser;
    if (formParser == null) return jsonEncode(null);
    final field = formParser.findFieldWithFullFieldName(fieldName.toNSString());
    if (field == null) return jsonEncode(null);
    return jsonEncode({
      'name': field.name?.toDartString(),
      'fullyQualifiedName': field.fullyQualifiedName?.toDartString(),
    });
  }
}
