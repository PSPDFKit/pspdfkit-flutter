///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// One-stop entry point for the **bindings-based** Nutrient Flutter API.
///
/// Import this library instead of `package:nutrient_flutter/nutrient_flutter.dart`
/// when you want to build against the bindings surface
/// ([NutrientPlatformAdapter], [NutrientController],
/// [NutrientControllerInterface], typed [NutrientEvent] stream, etc.) rather
/// than the legacy method-channel surface.
///
/// ```dart
/// import 'package:nutrient_flutter/bindings.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Nutrient.initialize(
///     androidAdapter: MyAndroidAdapter(),
///     iosAdapter: MyIOSAdapter(),
///     webAdapter: MyWebAdapter(),
///   );
///   runApp(const MyApp());
/// }
/// ```
///
/// This library re-exports:
///
/// - All cross-platform bindings types from
///   `nutrient_flutter_platform_interface` (`Nutrient`, `NutrientController`,
///   `NutrientControllerInterface`, `NutrientPlatformAdapter`,
///   `NutrientDocumentInterface`, `NutrientViewConfiguration`, the typed
///   `NutrientEvent` sealed class hierarchy, etc.).
/// - [NutrientDocumentView] — the adapter-driven view widget.
///
/// ## Writing a custom adapter
///
/// Adapter base classes live in the per-platform packages and pull in
/// platform-specific bindings, so they're not re-exported here. Import
/// them directly from the platform package (you'll typically only
/// reference the one for the platform you're targeting):
///
/// ```dart
/// // ignore: depend_on_referenced_packages
/// import 'package:nutrient_flutter_android/nutrient_flutter_android.dart';
///
/// class MyAndroidAdapter extends AndroidAdapter { /* ... */ }
/// ```
///
/// The `depend_on_referenced_packages` ignore is needed because the
/// per-platform packages are transitive dependencies of `nutrient_flutter`
/// (not direct deps of your app) — declaring them as direct deps would
/// prevent the Flutter plugin tooling from registering `nutrient_flutter`
/// itself as an Android plugin.
///
/// ## Legacy API
///
/// The Pigeon-generated method-channel types still live on
/// `package:nutrient_flutter/nutrient_flutter.dart` (`Nutrient.present()`,
/// the legacy `Bookmark`/`PageInfo`/`AnnotationProperties`/`NutrientEvent`
/// enums, etc.). They are deprecated for the bindings flow but kept around
/// for backwards compatibility — see the legacy example app for usage.
library nutrient_flutter.bindings;

// Cross-platform types: Nutrient (entry point), NutrientController,
// NutrientControllerInterface, NutrientDocumentInterface,
// NutrientPlatformAdapter, NutrientViewConfiguration, the typed
// NutrientEvent sealed class hierarchy, the document/annotation/bookmark/
// form manager interfaces, the new Bookmark / PageInfo / AnnotationProperties
// / DocumentSaveOptions / AnnotationTool models, etc.
export 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

// Typed annotation model base class. The platform-interface barrel hides
// `Annotation` because `nutrient_flutter_android` imports that barrel and has a
// JNI-generated `Annotation` extension type it would collide with. Bindings apps
// import this library (not the android bindings), so re-export the typed
// `Annotation` here — the subclasses (`InkAnnotation`, `HighlightAnnotation`, …)
// already come through the barrel, this adds the base type so `List<Annotation>`
// and `Annotation.fromJson`/`tryFromJson` are usable from the bindings surface.
export 'package:nutrient_flutter_platform_interface/src/models/annotations/annotation_models.dart'
    show Annotation;

// The Instant-JSON enums used by the typed annotation/form APIs
// (`getAnnotations(type)`, `PdfFormField.type`). They live in the pigeon
// `nutrient_api.g.dart`, which the platform-interface barrel doesn't surface,
// so re-export them here for bindings apps.
export 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart'
    show AnnotationType, PdfFormFieldTypes;

// Adapter-driven view widget. Lives in `nutrient_flutter` proper because
// the conditional-platform-view factory wiring is platform-package-aware.
export 'src/widgets/document_view/nutrient_document_view.dart';

// Bookmark convenience helpers — `Bookmark.forPage(...)` factory, the
// `pageIndex` getter that parses the GoTo action JSON, `copyWith`, and the
// Instant-JSON converter. Pure Dart sugar on top of the platform-interface
// `Bookmark` model, useful from the bindings surface as well as the legacy
// one.
export 'src/bookmarks/bookmark_extensions.dart';

// AnnotationProperties convenience helpers — the `with*` mutation helpers
// (`withColor`, `withOpacity`, `withLineWidth`, …), the typed getters
// (`AnnotationPropertiesGetters`), and the per-type sugar (`InkAnnotation-
// Properties` etc.). Pure Dart sugar on top of the platform-interface
// `AnnotationProperties` model — same both-barrels story as the bookmark
// helpers above, needed for the getAnnotationProperties/saveAnnotationProperties
// round-trip on the bindings surface.
export 'src/document/annotation_properties_extensions.dart';

// Web-specific view configuration. `NutrientViewConfiguration.webConfig` is
// typed `Object?` in the platform interface (which can't depend on this
// package), so the concrete `WebViewConfiguration` class lives here. Export
// it together with the enums and web models its fields reference, so bindings
// apps can construct one without importing the legacy barrel.
export 'src/configuration/web_view_configuration.dart';
export 'src/types.dart'
    show
        AutoSaveMode,
        NutrientWebInteractionMode,
        ShowSignatureValidationStatusMode,
        SidebarMode,
        ToolbarPlacement,
        ZoomMode;
export 'src/web/models/models.dart';
export 'src/web/office_conversion_settings.dart';

// Instant collaboration view. Built on the bindings adapters (Android
// InstantPdfUiFragment via JNI, iOS PSPDFInstantViewController via FFI,
// web via the Web SDK's native Instant mode in `NutrientViewer.load()`).
export 'src/widgets/nutrient_instant_view.dart'
    if (dart.library.js_interop) 'src/widgets/nutrient_instant_view_web.dart';
