///
///  Copyright © 2023-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import '../pspdfkit.dart';

/// A class representing the configuration options for a PDF document.
class PdfConfiguration {
  /// Sets the direction in which pages are laid out horizontally.
  /// This is available only on Android and iOS.
  final PspdfkitScrollDirection? scrollDirection;

  /// Sets the page transition mode. This is only applicable to continuous scroll modes.
  final PspdfkitPageTransition? pageTransition;

  /// Enables text selection. Defaults to true.
  final bool? enableTextSelection;

  /// Disables autosaving. Defaults to false.
  final bool? disableAutosave;

  /// Document Presentation Options
  final PspdfkitPageLayoutMode? pageLayoutMode;

  /// Sets the spread fitting mode. This is only applicable to double page modes.
  final PspdfkitSpreadFitting? spreadFitting;

  /// Sets whether to show page labels instead of page numbers.
  final bool? showPageLabels;

  /// Sets the page to start the document with.
  final int? startPage;

  /// Sets whether to show the document label on top of the document. Defaults to false.
  final bool? documentLabelEnabled;

  /// Sets whether the first page should be always single in double page mode. Defaults to false.
  final bool? firstPageAlwaysSingle;

  /// Sets whether to invert the colors of the document. Defaults to false.
  final bool? invertColors;

  /// Sets the password to unlock the document.
  final String? password;

  /// Sets whether to show the document in gray scale. Defaults to false.
  final bool? androidGrayScale;

  /// User Interface Options
  /// Sets whether to make the search mode inline. Defaults to false.
  final bool? inlineSearch;

  /// Sets the title of the toolbar.
  final String? toolbarTitle;

  /// Sets whether to show the action navigation buttons. Defaults to false.
  final bool? showActionNavigationButtons;

  /// Sets the user interface view mode. Defaults to automatic.
  final PspdfkitUserInterfaceViewMode? userInterfaceViewMode;

  /// Sets whether to enable immersive mode. Defaults to false.
  final bool? immersiveMode;

  /// Sets the appearance mode. Defaults to defaultMode.
  final PspdfkitAppearanceMode? appearanceMode;

  /// Sets the items to show in the settings menu.
  final List<String>? settingsMenuItems;

  /// Sets whether to show the search action in the Android toolbar. Defaults
  /// to true.
  final bool? androidShowSearchAction;

  /// Sets whether to show the outline action in the Android toolbar. Defaults
  /// to true.
  final bool? androidShowOutlineAction;

  /// Sets whether to show the bookmarks action in the Android toolbar. Defaults
  ///  to true.
  final bool? androidShowBookmarksAction;

  /// Sets whether to enable the document editor. Defaults to true.
  /// This feature requires a document editor license.
  final bool? androidEnableDocumentEditor;

  /// Sets whether to show the share action in the Android toolbar. Defaults
  /// to true.
  final bool? androidShowShareAction;

  /// Sets whether to show the print action in the Android toolbar.
  /// Defaults to true.
  final bool? androidShowPrintAction;

  /// Sets whether to show the document info view in the Android toolbar.
  /// Defaults to true.
  final bool? androidShowDocumentInfoView;

  /// Sets the dark theme XML resource for the Android toolbar.
  final String? androidDarkThemeResource;

  /// Sets the default theme XML resource for the Android toolbar.
  final String? androidDefaultThemeResource;

  /// Sets the left bar button items for the iOS toolbar.
  final List<String>? iOSLeftBarButtonItems;

  /// Sets the right bar button items for the iOS toolbar.
  final List<String>? iOSRightBarButtonItems;

  /// Sets whether to allow the toolbar title to change when the document is
  /// scrolled. Defaults to false.
  final bool? iOSAllowToolbarTitleChange;

  /// Thumbnail Options
  /// Sets the thumbnail bar mode. Defaults to defaultMode.
  final PspdfkitThumbnailBarMode? showThumbnailBar;

  /// Sets whether to show the thumbnail grid action in the Android toolbar.
  /// Defaults to true.
  final bool? androidShowThumbnailGridAction;

  /// Annotation, Forms and Bookmark Options
  /// Sets whether to enable annotation editing. Defaults to true.
  final bool? enableAnnotationEditing;

  /// Sets whether to show the annotation list action in the Android toolbar.
  /// Defaults to true.
  final bool? androidShowAnnotationListAction;

  /// Sets whether to enable instant comments. Defaults to true. This feature
  /// requires a Instant Synchronization license.
  final bool? enableInstantComments;

  /// Sets the web specific configuration. This is only applicable to web.
  /// If not set, the default web configuration will be used.
  final PdfWebConfiguration? webConfiguration;

  /// Sets the annotation types that are editable. Defaults to null.
  final List<String>? editableAnnotationTypes;

  /// Sets the toolbar menu items. Defaults to null.
  final List<PspdfkitToolbarMenuItems>? toolbarMenuItems;

  /// Sets the measurement configuration. Defaults to null.
  /// This feature requires a Measurement license.
  /// See [MeasurementConfiguration] for more information.
  final List<MeasurementValueConfiguration>? measurementValueConfigurations;

  /// Sets whether to enable measurement snapping. Defaults to true.
  /// This feature requires a Measurement license.
  final bool? measurementSnappingEnabled;

  /// Sets whether to enable the measurement magnifier. Defaults to true.
  /// This feature requires a Measurement license.
  final bool? enableMagnifier;

  final bool? enableMeasurementTools;
  // Set grouping for annotation toolbar items.
  // The list must contain only AnnotationToolsGroup and AnnotationTool.
  final List<dynamic>? annotationToolsGrouping;

  /// Sets the default zoom scale. Defaults to null. On Web, this is the zoom has priority over PdfConfiguration.zoom.
  final double? defaultZoomScale;

  /// Sets the maximum zoom scale. Defaults to null.
  final double? maximumZoomScale;

  /// Sets the minimum zoom scale. Defaults to null.
  final double? minimumZoomScale;

  PdfConfiguration(
      {this.scrollDirection,
      this.pageTransition,
      this.enableTextSelection,
      this.disableAutosave,
      this.pageLayoutMode,
      this.spreadFitting,
      this.showPageLabels,
      this.startPage,
      this.documentLabelEnabled,
      this.firstPageAlwaysSingle,
      this.invertColors,
      this.password,
      this.androidGrayScale,
      this.inlineSearch,
      this.toolbarTitle,
      this.showActionNavigationButtons,
      this.userInterfaceViewMode,
      this.immersiveMode,
      this.appearanceMode,
      this.settingsMenuItems,
      this.androidShowSearchAction,
      this.androidShowOutlineAction,
      this.androidShowBookmarksAction,
      this.androidEnableDocumentEditor,
      this.androidShowShareAction,
      this.androidShowPrintAction,
      this.androidShowDocumentInfoView,
      this.androidShowAnnotationListAction,
      this.androidDarkThemeResource,
      this.androidDefaultThemeResource,
      this.iOSLeftBarButtonItems,
      this.iOSRightBarButtonItems,
      this.iOSAllowToolbarTitleChange,
      this.showThumbnailBar,
      this.androidShowThumbnailGridAction,
      this.enableAnnotationEditing,
      this.enableInstantComments,
      this.webConfiguration,
      this.editableAnnotationTypes,
      this.toolbarMenuItems,
      this.enableMeasurementTools,
      this.measurementSnappingEnabled,
      this.enableMagnifier,
      this.measurementValueConfigurations,
      this.annotationToolsGrouping,
      this.defaultZoomScale,
      this.maximumZoomScale,
      this.minimumZoomScale});

  /// Returns a [Map] representation of the [PdfConfiguration] object.
  /// This is used to pass the configuration to the platform side.
  Map<String, dynamic> toMap() {
    return {
      'scrollDirection': scrollDirection?.name,
      'pageTransition': pageTransition?.name,
      'enableTextSelection': enableTextSelection,
      'disableAutosave': disableAutosave,
      'pageLayoutMode': pageLayoutMode?.name,
      'spreadFitting': spreadFitting?.name,
      'showPageLabels': showPageLabels,
      'startPage': startPage,
      'documentLabelEnabled': documentLabelEnabled,
      'firstPageAlwaysSingle': firstPageAlwaysSingle,
      'invertColors': invertColors,
      'password': password,
      'androidGrayScale': androidGrayScale,
      'inlineSearch': inlineSearch,
      'toolbarTitle': toolbarTitle,
      'showActionNavigationButtons': showActionNavigationButtons,
      'userInterfaceViewMode': userInterfaceViewMode?.name,
      'immersiveMode': immersiveMode,
      'appearanceMode': appearanceMode?.name,
      'settingsMenuItems': settingsMenuItems,
      'androidShowSearchAction': androidShowSearchAction,
      'androidShowOutlineAction': androidShowOutlineAction,
      'androidShowBookmarksAction': androidShowBookmarksAction,
      'androidEnableDocumentEditor': androidEnableDocumentEditor,
      'androidShowShareAction': androidShowShareAction,
      'androidShowPrintAction': androidShowPrintAction,
      'androidShowDocumentInfoView': androidShowDocumentInfoView,
      'androidDarkThemeResource': androidDarkThemeResource,
      'androidDefaultThemeResource': androidDefaultThemeResource,
      'iOSLeftBarButtonItems': iOSLeftBarButtonItems,
      'iOSRightBarButtonItems': iOSRightBarButtonItems,
      'iOSAllowToolbarTitleChange': iOSAllowToolbarTitleChange,
      'showThumbnailBar': showThumbnailBar?.name,
      'androidShowThumbnailGridAction': androidShowThumbnailGridAction,
      'enableAnnotationEditing': enableAnnotationEditing,
      'androidShowAnnotationListAction': androidShowAnnotationListAction,
      'enableInstantComments': enableInstantComments,
      'enableMeasurementTools': enableMeasurementTools,
      'enableMeasurementToolSnapping': measurementSnappingEnabled,
      'enableMagnifier': enableMagnifier,
      'measurementValueConfigurations':
          measurementValueConfigurations?.map((e) => e.toMap()).toList(),
      'toolbarItemGrouping': convertAnnotationToolsGrouping(),
      'defaultZoomScale': defaultZoomScale,
      'maximumZoomScale': maximumZoomScale,
      'minimumZoomScale': minimumZoomScale
    }..removeWhere((key, value) => value == null);
  }

  dynamic convertAnnotationToolsGrouping() {
    if (annotationToolsGrouping == null) {
      return null;
    }
    return annotationToolsGrouping!
        .map((e) => e is AnnotationToolsGroup
            ? e.toMap()
            : e is AnnotationToolbarItem
                ? e.name
                : null)
        .toList();
  }
}
