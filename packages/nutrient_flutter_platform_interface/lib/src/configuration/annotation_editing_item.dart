///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// A control on the **annotation editing / property toolbar** — the bar shown
/// when an existing annotation is selected.
///
/// Hand a list of these to
/// [NutrientControllerInterface.setAnnotationEditingToolbarItems] to reorder,
/// add, or remove the property controls / actions for a selected annotation.
///
/// ## Platform parity
///
/// - **Web** — all items apply (mapped to the Web SDK's annotation toolbar item
///   types via `instance.setAnnotationToolbarItems`).
/// - **Android** — style items ([color], [opacity], …) map to the editable
///   annotation properties; the [note] / [delete] actions map to the editing
///   toolbar buttons.
/// - **iOS** — the **style** items ([color], [fillColor], [outlineColor],
///   [opacity], [thickness], [blendMode], [font], [borderStyle], [lineEnds])
///   apply via the style inspector; [note] and [delete] are selected-annotation
///   *menu actions* and are **not** customizable from Dart yet (they need native
///   glue — see docs/annotation-toolbar-customization.md), so they are ignored
///   on iOS.
///
/// Individual items that a platform/annotation type doesn't support are ignored.
enum AnnotationEditingItem {
  /// Stroke / primary color.
  color,

  /// Fill color (shapes).
  fillColor,

  /// Outline color.
  outlineColor,

  /// Opacity / alpha.
  opacity,

  /// Stroke thickness / line width.
  thickness,

  /// Blend mode (Web/iOS).
  blendMode,

  /// Font (free text).
  font,

  /// Border / line style (e.g. solid, dashed).
  borderStyle,

  /// Line end caps (line/arrow).
  lineEnds,

  /// Open the annotation's note.
  note,

  /// Delete the annotation.
  delete,
}
