///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

enum PspdfkitWebAnnotationToolbarItemType {
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

extension WebAnnotationToolbarTypeX on PspdfkitWebAnnotationToolbarItemType {
  String get name {
    switch (this) {
      // Basic Controls
      case PspdfkitWebAnnotationToolbarItemType.spacer:
        return 'spacer';
      case PspdfkitWebAnnotationToolbarItemType.back:
        return 'back';
      case PspdfkitWebAnnotationToolbarItemType.close:
        return 'close';
      case PspdfkitWebAnnotationToolbarItemType.delete:
        return 'delete';
      case PspdfkitWebAnnotationToolbarItemType.custom:
        return 'custom';

      // Color Controls
      case PspdfkitWebAnnotationToolbarItemType.strokeColor:
        return 'stroke-color';
      case PspdfkitWebAnnotationToolbarItemType.fillColor:
        return 'fill-color';
      case PspdfkitWebAnnotationToolbarItemType.backgroundColor:
        return 'background-color';
      case PspdfkitWebAnnotationToolbarItemType.color:
        return 'color';
      case PspdfkitWebAnnotationToolbarItemType.outlineColor:
        return 'outline-color';
      case PspdfkitWebAnnotationToolbarItemType.textColor:
        return 'text-color';

      // Appearance Controls
      case PspdfkitWebAnnotationToolbarItemType.opacity:
        return 'opacity';
      case PspdfkitWebAnnotationToolbarItemType.lineWidth:
        return 'line-width';
      case PspdfkitWebAnnotationToolbarItemType.borderWidth:
        return 'border-width';
      case PspdfkitWebAnnotationToolbarItemType.borderColor:
        return 'border-color';
      case PspdfkitWebAnnotationToolbarItemType.borderStyle:
        return 'border-style';
      case PspdfkitWebAnnotationToolbarItemType.lineStyle:
        return 'line-style';
      case PspdfkitWebAnnotationToolbarItemType.linecapsDasharray:
        return 'linecaps-dasharray';
      case PspdfkitWebAnnotationToolbarItemType.blendMode:
        return 'blend-mode';
      case PspdfkitWebAnnotationToolbarItemType.font:
        return 'font';

      // Annotation Specific
      case PspdfkitWebAnnotationToolbarItemType.annotationNote:
        return 'annotation-note';
      case PspdfkitWebAnnotationToolbarItemType.annotationComment:
        return 'annotation-comment';
      case PspdfkitWebAnnotationToolbarItemType.noteIcon:
        return 'note-icon';
      case PspdfkitWebAnnotationToolbarItemType.overlayText:
        return 'overlay-text';

      // Redaction Controls
      case PspdfkitWebAnnotationToolbarItemType.applyRedactions:
        return 'apply-redactions';
      case PspdfkitWebAnnotationToolbarItemType.overlay:
        return 'overlay';

      // Measurement Controls
      case PspdfkitWebAnnotationToolbarItemType.measurementType:
        return 'measurementType';
      case PspdfkitWebAnnotationToolbarItemType.measurementScale:
        return 'measurementScale';
      case PspdfkitWebAnnotationToolbarItemType.snapping:
        return 'snapping';

      // Document Editing
      case PspdfkitWebAnnotationToolbarItemType.cropCurrent:
        return 'crop-current';
      case PspdfkitWebAnnotationToolbarItemType.cropAll:
        return 'crop-all';

      // Content Editor Controls
      case PspdfkitWebAnnotationToolbarItemType.addTextBox:
        return 'add-text-box';
      case PspdfkitWebAnnotationToolbarItemType.cancelSave:
        return 'cancel-save';

      // Rotation Controls
      case PspdfkitWebAnnotationToolbarItemType.counterclockwiseRotation:
        return 'counterclockwise-rotation';
      case PspdfkitWebAnnotationToolbarItemType.clockwiseRotation:
        return 'clockwise-rotation';

      // Form Controls
      case PspdfkitWebAnnotationToolbarItemType.formButton:
        return 'form-button';
      case PspdfkitWebAnnotationToolbarItemType.formText:
        return 'form-text';
      case PspdfkitWebAnnotationToolbarItemType.formRadio:
        return 'form-radio';
      case PspdfkitWebAnnotationToolbarItemType.formCheckbox:
        return 'form-checkbox';
      case PspdfkitWebAnnotationToolbarItemType.formCombobox:
        return 'form-combobox';
      case PspdfkitWebAnnotationToolbarItemType.formListbox:
        return 'form-listbox';
      case PspdfkitWebAnnotationToolbarItemType.formSignature:
        return 'form-signature';
      case PspdfkitWebAnnotationToolbarItemType.formDate:
        return 'form-date';
      case PspdfkitWebAnnotationToolbarItemType.separatorEndEnforce:
        return 'separator-end-enforce';
    }
  }
}
