// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

library;

import 'dart:async';

import 'package:nutrient_flutter/bindings.dart';
import 'package:nutrient_flutter_ios/nutrient_flutter_ios.dart';
import 'package:objective_c/objective_c.dart' as objc;

import 'catalog_adapter_controller.dart';

/// iOS adapter for the Nutrient Flutter catalog app.
///
/// Document operations are accessed via `controller.document` after
/// `NutrientDocumentView.onControllerReady` fires. Document, page, and
/// annotation lifecycle events flow through `controller.events`; iOS-only
/// events (view-mode changes, user-interface show/hide, view-controller
/// dismissal) flow through `iosEvents` on this adapter.
///
/// This adapter's only catalog-specific responsibilities are:
///
/// - `goToPage` reach-through to `PSPDFViewController.setPageIndex_animated`
///   until `NutrientControllerInterface` exposes a public navigation API.
/// - Surfacing the current document info to a page-attached listener on
///   demand (the iOS base adapter doesn't emit page-count + title as a
///   single snapshot).
///
/// Pages opt in to receiving document-info snapshots and any future
/// native-only log entries by registering listeners via [attachListeners]
/// in `initState`; they must call [detachListeners] in `dispose`.
class CatalogIOSAdapter extends IOSAdapter
    implements CatalogAdapterController {
  AdapterLogListener? _logListener;
  AdapterDocumentInfoListener? _infoListener;

  PSPDFViewController? _viewController;
  PSPDFDocument? _document;
  StreamSubscription<NutrientEvent>? _typedEventSub;
  StreamSubscription<IOSNutrientEvent>? _iosEventSub;

  @override
  void attachListeners({
    AdapterLogListener? onLog,
    AdapterDocumentInfoListener? onDocumentInfoChanged,
  }) {
    _logListener = onLog;
    _infoListener = onDocumentInfoChanged;

    // Surface current document info immediately when a listener attaches.
    final document = _document;
    if (document != null) {
      _emitDocumentInfo(document);
    }
  }

  @override
  void detachListeners() {
    _logListener = null;
    _infoListener = null;
  }

  void _emitDocumentInfo(PSPDFDocument document) {
    final pageCount = document.pageCount;
    final title = document.title?.toDartString() ?? 'Untitled';
    final currentPage = _viewController?.pageIndex ?? 0;
    _infoListener?.call(
      AdapterDocumentInfo(
        pageCount: pageCount,
        currentPage: currentPage,
        title: title,
        isReady: true,
      ),
    );
  }

  @override
  Future<void> onViewControllerReady(PSPDFViewController viewController) async {
    _viewController = viewController;

    // If a document is already loaded, snapshot it immediately. Otherwise
    // wait for the SDK delegate to flip it on through `events`.
    final document = viewController.document;
    if (document != null) {
      _document = document;
      _emitDocumentInfo(document);
    }

    // Mirror PageChangedEvent into the document-info snapshot so pages that
    // only care about "current page" don't need to keep their own event
    // subscription. Cancel any subscription from a previous view-controller
    // lifecycle before re-subscribing — the catalog adapter is a
    // long-lived singleton, so without this each screen visit would add a
    // duplicate listener.
    _typedEventSub?.cancel();
    _typedEventSub = events.listen((event) {
      switch (event) {
        case DocumentLoadedEvent():
          final doc = _viewController?.document;
          if (doc != null) {
            _document = doc;
            _emitDocumentInfo(doc);
          }
        case PageChangedEvent(:final pageIndex):
          _infoListener?.call(AdapterDocumentInfo(currentPage: pageIndex));
        default:
          break;
      }
    });

    // Route iOS-only events through the log listener so the page can show
    // a single combined log without having to subscribe to both streams.
    _iosEventSub?.cancel();
    _iosEventSub = iosEvents.listen((event) {
      final message = _describeIOSEvent(event);
      if (message != null) {
        _logListener?.call(AdapterLogEntry(AdapterLogKind.ui, message));
      }
    });
  }

  String? _describeIOSEvent(IOSNutrientEvent event) => switch (event) {
        IOSViewModeChangedEvent(:final viewMode) =>
          'View mode changed: $viewMode',
        IOSUserInterfaceShownEvent() => 'User interface shown',
        IOSUserInterfaceHiddenEvent() => 'User interface hidden',
        IOSViewControllerWillDismissEvent() => 'View controller will dismiss',
        IOSViewControllerDidDismissEvent() => 'View controller did dismiss',
        _ => null,
      };

  // — CatalogAdapterController API

  @override
  Future<int> getPageCount() async => _document?.pageCount ?? 0;

  @override
  Future<int> getCurrentPageIndex() async => _viewController?.pageIndex ?? 0;

  @override
  Future<void> goToPage(int pageIndex) async {
    _viewController?.setPageIndex_animated(pageIndex, animated: true);
  }

  @override
  Future<String?> getDocumentTitle() async =>
      _document?.title?.toDartString();

  @override
  Future<void> onViewControllerDetached() async {
    await _typedEventSub?.cancel();
    _typedEventSub = null;
    await _iosEventSub?.cancel();
    _iosEventSub = null;
    _viewController = null;
    _document = null;
  }
}
