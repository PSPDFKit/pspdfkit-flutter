///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui';

import '../configuration/annotation_editing_item.dart';
import '../configuration/toolbar_item.dart';
import '../events/nutrient_event.dart';
import '../models/annotation_tool.dart';
import 'nutrient_document_interface.dart';

/// Pure interface for the Nutrient viewer controller.
///
/// This defines the public API surface that users interact with when
/// controlling a PDF viewer. It is intentionally separate from the
/// internal lifecycle plumbing in [NutrientController].
///
/// ## Usage
///
/// Define your own controller type by extending this interface:
///
/// ```dart
/// abstract class MyController implements NutrientControllerInterface {
///   Future<int> getCurrentPageIndex();
///   Future<void> goToPage(int pageIndex);
/// }
/// ```
///
/// Then use it with [NutrientView] for type-safe access:
///
/// ```dart
/// NutrientView<MyController>(
///   documentPath: 'document.pdf',
///   onControllerReady: (controller) async {
///     final count = await controller.document.getPageCount();
///     await controller.goToPage(5);
///   },
/// )
/// ```
///
/// ## Provided APIs
///
/// - [document] — access to document-level operations (annotations,
///   bookmarks, forms, save/export, etc.)
/// - [isReady] / [isDisposed] — lifecycle state queries
/// - [dispose] — resource cleanup
/// - [setAnnotationConfigurations] — annotation toolbar presets
/// - [setAnnotationMenuConfiguration] — annotation context menu config
/// - [getVisibleRect], [zoomToRect], [getZoomScale] — viewport queries
///   and zoom control
/// - [enterAnnotationCreationMode], [exitAnnotationCreationMode] —
///   annotation creation mode toggling
/// - [convertViewPointToPdfPoint], [convertPdfPointToViewPoint] —
///   coordinate-space conversion between view and PDF page
abstract class NutrientControllerInterface {
  /// The open PDF document and its document-level operations.
  ///
  /// Available after the controller is ready.
  ///
  /// ```dart
  /// final count = await controller.document.getPageCount();
  /// final json = await controller.document.annotations.getAnnotationsJson(0, 'all');
  /// final bookmarks = await controller.document.bookmarks.getBookmarks();
  /// ```
  NutrientDocumentInterface get document;

  /// A broadcast stream of cross-platform typed SDK events.
  ///
  /// Covers the common event surface available on Android, iOS, and Web.
  /// Subscribe to all events or use the typed getters from [NutrientEventStreamX]:
  ///
  /// ```dart
  /// // All events via switch
  /// controller.events.listen((event) {
  ///   switch (event) {
  ///     case PageChangedEvent(:final pageIndex):
  ///       print('Page → $pageIndex');
  ///     default:
  ///       break;
  ///   }
  /// });
  ///
  /// // Filtered via extension getters
  /// controller.events.pageChanged.listen((e) => print(e.pageIndex));
  /// controller.events.annotationCreated.listen((e) => print(e.annotationsJson));
  /// ```
  ///
  /// Platform-specific events are available on the respective adapter:
  /// - Android: `AndroidAdapter.androidEvents`
  /// - iOS: `IOSAdapter.iosEvents`
  /// - Web: `NutrientWebAdapter.webEvents`
  Stream<NutrientEvent> get events;

  /// Whether the controller is ready for use.
  bool get isReady;

  /// Whether the controller has been disposed.
  bool get isDisposed;

  /// Dispose of this controller and release resources.
  Future<void> dispose();

  // ---------------------------------------------------------------------------
  // View / UI configuration
  // ---------------------------------------------------------------------------

  /// Sets annotation preset configurations for the viewer's annotation toolbar.
  ///
  /// [configurations] is a map of annotation tool name → configuration map.
  /// This controls the default properties (color, line width, etc.) shown in
  /// the annotation creation toolbar.
  ///
  /// This is a view-level setting — it requires an active viewer.
  Future<bool> setAnnotationConfigurations(Map<String, dynamic> configurations);

  /// Configures the annotation context menu (items to show, disable, or hide).
  ///
  /// [configuration] contains keys such as `itemsToExclude`, `itemsToInclude`,
  /// and `retainSuggestedMenuItems`.
  ///
  /// This is a view-level setting — it requires an active viewer.
  Future<bool> setAnnotationMenuConfiguration(
      Map<String, dynamic> configuration);

  // ---------------------------------------------------------------------------
  // Viewport and zoom
  // ---------------------------------------------------------------------------

  /// Gets the visible rect of the given page.
  ///
  /// [pageIndex] is zero-based.
  /// Returns the visible rect in PDF page coordinates.
  Future<Rect> getVisibleRect(int pageIndex);

  /// Zooms to the given [rect] on the given page.
  ///
  /// [pageIndex] is zero-based. [rect] is in PDF page coordinates.
  Future<void> zoomToRect(int pageIndex, Rect rect);

  /// Gets the current zoom scale of the given page.
  ///
  /// [pageIndex] is zero-based.
  Future<double> getZoomScale(int pageIndex);

  // ---------------------------------------------------------------------------
  // Annotation creation mode
  // ---------------------------------------------------------------------------

  /// Enters annotation creation mode for the specified [annotationTool].
  ///
  /// If no tool is specified, the platform default is used (typically
  /// [AnnotationTool.inkPen]).
  ///
  /// Returns `true` if the mode was entered, `false` if the request was
  /// rejected (e.g. the viewer is not ready), or `null` if the platform
  /// does not report a result.
  Future<bool?> enterAnnotationCreationMode([AnnotationTool? annotationTool]);

  /// Exits annotation creation mode and returns to normal viewer
  /// interaction.
  ///
  /// Returns `true` if the mode was exited, `false` if the request was
  /// rejected, or `null` if the platform does not report a result.
  Future<bool?> exitAnnotationCreationMode();

  // ---------------------------------------------------------------------------
  // Toolbar customization
  // ---------------------------------------------------------------------------

  /// Replaces the viewer's main toolbar with [items].
  ///
  /// [CustomToolbarItem] entries add custom buttons whose taps run their Dart
  /// `onPressed` — supported on Android, iOS, and Web. [ToolbarItemType] values
  /// reorder/remove the built-in items and are honored on Web only.
  ///
  /// Re-callable at any time (e.g. to add, remove, enable, or disable items
  /// dynamically). No-op on controllers that don't support customization.
  ///
  /// ```dart
  /// onControllerReady: (controller) => controller.setMainToolbarItems([
  ///   ToolbarItemType.zoomIn,
  ///   CustomToolbarItem(id: 'greet', title: 'Hello', onPressed: _onGreet),
  /// ]);
  /// ```
  Future<void> setMainToolbarItems(List<ToolbarItem> items);

  /// Replaces the viewer's **annotation creation toolbar** (the tool picker) with
  /// [items] — reorder, add, remove, or group the annotation tools.
  ///
  /// Each entry is an [AnnotationTool] or an [AnnotationToolGroup]. Supported on
  /// **Android and iOS**; on **Web** the annotation tools live in the main
  /// toolbar (use [setMainToolbarItems]), so this is a no-op there.
  ///
  /// Re-callable at any time. No-op on controllers that don't support it.
  ///
  /// ```dart
  /// onControllerReady: (controller) => controller.setAnnotationToolbarItems([
  ///   AnnotationTool.inkPen,
  ///   AnnotationToolGroup(representative: AnnotationTool.highlight, items: [
  ///     AnnotationTool.highlight, AnnotationTool.underline, AnnotationTool.strikeOut,
  ///   ]),
  /// ]);
  /// ```
  Future<void> setAnnotationToolbarItems(List<AnnotationToolbarItem> items);

  /// Replaces the **annotation editing / property toolbar** (the bar shown when
  /// an annotation is selected) with [items] — reorder, add, or remove the
  /// property controls / actions.
  ///
  /// Supported on **Web and Android**; on **iOS** the style controls apply but
  /// the `note` / `delete` menu actions are ignored (see the parity notes on
  /// [AnnotationEditingItem]).
  ///
  /// Re-callable at any time. No-op on controllers that don't support it.
  ///
  /// ```dart
  /// onControllerReady: (controller) => controller.setAnnotationEditingToolbarItems([
  ///   AnnotationEditingItem.color,
  ///   AnnotationEditingItem.opacity,
  ///   AnnotationEditingItem.thickness,
  ///   AnnotationEditingItem.delete,
  /// ]);
  /// ```
  Future<void> setAnnotationEditingToolbarItems(
      List<AnnotationEditingItem> items);

  // ---------------------------------------------------------------------------
  // Coordinate conversion
  // ---------------------------------------------------------------------------

  /// Converts a point from the page view's coordinate space to PDF page
  /// coordinates.
  ///
  /// [point] must be in logical pixel coordinates (device-independent
  /// pixels), relative to the top-left corner of the rendered page within
  /// the viewer. This corresponds to the position reported by gesture or
  /// tap callbacks on the page view widget.
  ///
  /// [pageIndex] is zero-based.
  Future<Offset> convertViewPointToPdfPoint(int pageIndex, Offset point);

  /// Converts a point from PDF page coordinates to the page view's
  /// coordinate space.
  ///
  /// The returned [Offset] is in logical pixel coordinates (device-
  /// independent pixels), relative to the top-left corner of the rendered
  /// page within the viewer. These are the same coordinates reported by
  /// gesture or tap callbacks on the page view widget.
  ///
  /// [pageIndex] is zero-based.
  Future<Offset> convertPdfPointToViewPoint(int pageIndex, Offset point);
}
