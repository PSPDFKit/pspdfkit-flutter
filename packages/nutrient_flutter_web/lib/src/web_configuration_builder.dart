///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'generated/nutrient_web_bindings.g.dart' as nutrient_web;
import 'utils/namespace_utils.dart';
import 'utils/signature_web_mapping.dart';

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
      // Web SDK LayoutMode is SINGLE / DOUBLE / AUTO (there is no
      // "AUTOMATIC" — passing it makes the Web SDK reject the load config and
      // the viewer fails to initialize).
      viewState['layoutMode'] = switch (config.pageLayoutMode!) {
        PageLayoutMode.single => 'SINGLE',
        PageLayoutMode.double => 'DOUBLE',
        PageLayoutMode.automatic => 'AUTO',
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

    // password → top-level password (passed directly to PSPDFKit.load())
    if (config.password != null && config.password!.isNotEmpty) {
      topLevel['password'] = config.password;
    }

    // signatureSavingStrategy: NOT supported on Web. The Web SDK has no
    // equivalent "save the signature the user just drew" toggle — signature
    // persistence is entirely app-managed via the stored-signatures API
    // (`instance.getStoredSignatures()` / your own storage backend), so
    // there's nothing to map this onto. Silently ignored, per the
    // cross-platform doc comment on `NutrientViewConfiguration`.

    // signatureCreationConfiguration → top-level electronicSignatures
    //
    // Precedence: this sets `topLevel['electronicSignatures']` from the
    // typed config. `_applyWebConfig` runs after `_applyCrossPlatform` (see
    // `buildConfig`) and merges the legacy free-form
    // `WebViewConfiguration.electronicSignatures` pass-through via
    // `topLevel.addAll(...)`, which overwrites this key wholesale if the
    // caller also set it there. So an explicit `webConfig.electronicSignatures`
    // always wins over the typed `signatureCreationConfiguration` — same
    // "webConfig overrides typed cross-platform fields" precedence every
    // other key in this builder already follows. There is no per-field merge
    // between the two (e.g. typed `fonts` + legacy `colorPresets`); it's
    // whole-object replacement, so mixing both configuration styles for
    // signatures on the same view is not supported.
    if (config.signatureCreationConfiguration != null) {
      topLevel['electronicSignatures'] = _buildElectronicSignatures(
        config.signatureCreationConfiguration!,
      );
    }
  }

  /// Converts [SignatureCreationConfiguration] into a Web SDK
  /// `ElectronicSignaturesConfiguration` instance for
  /// `PSPDFKit.load({ electronicSignatures })`.
  ///
  /// `iosSignatureAspectRatio` and `androidSignatureOrientation` are
  /// other-platform-only options and are ignored here.
  nutrient_web.ElectronicSignaturesConfiguration _buildElectronicSignatures(
    SignatureCreationConfiguration config,
  ) {
    // The generated constructor declares `creationModes`/`fonts`/
    // `colorPresets` as non-nullable JSAny params (they're optional named
    // params, just not nullable), so build the instance first and only
    // assign the fields that are actually present.
    final result = nutrient_web.ElectronicSignaturesConfiguration();

    final creationModes = config.creationModes;
    if (creationModes != null) {
      result.creationModes = creationModes.map(_webCreationMode).toList().toJS;
    }

    final colorOptions = config.colorOptions;
    if (colorOptions != null) {
      result.colorPresets = _buildColorPresets(colorOptions);
    }

    final fonts = config.fonts;
    if (fonts != null) {
      result.fonts = fonts.map(_buildFont).toList().toJS;
    }

    return result;
  }

  /// Maps a [SignatureCreationMode] to the matching
  /// `NutrientViewer.ElectronicSignatureCreationMode` value.
  ///
  /// Prefers the live namespace constant (`NutrientViewer
  /// .ElectronicSignatureCreationMode.DRAW`, etc.) and falls back to the
  /// stable string id (see [webCreationModeString]) if the namespace lookup
  /// fails for some reason (e.g. SDK not yet loaded).
  JSAny _webCreationMode(SignatureCreationMode mode) {
    final modes = NutrientNamespace.getAsJSObject()
        .getProperty<nutrient_web.AnonymousType_4840901?>(
            'ElectronicSignatureCreationMode'.toJS);
    final value = switch (mode) {
      SignatureCreationMode.draw => modes?.DRAW,
      SignatureCreationMode.image => modes?.IMAGE,
      SignatureCreationMode.type => modes?.TYPE,
    };
    return (value ?? webCreationModeString(mode)).toJS;
  }

  /// Builds the 3-entry `colorPresets` array from [SignatureColorOptions].
  JSArray<nutrient_web.ColorPreset> _buildColorPresets(
    SignatureColorOptions options,
  ) {
    return buildColorPresetShapes(options).map(_buildColorPreset).toList().toJS;
  }

  /// Builds a single Web SDK `ColorPreset` from its pure-Dart
  /// [WebColorPresetShape] (see `signature_web_mapping.dart` for how the
  /// shape — including the `localization.id` fallback — is derived).
  nutrient_web.ColorPreset _buildColorPreset(WebColorPresetShape shape) {
    final localization =
        nutrient_web.AnonymousType_2569150(id: shape.localizationId);
    if (shape.defaultMessage != null) {
      localization.defaultMessage = shape.defaultMessage;
    }
    if (shape.description != null) {
      localization.description = shape.description;
    }

    return nutrient_web.ColorPreset(
      color: _construct<nutrient_web.Color>(
        'Color',
        nutrient_web.AnonymousType_2777951(
          r: shape.r.toDouble(),
          g: shape.g.toDouble(),
          b: shape.b.toDouble(),
        ),
      ),
      localization: localization,
    );
  }

  /// Builds a Web SDK `Font` instance from a font family name.
  nutrient_web.Font _buildFont(String name) {
    return _construct<nutrient_web.Font>(
      'Font',
      nutrient_web.AnonymousType_1170366(name: name),
    );
  }

  /// Constructs a Web SDK class (e.g. `Color`, `Font`) by resolving its
  /// constructor off the `NutrientViewer` / `PSPDFKit` namespace at runtime.
  ///
  /// The generated `nutrient_web.Color(...)` / `nutrient_web.Font(...)`
  /// constructors are bound to a *global* `Color` / `Font` (`@JS('Color')`),
  /// which the Web SDK does not expose — these classes live only on the
  /// namespace object. Invoking the global binding throws
  /// `TypeError: Color is not a constructor`, so we look the constructor up on
  /// the namespace and `new` it, mirroring how [_webCreationMode] resolves
  /// `ElectronicSignatureCreationMode`.
  T _construct<T extends JSObject>(String className, JSAny arg) {
    final ctor = NutrientNamespace.getAsJSObject()
        .getProperty<JSFunction>(className.toJS);
    return ctor.callAsConstructor<T>(arg);
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
