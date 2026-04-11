///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'bindings/nutrient_android_sdk_bindings.dart'
    hide Nutrient, PageLayoutMode, ThumbnailBarMode, UserInterfaceViewMode;
import 'bindings/nutrient_android_sdk_bindings.dart' as jni;

/// Android implementation of [PdfConfigurationBuilder].
///
/// Converts a [NutrientViewConfiguration] into a native
/// [PdfActivityConfiguration] via [PdfActivityConfiguration$Builder] JNI
/// bindings. Call [build] to obtain the native object, then pass it to
/// [InstantPdfUiFragmentBuilder.configuration] or
/// [PdfUiFragmentBuilder.configuration].
///
/// The caller is responsible for releasing the returned object with
/// `.release()` once it has been passed to the fragment builder.
class AndroidConfigurationBuilder {
  /// Builds a [PdfActivityConfiguration] from [config] using [context].
  ///
  /// Returns `null` when [config] has no fields set.
  PdfActivityConfiguration? build(
    NutrientViewConfiguration config,
    Context context,
  ) {
    final builder = PdfActivityConfiguration$Builder(context);
    try {
      _applyScrollDirection(builder, config);
      _applyPageTransition(builder, config);
      _applyLayoutMode(builder, config);
      _applyThemeMode(builder, config);
      _applyThumbnailBarMode(builder, config);
      _applyUserInterfaceViewMode(builder, config);
      _applyBooleans(builder, config);
      _applyAndroidConfig(builder, config.androidConfig);
      return builder.build();
    } finally {
      builder.release();
    }
  }

  // ---------------------------------------------------------------------------
  // Cross-platform properties
  // ---------------------------------------------------------------------------

  void _applyScrollDirection(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    if (config.scrollDirection == null) return;
    final direction = _toScrollDirection(config.scrollDirection!);
    if (direction != null) {
      builder.scrollDirection(direction);
      direction.release();
    }
  }

  void _applyPageTransition(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    // Flutter PageTransition maps to Android PageScrollMode
    if (config.pageTransition == null) return;
    final mode = _toScrollMode(config.pageTransition!);
    if (mode != null) {
      builder.scrollMode(mode);
      mode.release();
    }
  }

  void _applyLayoutMode(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    if (config.pageLayoutMode == null) return;
    final mode = _toLayoutMode(config.pageLayoutMode!);
    if (mode != null) {
      builder.layoutMode(mode);
      mode.release();
    }
  }

  void _applyThemeMode(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    // Top-level appearanceMode takes precedence; androidConfig can override.
    final appearance =
        config.androidConfig?.appearanceMode ?? config.appearanceMode;
    if (appearance == null) return;
    final mode = _toThemeMode(appearance);
    if (mode != null) {
      builder.themeMode(mode);
      mode.release();
    }
  }

  void _applyThumbnailBarMode(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    final tbm =
        config.androidConfig?.thumbnailBarMode ?? config.thumbnailBarMode;
    if (tbm == null) return;
    final mode = _toThumbnailBarMode(tbm);
    if (mode != null) {
      builder.setThumbnailBarMode(mode);
      mode.release();
    }
  }

  void _applyUserInterfaceViewMode(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    if (config.userInterfaceViewMode == null) return;
    final mode = _toUserInterfaceViewMode(config.userInterfaceViewMode!);
    if (mode != null) {
      builder.setUserInterfaceViewMode(mode);
      mode.release();
    }
  }

  void _applyBooleans(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    if (config.firstPageAlwaysSingle != null) {
      builder.firstPageAlwaysSingle(config.firstPageAlwaysSingle!);
    }
    if (config.enableTextSelection != null) {
      builder.textSelectionEnabled(config.enableTextSelection!);
    }
    if (config.enableAnnotationEditing != null) {
      builder.annotationEditingEnabled(config.enableAnnotationEditing!);
    }
    if (config.enableFormEditing != null) {
      builder.formEditingEnabled(config.enableFormEditing!);
    }
    if (config.disableAutosave != null) {
      builder.autosaveEnabled(!config.disableAutosave!);
    }
  }

  // ---------------------------------------------------------------------------
  // Android-specific properties
  // ---------------------------------------------------------------------------

  void _applyAndroidConfig(
    PdfActivityConfiguration$Builder builder,
    AndroidViewConfiguration? android,
  ) {
    if (android == null) return;

    if (android.grayScale != null) builder.toGrayscale(android.grayScale!);
    if (android.showPageLabels != null) {
      builder.pageLabelsEnabled(android.showPageLabels!);
    }
    if (android.documentLabelEnabled != null) {
      builder.documentTitleOverlayEnabled(android.documentLabelEnabled!);
    }
    if (android.inlineSearch != null) {
      // Android does not have a direct inlineSearch setter; search mode is
      // controlled by the toolbar. No-op here — kept for API completeness.
    }
    if (android.showActionNavigationButtons != null) {
      builder.navigationButtonsEnabled(android.showActionNavigationButtons!);
    }
    if (android.showSearchAction != null) {
      builder.searchEnabled(android.showSearchAction!);
    }
    if (android.showOutlineAction != null) {
      builder.outlineEnabled(android.showOutlineAction!);
    }
    if (android.showBookmarksAction != null) {
      builder.bookmarkListEnabled(android.showBookmarksAction!);
    }
    if (android.showAnnotationListAction != null) {
      builder.annotationListEnabled(android.showAnnotationListAction!);
    }
    if (android.showThumbnailGridAction != null) {
      builder.thumbnailGridEnabled(android.showThumbnailGridAction!);
    }
    if (android.showPrintAction != null) {
      builder.printingEnabled(android.showPrintAction!);
    }
    if (android.enableDocumentEditor != null) {
      builder.documentEditorEnabled(android.enableDocumentEditor!);
    }
    if (android.contentEditorEnabled != null) {
      builder.contentEditingEnabled(android.contentEditorEnabled!);
    }
  }

  // ---------------------------------------------------------------------------
  // Enum helpers — map shared enums to Android JNI enum constants
  // ---------------------------------------------------------------------------

  PageScrollDirection? _toScrollDirection(ScrollDirection d) => switch (d) {
        ScrollDirection.horizontal => PageScrollDirection.HORIZONTAL,
        ScrollDirection.vertical => PageScrollDirection.VERTICAL,
      };

  /// Flutter [PageTransition] maps to Android [PageScrollMode].
  PageScrollMode? _toScrollMode(PageTransition t) => switch (t) {
        PageTransition.scrollPerSpread => PageScrollMode.PER_PAGE,
        PageTransition.scrollContinuous => PageScrollMode.CONTINUOUS,
        _ => null,
      };

  jni.PageLayoutMode? _toLayoutMode(PageLayoutMode m) => switch (m) {
        PageLayoutMode.single => jni.PageLayoutMode.SINGLE,
        PageLayoutMode.double => jni.PageLayoutMode.DOUBLE,
        PageLayoutMode.automatic => jni.PageLayoutMode.AUTO,
      };

  ThemeMode? _toThemeMode(AppearanceMode m) => switch (m) {
        AppearanceMode.night => ThemeMode.NIGHT,
        AppearanceMode.defaultMode => ThemeMode.DEFAULT,
        _ => null,
      };

  /// Maps the shared [ThumbnailBarMode] to the Android [ThumbnailBarMode] JNI
  /// constant.
  ///
  /// Android has: FLOATING, PINNED, SCROLLABLE, NONE.
  /// The shared `scrubberBar` and `defaultStyle` values fall back to PINNED
  /// as the closest Android equivalent.
  jni.ThumbnailBarMode? _toThumbnailBarMode(ThumbnailBarMode m) => switch (m) {
        ThumbnailBarMode.floating =>
          jni.ThumbnailBarMode.THUMBNAIL_BAR_MODE_FLOATING,
        ThumbnailBarMode.pinned =>
          jni.ThumbnailBarMode.THUMBNAIL_BAR_MODE_PINNED,
        ThumbnailBarMode.scrollable =>
          jni.ThumbnailBarMode.THUMBNAIL_BAR_MODE_SCROLLABLE,
        ThumbnailBarMode.none => jni.ThumbnailBarMode.THUMBNAIL_BAR_MODE_NONE,
        ThumbnailBarMode.scrubberBar =>
          jni.ThumbnailBarMode.THUMBNAIL_BAR_MODE_PINNED,
        ThumbnailBarMode.defaultStyle =>
          jni.ThumbnailBarMode.THUMBNAIL_BAR_MODE_FLOATING,
      };

  jni.UserInterfaceViewMode? _toUserInterfaceViewMode(
          UserInterfaceViewMode m) =>
      switch (m) {
        UserInterfaceViewMode.automatic =>
          jni.UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_AUTOMATIC,
        UserInterfaceViewMode.automaticNoFirstLastPage => jni
            .UserInterfaceViewMode
            .USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES,
        UserInterfaceViewMode.always =>
          jni.UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_VISIBLE,
        UserInterfaceViewMode.never =>
          jni.UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_HIDDEN,
      };
}
