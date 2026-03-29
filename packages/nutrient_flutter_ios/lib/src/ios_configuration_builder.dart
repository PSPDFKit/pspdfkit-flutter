///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

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
///
/// Only options with a direct 1-to-1 property in PSPDFConfigurationBuilder are
/// translated. Complex options (toolbar items, annotation menus, theme colours,
/// measurement tools) are not handled here.
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

    return result;
  }

  /// Satisfies the [PdfConfigurationBuilder] interface (map-based path).
  ///
  /// Prefer [buildConfig] for the typed [NutrientViewConfiguration] path.
  @override
  Map<String, dynamic> buildConfigMap(Map<String, dynamic> configMap) =>
      configMap;

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
}
