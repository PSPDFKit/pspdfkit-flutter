///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

library;

import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:jni/jni.dart' as jni;

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:nutrient_flutter_android/src/android_platform_adapter.dart';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:nutrient_flutter_android/src/bindings/nutrient_android_sdk_bindings.dart';

// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'example_adapter_controller.dart';

/// Example Android adapter demonstrating the adapter-as-controller pattern.
///
/// Combines configuration, document/annotation event listening, toolbar
/// customization, and controller API access in a single class using JNI bindings.
class ExampleAndroidAdapter extends AndroidAdapter
    implements ExampleAdapterController {
  @override
  final StatusChangedCallback? onStatusChanged;

  @override
  final DocumentInfoCallback? onDocumentInfo;

  PdfFragment? _pdfFragment;
  PdfUiFragment? _pdfUiFragment;
  PdfDocument? _document;
  int _currentPageIndex = 0;

  DocumentListener? _documentListener;
  AnnotationProvider$OnAnnotationUpdatedListener? _annotationListener;
  ToolbarCoordinatorLayout$OnContextualToolbarLifecycleListener?
      _toolbarLifecycleListener;

  ExampleAndroidAdapter({
    this.onStatusChanged,
    this.onDocumentInfo,
  });

  void _log(String message) {
    debugPrint('[ExampleAndroid] $message');
    onStatusChanged?.call(message);
  }

  // — Configuration

  @override
  Future<void> configureFragment(
    NutrientViewHandle handle,
    PdfUiFragmentBuilder builder,
    Context context,
  ) async {
    await super.configureFragment(handle, builder, context);

    PdfActivityConfiguration configuration =
        PdfActivityConfiguration$Builder(context)
            // Layout & display
            .layoutMode(PageLayoutMode.SINGLE)
            .scrollDirection(PageScrollDirection.VERTICAL)
            .fitMode(PageFitMode.FIT_TO_WIDTH)
            .firstPageAlwaysSingle(true)
            .showGapBetweenPages(true)
            .restoreLastViewedPage(true)
            // UI features
            .setThumbnailBarMode(
              ThumbnailBarMode.THUMBNAIL_BAR_MODE_SCROLLABLE,
            )
            .searchEnabled(true)
            .outlineEnabled(true)
            .allowMultipleBookmarksPerPage(true)
            .pageNumberOverlayEnabled(true)
            .pageLabelsEnabled(true)
            .documentTitleOverlayEnabled(true)
            .scrollbarsEnabled(true)
            .immersiveModeEnabled(false)
            // Annotations
            .annotationEditingEnabled(true)
            .annotationListEnabled(true)
            // Text & forms
            .textSelectionEnabled(true)
            .copyPastEnabled(true)
            // Document operations
            .printingEnabled(true)
            .undoEnabled(true)
            .redoEnabled(true)
            .autosaveEnabled(true)
            .build();

    builder.configuration(configuration);
  }

  // — Fragment lifecycle

  @override
  Future<void> onFragmentAttached(
    PdfUiFragment fragment,
    Context context,
  ) async {
    _pdfUiFragment = fragment;
  }

  @override
  Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
    _pdfFragment = pdfFragment;

    final document = pdfFragment.getDocument();
    if (document != null) {
      _handleDocumentLoaded(document);
    }

    _setupDocumentListener(pdfFragment);
    _setupAnnotationListener(pdfFragment);
    _setupContextualToolbarListener();
  }

  void _handleDocumentLoaded(PdfDocument document) {
    _document = document;
    final pageCount = document.getPageCount();
    final title = document.getTitle()?.toDartString(releaseOriginal: true);
    _currentPageIndex = _pdfFragment?.getPageIndex() ?? 0;

    onDocumentInfo?.call(
      pageCount: pageCount,
      currentPage: _currentPageIndex,
      title: title ?? 'Untitled',
      isReady: true,
    );
    markReady();
    _log('Document loaded: $pageCount pages, title: $title');
  }

  // — Document event listener

  void _setupDocumentListener(PdfFragment pdfFragment) {
    _documentListener = DocumentListener.implement(
      $DocumentListener(
        onDocumentLoaded: (document) {
          _handleDocumentLoaded(document);
        },
        onDocumentLoadFailed: (exception) {
          _log('[Event] Document load failed');
        },
        onDocumentSave: (document, options) => true,
        onDocumentSaved: (document) {
          _log('[Event] Document saved');
        },
        onDocumentSaveFailed: (document, exception) {
          _log('[Event] Document save failed');
        },
        onDocumentSaveCancelled: (document) {
          _log('[Event] Document save cancelled');
        },
        onPageClick: (document, pageIndex, motionEvent, pointF, annotation) {
          _log('[Event] Page $pageIndex clicked');
          return false;
        },
        onDocumentClick: () {
          _log('[Event] Document clicked');
          return false;
        },
        onPageChanged: (document, pageIndex) {
          _currentPageIndex = pageIndex;
          onDocumentInfo?.call(currentPage: pageIndex);
          _log('[Event] Page changed to $pageIndex');
        },
        onDocumentZoomed: (document, pageIndex, zoom) {
          _log('[Event] Zoomed to ${zoom.toStringAsFixed(2)}x');
        },
        onPageUpdated: (document, pageIndex) {
          _log('[Event] Page $pageIndex updated');
        },
      ),
    );

    pdfFragment.addDocumentListener(_documentListener!);
  }

  // — Annotation event listener

  void _setupAnnotationListener(PdfFragment pdfFragment) {
    _annotationListener =
        AnnotationProvider$OnAnnotationUpdatedListener.implement(
      $AnnotationProvider$OnAnnotationUpdatedListener(
        onAnnotationCreated: (Annotation annotation) {
          _log('[Event] Annotation created: ${annotation.getType()}');
        },
        onAnnotationUpdated: (Annotation annotation) {
          _log('[Event] Annotation updated: ${annotation.getType()}');
        },
        onAnnotationRemoved: (Annotation annotation) {
          _log('[Event] Annotation removed: ${annotation.getType()}');
        },
        onAnnotationZOrderChanged: (
          int pageIndex,
          jni.JList<Annotation> annotationsAbove,
          jni.JList<Annotation> annotationsBelow,
        ) {
          _log('[Event] Z-order changed on page $pageIndex');
        },
      ),
    );

    pdfFragment.addOnAnnotationUpdatedListener(_annotationListener!);
  }

  // — Contextual toolbar listener

  void _setupContextualToolbarListener() {
    if (_pdfUiFragment == null) return;

    _toolbarLifecycleListener =
        ToolbarCoordinatorLayout$OnContextualToolbarLifecycleListener.implement(
      $ToolbarCoordinatorLayout$OnContextualToolbarLifecycleListener(
        onPrepareContextualToolbar: (ContextualToolbar<jni.JObject?> toolbar) {
          final itemCount = toolbar.getMenuItems().length;
          _log('[UI] Contextual toolbar preparing: $itemCount items');
        },
        onDisplayContextualToolbar: (ContextualToolbar<jni.JObject?> toolbar) {
          _log('[UI] Contextual toolbar displayed');
        },
        onRemoveContextualToolbar: (ContextualToolbar<jni.JObject?> toolbar) {
          _log('[UI] Contextual toolbar removed');
        },
      ),
    );

    _pdfUiFragment!.setOnContextualToolbarLifecycleListener(
      _toolbarLifecycleListener,
    );
  }

  // — Controller implementation

  @override
  Future<int> getPageCount() async => _document?.getPageCount() ?? 0;

  @override
  Future<int> getCurrentPageIndex() async => _currentPageIndex;

  @override
  Future<void> setPageIndex(int pageIndex) async {
    _currentPageIndex = pageIndex;
    _pdfFragment?.setPageIndex$1(pageIndex, true);
  }

  @override
  Future<String?> getDocumentTitle() async =>
      _document?.getTitle()?.toDartString(releaseOriginal: true);

  // — Cleanup

  @override
  Future<void> onFragmentDetached() async {
    if (_documentListener != null && _pdfFragment != null) {
      _pdfFragment!.removeDocumentListener(_documentListener!);
    }
    if (_annotationListener != null && _pdfFragment != null) {
      _pdfFragment!.removeOnAnnotationUpdatedListener(_annotationListener!);
    }
    if (_pdfUiFragment != null) {
      _pdfUiFragment!.setOnContextualToolbarLifecycleListener(null);
    }

    _documentListener = null;
    _annotationListener = null;
    _toolbarLifecycleListener = null;
    _pdfFragment = null;
    _pdfUiFragment = null;
    _document = null;
  }
}
