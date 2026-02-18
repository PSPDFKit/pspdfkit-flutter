///
///  Copyright © 2023-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter/nutrient_flutter.dart';

/// A class representing the configuration options for a PDF document.
class PdfConfiguration {
  /// Sets the direction in which pages are laid out horizontally.
  /// This is available only on Android and iOS.
  final ScrollDirection? scrollDirection;

  /// Sets the page transition mode. This is only applicable to continuous scroll modes.
  final PageTransition? pageTransition;

  /// Enables text selection. Defaults to true.
  final bool? enableTextSelection;

  /// Disables autosaving. Defaults to false.
  final bool? disableAutosave;

  /// Document Presentation Options
  final PageLayoutMode? pageLayoutMode;

  /// Sets the spread fitting mode. This is only applicable to double page modes.
  final SpreadFitting? spreadFitting;

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
  final UserInterfaceViewMode? userInterfaceViewMode;

  /// Sets whether to enable immersive mode. Defaults to false.
  final bool? immersiveMode;

  /// Sets the appearance mode. Defaults to defaultMode.
  final AppearanceMode? appearanceMode;

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

  /// Sets whether to enable the content editor. Defaults to true.
  /// This feature requires a content editor license.
  final bool? androidContentEditorEnabled;

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

  /// Sets the bookmark indicator mode for iOS. This controls whether a button
  /// indicating the current bookmark status of the page will be displayed on
  /// the page itself. Defaults to `off`.
  ///
  /// This is only available on iOS. On Android and Web, this setting is ignored.
  final IOSBookmarkIndicatorMode? iOSBookmarkIndicatorMode;

  /// Enables/disables the bookmark indicator's interaction on iOS. Defaults to `true`.
  /// If this is enabled, tapping the indicator will bookmark or un-bookmark
  /// the page it is displayed on.
  ///
  /// Use this in conjunction with [iOSBookmarkIndicatorMode] to get the desired behavior.
  ///
  /// This is only available on iOS. On Android and Web, this setting is ignored.
  final bool? iOSBookmarkIndicatorInteractionEnabled;

  /// Sets the file conflict resolution strategy for iOS.
  ///
  /// When a PDF file is modified or deleted externally while being viewed in
  /// the app, the SDK can handle this conflict in different ways. This option
  /// specifies how to resolve such conflicts.
  ///
  /// This option is iOS-only. On Android and Web, this setting is ignored.
  ///
  /// Defaults to [IOSFileConflictResolution.defaultBehavior], which shows an
  /// alert to the user to choose how to resolve the conflict.
  ///
  /// See [IOSFileConflictResolution] for available options.
  final IOSFileConflictResolution? iOSFileConflictResolution;

  /// Thumbnail Options
  /// Sets the thumbnail bar mode. Defaults to defaultMode.
  final ThumbnailBarMode? showThumbnailBar;

  /// Sets whether to show the thumbnail grid action in the Android toolbar.
  /// Defaults to true.
  final bool? androidShowThumbnailGridAction;

  /// Annotation, Forms and Bookmark Options
  /// Sets whether to enable annotation editing. Defaults to true.
  final bool? enableAnnotationEditing;

  /// Sets whether to enable form field editing. Defaults to true.
  /// When set to false, form fields (text fields, checkboxes, radio buttons, etc.)
  /// cannot be edited by the user.
  ///
  /// **Platform behavior:**
  /// - **Android**: Uses a separate `formEditingEnabled` API, so form editing can be
  ///   controlled independently from annotation editing.
  /// - **iOS**: Forms are implemented as widget annotations. When [enableAnnotationEditing]
  ///   is set to `false`, all annotations including forms are disabled by default. However,
  ///   setting `enableFormEditing: true` will re-enable form editing even when annotation
  ///   editing is disabled.
  ///
  /// **Behavior matrix:**
  /// | [enableAnnotationEditing] | [enableFormEditing] | Result |
  /// |---------------------------|---------------------|--------|
  /// | `true` (or not set)       | `true` (or not set) | All annotations and forms editable |
  /// | `true` (or not set)       | `false`             | Annotations editable, forms NOT editable |
  /// | `false`                   | `true`              | Forms editable, other annotations NOT editable |
  /// | `false`                   | `false` (or not set)| Nothing editable |
  final bool? enableFormEditing;

  /// Sets whether to show the annotation list action in the Android toolbar.
  /// Defaults to true.
  final bool? androidShowAnnotationListAction;

  /// Sets whether to show the annotation creation action in the Android toolbar.
  /// Defaults to true. When set to false, hides the main annotation button while
  /// keeping annotation editing functionality enabled.
  final bool? androidShowAnnotationCreationAction;

  /// Sets whether to enable instant comments. Defaults to true. This feature
  /// requires a Instant Synchronization license.
  final bool? enableInstantComments;

  /// Sets the web specific configuration. This is only applicable to web.
  /// If not set, the default web configuration will be used.
  final PdfWebConfiguration? webConfiguration;

  /// Sets the annotation types that are editable. Defaults to null.
  final List<String>? editableAnnotationTypes;

  /// Sets the toolbar menu items. Defaults to null.
  final List<ToolbarMenuItems>? toolbarMenuItems;

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

  final SignatureSavingStrategy? signatureSavingStrategy;

  final SignatureCreationConfiguration? signatureCreationConfiguration;

  final AIAssistantConfiguration? aiAssistantConfiguration;

  final bool? androidEnableAiAssistant;

  /// Configuration for annotation contextual menu customization.
  final AnnotationMenuConfiguration? annotationMenuConfiguration;

  /// Configuration for customizing the viewer's visual theme.
  ///
  /// Allows controlling colors for the toolbar, sub-toolbar, icons,
  /// background, search, thumbnails, selection, dialogs, and more
  /// from Flutter. This overrides the device's system theme for the
  /// viewer on all platforms (Android, iOS, Web).
  ///
  /// See [ThemeConfiguration] for details and available options.
  final ThemeConfiguration? themeConfiguration;

  PdfConfiguration({
    this.scrollDirection,
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
    this.androidContentEditorEnabled,
    this.androidShowShareAction,
    this.androidShowPrintAction,
    this.androidShowDocumentInfoView,
    this.androidShowAnnotationListAction,
    this.androidShowAnnotationCreationAction,
    this.androidDarkThemeResource,
    this.androidDefaultThemeResource,
    this.iOSLeftBarButtonItems,
    this.iOSRightBarButtonItems,
    this.iOSAllowToolbarTitleChange,
    this.iOSBookmarkIndicatorMode,
    this.iOSBookmarkIndicatorInteractionEnabled,
    this.iOSFileConflictResolution,
    this.showThumbnailBar,
    this.androidShowThumbnailGridAction,
    this.enableAnnotationEditing,
    this.enableFormEditing,
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
    this.minimumZoomScale,
    this.signatureSavingStrategy,
    this.signatureCreationConfiguration,
    this.aiAssistantConfiguration,
    this.androidEnableAiAssistant,
    this.annotationMenuConfiguration,
    this.themeConfiguration,
  });

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
      'androidEnableContentEditor': androidContentEditorEnabled,
      'androidShowShareAction': androidShowShareAction,
      'androidShowPrintAction': androidShowPrintAction,
      'androidShowDocumentInfoView': androidShowDocumentInfoView,
      'androidDarkThemeResource': androidDarkThemeResource,
      'androidDefaultThemeResource': androidDefaultThemeResource,
      'iOSLeftBarButtonItems': iOSLeftBarButtonItems,
      'iOSRightBarButtonItems': iOSRightBarButtonItems,
      'iOSAllowToolbarTitleChange': iOSAllowToolbarTitleChange,
      'iOSBookmarkIndicatorMode': iOSBookmarkIndicatorMode?.name,
      'iOSBookmarkIndicatorInteractionEnabled':
          iOSBookmarkIndicatorInteractionEnabled,
      'iOSFileConflictResolution': iOSFileConflictResolution?.name,
      'showThumbnailBar': showThumbnailBar?.name,
      'androidShowThumbnailGridAction': androidShowThumbnailGridAction,
      'enableAnnotationEditing': enableAnnotationEditing,
      'enableFormEditing': enableFormEditing,
      'androidShowAnnotationListAction': androidShowAnnotationListAction,
      'androidShowAnnotationCreationAction':
          androidShowAnnotationCreationAction,
      'enableInstantComments': enableInstantComments,
      'enableMeasurementTools': enableMeasurementTools,
      'enableMeasurementToolSnapping': measurementSnappingEnabled,
      'enableMagnifier': enableMagnifier,
      'measurementValueConfigurations':
          measurementValueConfigurations?.map((e) => e.toMap()).toList(),
      'toolbarItemGrouping': convertAnnotationToolsGrouping(),
      'defaultZoomScale': defaultZoomScale,
      'maximumZoomScale': maximumZoomScale,
      'minimumZoomScale': minimumZoomScale,
      'signatureSavingStrategy': signatureSavingStrategy?.name,
      'signatureCreationConfiguration': signatureCreationConfiguration?.toMap(),
      'aiAssistant': aiAssistantConfiguration?.toMap(),
      'enableAiAssistant': androidEnableAiAssistant,
      'annotationMenuConfiguration': annotationMenuConfiguration?.toMap(),
      'themeConfiguration': themeConfiguration?.toMap(),
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
