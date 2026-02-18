///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

library;

import 'dart:js_interop';

import 'package:flutter/foundation.dart';

// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart';

// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'example_adapter_controller.dart';

/// Example Web adapter demonstrating the adapter-as-controller pattern.
///
/// Combines load configuration, JS event listeners, toolbar customization,
/// and controller API access in a single class using JS interop.
class ExampleWebAdapter extends NutrientWebAdapter
    implements ExampleAdapterController {
  @override
  final StatusChangedCallback? onStatusChanged;

  @override
  final DocumentInfoCallback? onDocumentInfo;

  int _currentPageIndex = 0;

  // JS event listener references for cleanup.
  JSFunction? _pageChangeListener;
  JSFunction? _zoomChangeListener;
  JSFunction? _annotationCreateListener;
  JSFunction? _annotationUpdateListener;
  JSFunction? _annotationDeleteListener;

  ExampleWebAdapter({
    this.onStatusChanged,
    this.onDocumentInfo,
  });

  void _log(String message) {
    debugPrint('[ExampleWeb] $message');
    onStatusChanged?.call(message);
  }

  // — Configuration

  @override
  Future<void> configureLoad(
    NutrientViewHandle handle,
    Map<String, dynamic> config,
  ) async {
    await super.configureLoad(handle, config);

    // Layout & display
    config['layoutMode'] = 'SINGLE';
    config['scrollMode'] = 'CONTINUOUS';
    config['spreadFitting'] = 'FIT_TO_VIEWPORT';
    config['initialPageIndex'] = 0;
    config['initialZoomLevel'] = null;

    // Theme
    config['theme'] = 'AUTO';
    config['toolbarPlacement'] = 'TOP';

    // Toolbar items
    config['toolbarItems'] = [
      {'type': 'sidebar-thumbnails'},
      {'type': 'sidebar-document-outline'},
      {'type': 'sidebar-annotations'},
      {'type': 'sidebar-bookmarks'},
      {'type': 'spacer'},
      {'type': 'pager'},
      {'type': 'zoom-out'},
      {'type': 'zoom-in'},
      {'type': 'zoom-mode'},
      {'type': 'spacer'},
      {'type': 'highlighter'},
      {'type': 'text-highlighter'},
      {'type': 'ink'},
      {'type': 'ink-eraser'},
      {'type': 'signature'},
      {'type': 'note'},
      {'type': 'text'},
      {'type': 'line'},
      {'type': 'arrow'},
      {'type': 'rectangle'},
      {'type': 'ellipse'},
      {'type': 'spacer'},
      {'type': 'print'},
      {'type': 'search'},
      {'type': 'export-pdf'},
    ];

    // Features
    config['enableAnnotationToolbar'] = true;
    config['enableHistory'] = true;
    config['enableClipboardActions'] = true;
    config['enableTextSelection'] = true;
    config['enableFormDesignMode'] = false;
    config['enablePrinting'] = true;
    config['enableDownload'] = true;
    config['autoSaveMode'] = 'INTELLIGENT';
  }

  // — Instance lifecycle

  @override
  Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
    await super.onInstanceLoaded(instance);

    final pageCount = instance.totalPageCount ?? instance.pageCount ?? 0;
    _currentPageIndex = instance.viewState.currentPageIndex;

    onDocumentInfo?.call(
      pageCount: pageCount,
      currentPage: _currentPageIndex,
      title: 'Web Document',
      isReady: true,
    );
    markReady();
    _log('Document loaded: $pageCount pages');

    _setupEventListeners(instance);
  }

  // — Event listeners

  void _setupEventListeners(NutrientWebInstance instance) {
    _pageChangeListener = ((JSAny event) {
      _currentPageIndex = instance.viewState.currentPageIndex;
      onDocumentInfo?.call(currentPage: _currentPageIndex);
      _log('[Event] Page changed to: $_currentPageIndex');
    }).toJS;
    instance.addEventListener(
        'viewState.currentPageIndex.change', _pageChangeListener!);

    _zoomChangeListener = ((JSAny event) {
      final zoomLevel = instance.currentZoomLevel;
      _log('[Event] Zoom level changed to: ${zoomLevel.toStringAsFixed(2)}x');
    }).toJS;
    instance.addEventListener('viewState.zoom.change', _zoomChangeListener!);

    _annotationCreateListener = ((JSAny event) {
      _log('[Event] Annotation created');
    }).toJS;
    instance.addEventListener('annotations.create', _annotationCreateListener!);

    _annotationUpdateListener = ((JSAny event) {
      _log('[Event] Annotation updated');
    }).toJS;
    instance.addEventListener('annotations.update', _annotationUpdateListener!);

    _annotationDeleteListener = ((JSAny event) {
      _log('[Event] Annotation deleted');
    }).toJS;
    instance.addEventListener('annotations.delete', _annotationDeleteListener!);
  }

  // — Controller implementation

  @override
  Future<int> getPageCount() async =>
      instance?.totalPageCount ?? instance?.pageCount ?? 0;

  @override
  Future<int> getCurrentPageIndex() async => _currentPageIndex;

  @override
  Future<void> setPageIndex(int pageIndex) async {
    _currentPageIndex = pageIndex;
    final inst = instance;
    if (inst != null) {
      final currentViewState = inst.viewState;
      final updates = {'currentPageIndex': pageIndex}.jsify()!;
      final newViewState = currentViewState.merge(updates);
      inst.setViewState(newViewState as JSAny);
    }
  }

  @override
  Future<String?> getDocumentTitle() async => 'Web Document';

  // — Cleanup

  @override
  Future<void> dispose() async {
    final inst = instance;
    if (inst != null) {
      if (_pageChangeListener != null) {
        inst.removeEventListener(
            'viewState.currentPageIndex.change', _pageChangeListener!);
      }
      if (_zoomChangeListener != null) {
        inst.removeEventListener('viewState.zoom.change', _zoomChangeListener!);
      }
      if (_annotationCreateListener != null) {
        inst.removeEventListener(
            'annotations.create', _annotationCreateListener!);
      }
      if (_annotationUpdateListener != null) {
        inst.removeEventListener(
            'annotations.update', _annotationUpdateListener!);
      }
      if (_annotationDeleteListener != null) {
        inst.removeEventListener(
            'annotations.delete', _annotationDeleteListener!);
      }
    }

    _pageChangeListener = null;
    _zoomChangeListener = null;
    _annotationCreateListener = null;
    _annotationUpdateListener = null;
    _annotationDeleteListener = null;

    await super.dispose();
  }
}
