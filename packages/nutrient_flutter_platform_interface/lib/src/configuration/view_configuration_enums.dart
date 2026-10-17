///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Enums shared across Android, iOS, and Web that are used by
/// [NutrientViewConfiguration] and its platform sub-configurations.

/// The direction in which pages are scrolled.
///
/// Applies to both the horizontal swipe gesture and the continuous-scroll
/// layout. Combine with [PageTransition] for precise control over how users
/// move through the document.
///
/// Platform availability:
/// - Android: supported via `PdfActivityConfiguration$Builder.scrollDirection`.
/// - iOS: supported via `PSPDFConfigurationBuilder.scrollDirection`.
/// - Web: supported via `initialViewState.scrollMode` (`HORIZONTAL` / `VERTICAL`).
enum ScrollDirection {
  /// Pages scroll left and right (the default for most readers).
  horizontal,

  /// Pages scroll up and down, similar to a long web page.
  vertical,
}

/// Page layout mode — single page, double-page spread, or automatic.
///
/// Controls how many pages are shown side-by-side in the viewport.
///
/// Platform availability:
/// - Android: supported via `PdfActivityConfiguration$Builder.layoutMode`.
/// - iOS: supported via `PSPDFConfigurationBuilder.pageMode`.
/// - Web: supported via the `pageLayout` load option. Use [PageLayoutModeWebName.webName]
///   to convert a value to the Web SDK string (`'SINGLE'`, `'DOUBLE'`, `'AUTOMATIC'`).
enum PageLayoutMode {
  /// Display one page at a time.
  single,

  /// Display two pages side-by-side (book/magazine spread view).
  double,

  /// Let the SDK decide based on screen width and orientation.
  automatic,
}

/// The page transition animation used when changing pages.
///
/// Not all transitions are supported on every platform. Unsupported values
/// silently fall back to the platform default.
///
/// Platform availability:
/// - Android: maps to `PdfActivityConfiguration$Builder.pageTransition`.
/// - iOS: maps to `PSPDFConfigurationBuilder.pageTransition`.
/// - Web: a subset of values is mapped via [PageTransitionWebName.webName].
///   Only [scrollContinuous], [scrollPerSpread], and [disabled] produce
///   distinct Web SDK values (`'CONTINUOUS'`, `'PER_SPREAD'`, `'DISABLED'`);
///   all other values fall back to `'PER_SPREAD'`.
enum PageTransition {
  /// Continuous scroll — pages flow together without a visible gap.
  scrollContinuous,

  /// Scroll one spread at a time, snapping between page boundaries.
  scrollPerSpread,

  /// Curl animation that mimics turning a physical page (iOS only).
  curl,

  /// Slide the new page in from the right/left.
  slideHorizontal,

  /// Slide the new page in from the top/bottom.
  slideVertical,

  /// Cover animation — new page slides over the existing one.
  cover,

  /// Cross-fade between pages.
  fade,

  /// Continuous scroll but advancing one page at a time.
  scrollContinuousPerPage,

  /// Let the SDK choose the transition automatically.
  auto,

  /// No animation — pages switch instantly.
  disabled,
}

/// How a page spread is fitted into the available viewport.
///
/// Controls whether pages are letterboxed, cropped to fill, or use an
/// adaptive algorithm that selects the best strategy per spread.
///
/// Platform availability:
/// - Android: not exposed; Android always uses a fit-within-width strategy.
/// - iOS: supported via `PSPDFConfigurationBuilder.spreadFitting`.
///   Use [IOSViewConfiguration.spreadFitting] to set this option.
/// - Web: partially supported; pass via [WebViewConfiguration] as needed.
enum SpreadFitting {
  /// Scale the spread to fit entirely within the viewport (letterbox).
  ///
  /// The full page is always visible, but there may be empty space around it.
  fit,

  /// Scale and crop the spread to fill the viewport edge-to-edge.
  ///
  /// No empty space is shown, but parts of the page may be clipped.
  fill,

  /// Let the SDK automatically choose between [fit] and [fill] per spread.
  ///
  /// Typically selects [fill] for portrait single pages and [fit] for
  /// landscape or double-page spreads.
  adaptive,
}

/// Controls when the viewer toolbar and overlays are shown.
///
/// Platform availability:
/// - Android: maps to `PdfActivityConfiguration$Builder.userInterfaceViewMode`.
/// - iOS: maps to `PSPDFConfigurationBuilder.userInterfaceViewMode`.
/// - Web: only [always] and [never] have a direct equivalent
///   (`initialViewState.showToolbar`). Prefer [WebViewConfiguration.showToolbar]
///   for finer-grained web control.
enum UserInterfaceViewMode {
  /// Show or hide the UI automatically based on user interaction.
  ///
  /// The toolbar and overlays appear when the user taps the document and
  /// hide after a short idle period.
  automatic,

  /// Always keep the toolbar and overlays visible.
  always,

  /// Automatic visibility, but the UI remains visible on the first and last page.
  automaticNoFirstLastPage,

  /// Never show the UI (full immersive / kiosk mode).
  never,
}

/// The appearance (colour scheme) of the viewer.
///
/// Platform availability:
/// - Android: maps to `PdfActivityConfiguration$Builder.themeMode`
///   (`LIGHT`, `DARK`, `DEFAULT`).
/// - iOS: appearance is applied through the platform adapter rather than the
///   configuration builder.
/// - Web: maps to the `theme` load option. Use [AppearanceModeWebName.webName]
///   to convert; only [night] maps to `'DARK'` — all other values map to `'LIGHT'`.
enum AppearanceMode {
  /// System or SDK default appearance (follows the device theme where possible).
  defaultMode,

  /// Sepia-tinted paper-like appearance.
  ///
  /// On Web there is no native sepia theme — this value maps to `'LIGHT'`.
  sepia,

  /// Dark / night-mode appearance with a dark background.
  ///
  /// On Web maps to `'DARK'`.
  night,

  /// Full custom colour scheme (advanced use; requires additional SDK
  /// configuration to define the exact colours).
  ///
  /// On Web there is no equivalent — this value maps to `'LIGHT'`.
  allCustomColors,
}

/// Where and how the thumbnail bar is displayed.
///
/// The exact visual presentation differs between platforms. Android and iOS map
/// the shared values to their respective native enums via helper functions
/// inside each platform builder.
///
/// Platform availability:
/// - Android: maps to `ThumbnailBarMode` in `PdfActivityConfiguration`.
/// - iOS: maps to `PSPDFThumbnailBarMode` in `PSPDFConfiguration`.
/// - Web: not directly supported; configure via [WebViewConfiguration] if
///   thumbnail visibility needs to be controlled on the web.
enum ThumbnailBarMode {
  /// Do not show a thumbnail bar.
  none,

  /// Use the platform's default thumbnail bar style.
  defaultStyle,

  /// Pin the thumbnail bar to an edge of the viewport.
  ///
  /// On iOS this renders as a scrubber-style bar pinned to the bottom.
  /// On Android it renders as a pinned strip at the bottom of the viewer.
  pinned,

  /// Render a compact scrubber bar (primarily an iOS concept).
  ///
  /// On Android this falls back to [pinned] behaviour.
  scrubberBar,

  /// Render a scrollable strip of page thumbnails.
  scrollable,

  /// Display the thumbnail bar as a floating overlay.
  ///
  /// Floats above the document content rather than displacing it.
  floating,
}

// ---------------------------------------------------------------------------
// Web SDK name mappings
// ---------------------------------------------------------------------------

/// Extension that provides the Web SDK string name for [PageTransition] values.
///
/// Used internally by the configuration builder when serialising
/// [NutrientViewConfiguration] for the Nutrient Web SDK.
///
/// Only [PageTransition.scrollContinuous] and [PageTransition.disabled] have
/// dedicated Web SDK equivalents. All other values default to `'PER_SPREAD'`.
extension PageTransitionWebName on PageTransition {
  /// Returns the Web SDK `layoutMode` string for this transition, or `null`
  /// when the transition is not expressible in the Web SDK.
  String? get webName {
    switch (this) {
      case PageTransition.scrollContinuous:
        return 'CONTINUOUS';
      case PageTransition.disabled:
        return 'DISABLED';
      case PageTransition.scrollPerSpread:
      default:
        return 'PER_SPREAD';
    }
  }
}

/// Extension that provides the Web SDK string name for [PageLayoutMode] values.
///
/// Used internally by the configuration builder when serialising
/// [NutrientViewConfiguration] for the Nutrient Web SDK.
extension PageLayoutModeWebName on PageLayoutMode {
  /// Returns the Web SDK `pageLayout` string for this layout mode.
  String? get webName {
    switch (this) {
      case PageLayoutMode.double:
        return 'DOUBLE';
      case PageLayoutMode.automatic:
        return 'AUTOMATIC';
      case PageLayoutMode.single:
        return 'SINGLE';
    }
  }
}

/// Extension that provides the Web SDK string name for [AppearanceMode] values.
///
/// Used internally by the configuration builder when serialising
/// [NutrientViewConfiguration] for the Nutrient Web SDK.
///
/// The Web SDK supports only `'DARK'` and `'LIGHT'` themes. [AppearanceMode.night]
/// maps to `'DARK'`; all other values map to `'LIGHT'`.
extension AppearanceModeWebName on AppearanceMode {
  /// Returns the Web SDK `theme` string (`'DARK'` or `'LIGHT'`) for this mode.
  String? get webName {
    switch (this) {
      case AppearanceMode.night:
        return 'DARK';
      case AppearanceMode.defaultMode:
      case AppearanceMode.sepia:
      case AppearanceMode.allCustomColors:
        return 'LIGHT';
    }
  }
}
