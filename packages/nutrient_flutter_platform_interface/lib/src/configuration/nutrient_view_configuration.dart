///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'android_view_configuration.dart';
import 'ios_view_configuration.dart';
import 'signature_creation_configuration.dart';
import 'view_configuration_enums.dart';

export 'android_view_configuration.dart';
export 'ios_view_configuration.dart';
export 'signature_creation_configuration.dart';
export 'view_configuration_enums.dart';

/// Typed viewer configuration for bindings-based Nutrient views.
///
/// [NutrientViewConfiguration] replaces the legacy [PdfConfiguration] for
/// views that communicate with the native SDK directly via JNI/FFI bindings
/// (Android) or FFI (iOS) rather than through the Pigeon method channel.
///
/// Only options that have a direct 1-to-1 mapping in the platform's native
/// configuration builder are represented as cross-platform fields. Options
/// that are meaningful on only one platform are grouped under the
/// corresponding platform sub-configuration:
///
/// - [androidConfig] — Android-only options
/// - [iosConfig]     — iOS-only options
/// - [webConfig]     — Web-only options (type is `Object?` to avoid a
///                     dependency on `nutrient_flutter`; pass a
///                     `WebViewConfiguration` instance at the call site)
///
/// ## Example
/// ```dart
/// NutrientInstantView(
///   serverUrl: 'https://example.com/api/1/documents/abc',
///   jwt: 'eyJhbGci...',
///   configuration: NutrientViewConfiguration(
///     pageLayoutMode: PageLayoutMode.single,
///     appearanceMode: AppearanceMode.night,
///     thumbnailBarMode: ThumbnailBarMode.floating,
///     androidConfig: AndroidViewConfiguration(
///       showSearchAction: false,
///     ),
///     iosConfig: IOSViewConfiguration(
///       spreadFitting: SpreadFitting.adaptive,
///     ),
///   ),
/// )
/// ```
class NutrientViewConfiguration {
  // ---------------------------------------------------------------------------
  // Cross-platform layout
  // ---------------------------------------------------------------------------

  /// The direction pages are scrolled.
  final ScrollDirection? scrollDirection;

  /// Single page, double-page spread, or automatic.
  final PageLayoutMode? pageLayoutMode;

  /// The page transition animation.
  final PageTransition? pageTransition;

  /// Always show the first page as a single page in double-page mode.
  final bool? firstPageAlwaysSingle;

  // ---------------------------------------------------------------------------
  // Cross-platform UI chrome
  // ---------------------------------------------------------------------------

  /// When the viewer toolbar and overlays are shown.
  ///
  /// On web this controls `initialViewState.showToolbar`; prefer setting
  /// [WebViewConfiguration.showToolbar] for finer-grained web control.
  final UserInterfaceViewMode? userInterfaceViewMode;

  /// Where and how the page thumbnail bar is displayed.
  ///
  /// Android and iOS map the shared [ThumbnailBarMode] values to their
  /// respective native enums via helper functions in each builder.
  final ThumbnailBarMode? thumbnailBarMode;

  /// The colour theme / appearance mode of the viewer.
  ///
  /// On Android maps to `PdfActivityConfiguration$Builder.themeMode`.
  /// On Web maps to the `theme` load option (`DARK` / `LIGHT` / `AUTO`).
  /// On iOS appearance is applied through the platform adapter, not the
  /// configuration builder.
  final AppearanceMode? appearanceMode;

  /// The initial page index (zero-based) to display on open.
  ///
  /// Applied on Android and Web; silently ignored on iOS.
  final int? startPage;

  // ---------------------------------------------------------------------------
  // Cross-platform editing
  // ---------------------------------------------------------------------------

  /// Allow the user to select text in the document.
  final bool? enableTextSelection;

  /// Allow the user to create and edit annotations.
  final bool? enableAnnotationEditing;

  /// Allow the user to fill in form fields.
  final bool? enableFormEditing;

  /// Disable automatic saving of changes.
  ///
  /// On Android inverts `autosaveEnabled`; on iOS inverts `isAutosaveEnabled`;
  /// on Web sets `autoSaveMode: DISABLED`.
  final bool? disableAutosave;

  /// Enable Instant comments. Defaults to `false`.
  ///
  /// When `true`, the comment creation menu items are exposed in the viewer's
  /// long-press and text-selection menus (iOS) and the comment marker tool is
  /// added to the annotation creation toolbar (Android). Has no effect on
  /// non-Instant documents and requires the Instant Comments component in
  /// your server license.
  final bool? enableInstantComments;

  // ---------------------------------------------------------------------------
  // Cross-platform zoom (iOS + Web; Android does not expose min/max)
  // ---------------------------------------------------------------------------

  /// Minimum zoom scale factor.
  final double? minimumZoomScale;

  /// Maximum zoom scale factor.
  final double? maximumZoomScale;

  // ---------------------------------------------------------------------------
  // Cross-platform signatures
  // ---------------------------------------------------------------------------

  /// When the signature creation UI offers to save a new signature.
  ///
  /// Supported on Android and iOS. Ignored on Web, where signature storage is
  /// app-managed via the Web SDK's stored-signatures API.
  final SignatureSavingStrategy? signatureSavingStrategy;

  /// Configures the signature creation UI (creation modes, color presets,
  /// typed-signature fonts, and per-platform layout options).
  ///
  /// See [SignatureCreationConfiguration] for the per-option platform-support
  /// matrix.
  final SignatureCreationConfiguration? signatureCreationConfiguration;

  // ---------------------------------------------------------------------------
  // Platform sub-configurations
  // ---------------------------------------------------------------------------

  /// Android-specific options.
  final AndroidViewConfiguration? androidConfig;

  /// iOS-specific options.
  final IOSViewConfiguration? iosConfig;

  /// Web-specific options.
  ///
  /// Pass a `WebViewConfiguration` instance (from `nutrient_flutter`). The
  /// type is declared as `Object?` so that `platform_interface` does not need
  /// to depend on `nutrient_flutter`.
  final Object? webConfig;

  /// Optional AI Assistant configuration.
  ///
  /// Expected keys: `serverUrl`, `jwt`, `sessionId`, optionally `userId`. The
  /// shape matches `AIAssistantConfiguration.toMap()` in `nutrient_flutter`,
  /// but it's typed as a Map here to avoid a dependency cycle.
  ///
  /// On Android, when [NutrientInstantView] receives this, it builds an
  /// AI Assistant via `createAiAssistantForInstant` and registers it with the
  /// host activity's `AiAssistantProvider` so the SDK's built-in chat UI can
  /// reach it.
  final Map<String, String>? aiAssistantConfiguration;

  /// Password used to unlock an encrypted document when the view loads.
  ///
  /// When non-null and non-empty, the viewer attempts to open the document
  /// with this password before displaying it. Supported on Android, iOS,
  /// and Web. A wrong password produces a platform-level error or renders a
  /// blank view depending on the platform; it does not crash the widget tree.
  final String? password;

  const NutrientViewConfiguration({
    this.scrollDirection,
    this.pageLayoutMode,
    this.pageTransition,
    this.firstPageAlwaysSingle,
    this.userInterfaceViewMode,
    this.thumbnailBarMode,
    this.appearanceMode,
    this.startPage,
    this.enableTextSelection,
    this.enableAnnotationEditing,
    this.enableFormEditing,
    this.disableAutosave,
    this.enableInstantComments,
    this.minimumZoomScale,
    this.maximumZoomScale,
    this.signatureSavingStrategy,
    this.signatureCreationConfiguration,
    this.androidConfig,
    this.iosConfig,
    this.webConfig,
    this.aiAssistantConfiguration,
    this.password,
  });

  /// Returns a copy of this configuration with the given fields replaced.
  ///
  /// Passing `null` for a parameter keeps the current value — fields cannot
  /// be cleared through [copyWith].
  NutrientViewConfiguration copyWith({
    ScrollDirection? scrollDirection,
    PageLayoutMode? pageLayoutMode,
    PageTransition? pageTransition,
    bool? firstPageAlwaysSingle,
    UserInterfaceViewMode? userInterfaceViewMode,
    ThumbnailBarMode? thumbnailBarMode,
    AppearanceMode? appearanceMode,
    int? startPage,
    bool? enableTextSelection,
    bool? enableAnnotationEditing,
    bool? enableFormEditing,
    bool? disableAutosave,
    bool? enableInstantComments,
    double? minimumZoomScale,
    double? maximumZoomScale,
    SignatureSavingStrategy? signatureSavingStrategy,
    SignatureCreationConfiguration? signatureCreationConfiguration,
    AndroidViewConfiguration? androidConfig,
    IOSViewConfiguration? iosConfig,
    Object? webConfig,
    Map<String, String>? aiAssistantConfiguration,
    String? password,
  }) {
    return NutrientViewConfiguration(
      scrollDirection: scrollDirection ?? this.scrollDirection,
      pageLayoutMode: pageLayoutMode ?? this.pageLayoutMode,
      pageTransition: pageTransition ?? this.pageTransition,
      firstPageAlwaysSingle:
          firstPageAlwaysSingle ?? this.firstPageAlwaysSingle,
      userInterfaceViewMode:
          userInterfaceViewMode ?? this.userInterfaceViewMode,
      thumbnailBarMode: thumbnailBarMode ?? this.thumbnailBarMode,
      appearanceMode: appearanceMode ?? this.appearanceMode,
      startPage: startPage ?? this.startPage,
      enableTextSelection: enableTextSelection ?? this.enableTextSelection,
      enableAnnotationEditing:
          enableAnnotationEditing ?? this.enableAnnotationEditing,
      enableFormEditing: enableFormEditing ?? this.enableFormEditing,
      disableAutosave: disableAutosave ?? this.disableAutosave,
      enableInstantComments:
          enableInstantComments ?? this.enableInstantComments,
      minimumZoomScale: minimumZoomScale ?? this.minimumZoomScale,
      maximumZoomScale: maximumZoomScale ?? this.maximumZoomScale,
      signatureSavingStrategy:
          signatureSavingStrategy ?? this.signatureSavingStrategy,
      signatureCreationConfiguration:
          signatureCreationConfiguration ?? this.signatureCreationConfiguration,
      androidConfig: androidConfig ?? this.androidConfig,
      iosConfig: iosConfig ?? this.iosConfig,
      webConfig: webConfig ?? this.webConfig,
      aiAssistantConfiguration:
          aiAssistantConfiguration ?? this.aiAssistantConfiguration,
      password: password ?? this.password,
    );
  }
}
