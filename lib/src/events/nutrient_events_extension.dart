import 'package:nutrient_flutter/nutrient_flutter.dart';

extension NutrientEventX on NutrientEvent {
  /// Returns the web event name for this NutrientEvent.
  /// Returns an empty string for events not supported on the web platform.
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
      // Note: formFieldSelected and formFieldDeselected are not supported
      // on the Nutrient Web SDK. These events are only available on native platforms.
      case NutrientEvent.formFieldDeselected:
      case NutrientEvent.formFieldSelected:
        return '';
    }
  }

  /// Returns true if this event is supported on the web platform.
  bool get isWebSupported {
    switch (this) {
      case NutrientEvent.formFieldDeselected:
      case NutrientEvent.formFieldSelected:
        return false;
      default:
        return webName.isNotEmpty;
    }
  }
}
