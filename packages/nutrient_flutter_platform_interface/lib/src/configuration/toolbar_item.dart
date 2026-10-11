///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';

/// A built-in toolbar item — drop these straight into
/// [NutrientControllerInterface.setMainToolbarItems] (each value is itself a
/// [ToolbarItem]).
///
/// Each value maps to the Web SDK's toolbar item type id (its [id]) — listing
/// the ones you want, in order, is how you reorder/trim the toolbar. Built-in
/// reordering is honored on **Web only**; Android and iOS ignore built-in items
/// (see the parity matrix on [ToolbarItem]).
///
/// This mirrors the legacy `NutrientWebToolbarItemType`, lifted to the
/// bindings' platform-interface layer so the cross-platform [ToolbarItem] can
/// reference it (the legacy enum lives in the higher-level `nutrient_flutter`
/// wrapper, which depends on this package — not the other way around).
enum ToolbarItemType implements ToolbarItem {
  sidebarThumbnails('sidebar-thumbnails'),
  sidebarDocumentOutline('sidebar-document-outline'),
  sidebarAnnotations('sidebar-annotations'),
  sidebarBookmarks('sidebar-bookmarks'),
  sidebarSignatures('sidebar-signatures'),
  sidebarLayers('sidebar-layers'),
  sidebarAttachments('sidebar-attachments'),
  pager('pager'),
  pan('pan'),
  zoomOut('zoom-out'),
  zoomIn('zoom-in'),
  zoomMode('zoom-mode'),
  spacer('spacer'),
  annotate('annotate'),
  ink('ink'),
  highlighter('highlighter'),
  textHighlighter('text-highlighter'),
  inkEraser('ink-eraser'),
  signature('signature'),
  image('image'),
  stamp('stamp'),
  note('note'),
  text('text'),
  line('line'),
  arrow('arrow'),
  rectangle('rectangle'),
  cloudyRectangle('cloudy-rectangle'),
  dashedRectangle('dashed-rectangle'),
  ellipse('ellipse'),
  cloudyEllipse('cloudy-ellipse'),
  dashedEllipse('dashed-ellipse'),
  polygon('polygon'),
  cloudyPolygon('cloudy-polygon'),
  dashedPolygon('dashed-polygon'),
  polyline('polyline'),
  print('print'),
  documentEditor('document-editor'),
  documentCrop('document-crop'),
  search('search'),
  exportPdf('export-pdf'),
  debug('debug'),
  contentEditor('content-editor'),
  link('link'),
  multiAnnotationsSelection('multi-annotations-selection'),
  callout('callout'),
  responsiveGroup('responsive-group'),
  measurements('measure'),
  linearizedDownloadIndicator('linearized-download-indicator'),
  comment('comment'),
  aiAssistant('ai-assistant');

  const ToolbarItemType(this.id);

  /// The Web SDK toolbar item type id this maps to (e.g. `'zoom-in'`).
  final String id;
}

/// A single item in the viewer's main toolbar.
///
/// Hand a list of these to [NutrientControllerInterface.setMainToolbarItems]
/// (reachable from `NutrientDocumentView.onControllerReady`). There are two
/// kinds, both usable directly in the list — no wrapper needed:
///
/// - a [ToolbarItemType] value (e.g. [ToolbarItemType.zoomIn]) — a built-in item
/// - a [CustomToolbarItem] — a custom button backed by a Dart `onPressed`
///
/// The call is re-appliable at any time, so you can add / remove / enable /
/// disable items dynamically.
///
/// ```dart
/// NutrientDocumentView(
///   documentPath: path,
///   onControllerReady: (controller) {
///     controller.setMainToolbarItems([
///       ToolbarItemType.zoomOut,
///       ToolbarItemType.zoomIn,
///       CustomToolbarItem(
///         id: 'say-hello',
///         title: 'Hello',
///         onPressed: () => debugPrint('toolbar button tapped'),
///       ),
///     ]);
///   },
/// );
/// ```
///
/// ## Platform parity
///
/// - [CustomToolbarItem] — a custom button backed by a Dart [onPressed]
///   callback — works on **Android, iOS, and Web**. On Android/Web it sits in
///   the viewer's document toolbar; on iOS it's added to the navigation bar.
/// - [ToolbarItemType] — reorder/remove the viewer's built-in items — is
///   honored on **Web only**; Android and iOS ignore built-in entries (the
///   custom items in the same list still apply).
sealed class ToolbarItem {
  const ToolbarItem();
}

/// A custom toolbar button backed by a Dart [onPressed] callback. Works on
/// Android, iOS, and Web.
///
/// [id] must be unique across the toolbar. [onPressed] is invoked on the Dart
/// side when the user taps the button. [title] is the label / tooltip.
///
/// [icon] is best-effort per platform (Web: a URL, data-URI, or inline SVG
/// string; native platforms currently render [title]). [className] / [selected]
/// / [disabled] are honored on Web; native ignores [className] and uses
/// [disabled] where the platform allows.
final class CustomToolbarItem extends ToolbarItem {
  const CustomToolbarItem({
    required this.id,
    this.title,
    this.icon,
    this.className,
    this.onPressed,
    this.selected,
    this.disabled,
  });

  /// Unique id for the item.
  final String id;

  /// Label / tooltip.
  final String? title;

  /// Button icon — best-effort per platform (Web: URL/data-URI/SVG string).
  final String? icon;

  /// CSS class applied to the button (Web only).
  final String? className;

  /// Invoked (on the Dart side) when the button is tapped.
  final VoidCallback? onPressed;

  /// Whether the button renders in a selected/active state (Web).
  final bool? selected;

  /// Whether the button is disabled.
  final bool? disabled;
}
