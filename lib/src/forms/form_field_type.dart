///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

enum PdfFormFieldTypes {
  // Text field
  text,

  // Checkbox
  checkbox,

  // Radio button
  radioButton,

  // Combo box
  comboBox,

  // List box
  listBox,

  // Signature field
  signature,

  // Button
  button,

  // Unknown field type
  unknown
}

extension PdfFormFieldTypesExtension on PdfFormFieldTypes {
  String get nativeName {
    switch (this) {
      case PdfFormFieldTypes.text:
        return 'TEXT';
      case PdfFormFieldTypes.checkbox:
        return 'CHECKBOX';
      case PdfFormFieldTypes.radioButton:
        return 'RADIOBUTTON';
      case PdfFormFieldTypes.comboBox:
        return 'COMBOBOX';
      case PdfFormFieldTypes.listBox:
        return 'LISTBOX';
      case PdfFormFieldTypes.signature:
        return 'SIGNATURE';
      case PdfFormFieldTypes.button:
        return 'PUSHBUTTON';
      case PdfFormFieldTypes.unknown:
        return 'UNDEFINED';
    }
  }
}
