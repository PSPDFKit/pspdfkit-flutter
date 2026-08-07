///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// Export the correct widget based on the platform.
export 'src/widgets/pspdfkit_widget.dart'
    if (dart.library.io) 'src/widgets/pspdfkit_widget.dart'
    if (dart.library.js_interop) 'src/widgets/pspdfkit_widget_web.dart';
export 'src/widgets/nutrient_view.dart'
    if (dart.library.io) 'src/widgets/nutrient_view.dart'
    if (dart.library.js_interop) 'src/widgets/nutrient_view_web.dart';
export 'src/widgets/nutrient_instant_view.dart'
    if (dart.library.js_interop) 'src/widgets/nutrient_instant_view_web.dart';

// Adapter-driven document viewer. Use this for new code — pair with a
// NutrientPlatformAdapter registered via Nutrient.initialize(...).
export 'src/widgets/document_view/nutrient_document_view.dart';

// All other exports.
export 'src/configuration/web_view_configuration.dart';
export 'src/pdf_configuration.dart';
export 'src/web/nutrient_web_configuration.dart';
export 'src/web/office_conversion_settings.dart';
// Legacy enum/class declarations not yet covered by platform_interface.
// The shared viewer-configuration enums (ScrollDirection, PageLayoutMode, etc.)
// and IOSBookmarkIndicatorMode used to be hidden from this export because
// they collided with PI's versions; they now live exclusively in PI, so no
// hide clause is needed.
export 'src/types.dart';
export 'src/web/models/models.dart';
export 'src/configuration_options.dart';
export 'src/toolbar/toolbar.dart';

export 'src/widgets/pspdfkit_widget_controller.dart';
// measurements.dart has moved to nutrient_flutter_platform_interface; re-export from there.
export 'package:nutrient_flutter_platform_interface/src/measurements/measurements.dart';
export 'src/processor/processor.dart';
export 'src/document/pdf_document.dart';
export 'src/document/headless_pdf_document_native.dart';
// Deprecated: AnnotationManager is no longer exposed as a user-facing API.
// Use annotation management methods directly on PdfDocument instead.
export 'src/document/annotation_manager.dart';
export 'src/document/annotation_properties_extensions.dart';
export 'package:nutrient_flutter_platform_interface/src/models/forms/forms.dart';
// Pigeon-generated transport types. The HostApi/FlutterApi proxy classes are
// implementation detail and must not be part of the public API: pigeon's docs
// explicitly warn against exposing generated code, and a regen can change the
// codec or class shape in a breaking way. Data classes still leak through
// here for now (they collide in name — but not always in shape — with the
// hand-written versions in nutrient_flutter_platform_interface). Resolving
// those collisions is a follow-up; for now we just stop exposing the API
// proxies and the internal-only FormFieldData DTO.
export 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart'
    hide
        // HostApi proxy classes — internal transport, never user-facing.
        NutrientApi,
        NutrientViewControllerApi,
        PdfDocumentApi,
        HeadlessDocumentApi,
        AnnotationManagerApi,
        BookmarkManagerApi,
        // FlutterApi callback classes — internal transport.
        NutrientApiCallbacks,
        NutrientViewCallbacks,
        NutrientEventsCallbacks,
        AnalyticsEventsCallback,
        CustomToolbarCallbacks,
        // Internal DTO with no external references; the public form-field API
        // is the PdfFormField hierarchy in src/forms/.
        FormFieldData,
        // Resolved data-class collisions — pigeon owns transport, the
        // hand-written class in nutrient_flutter_platform_interface owns
        // the public API. Internal call sites convert at the IPC boundary.
        PageInfo,
        Bookmark,
        DocumentSaveOptions,
        DocumentPermissions,
        PdfVersion,
        AnnotationProperties;

export 'src/annotation_preset_configurations.dart';
// Annotation models have moved to nutrient_flutter_platform_interface; re-export from there.
export 'package:nutrient_flutter_platform_interface/src/models/annotations/annotations.dart';
export 'src/annotations/annotations.dart';
export 'src/annotations/annotation_menu_configuration.dart';
export 'src/bookmarks/bookmarks.dart';
export 'src/web/models/nutrient_web_events.dart';
export 'src/nutrient.dart';

export 'src/widgets/nutrient_view_controller.dart';
export 'src/ai/ai_assistant_configuration.dart';
export 'src/theme_configuration.dart';
export 'src/utils/missing_platform_directory_exception.dart';

// Adapter infrastructure for native SDK access
export 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    show
        NutrientController,
        NutrientViewHandle,
        NativeInstanceRegistry,
        NutrientPlatformAdapter,
        // Typed view configuration
        NutrientViewConfiguration,
        AndroidViewConfiguration,
        IOSViewConfiguration,
        // Signature configuration (lifted from the legacy wrapper so the
        // bindings' NutrientViewConfiguration can use the same types)
        SignatureSavingStrategy,
        SignatureCreationMode,
        SignatureCreationConfiguration,
        SignatureColorOptions,
        SignatureColorPreset,
        NutrientAndroidSignatureOrientation,
        // Hand-written data classes that are the public API surface (pigeon
        // versions of these are intentionally hidden above and converted to
        // these at the IPC boundary).
        PageInfo,
        Bookmark,
        DocumentSaveOptions,
        DocumentPermissions,
        PdfVersion,
        AnnotationProperties,
        // Shared configuration enums
        ScrollDirection,
        PageLayoutMode,
        PageTransition,
        SpreadFitting,
        UserInterfaceViewMode,
        AppearanceMode,
        ThumbnailBarMode,
        IOSBookmarkIndicatorMode,
        IOSFileConflictResolution;
// Export the enums file directly so its extensions (webName etc.) are visible.
// A `show` export only re-exports named declarations, not extensions.
export 'package:nutrient_flutter_platform_interface/src/configuration/view_configuration_enums.dart'
    hide
        ScrollDirection,
        PageLayoutMode,
        PageTransition,
        SpreadFitting,
        UserInterfaceViewMode,
        AppearanceMode,
        ThumbnailBarMode;

// Platform adapters - conditional exports per platform
export 'src/adapters/adapters_stub.dart'
    if (dart.library.io) 'src/adapters/adapters_native.dart'
    if (dart.library.js_interop) 'src/adapters/adapters_web.dart';
