// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

library;

import 'package:nutrient_flutter/bindings.dart';

/// A single log line emitted by a catalog adapter when a native-only event
/// (not exposed on `controller.events`) fires.
class AdapterLogEntry {
  /// Where the entry originated. Used by the example page to color-code rows.
  final AdapterLogKind kind;

  /// Human-readable message.
  final String message;

  const AdapterLogEntry(this.kind, this.message);
}

/// Category of an [AdapterLogEntry].
enum AdapterLogKind {
  /// A native UI event (toolbar lifecycle, view-mode change, etc.).
  ui,

  /// A native low-level event (e.g. document-level tap that isn't promoted
  /// to a typed `PageClickedEvent`).
  event,
}

/// Listener for native-only log entries emitted by a catalog adapter.
typedef AdapterLogListener = void Function(AdapterLogEntry entry);

/// Snapshot of the currently-loaded document, surfaced opportunistically by
/// the adapter when the platform reports a lifecycle change.
class AdapterDocumentInfo {
  final int? pageCount;
  final int? currentPage;
  final String? title;
  final bool? isReady;

  const AdapterDocumentInfo({
    this.pageCount,
    this.currentPage,
    this.title,
    this.isReady,
  });
}

/// Listener for adapter-driven document-info updates.
typedef AdapterDocumentInfoListener = void Function(AdapterDocumentInfo info);

/// Page-side contract that the catalog's per-platform adapters implement.
///
/// Catalog example pages construct their *own* adapter via
/// `createCatalogAdapter()` in `initState`, hand it to
/// [NutrientDocumentView.adapter], and dispose it in `dispose`. The
/// adapter is therefore scoped to a single screen — no listener-attach
/// dance is strictly necessary to keep state from leaking between pages,
/// but [attachListeners] / [detachListeners] are kept so screens can wire
/// their `setState` callbacks cleanly at any point in the lifecycle (e.g.
/// after the page has subscribed to widget-level state).
///
/// Extends [NutrientController] so it satisfies the
/// `NutrientDocumentView<T extends NutrientController>` bound — the
/// adapter *is* the controller, gaining `events`, `markReady`, `dispose`,
/// etc. from the base class.
///
/// ```dart
/// final adapter = createCatalogAdapter();
/// adapter?.attachListeners(
///   onLog: _appendLog,
///   onDocumentInfoChanged: _updateInfo,
/// );
/// // …
/// NutrientDocumentView<CatalogAdapterController>(
///   documentPath: ...,
///   adapter: adapter,
///   onControllerReady: (c) { ... c.events.listen(...) ... },
/// )
/// ```
abstract class CatalogAdapterController implements NutrientController {
  /// Attach the page's listeners. Pass `null` for either to leave it unset.
  void attachListeners({
    AdapterLogListener? onLog,
    AdapterDocumentInfoListener? onDocumentInfoChanged,
  });

  /// Detach any listeners previously attached via [attachListeners].
  ///
  /// Pages must call this in `dispose` to avoid keeping a reference to a
  /// disposed `State` alive on the adapter.
  void detachListeners();

  /// Total page count of the currently loaded document, or `0` if no
  /// document is loaded yet.
  Future<int> getPageCount();

  /// Zero-based current page index of the currently loaded document.
  Future<int> getCurrentPageIndex();

  /// Navigate the underlying viewer to [pageIndex] (zero-based).
  ///
  /// The adapter reaches through to the native fragment / view controller /
  /// web SDK instance directly — this is the catalog's workaround until
  /// `NutrientControllerInterface` gets a public `goToPage`.
  Future<void> goToPage(int pageIndex);

  /// Document title from native metadata, or `null` if unavailable.
  Future<String?> getDocumentTitle();
}
