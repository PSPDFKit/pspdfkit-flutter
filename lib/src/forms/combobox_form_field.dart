///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter/nutrient_flutter.dart';

class ComboBoxFormField extends PdfFormField {
  final List<String> defaultValues;
  final List<int>? selectedIndices;
  final List<PdfFormOption> options;
  final List<String>? values;

  ComboBoxFormField(
      {required this.defaultValues,
      required this.selectedIndices,
      required this.options,
      required this.values});

  factory ComboBoxFormField.fromMap(dynamic map) {
    return ComboBoxFormField(
        defaultValues: List<String>.from(map['defaultValues']),
        selectedIndices: List<int>.from(map['selectedIndices']),
        options: _populateOptions(map['options']),
        values: List<String>.from(map['values']));
  }

  static List<PdfFormOption> _populateOptions(dynamic json) {
    return json
        .map((e) => PdfFormOption(
              value: e['value'],
              label: e['label'],
            ))
        .toList();
  }
}
