///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Web implementation of [PdfConfigurationBuilder].
///
/// Converts a [NutrientViewConfiguration] (and its optional [webConfig]
/// sub-object) into a `Map<String, dynamic>` suitable for merging into the
/// `PSPDFKit.load()` configuration object.
///
/// [webConfig] must be a `WebViewConfiguration` instance (from
/// `nutrient_flutter`). It is accepted as `Object?` to avoid a circular
/// dependency between `nutrient_flutter_web` and `nutrient_flutter`.
///
/// **View-state vs. top-level keys:**
/// Properties that belong to `PSPDFKit.ViewState` are nested under the
/// `initialViewState` key; all other properties are placed at the top level.
class WebConfigurationBuilder implements PdfConfigurationBuilder {
  /// Builds a web load-config map from a typed [NutrientViewConfiguration].
  ///
  /// [config] provides cross-platform fields.
  /// [config.webConfig] (a `WebViewConfiguration`) provides web-only fields.
  Map<String, dynamic> buildConfig(NutrientViewConfiguration config) {
    final viewState = <String, dynamic>{};
    final topLevel = <String, dynamic>{};

    _applyCrossPlatform(config, viewState, topLevel);
    _applyWebConfig(config.webConfig, viewState, topLevel);

    final result = <String, dynamic>{...topLevel};
    if (viewState.isNotEmpty) result['initialViewState'] = viewState;
    return result;
  }

  /// Satisfies the [PdfConfigurationBuilder] interface (legacy map-based path).
  ///
  /// Prefer [buildConfig] for the typed [NutrientViewConfiguration] path.
  @override
  Map<String, dynamic> buildConfigMap(Map<String, dynamic> configMap) =>
      configMap;

  // ---------------------------------------------------------------------------
  // Cross-platform fields from NutrientViewConfiguration
  // ---------------------------------------------------------------------------

  void _applyCrossPlatform(
    NutrientViewConfiguration config,
    Map<String, dynamic> viewState,
    Map<String, dynamic> topLevel,
  ) {
    // pageLayoutMode → initialViewState.layoutMode
    if (config.pageLayoutMode != null) {
      viewState['layoutMode'] = switch (config.pageLayoutMode!) {
        PageLayoutMode.single => 'SINGLE',
        PageLayoutMode.double => 'DOUBLE',
        PageLayoutMode.automatic => 'AUTOMATIC',
      };
    }

    // pageTransition → initialViewState.scrollMode
    if (config.pageTransition != null) {
      final mode = switch (config.pageTransition!) {
        PageTransition.scrollPerSpread => 'PER_SPREAD',
        PageTransition.scrollContinuous => 'CONTINUOUS',
        PageTransition.disabled => 'DISABLED',
        _ => null,
      };
      if (mode != null) viewState['scrollMode'] = mode;
    }

    // firstPageAlwaysSingle → initialViewState.keepFirstSpreadAsSinglePage
    if (config.firstPageAlwaysSingle != null) {
      viewState['keepFirstSpreadAsSinglePage'] = config.firstPageAlwaysSingle;
    }

    // startPage → initialViewState.currentPageIndex
    if (config.startPage != null) {
      viewState['currentPageIndex'] = config.startPage;
    }

    // userInterfaceViewMode → initialViewState.showToolbar
    if (config.userInterfaceViewMode != null) {
      viewState['showToolbar'] =
          config.userInterfaceViewMode != UserInterfaceViewMode.never;
    }

    // enableAnnotationEditing → initialViewState.readOnly + enableAnnotationToolbar
    if (config.enableAnnotationEditing != null) {
      viewState['readOnly'] = !config.enableAnnotationEditing!;
      viewState['enableAnnotationToolbar'] = config.enableAnnotationEditing;
    }

    // enableFormEditing → top-level disableForms (inverted)
    if (config.enableFormEditing != null) {
      topLevel['disableForms'] = !config.enableFormEditing!;
    }

    // enableTextSelection → top-level disableTextSelection (inverted)
    if (config.enableTextSelection != null) {
      topLevel['disableTextSelection'] = !config.enableTextSelection!;
    }

    // disableAutosave → top-level autoSaveMode
    if (config.disableAutosave == true) topLevel['autoSaveMode'] = 'DISABLED';

    // appearanceMode → top-level theme
    if (config.appearanceMode != null) {
      topLevel['theme'] = switch (config.appearanceMode!) {
        AppearanceMode.night => 'DARK',
        AppearanceMode.defaultMode => 'AUTO',
        AppearanceMode.sepia => 'AUTO', // no direct Web equivalent
        AppearanceMode.allCustomColors => 'AUTO',
      };
    }

    // zoom scales → top-level min/maxDefaultZoomLevel
    if (config.minimumZoomScale != null) {
      topLevel['minDefaultZoomLevel'] = config.minimumZoomScale;
    }
    if (config.maximumZoomScale != null) {
      topLevel['maxDefaultZoomLevel'] = config.maximumZoomScale;
    }
  }

  // ---------------------------------------------------------------------------
  // Web-only fields from WebViewConfiguration (passed as Object? to avoid
  // a circular dependency on nutrient_flutter)
  // ---------------------------------------------------------------------------

  void _applyWebConfig(
    Object? webConfigObj,
    Map<String, dynamic> viewState,
    Map<String, dynamic> topLevel,
  ) {
    if (webConfigObj == null) return;

    // NutrientViewConfiguration.webConfig is typed as Object? to avoid a
    // circular dependency. Callers must pass a WebViewConfiguration whose
    // toBuilderMap() has been pre-called before reaching here — the result
    // is a Map<String, dynamic> with 'viewState' and 'topLevel' keys.
    if (webConfigObj is Map<String, dynamic>) {
      _mergeWebMap(webConfigObj, viewState, topLevel);
    }
  }

  void _mergeWebMap(
    Map<String, dynamic> webMap,
    Map<String, dynamic> viewState,
    Map<String, dynamic> topLevel,
  ) {
    final vs = webMap['viewState'];
    if (vs is Map<String, dynamic>) viewState.addAll(vs);
    final tl = webMap['topLevel'];
    if (tl is Map<String, dynamic>) topLevel.addAll(tl);
  }
}
