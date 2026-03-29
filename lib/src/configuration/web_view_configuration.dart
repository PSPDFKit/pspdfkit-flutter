///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import '../types.dart';
import '../web/models/models.dart';
import '../web/office_conversion_settings.dart';

/// Web-specific viewer configuration options.
///
/// Passed as [NutrientViewConfiguration.webConfig]. All fields are optional;
/// unset fields use the PSPDFKit Web SDK's built-in defaults.
///
/// Properties map directly to keys in the `PSPDFKit.load()` configuration
/// object or to the `initialViewState` sub-object as noted in each field's
/// documentation.
class WebViewConfiguration {
  // ---------------------------------------------------------------------------
  // initialViewState properties
  // ---------------------------------------------------------------------------

  /// Show or hide the main toolbar. Corresponds to `initialViewState.showToolbar`.
  ///
  /// Prefer setting [NutrientViewConfiguration.userInterfaceViewMode] for
  /// cross-platform toolbar visibility; this field is the web-specific override.
  final bool? showToolbar;

  /// Show or hide all annotations. Corresponds to `initialViewState.showAnnotations`.
  final bool? showAnnotations;

  /// Show annotation note indicators. Corresponds to `initialViewState.showAnnotationNotes`.
  final bool? showAnnotationNotes;

  /// Show Instant collaboration comments. Corresponds to `initialViewState.showComments`.
  final bool? showComments;

  /// Put the viewer into read-only mode (no annotation creation or editing).
  /// Corresponds to `initialViewState.readOnly`.
  final bool? readOnly;

  /// Show or hide the annotation toolbar. Corresponds to `initialViewState.enableAnnotationToolbar`.
  final bool? enableAnnotationToolbar;

  /// The sidebar panel shown on load. Corresponds to `initialViewState.sidebarMode`.
  final SidebarMode? sidebarMode;

  /// The active interaction / tool mode on load. Corresponds to `initialViewState.interactionMode`.
  final NutrientWebInteractionMode? interactionMode;

  /// Initial zoom level. Can be a [num] scale factor or a [ZoomMode] constant.
  /// Corresponds to `initialViewState.zoom`.
  final dynamic zoom;

  /// Amount the zoom changes per zoom step. Corresponds to `initialViewState.zoomStep`.
  final double? zoomStep;

  /// Spacing between page spreads in CSS pixels. Corresponds to `initialViewState.spreadSpacing`.
  final num? spreadSpacing;

  /// Spacing between individual pages in CSS pixels. Corresponds to `initialViewState.pageSpacing`.
  final double? pageSpacing;

  /// Padding between the viewport edge and the document. Corresponds to `initialViewState.viewportPadding`.
  final num? viewportPadding;

  /// Whether printing is allowed from the viewer. Corresponds to `initialViewState.allowPrinting`.
  final bool? allowPrinting;

  /// Whether the user can scroll the document while drawing an annotation.
  /// Corresponds to `initialViewState.canScrollWhileDrawing`.
  final bool? canScrollWhileDrawing;

  /// Keep the first page as a single page in double-page mode.
  /// Corresponds to `initialViewState.keepFirstSpreadAsSinglePage`.
  final bool? keepFirstSpreadAsSinglePage;

  /// Keep the currently selected annotation tool active after use.
  /// Corresponds to `initialViewState.keepSelectedTool`.
  final bool? keepSelectedTool;

  /// Enable form design / editing mode. Corresponds to `initialViewState.formDesignMode`.
  final bool? formDesignMode;

  /// Show a preview of the redaction overlay before applying.
  /// Corresponds to `initialViewState.previewRedactionMode`.
  final bool? previewRedactionMode;

  /// When to show the digital signature validation status badge.
  /// Corresponds to `initialViewState.showSignatureValidationStatus`.
  final ShowSignatureValidationStatusMode? showSignatureValidationStatus;

  /// Initial page rotation in degrees (0, 90, 180, 270).
  /// Corresponds to `initialViewState.pagesRotation`.
  final num? pageRotation;

  // ---------------------------------------------------------------------------
  // Top-level PSPDFKit.load() properties
  // ---------------------------------------------------------------------------

  /// Document password for encrypted PDFs.
  final String? password;

  /// The viewer colour theme. Prefer [NutrientViewConfiguration.appearanceMode]
  /// for cross-platform theming; this field lets you pass a raw Web SDK theme
  /// string (`'DARK'`, `'LIGHT'`, `'AUTO'`) when needed.
  final String? theme;

  /// Auto-save behaviour. Corresponds to `autoSaveMode`.
  final AutoSaveMode? autoSaveMode;

  /// Disable text selection in the viewer. Corresponds to `disableTextSelection`.
  final bool? disableTextSelection;

  /// Disable form field interaction. Corresponds to `disableForms`.
  final bool? disableForms;

  /// Disable high-quality printing optimisations. Corresponds to `disableHighQualityPrinting`.
  final bool? disableHighQualityPrinting;

  /// Disable multi-annotation selection. Corresponds to `disableMultiSelection`.
  final bool? disableMultiSelection;

  /// Disable processing of PDF open parameters from the URL. Corresponds to `disableOpenParameters`.
  final bool? disableOpenParameters;

  /// Disable WebAssembly streaming compilation. Corresponds to `disableWebAssemblyStreaming`.
  final bool? disableWebAssemblyStreaming;

  /// Minimum zoom level as a scale factor. Corresponds to `minDefaultZoomLevel`.
  final num? minDefaultZoomLevel;

  /// Maximum zoom level as a scale factor. Corresponds to `maxDefaultZoomLevel`.
  final num? maxDefaultZoomLevel;

  /// Run the viewer without a UI (no toolbar, no overlays). Corresponds to `headless`.
  final bool? headless;

  /// BCP-47 locale string for the viewer UI (e.g. `'en'`, `'de'`). Corresponds to `locale`.
  final String? locale;

  /// Where the main toolbar is placed. Corresponds to `toolbarPlacement`.
  final ToolbarPlacement? toolbarPlacement;

  /// Additional CSS stylesheet URLs loaded into the viewer iframe. Corresponds to `styleSheets`.
  final List<String>? styleSheets;

  /// Annotation types the user is allowed to create/edit. Corresponds to `editableAnnotationTypes`.
  final List<dynamic>? editableAnnotationTypes;

  /// Enable undo/redo history. Corresponds to `enableHistory`.
  final bool? enableHistory;

  /// Automatically extract and linkify URLs in text. Corresponds to `enableAutomaticLinkExtraction`.
  final bool? enableAutomaticLinkExtraction;

  /// Enable clipboard cut/copy/paste for annotations. Corresponds to `enableClipboardActions`.
  final bool? enableClipboardActions;

  /// Enable service-worker caching for offline support. Corresponds to `enableServiceWorkerSupport`.
  final bool? enableServiceWorkerSupport;

  /// Prevent the user from copying text from the document. Corresponds to `preventTextCopy`.
  final bool? preventTextCopy;

  /// Restrict annotation placement to within page bounds. Corresponds to `restrictAnnotationToPageBounds`.
  final bool? restrictAnnotationToPageBounds;

  /// Seconds of inactivity before the document is automatically closed.
  /// Corresponds to `autoCloseThreshold`.
  final num? autoCloseThreshold;

  /// Override the WebAssembly memory limit in bytes. Corresponds to `overrideMemoryLimit`.
  final num? overrideMemoryLimit;

  /// Number of pre-warmed standalone viewer instances in the pool.
  /// Corresponds to `standaloneInstancesPoolSize`.
  final num? standaloneInstancesPoolSize;

  /// Maximum number of password retry attempts. Corresponds to `maxPasswordRetries`.
  final num? maxPasswordRetries;

  /// Maximum number of @mention suggestions shown in a comment.
  /// Corresponds to `maxMentionSuggestions`.
  final num? maxMentionSuggestions;

  /// Custom font definitions to load. Corresponds to `customFonts`.
  final List<dynamic>? customFonts;

  /// Stamp annotation template definitions. Corresponds to `stampAnnotationTemplates`.
  final List<dynamic>? stampAnnotationTemplates;

  /// Form field names whose signatures should not be persisted.
  /// Corresponds to `formFieldsNotSavingSignatures`.
  final List<String>? formFieldsNotSavingSignatures;

  /// Users available for @mention in comments. Corresponds to `mentionableUsers`.
  final List<dynamic>? mentionableUsers;

  /// Items shown in the document editor footer. Corresponds to `documentEditorFooterItems`.
  final List<dynamic>? documentEditorFooterItems;

  /// Items shown in the document editor toolbar. Corresponds to `documentEditorToolbarItems`.
  final List<dynamic>? documentEditorToolbarItems;

  /// Print configuration options. Corresponds to `printOptions`.
  final Map<String, dynamic>? printOptions;

  /// Base URL for loading the PSPDFKit Core WASM assets. Corresponds to `baseCoreUrl`.
  final String? baseCoreUrl;

  /// Base URL prefix for resolving relative asset paths. Corresponds to `baseUrl`.
  final String? baseUrl;

  /// Whether to load SDK assets from the Nutrient CDN. Corresponds to `useCDN`.
  ///
  /// Has no effect when [baseUrl] is provided.
  final bool? useCDN;

  /// CSS selector for the HTML element that hosts the viewer. Corresponds to `container`.
  final String? container;

  /// An XFDF string to import into the document on load. Corresponds to `xfdf`.
  final String? xfdf;

  /// Whether to keep existing annotations when importing [xfdf].
  /// Corresponds to `xfdfKeepCurrentAnnotations`.
  final bool? xfdfKeepCurrentAnnotations;

  /// Office document conversion settings (spreadsheet dimensions, etc.).
  final OfficeConversionSettings? officeConversionSettings;

  // ---------------------------------------------------------------------------
  // Toolbar & callbacks
  // ---------------------------------------------------------------------------

  /// The items shown in the main toolbar. When `null` the SDK default set is used.
  final List<NutrientWebToolbarItem>? toolbarItems;

  /// Callback that returns the annotation toolbar items for a given annotation type.
  final NutrientWebAnnotationToolbarItemsCallback? annotationToolbarItems;

  // ---------------------------------------------------------------------------
  // Opaque JS pass-through objects
  // ---------------------------------------------------------------------------

  /// Custom annotation/page renderers (JS object pass-through).
  final dynamic customRenderers;

  /// Custom UI configuration object (JS object pass-through).
  final dynamic customUIConfiguration;

  /// Electronic signatures configuration (JS object pass-through).
  final dynamic electronicSignatures;

  const WebViewConfiguration({
    this.showToolbar,
    this.showAnnotations,
    this.showAnnotationNotes,
    this.showComments,
    this.readOnly,
    this.enableAnnotationToolbar,
    this.sidebarMode,
    this.interactionMode,
    this.zoom,
    this.zoomStep,
    this.spreadSpacing,
    this.pageSpacing,
    this.viewportPadding,
    this.allowPrinting,
    this.canScrollWhileDrawing,
    this.keepFirstSpreadAsSinglePage,
    this.keepSelectedTool,
    this.formDesignMode,
    this.previewRedactionMode,
    this.showSignatureValidationStatus,
    this.pageRotation,
    this.password,
    this.theme,
    this.autoSaveMode,
    this.disableTextSelection,
    this.disableForms,
    this.disableHighQualityPrinting,
    this.disableMultiSelection,
    this.disableOpenParameters,
    this.disableWebAssemblyStreaming,
    this.minDefaultZoomLevel,
    this.maxDefaultZoomLevel,
    this.headless,
    this.locale,
    this.toolbarPlacement,
    this.styleSheets,
    this.editableAnnotationTypes,
    this.enableHistory,
    this.enableAutomaticLinkExtraction,
    this.enableClipboardActions,
    this.enableServiceWorkerSupport,
    this.preventTextCopy,
    this.restrictAnnotationToPageBounds,
    this.autoCloseThreshold,
    this.overrideMemoryLimit,
    this.standaloneInstancesPoolSize,
    this.maxPasswordRetries,
    this.maxMentionSuggestions,
    this.customFonts,
    this.stampAnnotationTemplates,
    this.formFieldsNotSavingSignatures,
    this.mentionableUsers,
    this.documentEditorFooterItems,
    this.documentEditorToolbarItems,
    this.printOptions,
    this.baseCoreUrl,
    this.baseUrl,
    this.useCDN,
    this.container,
    this.xfdf,
    this.xfdfKeepCurrentAnnotations,
    this.officeConversionSettings,
    this.toolbarItems,
    this.annotationToolbarItems,
    this.customRenderers,
    this.customUIConfiguration,
    this.electronicSignatures,
  });

  /// Serializes this configuration into a map with two keys — `'viewState'`
  /// and `'topLevel'` — consumed by `WebConfigurationBuilder`.
  ///
  /// This indirection lets `nutrient_flutter_web` consume [WebViewConfiguration]
  /// data without importing `nutrient_flutter` directly.
  Map<String, dynamic> toBuilderMap() {
    final viewState = <String, dynamic>{};
    final topLevel = <String, dynamic>{};

    // initialViewState properties
    if (showToolbar != null) viewState['showToolbar'] = showToolbar;
    if (showAnnotations != null) viewState['showAnnotations'] = showAnnotations;
    if (showAnnotationNotes != null) {
      viewState['showAnnotationNotes'] = showAnnotationNotes;
    }
    if (showComments != null) viewState['showComments'] = showComments;
    if (readOnly != null) viewState['readOnly'] = readOnly;
    if (enableAnnotationToolbar != null) {
      viewState['enableAnnotationToolbar'] = enableAnnotationToolbar;
    }
    if (sidebarMode != null) {
      viewState['sidebarMode'] = switch (sidebarMode!) {
        SidebarMode.annotations => 'ANNOTATIONS',
        SidebarMode.bookmarks => 'BOOKMARKS',
        SidebarMode.thumbnails => 'THUMBNAILS',
        SidebarMode.documentOutline => 'DOCUMENT_OUTLINE',
        SidebarMode.custom => 'CUSTOM',
      };
    }
    if (interactionMode != null) {
      viewState['interactionMode'] = interactionMode!.webName;
    }
    if (zoom != null) viewState['zoom'] = zoom;
    if (zoomStep != null) viewState['zoomStep'] = zoomStep;
    if (spreadSpacing != null) viewState['spreadSpacing'] = spreadSpacing;
    if (pageSpacing != null) viewState['pageSpacing'] = pageSpacing;
    if (viewportPadding != null) viewState['viewportPadding'] = viewportPadding;
    if (allowPrinting != null) viewState['allowPrinting'] = allowPrinting;
    if (canScrollWhileDrawing != null) {
      viewState['canScrollWhileDrawing'] = canScrollWhileDrawing;
    }
    if (keepFirstSpreadAsSinglePage != null) {
      viewState['keepFirstSpreadAsSinglePage'] = keepFirstSpreadAsSinglePage;
    }
    if (keepSelectedTool != null) {
      viewState['keepSelectedTool'] = keepSelectedTool;
    }
    if (formDesignMode != null) viewState['formDesignMode'] = formDesignMode;
    if (previewRedactionMode != null) {
      viewState['previewRedactionMode'] = previewRedactionMode;
    }
    if (showSignatureValidationStatus != null) {
      viewState['showSignatureValidationStatus'] =
          showSignatureValidationStatus!.webName;
    }
    if (pageRotation != null) viewState['pagesRotation'] = pageRotation;

    // Top-level properties
    if (password != null) topLevel['password'] = password;
    if (theme != null) topLevel['theme'] = theme;
    if (autoSaveMode != null) topLevel['autoSaveMode'] = autoSaveMode!.webName;
    if (disableTextSelection != null) {
      topLevel['disableTextSelection'] = disableTextSelection;
    }
    if (disableForms != null) topLevel['disableForms'] = disableForms;
    if (disableHighQualityPrinting != null) {
      topLevel['disableHighQualityPrinting'] = disableHighQualityPrinting;
    }
    if (disableMultiSelection != null) {
      topLevel['disableMultiSelection'] = disableMultiSelection;
    }
    if (disableOpenParameters != null) {
      topLevel['disableOpenParameters'] = disableOpenParameters;
    }
    if (disableWebAssemblyStreaming != null) {
      topLevel['disableWebAssemblyStreaming'] = disableWebAssemblyStreaming;
    }
    if (minDefaultZoomLevel != null) {
      topLevel['minDefaultZoomLevel'] = minDefaultZoomLevel;
    }
    if (maxDefaultZoomLevel != null) {
      topLevel['maxDefaultZoomLevel'] = maxDefaultZoomLevel;
    }
    if (headless != null) topLevel['headless'] = headless;
    if (locale != null) topLevel['locale'] = locale;
    if (toolbarPlacement != null) {
      topLevel['toolbarPlacement'] = toolbarPlacement!.webName;
    }
    if (styleSheets != null) topLevel['styleSheets'] = styleSheets;
    if (editableAnnotationTypes != null) {
      topLevel['editableAnnotationTypes'] = editableAnnotationTypes;
    }
    if (enableHistory != null) topLevel['enableHistory'] = enableHistory;
    if (enableAutomaticLinkExtraction != null) {
      topLevel['enableAutomaticLinkExtraction'] = enableAutomaticLinkExtraction;
    }
    if (enableClipboardActions != null) {
      topLevel['enableClipboardActions'] = enableClipboardActions;
    }
    if (enableServiceWorkerSupport != null) {
      topLevel['enableServiceWorkerSupport'] = enableServiceWorkerSupport;
    }
    if (preventTextCopy != null) topLevel['preventTextCopy'] = preventTextCopy;
    if (restrictAnnotationToPageBounds != null) {
      topLevel['restrictAnnotationToPageBounds'] =
          restrictAnnotationToPageBounds;
    }
    if (autoCloseThreshold != null) {
      topLevel['autoCloseThreshold'] = autoCloseThreshold;
    }
    if (overrideMemoryLimit != null) {
      topLevel['overrideMemoryLimit'] = overrideMemoryLimit;
    }
    if (standaloneInstancesPoolSize != null) {
      topLevel['standaloneInstancesPoolSize'] = standaloneInstancesPoolSize;
    }
    if (maxPasswordRetries != null) {
      topLevel['maxPasswordRetries'] = maxPasswordRetries;
    }
    if (maxMentionSuggestions != null) {
      topLevel['maxMentionSuggestions'] = maxMentionSuggestions;
    }
    if (customFonts != null) topLevel['customFonts'] = customFonts;
    if (stampAnnotationTemplates != null) {
      topLevel['stampAnnotationTemplates'] = stampAnnotationTemplates;
    }
    if (formFieldsNotSavingSignatures != null) {
      topLevel['formFieldsNotSavingSignatures'] = formFieldsNotSavingSignatures;
    }
    if (mentionableUsers != null) topLevel['mentionableUsers'] = mentionableUsers;
    if (documentEditorFooterItems != null) {
      topLevel['documentEditorFooterItems'] = documentEditorFooterItems;
    }
    if (documentEditorToolbarItems != null) {
      topLevel['documentEditorToolbarItems'] = documentEditorToolbarItems;
    }
    if (printOptions != null) topLevel['printOptions'] = printOptions;
    if (baseCoreUrl != null) topLevel['baseCoreUrl'] = baseCoreUrl;
    if (baseUrl != null) topLevel['baseUrl'] = baseUrl;
    if (useCDN != null) topLevel['useCDN'] = useCDN;
    if (container != null) topLevel['container'] = container;
    if (xfdf != null) topLevel['xfdf'] = xfdf;
    if (xfdfKeepCurrentAnnotations != null) {
      topLevel['xfdfKeepCurrentAnnotations'] = xfdfKeepCurrentAnnotations;
    }
    if (officeConversionSettings != null) {
      topLevel.addAll(officeConversionSettings!.toMap());
    }
    if (toolbarItems != null) topLevel['toolbarItems'] = toolbarItems;
    if (annotationToolbarItems != null) {
      topLevel['annotationToolbarItems'] = annotationToolbarItems;
    }
    if (customRenderers != null) topLevel['customRenderers'] = customRenderers;
    if (customUIConfiguration != null) {
      topLevel['customUIConfiguration'] = customUIConfiguration;
    }
    if (electronicSignatures != null) {
      topLevel['electronicSignatures'] = electronicSignatures;
    }

    return {'viewState': viewState, 'topLevel': topLevel};
  }
}
