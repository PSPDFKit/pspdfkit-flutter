///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

enum PspdfkitWebAnnotationToolbarItemType {
  strokeColor,
  fillColor,
  backgroundColor,
  opacity,
  lineWidth,
  lineStyle,
  linecapsDasharray,
  blendMode,
  delete,
  spacer,
  annotationNote,
  borderStyle,
  borderWidth,
  borderColor,
  applyRedactions,
  color,
  font,
  outlineColor,
  overlayText,
  noteIcon,
  counterclockwiseRotation,
  clockwiseRotation,
  measurementType,
  measurementScale,
  back,
  snapping,
  custom,
}

extension WebAnnotationToolbarTypeX on PspdfkitWebAnnotationToolbarItemType {
  String get name {
    switch (this) {
      case PspdfkitWebAnnotationToolbarItemType.strokeColor:
        return 'stroke-color';
      case PspdfkitWebAnnotationToolbarItemType.fillColor:
        return 'fill-color';
      case PspdfkitWebAnnotationToolbarItemType.backgroundColor:
        return 'background-color';
      case PspdfkitWebAnnotationToolbarItemType.opacity:
        return 'opacity';
      case PspdfkitWebAnnotationToolbarItemType.lineWidth:
        return 'line-width';
      case PspdfkitWebAnnotationToolbarItemType.lineStyle:
        return 'line-style';
      case PspdfkitWebAnnotationToolbarItemType.linecapsDasharray:
        return 'linecaps-dasharray';
      case PspdfkitWebAnnotationToolbarItemType.blendMode:
        return 'blend-mode';
      case PspdfkitWebAnnotationToolbarItemType.delete:
        return 'delete';
      case PspdfkitWebAnnotationToolbarItemType.spacer:
        return 'spacer';
      case PspdfkitWebAnnotationToolbarItemType.annotationNote:
        return 'annotation-note';
      case PspdfkitWebAnnotationToolbarItemType.borderStyle:
        return 'border-style';
      case PspdfkitWebAnnotationToolbarItemType.borderWidth:
        return 'border-width';
      case PspdfkitWebAnnotationToolbarItemType.borderColor:
        return 'border-color';
      case PspdfkitWebAnnotationToolbarItemType.applyRedactions:
        return 'apply-redactions';
      case PspdfkitWebAnnotationToolbarItemType.color:
        return 'color';
      case PspdfkitWebAnnotationToolbarItemType.font:
        return 'font';
      case PspdfkitWebAnnotationToolbarItemType.outlineColor:
        return 'outline-color';
      case PspdfkitWebAnnotationToolbarItemType.overlayText:
        return 'overlay-text';
      case PspdfkitWebAnnotationToolbarItemType.noteIcon:
        return 'note-icon';
      case PspdfkitWebAnnotationToolbarItemType.custom:
        return 'custom';
      case PspdfkitWebAnnotationToolbarItemType.counterclockwiseRotation:
        return 'counterclockwise-rotation';
      case PspdfkitWebAnnotationToolbarItemType.clockwiseRotation:
        return 'clockwise-rotation';
      case PspdfkitWebAnnotationToolbarItemType.measurementType:
        return 'measurementType';
      case PspdfkitWebAnnotationToolbarItemType.measurementScale:
        return 'measurementScale';
      case PspdfkitWebAnnotationToolbarItemType.back:
        return 'back';
      case PspdfkitWebAnnotationToolbarItemType.snapping:
        return 'snapping';
      default:
        throw Exception('Unknown annotation toolbar type: $this');
    }
  }
}
