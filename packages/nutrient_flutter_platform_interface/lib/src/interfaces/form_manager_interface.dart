///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import '../models/forms/form_field.dart';

/// Abstract interface for form field operations on a PDF document.
///
/// Concrete implementations are provided by each platform package:
/// - `FormManagerAndroid` in `nutrient_flutter_android`
/// - `FormManagerIOS` in `nutrient_flutter_ios`
/// - `FormManagerWeb` in `nutrient_flutter_web`
///
/// Access via `controller.document.forms`.
///
/// ## Customising Behaviour
///
/// Override the form manager in your document subclass:
///
/// ```dart
/// class MyDocument extends NutrientDocumentAndroid {
///   @override
///   FormManagerInterface createFormManager() => MyFormManager(this);
/// }
///
/// class MyFormManager extends FormManagerAndroid {
///   @override
///   Future<String?> getFormFieldValue(String fqn) async {
///     // custom logic
///     return super.getFormFieldValue(fqn);
///   }
/// }
/// ```
abstract class FormManagerInterface {
  /// Returns the value of the form field identified by [fullyQualifiedName],
  /// or `null` if not found.
  Future<String?> getFormFieldValue(String fullyQualifiedName);

  /// Sets the value of the form field identified by [fullyQualifiedName].
  ///
  /// Returns `true` if the field was found and the value was set successfully.
  Future<bool> setFormFieldValue(String value, String fullyQualifiedName);

  /// Returns a JSON string of all form fields in the document.
  Future<String> getFormFieldsJson();

  /// Returns a JSON string for the form field identified by [fieldName].
  Future<String> getFormFieldJson(String fieldName);
}

/// Typed convenience layer over the JSON transport on [FormManagerInterface].
///
/// Wraps the `*Json` methods and parses into the typed [PdfFormField]
/// hierarchy. Parsing is defensive — a field of an unrecognized type is skipped
/// rather than throwing. See documentation/typed-annotations-cross-platform.md.
extension FormManagerTyped on FormManagerInterface {
  /// Returns all form fields in the document as typed [PdfFormField]s.
  Future<List<PdfFormField>> getFormFields() async =>
      _parseFormFieldList(await getFormFieldsJson());

  /// Returns the typed form field named [fieldName], or `null` if not found or
  /// of an unrecognized type.
  Future<PdfFormField?> getFormField(String fieldName) async {
    final fields = _parseFormFieldList(await getFormFieldJson(fieldName));
    return fields.isEmpty ? null : fields.first;
  }
}

/// Parses a form-fields JSON payload — a bare array or a single field object —
/// into typed models, skipping any field of an unrecognized type.
List<PdfFormField> _parseFormFieldList(String jsonString) {
  if (jsonString.isEmpty) return const [];
  final dynamic decoded = jsonDecode(jsonString);
  final List<dynamic> raw =
      decoded is List ? decoded : (decoded is Map ? [decoded] : const []);
  final result = <PdfFormField>[];
  for (final item in raw) {
    if (item is Map) {
      try {
        result.add(PdfFormField.fromMap(Map<String, dynamic>.from(item)));
      } catch (_) {
        // Skip an unrecognized/malformed field rather than failing the batch.
      }
    }
  }
  return result;
}
