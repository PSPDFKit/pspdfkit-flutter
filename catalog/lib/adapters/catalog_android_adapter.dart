// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

library;

import 'package:jni/jni.dart';
import 'package:nutrient_flutter_android/nutrient_flutter_android.dart';

import 'catalog_adapter_controller.dart';

/// Android adapter for the Nutrient Flutter catalog app.
///
/// Document operations are accessed via `controller.document` after
/// `NutrientDocumentView.onControllerReady` fires; document/page/annotation
/// lifecycle events flow through `controller.events`.
///
/// This adapter wires the few Android-specific hooks that don't yet have a
/// cross-platform event:
///
/// - Document tap — only the page-level `onPageClick` is on the typed stream
/// - `goToPage` reach-through to `PdfFragment` until
///   `NutrientControllerInterface` exposes a public navigation API.
///
/// Pages opt in to receiving the extras by registering listeners via
/// [attachListeners] in `initState`; they must call [detachListeners] in
/// `dispose` so subsequent screens get a clean slate.
class CatalogAndroidAdapter extends AndroidAdapter
    implements CatalogAdapterController {
  AdapterLogListener? _logListener;
  AdapterDocumentInfoListener? _infoListener;

  DocumentListener? _supplementalDocListener;

  @override
  void attachListeners({
    AdapterLogListener? onLog,
    AdapterDocumentInfoListener? onDocumentInfoChanged,
  }) {
    _logListener = onLog;
    _infoListener = onDocumentInfoChanged;

    // Surface current document info immediately so the page doesn't have
    // to wait for the next lifecycle tick.
    final document = nativePdfDocument;
    if (document != null) {
      _emitDocumentInfo(document);
    }
  }

  @override
  void detachListeners() {
    _logListener = null;
    _infoListener = null;
  }

  void _emitLog(AdapterLogKind kind, String message) =>
      _logListener?.call(AdapterLogEntry(kind, message));

  void _emitDocumentInfo(PdfDocument document) {
    final pageCount = document.getPageCount();
    final title = document.getTitle()?.toDartString(releaseOriginal: true);
    final currentPage = nativePdfFragment?.getPageIndex() ?? 0;
    _infoListener?.call(
      AdapterDocumentInfo(
        pageCount: pageCount,
        currentPage: currentPage,
        title: title ?? 'Untitled',
        isReady: true,
      ),
    );
  }

  @override
  Future<void> onFragmentReady(PdfFragment pdfFragment) async {
    await super.onFragmentReady(pdfFragment);

    // Push initial document info to whatever listener is currently attached.
    final document = pdfFragment.document;
    if (document != null) {
      _emitDocumentInfo(document);
    }

    _installSupplementalDocumentListener(pdfFragment);
  }

  /// Wires the supplementary `DocumentListener` callbacks that the base
  /// `AndroidAdapter` does not surface on the typed event stream — currently
  /// `onDocumentClick` and follow-up `onPageChanged` notifications used to
  /// keep the document-info snapshot fresh.
  void _installSupplementalDocumentListener(PdfFragment pdfFragment) {
    _supplementalDocListener = DocumentListener.implement(
      $DocumentListener(
        onDocumentClick: () {
          _emitLog(AdapterLogKind.ui, 'Document clicked');
          return false; // don't consume
        },
        onPageChanged: (_, pageIndex) {
          _infoListener?.call(AdapterDocumentInfo(currentPage: pageIndex));
        },
        // The base `AndroidAdapter` emits `DocumentLoadedEvent` on the typed
        // event stream, but it doesn't push a document-info snapshot
        // (page count + title) the way the catalog page wants. Hook
        // `onDocumentLoaded` to refresh the snapshot when the SDK reports
        // the document is ready — the page count is null on `onFragmentReady`
        // because the document hasn't finished loading yet.
        onDocumentLoaded: (document) {
          _emitDocumentInfo(document);
        },
        onDocumentLoadFailed: (_) {},
        onDocumentSave: (_, __) => true,
        onDocumentSaved: (_) {},
        onDocumentSaveFailed: (_, __) {},
        onDocumentSaveCancelled: (_) {},
        onPageClick: (_, __, ___, ____, _____) => false,
        onDocumentZoomed: (_, __, ___) {},
        onPageUpdated: (_, __) {},
      ),
    );
    pdfFragment.addDocumentListener(_supplementalDocListener!);
  }

  // — CatalogAdapterController API

  @override
  Future<int> getPageCount() async => nativePdfDocument?.getPageCount() ?? 0;

  @override
  Future<int> getCurrentPageIndex() async =>
      nativePdfFragment?.getPageIndex() ?? 0;

  @override
  Future<void> goToPage(int pageIndex) async {
    // `setPageIndex$1` is the two-arg (index, animated) JNI overload.
    nativePdfFragment?.setPageIndex$1(pageIndex, true);
  }

  @override
  Future<String?> getDocumentTitle() async =>
      nativePdfDocument?.getTitle()?.toDartString(releaseOriginal: true);

  @override
  Future<void> onFragmentDetached() async {
    final fragment = nativePdfFragment;
    if (_supplementalDocListener != null && fragment != null) {
      fragment.removeDocumentListener(_supplementalDocListener!);
    }
    _supplementalDocListener = null;
    await super.onFragmentDetached();
  }
}
