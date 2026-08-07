///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// The annotation creation tool to activate when entering annotation creation
/// mode on a viewer.
///
/// Mirrors the pigeon-generated enum of the same name in
/// `nutrient_flutter_platform_interface/lib/src/api/nutrient_api.g.dart`.
/// The pigeon version is transport-only; this one is the public API
/// surface and is what
/// [NutrientControllerInterface.enterAnnotationCreationMode] expects.
enum AnnotationTool implements AnnotationToolbarItem {
  inkPen,
  inkMagic,
  inkHighlighter,
  freeText,
  freeTextCallOut,
  stamp,
  image,
  highlight,
  underline,
  squiggly,
  strikeOut,
  line,
  arrow,
  square,
  circle,
  polygon,
  polyline,
  eraser,
  cloudy,
  link,
  caret,
  richMedia,
  screen,
  file,
  widget,
  redaction,
  signature,
  stampImage,
  note,
  sound,
  measurementAreaRect,
  measurementAreaPolygon,
  measurementAreaEllipse,
  measurementPerimeter,
  measurementDistance,
}

/// A single item in the viewer's **annotation creation toolbar** (the tool
/// picker shown when you enter annotation mode).
///
/// Hand a list of these to
/// [NutrientControllerInterface.setAnnotationToolbarItems] to reorder, add,
/// remove, or group the annotation tools. There are two kinds, both usable
/// directly in the list — no wrapper needed:
///
/// - an [AnnotationTool] value (e.g. [AnnotationTool.inkPen]) — a single tool
/// - an [AnnotationToolGroup] — a collapsible group of tools
///
/// ```dart
/// controller.setAnnotationToolbarItems([
///   AnnotationTool.inkPen,
///   AnnotationTool.square,
///   AnnotationToolGroup(
///     representative: AnnotationTool.highlight,
///     items: [AnnotationTool.highlight, AnnotationTool.underline, AnnotationTool.strikeOut],
///   ),
/// ]);
/// ```
///
/// ## Platform parity
///
/// Reordering/grouping the creation tool picker is supported on **Android and
/// iOS**. On **Web** the annotation tools live in the main toolbar, so customize
/// them with [NutrientControllerInterface.setMainToolbarItems] instead (this
/// call is a no-op on Web).
sealed class AnnotationToolbarItem {
  const AnnotationToolbarItem();
}

/// A collapsible group of [AnnotationTool]s in the annotation creation toolbar.
///
/// The group occupies one slot on the toolbar showing [representative]; the
/// other [items] appear when the slot is expanded (long-press on Android, the
/// group's secondary tools on iOS).
final class AnnotationToolGroup extends AnnotationToolbarItem {
  const AnnotationToolGroup({
    required this.representative,
    required this.items,
  });

  /// The tool shown when the group is collapsed. Should be one of [items].
  final AnnotationTool representative;

  /// The tools in the group, in display order.
  final List<AnnotationTool> items;
}
