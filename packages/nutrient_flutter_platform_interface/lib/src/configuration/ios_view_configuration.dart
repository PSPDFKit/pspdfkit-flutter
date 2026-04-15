///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'view_configuration_enums.dart';

/// The mode for displaying a bookmark indicator on individual pages.
///
/// iOS-only. Controls whether a small bookmark icon is rendered on each page
/// to indicate the bookmarked state of that page.
///
/// On Android and Web this setting is ignored.
///
/// Configure via [IOSViewConfiguration.bookmarkIndicatorMode].
enum IOSBookmarkIndicatorMode {
  /// Never show the bookmark indicator, regardless of bookmark state.
  off,

  /// Always show the bookmark indicator on every page.
  alwaysOn,

  /// Show the bookmark indicator only on pages that are currently bookmarked.
  onWhenBookmarked,
}

/// iOS-specific viewer configuration options.
///
/// Use this class for options that only apply to the iOS platform. Pass an
/// instance as [NutrientViewConfiguration.iosConfig].
///
/// All fields are optional. Unset fields (`null`) use the Nutrient iOS SDK's
/// built-in defaults.
///
/// ## Example
/// ```dart
/// NutrientViewConfiguration(
///   iosConfig: IOSViewConfiguration(
///     spreadFitting: SpreadFitting.adaptive,
///     showPageLabels: true,
///     inlineSearch: true,
///     bookmarkIndicatorMode: IOSBookmarkIndicatorMode.onWhenBookmarked,
///     leftBarButtonItems: ['closeButtonItem'],
///     rightBarButtonItems: ['annotationButtonItem', 'searchButtonItem'],
///   ),
/// )
/// ```
///
/// ## Platform availability
/// All fields on this class are iOS-only. On Android and Web they are silently
/// ignored.
class IOSViewConfiguration {
  /// How a page spread is fitted into the available viewport.
  ///
  /// Controls whether pages are letterboxed ([SpreadFitting.fit]), cropped to
  /// fill the viewport ([SpreadFitting.fill]), or use an adaptive algorithm
  /// ([SpreadFitting.adaptive]) that picks the best strategy per spread.
  ///
  /// Maps to `PSPDFConfigurationBuilder.spreadFitting`.
  ///
  /// See also:
  /// - [SpreadFitting] for the available values and their descriptions.
  final SpreadFitting? spreadFitting;

  /// Where and how the thumbnail bar is displayed.
  ///
  /// Provides an iOS-specific override for the thumbnail bar position.
  /// When set, this takes precedence over [NutrientViewConfiguration.thumbnailBarMode].
  ///
  /// Maps to `PSPDFConfigurationBuilder.thumbnailBarMode`.
  ///
  /// See also:
  /// - [ThumbnailBarMode] for available positions.
  /// - [NutrientViewConfiguration.thumbnailBarMode] for the cross-platform equivalent.
  final ThumbnailBarMode? thumbnailBarMode;

  /// Show page labels instead of page numbers.
  ///
  /// When `true` and the document contains named page labels (e.g. "Cover",
  /// "i", "ii", "1", "2"), the labels are used in place of numeric page
  /// indices throughout the viewer UI.
  ///
  /// Maps to `PSPDFConfigurationBuilder.showPageLabels`.
  final bool? showPageLabels;

  /// Show the document title overlay at the top of the viewer.
  ///
  /// When `true`, the PDF document title (from the document metadata) is shown
  /// as an overlay at the top of the screen.
  ///
  /// Maps to `PSPDFConfigurationBuilder.documentLabelEnabled`.
  final bool? documentLabelEnabled;

  /// Use inline search instead of a separate search panel.
  ///
  /// When `true`, the search UI appears as a compact bar overlaid on the
  /// document rather than as a modal that pushes the content aside.
  ///
  /// Maps to `PSPDFConfigurationBuilder.searchMode` (`inline` vs `modal`).
  final bool? inlineSearch;

  /// Show back/forward page-navigation buttons in the navigation bar.
  ///
  /// When `true`, arrow buttons for navigating to the previous and next visited
  /// page are added to the viewer's navigation bar.
  ///
  /// Maps to `PSPDFConfigurationBuilder.showActionNavigationButtonsAsThumbnails`
  /// and related navigation button configuration.
  final bool? showActionNavigationButtons;

  /// Whether the navigation bar title updates as the user scrolls the document.
  ///
  /// When `true`, the title shown in the navigation bar changes to reflect the
  /// current page number or label as the user scrolls. When `false`, the title
  /// is fixed to the document title set at load time.
  ///
  /// Maps to `PSPDFConfigurationBuilder.allowToolbarTitleChange`.
  final bool? allowToolbarTitleChange;

  /// Controls when the per-page bookmark indicator is displayed.
  ///
  /// The bookmark indicator is a small icon rendered on each page to show
  /// whether the page is bookmarked. Use [IOSBookmarkIndicatorMode] to choose
  /// when it is visible.
  ///
  /// Maps to `PSPDFConfigurationBuilder.bookmarkIndicatorMode`.
  ///
  /// See also:
  /// - [IOSBookmarkIndicatorMode] for the available modes.
  /// - [bookmarkIndicatorInteractionEnabled] to control whether tapping the
  ///   indicator toggles the bookmark.
  final IOSBookmarkIndicatorMode? bookmarkIndicatorMode;

  /// Whether tapping the bookmark indicator toggles the bookmark on the page.
  ///
  /// When `true`, tapping the bookmark indicator adds or removes a bookmark for
  /// that page. When `false`, the indicator is read-only (informational only).
  ///
  /// Only meaningful when [bookmarkIndicatorMode] is not [IOSBookmarkIndicatorMode.off].
  ///
  /// Maps to `PSPDFConfigurationBuilder.bookmarkIndicatorInteractionEnabled`.
  final bool? bookmarkIndicatorInteractionEnabled;

  /// Custom bar button items for the left side of the navigation bar.
  ///
  /// Each string must be a valid PSPDFKit bar button item identifier as defined
  /// in the Nutrient iOS SDK. Common identifiers include:
  ///
  /// - `'closeButtonItem'` — a standard close/dismiss button
  /// - `'backButtonItem'` — a back-navigation button
  /// - `'brightnessButtonItem'` — a brightness control button
  ///
  /// The list replaces the SDK's default left bar button configuration. Pass an
  /// empty list to remove all left buttons.
  ///
  /// Maps to `PSPDFViewController.navigationItem.leftBarButtonItems`.
  ///
  /// See also:
  /// - [rightBarButtonItems] for the right-side button configuration.
  final List<String>? leftBarButtonItems;

  /// Custom bar button items for the right side of the navigation bar.
  ///
  /// Each string must be a valid PSPDFKit bar button item identifier as defined
  /// in the Nutrient iOS SDK. Common identifiers include:
  ///
  /// - `'annotationButtonItem'` — opens the annotation toolbar
  /// - `'searchButtonItem'` — opens search
  /// - `'outlineButtonItem'` — opens the outline/TOC panel
  /// - `'bookmarkButtonItem'` — opens the bookmarks panel
  /// - `'thumbnailsButtonItem'` — opens the thumbnail grid
  /// - `'printButtonItem'` — opens the print dialog
  /// - `'emailButtonItem'` — shares the document via email
  /// - `'activityButtonItem'` — opens the system share sheet
  ///
  /// The list replaces the SDK's default right bar button configuration. Pass an
  /// empty list to remove all right buttons.
  ///
  /// Maps to `PSPDFViewController.navigationItem.rightBarButtonItems`.
  ///
  /// See also:
  /// - [leftBarButtonItems] for the left-side button configuration.
  final List<String>? rightBarButtonItems;

  /// Creates an [IOSViewConfiguration].
  ///
  /// All parameters are optional. Omit any parameter to use the Nutrient
  /// iOS SDK's built-in default for that option.
  const IOSViewConfiguration({
    this.spreadFitting,
    this.thumbnailBarMode,
    this.showPageLabels,
    this.documentLabelEnabled,
    this.inlineSearch,
    this.showActionNavigationButtons,
    this.allowToolbarTitleChange,
    this.bookmarkIndicatorMode,
    this.bookmarkIndicatorInteractionEnabled,
    this.leftBarButtonItems,
    this.rightBarButtonItems,
  });
}
