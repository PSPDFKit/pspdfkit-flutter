///
///  Copyright © 2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:html';
import 'dart:js';
import '../../pspdfkit.dart';
import 'pspdfkit_web.dart';
import 'pspdfkit_web_utils.dart';

/// This is a utility class used to convert a [PdfConfiguration] to a [PSPDFKit.Configuration](https://pspdfkit.com/api/web/PSPDFKit.Configuration.html) JsObject for Web.
/// It is used in [PSPDFKitWeb.load]. This class isolates the js interop code from the rest of the plugin.
class WebConfigurationHelper {
  /// Populates a [PSPDFKit.Configuration](https://pspdfkit.com/api/web/PSPDFKit.Configuration.html)
  /// JsObject with the values from a [PdfConfiguration] and [PdfWebConfiguration].
  ///
  /// The [id] parameter is used to identify the container element in which the PSPDFKit instance will be rendered.
  ///
  /// The [documentPath] parameter is the path to the document that will be loaded.
  ///
  /// The [licenseKey] parameter is the license key that will be used to unlock PSPDFKit.
  ///
  /// The [configuration] parameter is the configuration that will be used to configure PSPDFKit.
  ///
  /// Returns a [PSPDFKit.Configuration](https://pspdfkit.com/api/web/PSPDFKit.Configuration.html) JsObject.
  static JsObject populateWebConfiguration(
    Element element,
    String documentPath,
    String? licenseKey,
    PdfConfiguration? configuration,
  ) {
    var viewState = <String, dynamic>{
      'currentPageIndex': configuration?.startPage,
      'allowPrinting': configuration?.webConfiguration?.allowPrinting,
      'canScrollWhileDrawing':
          configuration?.webConfiguration?.canScrollWhileDrawing,
      'enableAnnotationToolbar': configuration?.enableAnnotationEditing,
      'formDesignMode': configuration?.webConfiguration?.formDesignMode,
      'interactionMode':
          configuration?.webConfiguration?.interactionMode?.webName,
      'keepFirstSpreadAsSinglePage':
          configuration?.webConfiguration?.keepFirstSpreadAsSinglePage,
      'keepSelectedTool': configuration?.webConfiguration?.keepSelectedTool,
      'layoutMode': configuration?.pageLayoutMode?.webName,
      'pageSpacing': configuration?.webConfiguration?.pageSpacing,
      'pageRotation': configuration?.webConfiguration?.pageRotation,
      'previewRedactionMode':
          configuration?.webConfiguration?.previewRedactionMode,
      'readOnly': configuration?.enableAnnotationEditing != null &&
          !configuration!.enableAnnotationEditing!,
      'scrollMode': configuration?.pageTransition?.webName,
      'showAnnotationNotes':
          configuration?.webConfiguration?.showAnnotationNotes,
      'showAnnotations': configuration?.webConfiguration?.showAnnotations,
      'showComments': configuration?.enableInstantComments,
      'showSignatureValidationStatus': configuration
          ?.webConfiguration?.showSignatureValidationStatus?.webName,
      'showToolbar':
          _convertUserInterfaceViewMode(configuration?.userInterfaceViewMode),
      'sidebarMode': configuration?.webConfiguration?.sideBarMode?.webName,
      'spreadSpacing': configuration?.webConfiguration?.spreadSpacing,
      'viewportPadding': configuration?.webConfiguration?.viewportPadding,
      'zoom': _getZoomValue(configuration?.defaultZoomScale ??
          configuration?.webConfiguration?.zoom),
      'zoomStep': configuration?.webConfiguration?.zoomStep,
    }..removeWhere((key, value) => value == null);

    // Creating a new PSPDFKit.ViewState JsObject with viewState.
    var initialViewState =
        JsObject(context['PSPDFKit']['ViewState'], [JsObject.jsify(viewState)]);

    // Convert toolbar items from here to avoid html imports in the main plugin.
    var toolbarItems = configuration?.webConfiguration?.toolbarItems
        ?.map((item) => item.toJsObject())
        .toList();

    // Remove the toolbar items from the configuration.
    var finalWebConfigurations = configuration?.webConfiguration?.toMap()
      ?..removeWhere((key, value) => key == 'toolbarItems');

    // Override the default zoom levels if they are set.
    if (configuration?.maximumZoomScale != null) {
      finalWebConfigurations
          ?.addAll({'maxDefaultZoomLevel': configuration?.maximumZoomScale});
    }

    if (configuration?.minimumZoomScale != null) {
      finalWebConfigurations
          ?.addAll({'minDefaultZoomLevel': configuration?.minimumZoomScale});
    }

    // Convert annotation toolbar items from here to avoid html imports in the main plugin.
    dynamic annotationToolbarItemsCallback(
        JsObject annotation, JsObject options) {
      // Extract the default annotation toolbar items.
      var callbackOptions =
          annotationToolbarItemsCallbackOptionsFromJsObject(options);

      var newAnnotationToolbarItems = configuration
          ?.webConfiguration?.annotationToolbarItems
          ?.call(annotation.toJson(), callbackOptions);

      // Return a list of new annotation toolbar items.
      return JsObject.jsify(
          newAnnotationToolbarItems?.map((e) => e.toJsObject()).toList() ??
              [
                ...callbackOptions.defaultAnnotationToolbarItems
                    .map((e) => e.toJsObject())
              ]);
    }

    dynamic measurementValueConfigurationCallback(
        dynamic defaultConfigurations) {
      var measurementValueConfigurations =
          configuration?.measurementValueConfigurations ?? [];
      var configs = defaultConfigurations
          .map((e) => (e as JsObject).toJson())
          .toList(growable: false);
      try {
        for (var config in configs) {
          var value = MeasurementValueConfiguration.fromWebMap(config);
          measurementValueConfigurations.add(value);
        }
      } catch (e) {
        throw Exception(
            'Failed to convert measurement value configurations: $e');
      }
      var convertedConfigurations = measurementValueConfigurations
          .map((e) => e.toWebMap())
          .toList(growable: false);
      return JsObject.jsify([...convertedConfigurations]);
    }

    // Remove the annotation toolbar items from the configuration.
    finalWebConfigurations
        ?.removeWhere((key, value) => key == 'annotationToolbarItems');

    // Convert measurement configuration from here to avoid html imports in the main plugin.
    var map = <String, dynamic>{
      'document': documentPath,
      'licenseKey': licenseKey,
      'productId': flutterWebProductId,
      'container': element,
      'initialViewState': initialViewState,
      'password': configuration?.password,
      'editableAnnotationTypes': configuration?.editableAnnotationTypes,
      'disableTextSelection': configuration?.enableTextSelection,
      'autoSaveMode': configuration?.disableAutosave == true
          ? 'DISABLED'
          : configuration?.webConfiguration?.autoSaveMode?.webName,
      'theme': configuration?.appearanceMode?.webName,
      // Add the converted toolbar items.
      'toolbarItems': toolbarItems,
      'annotationToolbarItems': annotationToolbarItemsCallback,
      'measurementValueConfiguration': measurementValueConfigurationCallback,
      ...?finalWebConfigurations
    };

    var config = map..removeWhere((key, value) => value == null);
    var jsConfig = JsObject.jsify(config);
    return jsConfig;
  }

  static bool? _convertUserInterfaceViewMode(
      PspdfkitUserInterfaceViewMode? userInterfaceViewMode) {
    switch (userInterfaceViewMode) {
      case PspdfkitUserInterfaceViewMode.never:
        return false;
      case PspdfkitUserInterfaceViewMode.automatic:
      case PspdfkitUserInterfaceViewMode.automaticNoFirstLastPage:
      case PspdfkitUserInterfaceViewMode.always:
      default:
        return true;
    }
  }

  static dynamic _getZoomValue(dynamic zoom) {
    if (zoom is num) {
      return zoom;
    } else if (zoom is PspdfkitZoomMode) {
      return zoom.webName;
    } else {
      return null;
    }
  }
}
