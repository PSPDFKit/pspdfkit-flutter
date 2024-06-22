///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:pspdfkit_flutter/src/forms/form_field.dart';

class ButtonFormField extends PdfFormField {
  final String? buttonLabel;

  ButtonFormField({required this.buttonLabel});

  factory ButtonFormField.fromMap(dynamic map) {
    return ButtonFormField(buttonLabel: map['buttonLabel'] ?? map['label']);
  }
}
