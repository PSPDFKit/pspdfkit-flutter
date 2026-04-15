///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'view_configuration_enums.dart';

/// Android-specific viewer configuration options.
///
/// Use this class for options that only apply to the Android platform. Pass an
/// instance as [NutrientViewConfiguration.androidConfig].
///
/// All fields are optional. Unset fields (`null`) use the Nutrient Android SDK's
/// built-in defaults.
///
/// ## Example
/// ```dart
/// NutrientViewConfiguration(
///   androidConfig: AndroidViewConfiguration(
///     grayScale: false,
///     showSearchAction: true,
///     showOutlineAction: true,
///     showBookmarksAction: false,
///     inlineSearch: true,
///     enableDocumentEditor: true,
///     darkThemeResource: 'MyDarkTheme',
///   ),
/// )
/// ```
///
/// ## Platform availability
/// All fields on this class are Android-only. On iOS and Web they are silently
/// ignored.
class AndroidViewConfiguration {
  /// Render the document in greyscale.
  ///
  /// When `true`, the viewer renders all page content (including images and
  /// annotations) using a greyscale colour palette, which can reduce eye strain
  /// and battery usage on AMOLED displays.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.grayScale(boolean)`.
  final bool? grayScale;

  /// The colour theme for the viewer.
  ///
  /// Provides an Android-specific override for the viewer's appearance mode.
  /// This field takes precedence over [NutrientViewConfiguration.appearanceMode]
  /// when both are set.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.themeMode(ThemeMode)`.
  ///
  /// See also:
  /// - [AppearanceMode] for the list of available themes.
  /// - [NutrientViewConfiguration.appearanceMode] for the cross-platform equivalent.
  final AppearanceMode? appearanceMode;

  /// Where and how the thumbnail bar is displayed.
  ///
  /// Provides an Android-specific override for the thumbnail bar position.
  /// When set, this takes precedence over [NutrientViewConfiguration.thumbnailBarMode].
  ///
  /// See also:
  /// - [ThumbnailBarMode] for available positions.
  /// - [NutrientViewConfiguration.thumbnailBarMode] for the cross-platform equivalent.
  final ThumbnailBarMode? thumbnailBarMode;

  /// Show page labels instead of page numbers in the thumbnail bar and navigation.
  ///
  /// When `true` and the document contains named page labels (e.g. "Cover",
  /// "i", "ii", "1", "2"), the labels are used in place of numeric page indices.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showPageLabels(boolean)`.
  final bool? showPageLabels;

  /// Show the document title overlay at the top of the viewer.
  ///
  /// When `true`, the PDF document title (from the document metadata) is shown
  /// as an overlay at the top of the screen.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.documentLabelEnabled(boolean)`.
  final bool? documentLabelEnabled;

  /// Use inline search instead of a full-screen search dialog.
  ///
  /// When `true`, the search UI appears in a compact bar within the viewer
  /// rather than as a separate modal dialog. Inline search allows the user to
  /// see the document while entering a query.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.setInlineSearchEnabled(boolean)`.
  final bool? inlineSearch;

  /// Show back/forward page-navigation buttons in the toolbar.
  ///
  /// When `true`, arrow buttons for navigating to the previous and next visited
  /// page are shown in the viewer toolbar.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showActionNavigationButtons(boolean)`.
  final bool? showActionNavigationButtons;

  /// Show the full-text search action button in the viewer toolbar.
  ///
  /// When `false`, the search icon is removed from the toolbar and the search
  /// feature is inaccessible through the UI.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showSearchAction(boolean)`.
  final bool? showSearchAction;

  /// Show the outline (table of contents) action in the viewer toolbar.
  ///
  /// When `true`, a button that opens the document outline / table of contents
  /// panel is shown in the toolbar.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showOutlineAction(boolean)`.
  final bool? showOutlineAction;

  /// Show the bookmarks action in the viewer toolbar.
  ///
  /// When `true`, a bookmark button that opens the bookmarks list is shown in
  /// the toolbar, allowing users to add, remove, and navigate bookmarks.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showBookmarksAction(boolean)`.
  final bool? showBookmarksAction;

  /// Show the annotation list action in the viewer toolbar.
  ///
  /// When `true`, a button that opens a list of all annotations in the document
  /// is shown in the toolbar.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showAnnotationListAction(boolean)`.
  final bool? showAnnotationListAction;

  /// Show the thumbnail grid action in the viewer toolbar.
  ///
  /// When `true`, a button that opens a full-screen grid of page thumbnails is
  /// shown in the toolbar, allowing the user to jump to any page quickly.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showThumbnailGridAction(boolean)`.
  final bool? showThumbnailGridAction;

  /// Show the print action in the viewer toolbar.
  ///
  /// When `true`, a print button is shown in the toolbar overflow menu.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.showPrintAction(boolean)`.
  final bool? showPrintAction;

  /// Enable the document editor feature.
  ///
  /// When `true`, the document editor (page manipulation: insert, delete,
  /// reorder, rotate pages) is accessible from the toolbar. This feature
  /// requires a **Document Editor** add-on licence; enabling it without a
  /// valid licence has no effect.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.enableDocumentEditor(boolean)`.
  final bool? enableDocumentEditor;

  /// Enable the content editing feature.
  ///
  /// When `true`, the user can edit PDF text and images in-place using the
  /// content editor. This feature requires a **Content Editor** add-on licence;
  /// enabling it without a valid licence has no effect.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.contentEditorEnabled(boolean)`.
  final bool? contentEditorEnabled;

  /// Name of the Android XML theme resource to use for the dark colour scheme.
  ///
  /// The string must match a theme declared in your Android app's `res/values/`
  /// directory. This theme is applied when [appearanceMode] (or
  /// [NutrientViewConfiguration.appearanceMode]) is set to [AppearanceMode.night].
  ///
  /// Example: `'MyApp_Dark'` — the theme must extend one of the Nutrient SDK
  /// base themes.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.darkTheme(int)` (resolved by
  /// `Resources.getIdentifier`).
  final String? darkThemeResource;

  /// Name of the Android XML theme resource to use for the default (light) colour scheme.
  ///
  /// The string must match a theme declared in your Android app's `res/values/`
  /// directory. This theme is applied when [appearanceMode] (or
  /// [NutrientViewConfiguration.appearanceMode]) is set to [AppearanceMode.defaultMode]
  /// or [AppearanceMode.sepia].
  ///
  /// Example: `'MyApp_Light'` — the theme must extend one of the Nutrient SDK
  /// base themes.
  ///
  /// Maps to `PdfActivityConfiguration$Builder.defaultTheme(int)` (resolved by
  /// `Resources.getIdentifier`).
  final String? defaultThemeResource;

  /// Creates an [AndroidViewConfiguration].
  ///
  /// All parameters are optional. Omit any parameter to use the Nutrient
  /// Android SDK's built-in default for that option.
  const AndroidViewConfiguration({
    this.grayScale,
    this.appearanceMode,
    this.thumbnailBarMode,
    this.showPageLabels,
    this.documentLabelEnabled,
    this.inlineSearch,
    this.showActionNavigationButtons,
    this.showSearchAction,
    this.showOutlineAction,
    this.showBookmarksAction,
    this.showAnnotationListAction,
    this.showThumbnailGridAction,
    this.showPrintAction,
    this.enableDocumentEditor,
    this.contentEditorEnabled,
    this.darkThemeResource,
    this.defaultThemeResource,
  });
}
