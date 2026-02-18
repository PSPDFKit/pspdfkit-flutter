///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter/src/annotations/annotation_colors.dart';

/// Configuration for customizing the main toolbar appearance.
///
/// Controls the navigation/action bar at the top of the viewer.
class ToolbarTheme {
  /// Background color of the main toolbar.
  final Color? backgroundColor;

  /// Color for toolbar icons in their default (inactive) state.
  final Color? iconColor;

  /// Color for toolbar icons in their active/selected state.
  final Color? activeIconColor;

  /// Color for the toolbar title text.
  final Color? titleColor;

  /// Color for the status bar. Android only.
  final Color? statusBarColor;

  const ToolbarTheme({
    this.backgroundColor,
    this.iconColor,
    this.activeIconColor,
    this.titleColor,
    this.statusBarColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
      'iconColor': iconColor?.toHex(),
      'activeIconColor': activeIconColor?.toHex(),
      'titleColor': titleColor?.toHex(),
      'statusBarColor': statusBarColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing the annotation toolbar appearance.
///
/// Controls the contextual toolbar that appears when creating or editing annotations.
class AnnotationToolbarTheme {
  /// Background color of the annotation toolbar.
  final Color? backgroundColor;

  /// Color for annotation toolbar icons in their default state.
  final Color? iconColor;

  /// Color for annotation toolbar icons in their active/selected state.
  final Color? activeIconColor;

  /// Background color of the active/selected tool button.
  final Color? activeToolBackgroundColor;

  const AnnotationToolbarTheme({
    this.backgroundColor,
    this.iconColor,
    this.activeIconColor,
    this.activeToolBackgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
      'iconColor': iconColor?.toHex(),
      'activeIconColor': activeIconColor?.toHex(),
      'activeToolBackgroundColor': activeToolBackgroundColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing the navigation tab appearance.
///
/// Controls the outline, bookmarks, and thumbnails panel tabs.
class NavigationTabTheme {
  /// Background color of the tab bar.
  final Color? backgroundColor;

  /// Color for tab icons in their unselected state.
  final Color? iconColor;

  /// Color for tab icons in their selected state.
  final Color? selectedIconColor;

  const NavigationTabTheme({
    this.backgroundColor,
    this.iconColor,
    this.selectedIconColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
      'iconColor': iconColor?.toHex(),
      'selectedIconColor': selectedIconColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing the search UI appearance.
class SearchTheme {
  /// Background color of the search bar/panel.
  final Color? backgroundColor;

  /// Color used to highlight search results on the document.
  final Color? highlightColor;

  const SearchTheme({
    this.backgroundColor,
    this.highlightColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
      'highlightColor': highlightColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing the thumbnail bar appearance.
class ThumbnailBarTheme {
  /// Background color of the thumbnail bar.
  final Color? backgroundColor;

  const ThumbnailBarTheme({
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing text and annotation selection appearance.
class SelectionTheme {
  /// Color used to highlight selected text.
  final Color? textHighlightColor;

  /// Color for text selection handles. Android only.
  final Color? textHandleColor;

  /// Color for the annotation selection border.
  final Color? annotationBorderColor;

  const SelectionTheme({
    this.textHighlightColor,
    this.textHandleColor,
    this.annotationBorderColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'textHighlightColor': textHighlightColor?.toHex(),
      'textHandleColor': textHandleColor?.toHex(),
      'annotationBorderColor': annotationBorderColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing dialog and modal appearance.
class ViewerDialogTheme {
  /// Background color of dialogs and modals.
  final Color? backgroundColor;

  const ViewerDialogTheme({
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
    }..removeWhere((key, value) => value == null);
  }
}

/// Configuration for customizing the viewer's visual theme.
///
/// All properties are optional. If not set, the platform's default colors
/// will be used.
///
/// Example:
/// ```dart
/// NutrientView(
///   documentPath: 'assets/document.pdf',
///   configuration: PdfConfiguration(
///     themeConfiguration: ThemeConfiguration(
///       backgroundColor: Color(0xFF1E1E1E),
///       toolbar: ToolbarTheme(
///         backgroundColor: Color(0xFF2D2D30),
///         iconColor: Color(0xFFCCCCCC),
///         activeIconColor: Color(0xFF007ACC),
///         titleColor: Color(0xFFFFFFFF),
///       ),
///       annotationToolbar: AnnotationToolbarTheme(
///         backgroundColor: Color(0xFF333337),
///         iconColor: Color(0xFFCCCCCC),
///         activeIconColor: Color(0xFF007ACC),
///         activeToolBackgroundColor: Color(0xFF094771),
///       ),
///     ),
///   ),
/// )
/// ```
class ThemeConfiguration {
  /// Background color of the PDF viewer area (behind the document pages).
  final Color? backgroundColor;

  /// Color for separator/divider lines throughout the UI.
  final Color? separatorColor;

  /// Theme for the main toolbar (navigation/action bar).
  final ToolbarTheme? toolbar;

  /// Theme for the annotation toolbar (contextual toolbar for annotation creation/editing).
  final AnnotationToolbarTheme? annotationToolbar;

  /// Theme for navigation tabs (outline, bookmarks, thumbnails panels).
  final NavigationTabTheme? navigationTab;

  /// Theme for the search UI.
  final SearchTheme? search;

  /// Theme for the thumbnail bar.
  final ThumbnailBarTheme? thumbnailBar;

  /// Theme for text and annotation selection.
  final SelectionTheme? selection;

  /// Theme for dialogs and modals.
  final ViewerDialogTheme? dialog;

  const ThemeConfiguration({
    this.backgroundColor,
    this.separatorColor,
    this.toolbar,
    this.annotationToolbar,
    this.navigationTab,
    this.search,
    this.thumbnailBar,
    this.selection,
    this.dialog,
  });

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor?.toHex(),
      'separatorColor': separatorColor?.toHex(),
      'toolbar': toolbar?.toMap(),
      'annotationToolbar': annotationToolbar?.toMap(),
      'navigationTab': navigationTab?.toMap(),
      'search': search?.toMap(),
      'thumbnailBar': thumbnailBar?.toMap(),
      'selection': selection?.toMap(),
      'dialog': dialog?.toMap(),
    }..removeWhere((key, value) => value == null);
  }
}
