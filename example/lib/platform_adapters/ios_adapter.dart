// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

library;

import 'package:flutter/foundation.dart';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:nutrient_flutter_ios/src/ios_platform_adapter.dart';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:nutrient_flutter_ios/src/bindings/nutrient_ios_bindings.dart'
    hide Duration;

// ignore: depend_on_referenced_packages
import 'package:objective_c/objective_c.dart' as objc;

// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'example_adapter_controller.dart';

/// Example iOS adapter demonstrating the adapter-as-controller pattern.
///
/// Combines configuration, delegate-based event listening, toolbar customization,
/// and controller API access in a single class using FFI bindings.
class ExampleIOSAdapter extends IOSAdapter implements ExampleAdapterController {
  @override
  final StatusChangedCallback? onStatusChanged;

  @override
  final DocumentInfoCallback? onDocumentInfo;

  PSPDFViewController? _viewController;
  PSPDFDocument? _document;
  PSPDFViewControllerDelegate? _delegate;
  int _currentPageIndex = 0;

  ExampleIOSAdapter({
    this.onStatusChanged,
    this.onDocumentInfo,
  });

  void _log(String message) {
    debugPrint('[ExampleIOS] $message');
    onStatusChanged?.call(message);
  }

  // — Configuration

  @override
  void configureView(
    NutrientViewHandle handle,
    PSPDFConfigurationBuilder builder,
  ) {
    super.configureView(handle, builder);

    // Page display
    builder.pageMode = PSPDFPageMode.PSPDFPageModeSingle;
    builder.scrollDirection = PSPDFScrollDirection.PSPDFScrollDirectionVertical;
    builder.pageTransition =
        PSPDFPageTransition.PSPDFPageTransitionScrollContinuous;
    builder.spreadFitting =
        PSPDFConfigurationSpreadFitting.PSPDFConfigurationSpreadFittingFit;

    // UI features
    builder.thumbnailBarMode =
        PSPDFThumbnailBarMode.PSPDFThumbnailBarModeScrollable;
    builder.searchMode = PSPDFSearchMode.PSPDFSearchModeModal;
    builder.documentLabelEnabled =
        PSPDFAdaptiveConditional.PSPDFAdaptiveConditionalYES;
    builder.userInterfaceViewMode =
        PSPDFUserInterfaceViewMode.PSPDFUserInterfaceViewModeAutomatic;

    // User interactions
    builder.linkAction = PSPDFLinkAction.PSPDFLinkActionInlineBrowser;
    builder.allowToolbarTitleChange = true;
  }

  // — View controller lifecycle

  @override
  Future<void> onViewControllerReady(PSPDFViewController viewController) async {
    _viewController = viewController;

    _setupDelegate(viewController);
    _customizeMainToolbar(viewController);

    // Check for already-loaded document (delegate only fires on changes).
    final existingDocument = viewController.document;
    if (existingDocument != null) {
      _handleDocumentChanged(existingDocument);
    }
  }

  void _handleDocumentChanged(PSPDFDocument? document) {
    _document = document;
    if (document == null) return;

    final pageCount = document.pageCount;
    final title = document.title?.toDartString() ?? 'Untitled';
    _currentPageIndex = _viewController?.pageIndex ?? 0;

    onDocumentInfo?.call(
      pageCount: pageCount,
      currentPage: _currentPageIndex,
      title: title,
      isReady: true,
    );
    markReady();
    _log('Document loaded: $pageCount pages, title: $title');
  }

  // — Toolbar customization

  void _customizeMainToolbar(PSPDFViewController viewController) {
    final navigationItem = viewController.navigationItem;

    final rightItems = objc.NSMutableArray.array();
    rightItems.addObject(viewController.thumbnailsButtonItem);
    rightItems.addObject(viewController.searchButtonItem);
    rightItems.addObject(viewController.bookmarkButtonItem);
    rightItems.addObject(viewController.activityButtonItem);

    navigationItem.setRightBarButtonItems_forViewMode_animated(
      rightItems,
      viewMode: PSPDFViewMode.PSPDFViewModeDocument,
      animated: false,
    );
  }

  // — Delegate event listeners

  void _setupDelegate(PSPDFViewController viewController) {
    _delegate = PSPDFViewControllerDelegate$Builder.implementAsListener(
      pdfViewController_didChangeDocument:
          (PSPDFViewController controller, PSPDFDocument? document) {
        _handleDocumentChanged(document);
      },
      pdfViewController_didConfigurePageView_forPageAtIndex:
          (controller, pageView, pageIndex) {
        _currentPageIndex = pageIndex;
        onDocumentInfo?.call(currentPage: pageIndex);
        _log('[Event] Page changed to $pageIndex');
      },
      pdfViewController_didSelectAnnotations_onPageView: (
        PSPDFViewController controller,
        objc.NSArray annotations,
        PSPDFPageView pageView,
      ) {
        _log('[Event] Selected ${annotations.count} annotation(s)');
      },
      pdfViewController_didDeselectAnnotations_onPageView: (
        PSPDFViewController controller,
        objc.NSArray annotations,
        PSPDFPageView pageView,
      ) {
        _log('[Event] Deselected ${annotations.count} annotation(s)');
      },
      pdfViewController_didChangeViewMode:
          (PSPDFViewController controller, PSPDFViewMode viewMode) {
        _log('[Event] View mode changed: $viewMode');
      },
      pdfViewController_didSelectText_withGlyphs_atRect_onPageView: (
        PSPDFViewController controller,
        objc.NSString text,
        objc.NSArray glyphs,
        objc.CGRect rect,
        PSPDFPageView pageView,
      ) {
        final selectedText = text.toDartString();
        final truncated = selectedText.length > 50
            ? '${selectedText.substring(0, 50)}...'
            : selectedText;
        _log('[Event] Text selected: "$truncated"');
      },
      pdfViewController_didShowUserInterface:
          (PSPDFViewController controller, bool animated) {
        _log('[UI] User interface shown');
      },
      pdfViewController_didHideUserInterface:
          (PSPDFViewController controller, bool animated) {
        _log('[UI] User interface hidden');
      },
    );

    viewController.delegate = _delegate;
  }

  // — Controller implementation

  @override
  Future<int> getPageCount() async => _document?.pageCount ?? 0;

  @override
  Future<int> getCurrentPageIndex() async => _currentPageIndex;

  @override
  Future<void> setPageIndex(int pageIndex) async {
    _currentPageIndex = pageIndex;
    _viewController?.setPageIndex_animated(pageIndex, animated: true);
  }

  @override
  Future<String?> getDocumentTitle() async => _document?.title?.toDartString();

  // — Cleanup

  @override
  Future<void> onViewControllerDetached() async {
    _delegate = null;
    _viewController = null;
    _document = null;
  }
}
