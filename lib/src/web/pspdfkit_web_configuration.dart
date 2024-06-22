///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import '../../pspdfkit.dart';

/// This is the Configuration class for flutter web. It is used to group the configuration options for Flutter web.
class PdfWebConfiguration {
  /// The XFDF string to load into the document.
  final String? xfdf;

  /// Whether to keep the current annotations when loading XFDF.
  final bool? xfdfKeepCurrentAnnotations;

  /// The threshold for automatically closing the document.
  final num? autoCloseThreshold;

  /// The auto-save mode to use.
  final PspdfkitAutoSaveMode? autoSaveMode;

  /// The base URL for the PSPDFKit Core library.
  final String? baseCoreUrl;

  /// The base URL for the PSPDFKit server.
  final String? baseUrl;

  /// The ID of the container element for the viewer.
  final String? container;

  /// An array of custom fonts to load.
  final List<dynamic>? customFonts;

  /// Whether to disable forms.
  final bool? disableForms;

  /// Whether to disable high-quality printing.
  final bool? disableHighQualityPrinting;

  /// Whether to disable multi-selection.
  final bool? disableMultiSelection;

  /// Whether to disable open parameters.
  final bool? disableOpenParameters;

  /// Whether to disable text selection.
  final bool? disableTextSelection;

  /// Whether to disable WebAssembly streaming.
  final bool? disableWebAssemblyStreaming;

  /// An array of items to show in the document editor footer.
  final List<dynamic>? documentEditorFooterItems;

  /// An array of items to show in the document editor toolbar.
  final List<dynamic>? documentEditorToolbarItems;

  /// The ID of the document to load.
  final String? documentId;

  /// An array of editable annotation types.
  final List<dynamic>? editableAnnotationTypes;

  /// Whether to enable automatic link extraction.
  final bool? enableAutomaticLinkExtraction;

  /// Whether to enable clipboard actions.
  final bool? enableClipboardActions;

  /// Whether to enable history.
  final bool? enableHistory;

  /// Whether to enable service worker support.
  final bool? enableServiceWorkerSupport;

  /// An array of form fields that should not save signatures.
  final List<String>? formFieldsNotSavingSignatures;

  /// Whether to run in headless mode.
  final bool? headless;

  /// Whether to run in instant mode (server only).
  final bool? instant;

  /// The JSON configuration for instant mode (server only).
  final Map<String, dynamic>? instantJSON;

  /// The locale to use.
  final String? locale;

  /// The maximum default zoom level.
  final num? maxDefaultZoomLevel;

  /// The maximum number of mention suggestions to show.
  final num? maxMentionSuggestions;

  /// The maximum number of password retries.
  final num? maxPasswordRetries;

  /// An array of mentionable users.
  final List<dynamic>? mentionableUsers;

  /// The minimum default zoom level.
  final num? minDefaultZoomLevel;

  /// The memory limit to override.
  final num? overrideMemoryLimit;

  /// Whether to prevent text copy.
  final bool? preventTextCopy;

  /// The print options to use.
  final Map<String, dynamic>? printOptions;

  /// Whether to restrict annotations to page bounds.
  final bool? restrictAnnotationToPageBounds;

  /// The URL of the PSPDFKit server (server only).
  final String? serverUrl;

  final Map<String, dynamic>? authPayload;

  /// An array of stamp annotation templates.
  final List<dynamic>? stampAnnotationTemplates;

  /// The size of the standalone instances pool.
  final num? standaloneInstancesPoolSize;

  /// An array of style sheets to load.
  final List<String>? styleSheets;

  /// The theme to use.
  final String? theme;

  /// The toolbar placement to use.
  final PspdfKitToolbarPlacement? toolbarPlacement;

  /// Custom renderers to use.
  final dynamic customRenderers;

  /// Custom UI configuration to use.
  final dynamic customUIConfiguration;

  /// Electronic signatures configuration to use.
  final dynamic electronicSignatures;

  /// Whether to enable form design mode.
  final bool? formDesignMode;

  /// The interaction mode to use.
  final PspdfkitWebInteractionMode? interactionMode;

  /// The sidebar mode to use.
  final PspdfkitSidebarMode? sidebarMode;

  /// Whether to allow printing.
  final bool? allowPrinting;

  /// Whether to allow scrolling while drawing.
  final bool? canScrollWhileDrawing;

  /// Whether to keep the first spread as a single page.
  final bool? keepFirstSpreadAsSinglePage;

  /// Whether to keep the selected tool.
  final bool? keepSelectedTool;

  /// The spacing between pages.
  final double? pageSpacing;

  /// The rotation of the page.
  final num? pageRotation;

  /// Whether to preview redaction mode.
  final bool? previewRedactionMode;

  /// Whether to show annotation notes.
  final bool? showAnnotationNotes;

  /// Whether to show annotations.
  final bool? showAnnotations;

  /// The mode for showing signature validation status.
  final ShowSignatureValidationStatusMode? showSignatureValidationStatus;

  /// The sidebar mode to use.
  final PspdfkitSidebarMode? sideBarMode;

  /// The spacing between spreads.
  final num? spreadSpacing;

  /// The viewport padding to use.
  final num? viewportPadding;

  /// The zoom level to use.
  final dynamic zoom;

  /// The zoom step to use.
  final double? zoomStep;

  /// Main toolbar items. If not set, the default toolbar items will be used.
  final List<PspdfkitWebToolbarItem>? toolbarItems;

  /// Annotation toolbar items callback. If not set, the default annotation toolbar items will be used.
  final PspdfkitWebAnnotationToolbarItemsCallback? annotationToolbarItems;

  PdfWebConfiguration(
      {this.xfdf,
      this.xfdfKeepCurrentAnnotations,
      this.autoCloseThreshold,
      this.autoSaveMode,
      this.baseCoreUrl,
      this.baseUrl,
      this.container,
      this.customFonts,
      this.disableHighQualityPrinting,
      this.disableMultiSelection,
      this.disableOpenParameters,
      this.disableWebAssemblyStreaming,
      this.documentEditorFooterItems,
      this.documentEditorToolbarItems,
      this.enableAutomaticLinkExtraction,
      this.enableClipboardActions,
      this.enableHistory,
      this.enableServiceWorkerSupport,
      this.formFieldsNotSavingSignatures,
      this.headless,
      this.instantJSON,
      this.locale,
      this.maxDefaultZoomLevel,
      this.maxMentionSuggestions,
      this.maxPasswordRetries,
      this.mentionableUsers,
      this.minDefaultZoomLevel,
      this.overrideMemoryLimit,
      this.preventTextCopy,
      this.printOptions,
      this.restrictAnnotationToPageBounds,
      this.serverUrl,
      this.authPayload,
      this.stampAnnotationTemplates,
      this.standaloneInstancesPoolSize,
      this.styleSheets,
      this.theme,
      this.toolbarPlacement,
      this.sidebarMode,
      this.formDesignMode,
      this.interactionMode,
      this.allowPrinting,
      this.canScrollWhileDrawing,
      this.keepFirstSpreadAsSinglePage,
      this.keepSelectedTool,
      this.pageSpacing,
      this.pageRotation,
      this.previewRedactionMode,
      this.sideBarMode,
      this.showSignatureValidationStatus,
      this.showAnnotationNotes,
      this.showAnnotations,
      this.spreadSpacing,
      this.viewportPadding,
      this.zoom,
      this.zoomStep,
      this.customUIConfiguration,
      this.customRenderers,
      this.electronicSignatures,
      this.documentId,
      this.editableAnnotationTypes,
      this.instant,
      this.disableForms,
      this.disableTextSelection,
      this.toolbarItems,
      this.annotationToolbarItems});

  Map<String, dynamic> toMap() {
    return {
      'xfdf': xfdf,
      'xfdfKeepCurrentAnnotations': xfdfKeepCurrentAnnotations,
      'autoCloseThreshold': autoCloseThreshold,
      'baseCoreUrl': baseCoreUrl,
      'baseUrl': baseUrl,
      'container': container,
      'customFonts': customFonts,
      'disableHighQualityPrinting': disableHighQualityPrinting,
      'disableMultiSelection': disableMultiSelection,
      'disableOpenParameters': disableOpenParameters,
      'disableWebAssemblyStreaming': disableWebAssemblyStreaming,
      'documentEditorFooterItems': documentEditorFooterItems,
      'documentEditorToolbarItems': documentEditorToolbarItems,
      'enableAutomaticLinkExtraction': enableAutomaticLinkExtraction,
      'enableClipboardActions': enableClipboardActions,
      'enableHistory': enableHistory,
      'enableServiceWorkerSupport': enableServiceWorkerSupport,
      'formFieldsNotSavingSignatures': formFieldsNotSavingSignatures,
      'headless': headless,
      'instantJSON': instantJSON,
      'locale': locale,
      'maxDefaultZoomLevel': maxDefaultZoomLevel,
      'maxMentionSuggestions': maxMentionSuggestions,
      'maxPasswordRetries': maxPasswordRetries,
      'mentionableUsers': mentionableUsers,
      'minDefaultZoomLevel': minDefaultZoomLevel,
      'overrideMemoryLimit': overrideMemoryLimit,
      'preventTextCopy': preventTextCopy,
      'printOptions': printOptions,
      'restrictAnnotationToPageBounds': restrictAnnotationToPageBounds,
      'serverUrl': serverUrl,
      'stampAnnotationTemplates': stampAnnotationTemplates,
      'standaloneInstancesPoolSize': standaloneInstancesPoolSize,
      'styleSheets': styleSheets,
      'toolbarPlacement': toolbarPlacement?.webName,
      'formDesignMode': formDesignMode,
      'interactionMode': interactionMode?.webName,
      'allowPrinting': allowPrinting,
      'canScrollWhileDrawing': canScrollWhileDrawing,
      'keepFirstSpreadAsSinglePage': keepFirstSpreadAsSinglePage,
      'keepSelectedTool': keepSelectedTool,
      'pageSpacing': pageSpacing,
      'pageRotation': pageRotation,
      'previewRedactionMode': previewRedactionMode,
      'showSignatureValidationStatus': showSignatureValidationStatus?.webName,
      'showAnnotationNotes': showAnnotationNotes,
      'showAnnotations': showAnnotations,
      'spreadSpacing': spreadSpacing,
      'customUIConfiguration': customUIConfiguration,
      'customRenderers': customRenderers,
      'electronicSignatures': electronicSignatures,
      'documentId': documentId,
      'editableAnnotationTypes': editableAnnotationTypes,
      'instant': instant,
      'disableForms': disableForms,
      'disableTextSelection': disableTextSelection,
      'toolbarItems': toolbarItems,
      'annotationToolbarItems': annotationToolbarItems,
      'authPayload': authPayload
    }..removeWhere((key, value) => value == null);
  }
}
