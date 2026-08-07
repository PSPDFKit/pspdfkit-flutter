// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

library;

import 'dart:async';

import 'package:nutrient_flutter/bindings.dart';
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart';
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart' as nutrient_web;

import 'catalog_adapter_controller.dart';

/// Web adapter for the Nutrient Flutter catalog app.
///
/// Document operations are accessed via `controller.document` after
/// `NutrientDocumentView.onControllerReady` fires; document, page, and
/// annotation lifecycle events flow through `controller.events`. Raw Web
/// SDK events (`viewState.zoom.change`, form events, etc.) are available
/// on `webEvents`.
///
/// This adapter wires the few Web-only hooks the catalog wants to surface
/// in a single log:
///
/// - Zoom changes (Web SDK fires these only on `webEvents`).
/// - `goToPage` reach-through to the Web SDK `Instance.setViewState` until
///   `NutrientControllerInterface` exposes a public navigation API.
///
/// Pages opt in to receiving the extras by registering listeners via
/// [attachListeners] in `initState`; they must call [detachListeners] in
/// `dispose` so subsequent screens get a clean slate.
class CatalogWebAdapter extends NutrientWebAdapter
    implements CatalogAdapterController {
  AdapterLogListener? _logListener;
  AdapterDocumentInfoListener? _infoListener;
  StreamSubscription<NutrientEvent>? _typedEventSub;
  StreamSubscription<NutrientWebEventData>? _webEventSub;

  @override
  void attachListeners({
    AdapterLogListener? onLog,
    AdapterDocumentInfoListener? onDocumentInfoChanged,
  }) {
    _logListener = onLog;
    _infoListener = onDocumentInfoChanged;

    // Surface current document info immediately when a listener attaches.
    final inst = instance;
    if (inst != null) {
      _emitDocumentInfo(inst);
    }
  }

  @override
  void detachListeners() {
    _logListener = null;
    _infoListener = null;
  }

  void _emitDocumentInfo(nutrient_web.Instance inst) {
    _infoListener?.call(
      AdapterDocumentInfo(
        pageCount: inst.totalPageCount.toInt(),
        currentPage: currentPageIndex ?? 0,
        title: 'Web Document',
        isReady: true,
      ),
    );
  }

  @override
  Future<void> onInstanceLoaded(nutrient_web.Instance instance) async {
    await super.onInstanceLoaded(instance);

    _emitDocumentInfo(instance);

    // Listen to cross-platform events that the base adapter already emits
    // (PageChangedEvent for page index) to keep the document-info snapshot
    // fresh. Cancel any subscription from a previous instance load before
    // re-subscribing — the catalog adapter is a long-lived singleton, so
    // without this each `onInstanceLoaded` would add a duplicate listener.
    _typedEventSub?.cancel();
    _typedEventSub = events.listen((event) {
      switch (event) {
        case PageChangedEvent(:final pageIndex):
          _infoListener?.call(AdapterDocumentInfo(currentPage: pageIndex));
        default:
          break;
      }
    });

    // Route Web-only events that aren't on the cross-platform stream
    // (notably zoom changes) into the log listener so the page sees a
    // single combined log.
    _webEventSub?.cancel();
    _webEventSub = webEvents.listen((event) {
      final message = _describeWebEvent(instance, event);
      if (message != null) {
        _logListener?.call(AdapterLogEntry(AdapterLogKind.ui, message));
      }
    });
  }

  String? _describeWebEvent(nutrient_web.Instance inst, NutrientWebEventData e) {
    switch (e.type) {
      case 'viewState.zoom.change':
        final zoom = inst.currentZoomLevel.toStringAsFixed(2);
        return 'Zoom: ${zoom}x';
      case 'history.undo':
        return 'Undo';
      case 'history.redo':
        return 'Redo';
      default:
        return null;
    }
  }

  // — CatalogAdapterController API

  @override
  Future<int> getPageCount() async => instance?.totalPageCount.toInt() ?? 0;

  @override
  Future<int> getCurrentPageIndex() async => currentPageIndex ?? 0;

  @override
  Future<void> goToPage(int pageIndex) async => setCurrentPageIndex(pageIndex);

  @override
  Future<String?> getDocumentTitle() async => 'Web Document';

  @override
  Future<void> dispose() async {
    await _typedEventSub?.cancel();
    _typedEventSub = null;
    await _webEventSub?.cancel();
    _webEventSub = null;
    await super.dispose();
  }
}
