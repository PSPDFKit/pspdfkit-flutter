///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:jni/jni.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'bindings/nutrient_android_sdk_bindings.dart'
    hide
        Nutrient,
        PageLayoutMode,
        ThumbnailBarMode,
        UserInterfaceViewMode,
        SignatureSavingStrategy,
        SignatureCreationMode,
        SignatureColorOptions;
import 'bindings/nutrient_android_sdk_bindings.dart' as jni;
import 'utils/jni_resources.dart';

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
      _applySignatureConfiguration(builder, config);
      _applyAndroidConfig(builder, config.androidConfig, context);
      final built = builder.build();
      if (config.enableInstantComments == true) {
        return _withInstantCommentTools(built, builder);
      }
      return built;
    } finally {
      builder.release();
    }
  }

  /// Adds [INSTANT_COMMENT_MARKER] and [INSTANT_HIGHLIGHT_COMMENT] to the
  /// builder's enabled tools without disturbing the defaults the SDK applied.
  ///
  /// The Android SDK gates the Instant Comment toolbar items behind these two
  /// tools being explicitly listed in [enabledAnnotationTools]. We follow the
  /// same pattern as the legacy `ConfigurationAdapter`: build once to capture
  /// the default tool list, append the comment tools, and rebuild.
  PdfActivityConfiguration _withInstantCommentTools(
    PdfActivityConfiguration built,
    PdfActivityConfiguration$Builder builder,
  ) {
    final pdfConfig = built.configuration;
    try {
      final tools = pdfConfig.enabledAnnotationTools;
      try {
        tools.add(jni.AnnotationTool.INSTANT_COMMENT_MARKER);
        tools.add(jni.AnnotationTool.INSTANT_HIGHLIGHT_COMMENT);
        final next = builder.enabledAnnotationTools(tools);
        next.release();
        return builder.build();
      } finally {
        tools.release();
      }
    } finally {
      pdfConfig.release();
      built.release();
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
    // When the user provides AI Assistant configuration, surface the
    // toolbar button. The Nutrient Android SDK gates the button on
    // `setAiAssistantEnabled(true)`; without it the dialog can be opened
    // programmatically but never via the built-in toolbar entry.
    if (config.aiAssistantConfiguration != null) {
      builder.setAiAssistantEnabled(true);
    }
  }

  /// Applies [NutrientViewConfiguration.signatureSavingStrategy] and
  /// [NutrientViewConfiguration.signatureCreationConfiguration] to [builder].
  ///
  /// `SignatureCreationConfiguration.fonts` has no native Android API (typed
  /// signature fonts are an iOS/Web-only capability) and is intentionally
  /// ignored here. `SignatureCreationConfiguration.iosSignatureAspectRatio` is
  /// iOS-only and is likewise ignored.
  void _applySignatureConfiguration(
    PdfActivityConfiguration$Builder builder,
    NutrientViewConfiguration config,
  ) {
    if (config.signatureSavingStrategy != null) {
      final strategy =
          _toSignatureSavingStrategy(config.signatureSavingStrategy!);
      final next = builder.signatureSavingStrategy(strategy);
      next.release();
      strategy.release();
    }

    final creationConfig = config.signatureCreationConfiguration;
    if (creationConfig == null) return;

    if (creationConfig.creationModes != null) {
      final modes = JArrayList<jni.SignatureCreationMode>();
      final list = modes as JList<jni.SignatureCreationMode>;
      try {
        for (final mode in creationConfig.creationModes!) {
          final native = _toSignatureCreationMode(mode);
          list.add(native);
          native.release();
        }
        final next = builder.signatureCreationModes(list);
        next.release();
      } finally {
        modes.release();
      }
    }

    if (creationConfig.colorOptions != null) {
      final options = _toSignatureColorOptions(creationConfig.colorOptions!);
      if (options != null) {
        final next = builder.signatureColorOptions(options);
        next.release();
        options.release();
      }
    }

    if (creationConfig.androidSignatureOrientation != null) {
      final orientation = _toSignaturePickerOrientation(
        creationConfig.androidSignatureOrientation!,
      );
      final next = builder.setSignaturePickerOrientation(orientation);
      next.release();
      orientation.release();
    }
  }

  // ---------------------------------------------------------------------------
  // Android-specific properties
  // ---------------------------------------------------------------------------

  void _applyAndroidConfig(
    PdfActivityConfiguration$Builder builder,
    AndroidViewConfiguration? android,
    Context context,
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
    _applyThemeResources(builder, android, context);
  }

  /// Resolves [AndroidViewConfiguration.defaultThemeResource] and
  /// [AndroidViewConfiguration.darkThemeResource] from string style-resource
  /// names to integer resource IDs and applies them to [builder].
  ///
  /// Resource names are resolved via `Resources.getIdentifier(name, "style",
  /// packageName)`. When a name cannot be resolved (returns 0), a warning is
  /// logged and that theme is skipped so the SDK default applies instead.
  ///
  /// These theme resources work in combination with [_applyThemeMode]: setting
  /// [AndroidViewConfiguration.darkThemeResource] alongside
  /// [AppearanceMode.night] configures the custom dark-mode theme that the SDK
  /// will use when night mode is active.
  void _applyThemeResources(
    PdfActivityConfiguration$Builder builder,
    AndroidViewConfiguration android,
    Context context,
  ) {
    if (android.defaultThemeResource == null &&
        android.darkThemeResource == null) {
      return;
    }

    final resources = context.resources;
    if (resources == null) {
      debugPrint('[AndroidConfigurationBuilder] getResources() returned null — '
          'cannot resolve theme resources; skipping theme application.');
      return;
    }
    final packageNameJString = context.packageName;
    final packageName = packageNameJString?.toDartString() ?? '';
    packageNameJString?.release();

    try {
      if (android.defaultThemeResource != null) {
        final name = android.defaultThemeResource!;
        final id =
            JniResources.getIdentifier(resources, name, 'style', packageName);
        if (id == 0) {
          debugPrint(
              '[AndroidConfigurationBuilder] Could not resolve defaultThemeResource '
              '"$name" in package "$packageName" — skipping theme(). '
              'Ensure the style is declared in your app\'s res/values/styles.xml.');
        } else {
          builder.theme(id);
        }
      }

      if (android.darkThemeResource != null) {
        final name = android.darkThemeResource!;
        final id =
            JniResources.getIdentifier(resources, name, 'style', packageName);
        if (id == 0) {
          debugPrint(
              '[AndroidConfigurationBuilder] Could not resolve darkThemeResource '
              '"$name" in package "$packageName" — skipping themeDark(). '
              'Ensure the style is declared in your app\'s res/values/styles.xml.');
        } else {
          builder.themeDark(id);
        }
      }
    } finally {
      resources.release();
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

  /// The returned reference must be released by the caller.
  jni.SignatureSavingStrategy _toSignatureSavingStrategy(
          SignatureSavingStrategy s) =>
      switch (s) {
        SignatureSavingStrategy.alwaysSave =>
          jni.SignatureSavingStrategy.ALWAYS_SAVE,
        SignatureSavingStrategy.saveIfSelected =>
          jni.SignatureSavingStrategy.SAVE_IF_SELECTED,
        SignatureSavingStrategy.neverSave =>
          jni.SignatureSavingStrategy.NEVER_SAVE,
      };

  /// The returned reference must be released by the caller.
  jni.SignatureCreationMode _toSignatureCreationMode(SignatureCreationMode m) =>
      switch (m) {
        SignatureCreationMode.draw => jni.SignatureCreationMode.DRAW,
        SignatureCreationMode.image => jni.SignatureCreationMode.IMAGE,
        SignatureCreationMode.type => jni.SignatureCreationMode.TYPE,
      };

  /// Converts the three Flutter [Color] presets to a native
  /// `SignatureColorOptions` via the `fromColorInt(int, int, int)` factory.
  ///
  /// Returns `null` (rather than throwing) if the native factory call fails
  /// to produce an object, matching this file's null-safe style for optional
  /// JNI results.
  ///
  /// The returned reference must be released by the caller.
  jni.SignatureColorOptions? _toSignatureColorOptions(
    SignatureColorOptions options,
  ) {
    return jni.SignatureColorOptions.fromColorInt(
      options.option1.color.toARGB32(),
      options.option2.color.toARGB32(),
      options.option3.color.toARGB32(),
    );
  }

  /// The returned reference must be released by the caller.
  SignaturePickerOrientation _toSignaturePickerOrientation(
          NutrientAndroidSignatureOrientation o) =>
      switch (o) {
        NutrientAndroidSignatureOrientation.portrait =>
          SignaturePickerOrientation.LOCKED_PORTRAIT,
        NutrientAndroidSignatureOrientation.landscape =>
          SignaturePickerOrientation.LOCKED_LANDSCAPE,
        NutrientAndroidSignatureOrientation.automatic =>
          SignaturePickerOrientation.AUTOMATIC,
        NutrientAndroidSignatureOrientation.unlocked =>
          SignaturePickerOrientation.UNLOCKED,
      };
}
