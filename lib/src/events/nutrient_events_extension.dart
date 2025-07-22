import 'package:nutrient_flutter/nutrient_flutter.dart';

extension NutrientEventX on NutrientEvent {
  String get webName {
    switch (this) {
      case NutrientEvent.annotationsCreated:
        return 'annotations.create';
      case NutrientEvent.annotationsUpdated:
        return 'annotations.update';
      case NutrientEvent.annotationsDeleted:
        return 'annotations.delete';
      case NutrientEvent.annotationsSelected:
        return 'annotations.focus';
      case NutrientEvent.annotationsDeselected:
        return 'annotations.blur';
      case NutrientEvent.textSelectionChanged:
        return 'textSelection.change';
      case NutrientEvent.formFieldValuesUpdated:
        return 'formFieldValues.update';
      case NutrientEvent.formFieldDeselected:
        return 'formFields.deselected';
      case NutrientEvent.formFieldSelected:
        return 'formFields.selected';
      default:
        return '';
    }
  }
}
