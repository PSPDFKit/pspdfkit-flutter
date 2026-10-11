///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert' show jsonEncode, utf8;
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi_pkg;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'bindings/nutrient_ios_bindings.dart';

/// iOS implementation of [PdfConfigurationBuilder].
///
/// Converts a [NutrientViewConfiguration] into an iOS-specific
/// `Map<String, dynamic>` whose keys match [PSPDFConfigurationBuilder]
/// properties. The map is JSON-encoded and forwarded to the native
/// `nutrient_create_instant_view_controller_with_config` C function, which
/// applies the values via a `PSPDFConfigurationBuilder` block.
///
/// Integer values for ObjC enums are the raw ordinals from
/// `PSPDFConfiguration.h` (PSPDFKitUI.xcframework):
///
/// | Enum | Values |
/// |------|--------|
/// | PSPDFScrollDirection | Horizontal=0, Vertical=1 |
/// | PSPDFPageMode | Single=0, Double=1, Automatic=2 |
/// | PSPDFPageTransition | ScrollPerSpread=0, ScrollContinuous=1, Curl=2 |
/// | PSPDFConfigurationSpreadFitting | Fit=0, Fill=1, Adaptive=2 |
/// | PSPDFPageBookmarkIndicatorMode | Off=0, AlwaysOn=1, OnWhenBookmarked=2 |
/// | PSPDFThumbnailBarMode | None=0, ScrubberBar=1, Scrollable=2, FloatingScrubberBar=3 |
/// | PSPDFUserInterfaceViewMode | Always=0, Automatic=1, AutomaticNoFirstLastPage=2, Never=3 |
/// | PSPDFSearchMode | Modal=0, Inline=1 |
/// | PSPDFSignatureSavingStrategy | AlwaysSave=0, NeverSave=1, SaveIfSelected=2 |
///
/// Only options with a direct 1-to-1 property in PSPDFConfigurationBuilder are
/// translated. Complex options (toolbar items, annotation menus, theme colours,
/// measurement tools) are not handled here.
///
/// Two exceptions ride along in the JSON map instead of mapping to a builder
/// property:
///
/// - `fileConflictResolution` has no `PSPDFConfigurationBuilder` property at
///   all (conflict resolution is a runtime, per-`PDFViewController` concern —
///   see `IOSViewConfiguration.fileConflictResolution`'s doc comment). It is
///   encoded as a string (`close`/`save`/`reload`; absent for
///   `defaultBehavior`) but consumed separately, by
///   `nutrient_register_file_conflict_resolution` after the view controller
///   exists, not by `applyToBuilder`/`nutrient_apply_config_dict`.
/// - `signatureCreationConfiguration` is forwarded as a raw nested map (same
///   pattern as `aiAssistantConfiguration`) rather than applied via a typed
///   setter here, because building it requires constructing `UIColor`/`UIFont`
///   instances that the generated FFI bindings don't expose designated
///   initializers for. See
///   `nutrient_apply_signature_creation_configuration` in `NutrientFFI.mm`
///   (mirrors the legacy `SignatureHelper.swift` mapping) for the native side.
class IOSConfigurationBuilder implements PdfConfigurationBuilder {
  /// Builds an iOS-specific config map from [config] for JSON encoding.
  ///
  /// Returns an empty map when no applicable fields are set.
  Map<String, dynamic> buildConfig(NutrientViewConfiguration config) {
    final result = <String, dynamic>{};

    _applyScrollDirection(config, result);
    _applyPageMode(config, result);
    _applyPageTransition(config, result);
    _applyThumbnailBarMode(config, result);
    _applyUserInterfaceViewMode(config, result);
    _applyBooleans(config, result);
    _applyZoom(config, result);
    _applyIOSConfig(config.iosConfig, result);
    _applySignatureOptions(config, result);
    // Forward AI Assistant config so NutrientFFI can build an
    // AIAssistantConfiguration and assign it to the PDFConfigurationBuilder.
    // Shape matches AIAssistantConfiguration.toMap() in nutrient_flutter.
    final aiAssistant = config.aiAssistantConfiguration;
    if (aiAssistant != null) {
      result['aiAssistantConfiguration'] = aiAssistant;
    }

    return result;
  }

  /// Satisfies the [PdfConfigurationBuilder] interface (map-based path).
  ///
  /// Prefer [buildConfig] for the typed [NutrientViewConfiguration] path.
  @override
  Map<String, dynamic> buildConfigMap(Map<String, dynamic> configMap) =>
      configMap;

  /// Applies [config] directly to a [PSPDFConfigurationBuilder] via ObjC
  /// setters. Use this inside `PSPDFConfiguration.configurationWithBuilder`
  /// blocks where the builder is available as an FFI object, rather than the
  /// JSON path used by Instant factory functions.
  ///
  /// Only properties with direct setters on [PSPDFConfigurationBuilder] are
  /// applied. Keys without Dart bindings (e.g. `bookmarkIndicatorMode`,
  /// `showBackActionButton`) are silently skipped.
  void applyToBuilder(
    PSPDFConfigurationBuilder builder,
    NutrientViewConfiguration config,
  ) {
    final map = buildConfig(config);

    final scrollDir = map['scrollDirection'];
    if (scrollDir is int) {
      builder.scrollDirection = PSPDFScrollDirection.fromValue(scrollDir);
    }

    final pageMode = map['pageMode'];
    if (pageMode is int) {
      builder.pageMode = PSPDFPageMode.fromValue(pageMode);
    }

    final pageTransition = map['pageTransition'];
    if (pageTransition is int) {
      builder.pageTransition = PSPDFPageTransition.fromValue(pageTransition);
    }

    final spreadFitting = map['spreadFitting'];
    if (spreadFitting is int) {
      builder.spreadFitting = PSPDFConfigurationSpreadFitting.fromValue(
        spreadFitting,
      );
    }

    final thumbnailBarMode = map['thumbnailBarMode'];
    if (thumbnailBarMode is int) {
      builder.thumbnailBarMode = PSPDFThumbnailBarMode.fromValue(
        thumbnailBarMode,
      );
    }

    final uiViewMode = map['userInterfaceViewMode'];
    if (uiViewMode is int) {
      builder.userInterfaceViewMode = PSPDFUserInterfaceViewMode.fromValue(
        uiViewMode,
      );
    }

    final firstPageAlwaysSingle = map['firstPageAlwaysSingle'];
    if (firstPageAlwaysSingle is bool) {
      builder.isFirstPageAlwaysSingle = firstPageAlwaysSingle;
    }

    final textSelectionEnabled = map['textSelectionEnabled'];
    if (textSelectionEnabled is bool) {
      builder.isTextSelectionEnabled = textSelectionEnabled;
    }

    final autosaveEnabled = map['autosaveEnabled'];
    if (autosaveEnabled is bool) {
      builder.isAutosaveEnabled = autosaveEnabled;
    }

    final createAnnotationMenuEnabled = map['isCreateAnnotationMenuEnabled'];
    if (createAnnotationMenuEnabled is bool) {
      builder.isCreateAnnotationMenuEnabled = createAnnotationMenuEnabled;
    }

    final pageLabelEnabled = map['pageLabelEnabled'];
    if (pageLabelEnabled is bool) {
      builder.isPageLabelEnabled = pageLabelEnabled;
    }

    final minZoom = map['minimumZoomScale'];
    if (minZoom is num) {
      builder.minimumZoomScale = minZoom.toDouble();
    }

    final maxZoom = map['maximumZoomScale'];
    if (maxZoom is num) {
      builder.maximumZoomScale = maxZoom.toDouble();
    }

    final signatureSavingStrategy = map['signatureSavingStrategy'];
    if (signatureSavingStrategy is int) {
      final strategy = PSPDFSignatureSavingStrategy.fromValue(
        signatureSavingStrategy,
      );
      builder.signatureSavingStrategy = strategy;
      // A `signatureStore` is required for `alwaysSave` / `saveIfSelected` to
      // actually persist anything — `PSPDFConfigurationBuilder.signatureStore`
      // defaults to nil when Electronic Signatures licensing is active (see
      // the property doc-comment in the generated bindings), so saving would
      // silently no-op without one. Install the on-device keychain store only
      // when the strategy calls for saving, rather than unconditionally
      // whenever the key is present — the legacy `PspdfPlatformView.m` path
      // installs `PSPDFKeychainSignatureStore` any time
      // `signatureSavingStrategy` is set at all (even for `neverSave`), which
      // pointlessly persists a store no strategy value asks for.
      if (strategy !=
          PSPDFSignatureSavingStrategy.PSPDFSignatureSavingStrategyNeverSave) {
        builder.signatureStore = PSPDFKeychainSignatureStore.new$();
      }
    }

    final signatureCreationConfiguration =
        map['signatureCreationConfiguration'];
    if (signatureCreationConfiguration is Map) {
      // Colors/fonts require constructing UIColor/UIFont instances, which
      // aren't reachable from the generated FFI bindings (no
      // colorWithRed:green:blue:alpha: / fontWithName:size: wrapper is
      // generated for either class) — delegate to the native helper instead,
      // same rationale as aiAssistantConfiguration above.
      final jsonPtr = _toCString(jsonEncode(signatureCreationConfiguration));
      final builderPtr = builder.ref.pointer.cast<ffi.Void>();
      nutrient_apply_signature_creation_configuration(builderPtr, jsonPtr);
      ffi_pkg.calloc.free(jsonPtr);
    }
  }

  /// Converts a Dart [String] to a heap-allocated, null-terminated C string.
  /// Caller owns the returned pointer and must free it with `calloc.free`.
  ffi.Pointer<ffi.Char> _toCString(String s) {
    final bytes = utf8.encode(s);
    final ptr = ffi_pkg.calloc<ffi.Char>(bytes.length + 1);
    for (var i = 0; i < bytes.length; i++) {
      ptr[i] = bytes[i];
    }
    ptr[bytes.length] = 0;
    return ptr;
  }

  // ---------------------------------------------------------------------------
  // Cross-platform properties
  // ---------------------------------------------------------------------------

  void _applyScrollDirection(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    if (config.scrollDirection == null) return;
    // PSPDFScrollDirectionHorizontal=0, PSPDFScrollDirectionVertical=1
    dst['scrollDirection'] = switch (config.scrollDirection!) {
      ScrollDirection.horizontal => 0,
      ScrollDirection.vertical => 1,
    };
  }

  void _applyPageMode(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    if (config.pageLayoutMode == null) return;
    // PSPDFPageModeSingle=0, Double=1, Automatic=2
    dst['pageMode'] = switch (config.pageLayoutMode!) {
      PageLayoutMode.single => 0,
      PageLayoutMode.double => 1,
      PageLayoutMode.automatic => 2,
    };
  }

  void _applyPageTransition(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    if (config.pageTransition == null) return;
    // PSPDFPageTransitionScrollPerSpread=0, ScrollContinuous=1, Curl=2
    final val = switch (config.pageTransition!) {
      PageTransition.scrollPerSpread => 0,
      PageTransition.scrollContinuous => 1,
      PageTransition.curl => 2,
      _ => null,
    };
    if (val != null) dst['pageTransition'] = val;
  }

  void _applyThumbnailBarMode(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    final tbm = config.iosConfig?.thumbnailBarMode ?? config.thumbnailBarMode;
    if (tbm == null) return;
    // PSPDFThumbnailBarModeNone=0, ScrubberBar=1, Scrollable=2, FloatingScrubberBar=3
    dst['thumbnailBarMode'] = _toThumbnailBarModeOrdinal(tbm);
  }

  void _applyUserInterfaceViewMode(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    if (config.userInterfaceViewMode == null) return;
    // PSPDFUserInterfaceViewModeAlways=0, Automatic=1, AutomaticNoFirstLastPage=2, Never=3
    dst['userInterfaceViewMode'] = _toUserInterfaceViewModeOrdinal(
      config.userInterfaceViewMode!,
    );
  }

  void _applyBooleans(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    if (config.firstPageAlwaysSingle != null) {
      dst['firstPageAlwaysSingle'] = config.firstPageAlwaysSingle;
    }
    if (config.enableTextSelection != null) {
      dst['textSelectionEnabled'] = config.enableTextSelection;
    }
    if (config.enableAnnotationEditing != null) {
      dst['isCreateAnnotationMenuEnabled'] = config.enableAnnotationEditing;
    }
    if (config.disableAutosave != null) {
      dst['autosaveEnabled'] = !config.disableAutosave!;
    }
    if (config.enableInstantComments != null) {
      // Picked up post-init in NutrientFFI.mm; not a builder property.
      dst['enableInstantComments'] = config.enableInstantComments;
    }
  }

  void _applyZoom(NutrientViewConfiguration config, Map<String, dynamic> dst) {
    if (config.minimumZoomScale != null) {
      dst['minimumZoomScale'] = config.minimumZoomScale;
    }
    if (config.maximumZoomScale != null) {
      dst['maximumZoomScale'] = config.maximumZoomScale;
    }
  }

  // ---------------------------------------------------------------------------
  // iOS-specific properties
  // ---------------------------------------------------------------------------

  void _applyIOSConfig(IOSViewConfiguration? ios, Map<String, dynamic> dst) {
    if (ios == null) return;

    if (ios.spreadFitting != null) {
      // PSPDFConfigurationSpreadFittingFit=0, Fill=1, Adaptive=2
      dst['spreadFitting'] = switch (ios.spreadFitting!) {
        SpreadFitting.fit => 0,
        SpreadFitting.fill => 1,
        SpreadFitting.adaptive => 2,
      };
    }
    if (ios.showPageLabels != null) {
      dst['pageLabelEnabled'] = ios.showPageLabels;
    }
    if (ios.documentLabelEnabled != null) {
      // PSPDFAdaptiveConditional: NO=0, YES=1, Adaptive=2
      dst['documentLabelEnabled'] = ios.documentLabelEnabled! ? 1 : 0;
    }
    if (ios.inlineSearch != null) {
      // PSPDFSearchModeModal=0, Inline=1
      dst['searchMode'] = ios.inlineSearch! ? 1 : 0;
    }
    if (ios.showActionNavigationButtons != null) {
      dst['showBackActionButton'] = ios.showActionNavigationButtons;
      dst['showForwardActionButton'] = ios.showActionNavigationButtons;
    }
    if (ios.allowToolbarTitleChange != null) {
      dst['allowToolbarTitleChange'] = ios.allowToolbarTitleChange;
    }
    if (ios.bookmarkIndicatorMode != null) {
      // PSPDFPageBookmarkIndicatorModeOff=0, AlwaysOn=1, OnWhenBookmarked=2
      dst['bookmarkIndicatorMode'] = switch (ios.bookmarkIndicatorMode!) {
        IOSBookmarkIndicatorMode.off => 0,
        IOSBookmarkIndicatorMode.alwaysOn => 1,
        IOSBookmarkIndicatorMode.onWhenBookmarked => 2,
      };
    }
    if (ios.bookmarkIndicatorInteractionEnabled != null) {
      dst['bookmarkIndicatorInteractionEnabled'] =
          ios.bookmarkIndicatorInteractionEnabled;
    }
    if (ios.fileConflictResolution != null) {
      // Not a PSPDFConfigurationBuilder property — PDFViewController's
      // conflict-resolution manager is a private, lazily-created property with
      // no public setter (see PSPDFViewController.mm). Serialized as the enum's
      // `.name` string and consumed by NutrientFFI's
      // nutrient_register_file_conflict_resolution, which maps the string to
      // the raw PSPDFFileConflictResolution value and registers an independent
      // notification-based conflict manager (ConflictResolutionCompanion.swift)
      // — mirroring the legacy `PspdfkitFlutterConverter.fileConflictResolution:`
      // string mapping. `defaultBehavior` is included for completeness but the
      // callers key off its absence to skip registration entirely, leaving the
      // SDK's built-in alert UI in place.
      dst['fileConflictResolution'] = ios.fileConflictResolution!.name;
    }
  }

  // ---------------------------------------------------------------------------
  // Signature options
  // ---------------------------------------------------------------------------

  void _applySignatureOptions(
    NutrientViewConfiguration config,
    Map<String, dynamic> dst,
  ) {
    if (config.signatureSavingStrategy != null) {
      // PSPDFSignatureSavingStrategyAlwaysSave=0, NeverSave=1, SaveIfSelected=2
      dst['signatureSavingStrategy'] =
          switch (config.signatureSavingStrategy!) {
            SignatureSavingStrategy.alwaysSave => 0,
            SignatureSavingStrategy.neverSave => 1,
            SignatureSavingStrategy.saveIfSelected => 2,
          };
    }

    // Forwarded as a raw nested map for the native helper to interpret (see
    // the class-level doc comment on why this can't be a typed setter here).
    // `androidSignatureOrientation` is Android-only and is naturally dropped
    // since `toMap()` only includes it when non-null and the native side
    // never reads that key.
    final signatureCreationConfiguration =
        config.signatureCreationConfiguration;
    if (signatureCreationConfiguration != null) {
      dst['signatureCreationConfiguration'] = signatureCreationConfiguration
          .toMap();
    }
  }

  // ---------------------------------------------------------------------------
  // Enum ordinal helpers
  // ---------------------------------------------------------------------------

  int _toThumbnailBarModeOrdinal(ThumbnailBarMode m) => switch (m) {
    ThumbnailBarMode.none => 0,
    // scrubberBar and pinned both map to ScrubberBar (1) on iOS
    ThumbnailBarMode.scrubberBar => 1,
    ThumbnailBarMode.pinned => 1,
    ThumbnailBarMode.scrollable => 2,
    // floating and defaultStyle both map to FloatingScrubberBar (3) on iOS
    ThumbnailBarMode.floating => 3,
    ThumbnailBarMode.defaultStyle => 3,
  };

  int _toUserInterfaceViewModeOrdinal(UserInterfaceViewMode m) => switch (m) {
    UserInterfaceViewMode.always => 0,
    UserInterfaceViewMode.automatic => 1,
    UserInterfaceViewMode.automaticNoFirstLastPage => 2,
    UserInterfaceViewMode.never => 3,
  };

  /// Maps an [IOSFileConflictResolution] to the raw `PSPDFFileConflictResolution`
  /// value expected by `nutrient_register_file_conflict_resolution`
  /// (`PSPDFFileConflictResolution.h`: Close=0, Save=1, Reload=2).
  ///
  /// Returns `null` for [IOSFileConflictResolution.defaultBehavior] (and for any
  /// unrecognized value) — callers should treat `null` as "don't register a
  /// custom conflict manager; leave the SDK's default alert UI in place",
  /// mirroring the legacy `PspdfkitFlutterConverter.fileConflictResolution:`
  /// behavior of returning `nil` for `defaultBehavior`/unknown strings.
  static int? rawFileConflictResolutionValue(IOSFileConflictResolution value) {
    switch (value) {
      case IOSFileConflictResolution.close:
        return 0;
      case IOSFileConflictResolution.save:
        return 1;
      case IOSFileConflictResolution.reload:
        return 2;
      case IOSFileConflictResolution.defaultBehavior:
        return null;
    }
  }
}
