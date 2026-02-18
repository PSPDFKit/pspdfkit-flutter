///
///  Copyright © 2023-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Product identifier for Flutter Web.
const flutterWebProductId = 'FlutterForWeb';

/// Utility class to convert a [PdfConfiguration] to a configuration Map
/// for the Nutrient Web SDK.
///
/// The resulting map is used by the adapter's `configureLoad()` method
/// and gets converted to a JSObject before passing to PSPDFKit.load().
class WebConfigurationHelper {
  /// Populates a configuration map with values from a [PdfConfiguration].
  ///
  /// The [config] map is modified in place, adding configuration values
  /// derived from the [PdfConfiguration].
  ///
  /// This is designed to be called from an adapter's `configureLoad()` method
  /// where the config map will later be converted to JS via `.jsify()`.
  static void populateConfiguration(
    Map<String, dynamic> config,
    PdfConfiguration? configuration,
  ) {
    if (configuration == null) {
      return;
    }

    // Build initial view state as a plain map.
    // The Web SDK accepts these as top-level config properties when
    // passed via PSPDFKit.load() configuration object.
    //
    // IMPORTANT: Only include properties that are explicitly set to avoid
    // type conversion issues when jsify() converts nested maps to JavaScript.
    // The SDK is strict about types (e.g., currentPageIndex must be a number).
    final viewStateProps = <String, dynamic>{
      'currentPageIndex': configuration.startPage,
      'allowPrinting': configuration.webConfiguration?.allowPrinting,
      'canScrollWhileDrawing':
          configuration.webConfiguration?.canScrollWhileDrawing,
      'enableAnnotationToolbar': configuration.enableAnnotationEditing,
      'formDesignMode': configuration.webConfiguration?.formDesignMode,
      'interactionMode':
          configuration.webConfiguration?.interactionMode?.webName,
      'keepFirstSpreadAsSinglePage':
          configuration.webConfiguration?.keepFirstSpreadAsSinglePage,
      'keepSelectedTool': configuration.webConfiguration?.keepSelectedTool,
      'layoutMode': configuration.pageLayoutMode?.webName,
      'pageSpacing': configuration.webConfiguration?.pageSpacing,
      'pagesRotation': configuration.webConfiguration?.pageRotation,
      'previewRedactionMode':
          configuration.webConfiguration?.previewRedactionMode,
      // Only set readOnly if enableAnnotationEditing was explicitly configured
      'readOnly': configuration.enableAnnotationEditing != null
          ? !configuration.enableAnnotationEditing!
          : null,
      'scrollMode': configuration.pageTransition?.webName,
      'showAnnotationNotes':
          configuration.webConfiguration?.showAnnotationNotes,
      'showAnnotations': configuration.webConfiguration?.showAnnotations,
      'showComments': configuration.enableInstantComments,
      'showSignatureValidationStatus': configuration
          .webConfiguration?.showSignatureValidationStatus?.webName,
      // Only set showToolbar if userInterfaceViewMode was explicitly configured
      'showToolbar': configuration.userInterfaceViewMode != null
          ? _convertUserInterfaceViewMode(configuration.userInterfaceViewMode)
          : null,
      'sidebarMode': configuration.webConfiguration?.sideBarMode?.webName,
      'spreadSpacing': configuration.webConfiguration?.spreadSpacing,
      'viewportPadding': configuration.webConfiguration?.viewportPadding,
      'zoom': _getZoomValue(configuration.defaultZoomScale ??
          configuration.webConfiguration?.zoom),
      'zoomStep': configuration.webConfiguration?.zoomStep,
    }..removeWhere((key, value) => value == null);

    // Apply view state properties as initialViewState map.
    // The Web SDK's PSPDFKit.load() accepts initialViewState as a plain object.
    // Only add if we have actual user-configured properties to set.
    if (viewStateProps.isNotEmpty) {
      config['initialViewState'] = viewStateProps;
    }

    // Convert toolbar items to plain maps.
    final toolbarItems = configuration.webConfiguration?.toolbarItems
        ?.map((item) => _toolbarItemToMap(item))
        .toList();

    // Get remaining web configurations, excluding:
    // - toolbarItems/annotationToolbarItems (handled separately above)
    // - ViewState properties (already handled via viewStateProps → initialViewState)
    //   The Web SDK's Configuration does not accept ViewState properties at the
    //   top level — they must be passed via initialViewState.
    const viewStateKeys = {
      'allowPrinting',
      'canScrollWhileDrawing',
      'formDesignMode',
      'interactionMode',
      'keepFirstSpreadAsSinglePage',
      'keepSelectedTool',
      'pageSpacing',
      'pageRotation',
      'previewRedactionMode',
      'showSignatureValidationStatus',
      'showAnnotationNotes',
      'showAnnotations',
      'spreadSpacing',
      'sidebarMode',
      'viewportPadding',
    };
    final finalWebConfigurations = configuration.webConfiguration?.toMap()
      ?..removeWhere((key, value) =>
          key == 'toolbarItems' ||
          key == 'annotationToolbarItems' ||
          viewStateKeys.contains(key));

    // Override default zoom levels if set.
    if (configuration.maximumZoomScale != null) {
      finalWebConfigurations
          ?.addAll({'maxDefaultZoomLevel': configuration.maximumZoomScale});
    }
    if (configuration.minimumZoomScale != null) {
      finalWebConfigurations
          ?.addAll({'minDefaultZoomLevel': configuration.minimumZoomScale});
    }

    // Build the configuration map.
    final configEntries = <String, dynamic>{
      'productId': flutterWebProductId,
      'password': configuration.password,
      'editableAnnotationTypes': configuration.editableAnnotationTypes,
      'disableTextSelection': configuration.enableTextSelection,
      'autoSaveMode': configuration.disableAutosave == true
          ? 'DISABLED'
          : configuration.webConfiguration?.autoSaveMode?.webName,
      'theme': configuration.appearanceMode?.webName,
      'toolbarItems': toolbarItems,
      'aiAssistant': configuration.aiAssistantConfiguration?.toWebMap(),
      // Measurement value configurations are applied as data, not callbacks.
      // The callback pattern from the old implementation required dart:js.
      // Instead, pass the configuration values directly.
      ...?finalWebConfigurations,
    }..removeWhere((key, value) => value == null);

    config.addAll(configEntries);
  }

  static bool? _convertUserInterfaceViewMode(
      UserInterfaceViewMode? userInterfaceViewMode) {
    switch (userInterfaceViewMode) {
      case UserInterfaceViewMode.never:
        return false;
      case UserInterfaceViewMode.automatic:
      case UserInterfaceViewMode.automaticNoFirstLastPage:
      case UserInterfaceViewMode.always:
      default:
        return true;
    }
  }

  static Map<String, dynamic> _toolbarItemToMap(NutrientWebToolbarItem item) {
    return <String, dynamic>{
      'type': item.type.name,
      if (item.title != null) 'title': item.title,
      if (item.className != null) 'className': item.className,
      if (item.disabled != null) 'disabled': item.disabled,
      if (item.dropdownGroup != null) 'dropdownGroup': item.dropdownGroup,
      if (item.icon != null) 'icon': item.icon,
      if (item.id != null) 'id': item.id,
      if (item.mediaQueries != null) 'mediaQueries': item.mediaQueries,
      if (item.onPress != null) 'onPress': item.onPress,
      if (item.preset != null) 'preset': item.preset,
      if (item.responsiveGroup != null) 'responsiveGroup': item.responsiveGroup,
      if (item.selected != null) 'selected': item.selected,
    };
  }

  static dynamic _getZoomValue(dynamic zoom) {
    if (zoom is num) {
      return zoom;
    } else if (zoom is ZoomMode) {
      return zoom.webName;
    } else {
      return null;
    }
  }

  /// Legacy method for backwards compatibility with `nutrient_web.dart`.
  ///
  /// @Deprecated: Use [populateConfiguration] instead with the new adapter pattern.
  /// This method will be removed when `nutrient_web.dart` is removed.
  @Deprecated('Use populateConfiguration with the new adapter pattern instead')
  static Map<String, dynamic> populateWebConfiguration(
    dynamic element,
    String documentPath,
    String? licenseKey,
    PdfConfiguration? configuration,
  ) {
    final config = <String, dynamic>{
      'container': element,
      'document': documentPath,
      if (licenseKey != null) 'licenseKey': licenseKey,
    };
    populateConfiguration(config, configuration);
    return config;
  }
}
