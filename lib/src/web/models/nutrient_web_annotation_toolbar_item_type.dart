///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

enum NutrientWebAnnotationToolbarItemType {
  // Basic Controls
  spacer,
  back,
  close,
  delete,
  custom,

  // Color Controls
  strokeColor,
  fillColor,
  backgroundColor,
  color,
  outlineColor,
  textColor,

  // Appearance Controls
  opacity,
  lineWidth,
  borderWidth,
  borderColor,
  borderStyle,
  lineStyle,
  linecapsDasharray,
  blendMode,
  font,

  // Annotation Specific
  annotationNote,
  annotationComment,
  noteIcon,
  overlayText,

  // Redaction Controls
  applyRedactions,
  overlay,

  // Measurement Controls
  measurementType,
  measurementScale,
  snapping,

  // Document Editing
  cropCurrent,
  cropAll,

  // Content Editor Controls
  addTextBox,
  cancelSave,

  // Rotation Controls
  counterclockwiseRotation,
  clockwiseRotation,

  // Form Controls
  formButton,
  formText,
  formRadio,
  formCheckbox,
  formCombobox,
  formListbox,
  formSignature,
  formDate,
  separatorEndEnforce
}

extension WebAnnotationToolbarTypeX on NutrientWebAnnotationToolbarItemType {
  String get name {
    switch (this) {
      // Basic Controls
      case NutrientWebAnnotationToolbarItemType.spacer:
        return 'spacer';
      case NutrientWebAnnotationToolbarItemType.back:
        return 'back';
      case NutrientWebAnnotationToolbarItemType.close:
        return 'close';
      case NutrientWebAnnotationToolbarItemType.delete:
        return 'delete';
      case NutrientWebAnnotationToolbarItemType.custom:
        return 'custom';

      // Color Controls
      case NutrientWebAnnotationToolbarItemType.strokeColor:
        return 'stroke-color';
      case NutrientWebAnnotationToolbarItemType.fillColor:
        return 'fill-color';
      case NutrientWebAnnotationToolbarItemType.backgroundColor:
        return 'background-color';
      case NutrientWebAnnotationToolbarItemType.color:
        return 'color';
      case NutrientWebAnnotationToolbarItemType.outlineColor:
        return 'outline-color';
      case NutrientWebAnnotationToolbarItemType.textColor:
        return 'text-color';

      // Appearance Controls
      case NutrientWebAnnotationToolbarItemType.opacity:
        return 'opacity';
      case NutrientWebAnnotationToolbarItemType.lineWidth:
        return 'line-width';
      case NutrientWebAnnotationToolbarItemType.borderWidth:
        return 'border-width';
      case NutrientWebAnnotationToolbarItemType.borderColor:
        return 'border-color';
      case NutrientWebAnnotationToolbarItemType.borderStyle:
        return 'border-style';
      case NutrientWebAnnotationToolbarItemType.lineStyle:
        return 'line-style';
      case NutrientWebAnnotationToolbarItemType.linecapsDasharray:
        return 'linecaps-dasharray';
      case NutrientWebAnnotationToolbarItemType.blendMode:
        return 'blend-mode';
      case NutrientWebAnnotationToolbarItemType.font:
        return 'font';

      // Annotation Specific
      case NutrientWebAnnotationToolbarItemType.annotationNote:
        return 'annotation-note';
      case NutrientWebAnnotationToolbarItemType.annotationComment:
        return 'annotation-comment';
      case NutrientWebAnnotationToolbarItemType.noteIcon:
        return 'note-icon';
      case NutrientWebAnnotationToolbarItemType.overlayText:
        return 'overlay-text';

      // Redaction Controls
      case NutrientWebAnnotationToolbarItemType.applyRedactions:
        return 'apply-redactions';
      case NutrientWebAnnotationToolbarItemType.overlay:
        return 'overlay';

      // Measurement Controls
      case NutrientWebAnnotationToolbarItemType.measurementType:
        return 'measurementType';
      case NutrientWebAnnotationToolbarItemType.measurementScale:
        return 'measurementScale';
      case NutrientWebAnnotationToolbarItemType.snapping:
        return 'snapping';

      // Document Editing
      case NutrientWebAnnotationToolbarItemType.cropCurrent:
        return 'crop-current';
      case NutrientWebAnnotationToolbarItemType.cropAll:
        return 'crop-all';

      // Content Editor Controls
      case NutrientWebAnnotationToolbarItemType.addTextBox:
        return 'add-text-box';
      case NutrientWebAnnotationToolbarItemType.cancelSave:
        return 'cancel-save';

      // Rotation Controls
      case NutrientWebAnnotationToolbarItemType.counterclockwiseRotation:
        return 'counterclockwise-rotation';
      case NutrientWebAnnotationToolbarItemType.clockwiseRotation:
        return 'clockwise-rotation';

      // Form Controls
      case NutrientWebAnnotationToolbarItemType.formButton:
        return 'form-button';
      case NutrientWebAnnotationToolbarItemType.formText:
        return 'form-text';
      case NutrientWebAnnotationToolbarItemType.formRadio:
        return 'form-radio';
      case NutrientWebAnnotationToolbarItemType.formCheckbox:
        return 'form-checkbox';
      case NutrientWebAnnotationToolbarItemType.formCombobox:
        return 'form-combobox';
      case NutrientWebAnnotationToolbarItemType.formListbox:
        return 'form-listbox';
      case NutrientWebAnnotationToolbarItemType.formSignature:
        return 'form-signature';
      case NutrientWebAnnotationToolbarItemType.formDate:
        return 'form-date';
      case NutrientWebAnnotationToolbarItemType.separatorEndEnforce:
        return 'separator-end-enforce';
    }
  }
}
