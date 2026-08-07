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

import '../operations/form_operations.dart';
import 'nutrient_document_web.dart';

/// Web implementation of [FormManagerInterface].
///
/// Delegates to [NutrientFormOperations] accessed via the adapter.
/// Obtained via `document.forms`.
class FormManagerWeb implements FormManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentWeb document;

  FormManagerWeb(this.document);

  NutrientFormOperations get _ops {
    final ops = document.internalFormOperations;
    if (ops == null) {
      throw StateError(
        'FormManagerWeb: instance not loaded — is onInstanceLoaded called?',
      );
    }
    return ops;
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async {
    return _ops.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool> setFormFieldValue(
      String value, String fullyQualifiedName) async {
    await _ops.setFormFieldValue(fullyQualifiedName, value);
    return true;
  }

  @override
  Future<String> getFormFieldsJson() async {
    final fields = await _ops.getFormFields();
    return jsonEncode(fields);
  }

  @override
  Future<String> getFormFieldJson(String fieldName) async {
    final field = await _ops.getFormField(fieldName);
    return jsonEncode(field);
  }
}
