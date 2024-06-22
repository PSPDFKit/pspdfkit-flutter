import 'package:pspdfkit_flutter/src/forms/form_field.dart';

class RadioButtonFormField extends PdfFormField {
  final bool? isSelected;

  RadioButtonFormField({required this.isSelected});

  factory RadioButtonFormField.fromMap(dynamic map) {
    return RadioButtonFormField(
      isSelected: map['isSelected'],
    );
  }
}
