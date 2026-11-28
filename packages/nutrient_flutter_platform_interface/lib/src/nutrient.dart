///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api/nutrient_api.g.dart' show AnnotationType, AnnotationProcessingMode;
import 'interfaces/nutrient_document_interface.dart';
import 'interfaces/nutrient_instant_controller.dart';
import 'nutrient_controller.dart';
import 'nutrient_flutter_platform.dart';
import 'nutrient_platform_adapter.dart';

/// Main entry point for the Nutrient Flutter Bindings plugin.
///
/// This class provides ONLY:
/// - SDK initialization with license key
/// - Platform adapter registration and management
/// - SDK version information
///
/// All other functionality (navigation, annotations, forms, events, etc.)
/// is provided through platform adapters.
///
/// ## Basic Usage
///
/// Initialize with just a license key:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await Nutrient.initialize(
///     licenseKey: 'YOUR_LICENSE_KEY',
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Advanced Usage with Platform Adapters
///
/// Register custom adapters for advanced functionality:
/// ```dart
/// await Nutrient.initialize(
///   licenseKey: 'YOUR_LICENSE_KEY',
///   androidAdapter: MyAndroidAdapter(),
///   iosAdapter: MyIOSAdapter(),
///   webAdapter: MyWebAdapter(),
/// );
///
/// // Later, access the adapter
/// final adapter = Nutrient.currentAdapter;
/// adapter.events.listen((event) {
///   // Handle events
/// });
/// ```
class Nutrient {
  static NutrientPlatformAdapter? _androidAdapter;
  static NutrientPlatformAdapter? _iosAdapter;
  static NutrientPlatformAdapter? _webAdapter;

  /// Controller factories keyed by controller type, registered via
  /// [addAdapterClass]. A `NutrientDocumentView<T>` builds a fresh instance per
  /// view from `_factories[T]`, so two views never share state.
  static final Map<Type, NutrientController Function()> _factories = {};

  static String? _androidLicenseKey;
  static String? _iosLicenseKey;
  static String? _webLicenseKey;
  static bool _initialized = false;

  /// Initialize the Nutrient SDK.
  ///
  /// Must be called before using [NutrientView] or accessing adapters.
  ///
  /// **License Keys**: License keys are optional. If not provided or set to null,
  /// the SDK will run in trial mode with watermarks.
  ///
  /// **Platform Adapters**: Adapters are also optional. When you don't pass one
  /// for the current platform, the SDK registers its built-in default adapter,
  /// which gives you the full default viewer. Pass a custom adapter only when
  /// you need to customize the viewer or reach platform-specific APIs. The
  /// simplest possible setup is therefore just:
  /// ```dart
  /// await Nutrient.initialize();
  /// // ... then use NutrientDocumentView(documentPath: ...)
  /// ```
  ///
  /// **Trial Mode** (no license key):
  /// ```dart
  /// await Nutrient.initialize(
  ///   androidLicenseKey: null,
  ///   iosLicenseKey: null,
  ///   webLicenseKey: null,
  /// );
  /// ```
  ///
  /// **Single Platform Example**:
  /// ```dart
  /// // For Android only
  /// await Nutrient.initialize(
  ///   androidLicenseKey: 'YOUR_ANDROID_KEY',
  /// );
  /// ```
  ///
  /// **Multi-Platform Example**:
  /// ```dart
  /// await Nutrient.initialize(
  ///   androidLicenseKey: 'YOUR_ANDROID_KEY',
  ///   iosLicenseKey: 'YOUR_IOS_KEY',
  ///   webLicenseKey: 'YOUR_WEB_KEY',
  /// );
  /// ```
  ///
  /// **Custom controllers** (preferred): register a controller type once, then
  /// select it per view — each `NutrientDocumentView<T>` builds a fresh instance:
  /// ```dart
  /// await Nutrient.initialize(androidLicenseKey: 'YOUR_ANDROID_KEY');
  /// Nutrient.addAdapterClass<MyController>(() => createMyAdapter());
  /// // …later: NutrientDocumentView<MyController>(documentPath: '…')
  /// ```
  ///
  /// The [androidAdapter] / [iosAdapter] / [webAdapter] parameters are
  /// **deprecated**: they register one process-shared adapter per platform.
  /// Prefer [addAdapterClass] + `NutrientDocumentView<T>` (or pass a per-view
  /// `adapter:`) so views don't share controller state. The parameters still
  /// work during the deprecation window and will be removed in a future release.
  ///
  /// Throws [StateError] if already initialized.
  static Future<void> initialize({
    String? androidLicenseKey,
    String? iosLicenseKey,
    String? webLicenseKey,
    @Deprecated(
      'Register a controller type with Nutrient.addAdapterClass<T>() and select '
      'it via NutrientDocumentView<T> instead. Will be removed in a future '
      'release.',
    )
    NutrientPlatformAdapter? androidAdapter,
    @Deprecated(
      'Register a controller type with Nutrient.addAdapterClass<T>() and select '
      'it via NutrientDocumentView<T> instead. Will be removed in a future '
      'release.',
    )
    NutrientPlatformAdapter? iosAdapter,
    @Deprecated(
      'Register a controller type with Nutrient.addAdapterClass<T>() and select '
      'it via NutrientDocumentView<T> instead. Will be removed in a future '
      'release.',
    )
    NutrientPlatformAdapter? webAdapter,
  }) async {
    if (_initialized) {
      throw StateError(
        'Nutrient has already been initialized. '
        'Call Nutrient.initialize() only once.',
      );
    }

    // License keys are optional - if null/empty, SDK runs in trial mode
    _androidLicenseKey = androidLicenseKey;
    _iosLicenseKey = iosLicenseKey;
    _webLicenseKey = webLicenseKey;

    _androidAdapter = androidAdapter;
    _iosAdapter = iosAdapter;
    _webAdapter = webAdapter;
    _initialized = true;

    // Adapters are only required when you want to customize the viewer. When
    // the caller didn't pass one for the current platform, fall back to the
    // SDK's built-in default adapter so `NutrientDocumentView` works out of the
    // box.
    _ensureDefaultAdapterForCurrentPlatform();

    // Activate the native license. This is an SDK-global, stateless step owned
    // by the platform implementation — independent of any per-view adapter.
    // Android licenses the SDK and iOS sets the license key (both must run
    // before any document opens); web no-ops and injects the key per-load.
    final platform = NutrientFlutterPlatform.instance;
    if (platform != null) {
      await platform.activateLicense(currentLicenseKey);
    } else if (currentLicenseKey != null && currentLicenseKey!.isNotEmpty) {
      // A key was provided but no platform implementation is registered — the
      // SDK would silently run in trial mode. Surface it rather than fail
      // quietly.
      debugPrint(
        '[Nutrient.initialize] A license key was provided for '
        '$defaultTargetPlatform but no platform implementation is registered, '
        'so the license cannot be activated — the SDK will run in trial mode.',
      );
    }
  }

  /// Fills the current platform's adapter slot with the SDK's built-in default
  /// ([NutrientFlutterPlatform.createDefaultAdapter]) when the caller didn't
  /// supply one. No-ops when an adapter was already provided, when no platform
  /// implementation is registered, or when the platform has no default.
  static void _ensureDefaultAdapterForCurrentPlatform() {
    final platform = NutrientFlutterPlatform.instance;
    if (platform == null) return;

    NutrientPlatformAdapter? makeDefault() {
      try {
        return platform.createDefaultAdapter();
      } on UnimplementedError {
        return null;
      }
    }

    if (kIsWeb) {
      _webAdapter ??= makeDefault();
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _androidAdapter ??= makeDefault();
        break;
      case TargetPlatform.iOS:
        _iosAdapter ??= makeDefault();
        break;
      default:
        break;
    }
  }

  /// The version of the underlying native Nutrient SDK on the current platform
  /// (Android, iOS, or Web) — for example `"11.5.1"`.
  ///
  /// Resolved from the platform implementation (a stateless, SDK-global query),
  /// so it reflects the real native framework — unlike [version], which is the
  /// Dart bindings version. Returns `null` when no platform implementation is
  /// registered or the platform doesn't report a version.
  static Future<String?> get frameworkVersion async =>
      NutrientFlutterPlatform.instance?.getPlatformVersion();

  /// Opens a document without a viewer (headless), returning the full document
  /// API — annotations, bookmarks, forms, save, export — with no UI.
  ///
  /// A document needs an adapter to host it. Pass [adapter] to use your own
  /// controller (e.g. for typed native access to the opened document); when
  /// omitted, the platform's built-in default adapter hosts it. The returned
  /// document keeps native resources alive — call
  /// [NutrientDocumentInterface.close] when done.
  ///
  /// ```dart
  /// final doc = await Nutrient.openDocument('report.pdf');
  /// await doc.annotations.importXfdf(xfdf);
  /// await doc.save(outputPath: '/tmp/out.pdf');
  /// await doc.close();
  ///
  /// // With native access:
  /// final adapter = createReaderAdapter();
  /// final doc2 = await Nutrient.openDocument('report.pdf', adapter: adapter);
  /// final native = (adapter as ReaderController).nativePdfDocument;
  /// ```
  ///
  /// Throws [StateError] when no [adapter] is given and the platform has no
  /// default adapter to host the document.
  static Future<NutrientDocumentInterface> openDocument(
    String path, {
    String? password,
    NutrientController? adapter,
  }) =>
      _headlessHost(adapter).openDocument(path, password: password);

  /// Opens a document from in-memory [bytes] without a viewer (headless).
  ///
  /// Like [openDocument] but for documents that aren't on disk. See
  /// [openDocument] for [adapter] / ownership semantics.
  static Future<NutrientDocumentInterface> openDocumentFromBytes(
    Uint8List bytes, {
    String? password,
    NutrientController? adapter,
  }) =>
      _headlessHost(adapter).openDocumentFromBytes(bytes, password: password);

  /// Processes the annotations of the document at [sourcePath] and writes the
  /// result to [destinationPath], mirroring the legacy SDK's
  /// `Nutrient.processAnnotations`.
  ///
  /// [type] selects which annotations to process (use `AnnotationType.all` for
  /// every annotation); [mode] chooses how — `flatten`, `remove`, `embed`, or
  /// `print`. The source document is opened and released internally, so no open
  /// document or viewer is required.
  ///
  /// In-place processing ([sourcePath] == [destinationPath]) is supported:
  /// the result is written to a sibling temp file and moved over the
  /// destination only after processing succeeds, so the original is preserved
  /// on failure. A pre-existing file at a distinct [destinationPath] is
  /// likewise only replaced by a complete output, never deleted up front.
  ///
  /// The native processing runs in a short-lived background isolate — the
  /// whole document is rewritten synchronously on the processing thread, so
  /// this keeps the UI responsive during large jobs.
  ///
  /// Supported on Android and iOS. Not supported on Web (throws
  /// [UnsupportedError]). Pass [adapter] to host the operation on a specific
  /// controller; otherwise the platform default adapter is used.
  ///
  /// ```dart
  /// await Nutrient.processAnnotations(
  ///   sourcePath: 'in.pdf',
  ///   type: AnnotationType.all,
  ///   mode: AnnotationProcessingMode.flatten,
  ///   destinationPath: 'out.pdf',
  /// );
  /// ```
  static Future<bool> processAnnotations({
    required String sourcePath,
    required AnnotationType type,
    required AnnotationProcessingMode mode,
    required String destinationPath,
    NutrientController? adapter,
  }) =>
      _headlessHost(adapter)
          .processAnnotations(sourcePath, type, mode, destinationPath);

  /// Resolves the platform adapter that hosts a headless document: the
  /// caller-supplied [adapter] when given, otherwise the platform default.
  static NutrientPlatformAdapter _headlessHost(NutrientController? adapter) {
    final host = adapter ?? _makeDefaultAdapter();
    if (host is! NutrientPlatformAdapter) {
      throw StateError(
        'Nutrient.openDocument needs a platform adapter to host the document, '
        'but none is available for $defaultTargetPlatform. Pass `adapter:` with '
        'your controller, or ensure a platform implementation is registered.',
      );
    }
    return host;
  }

  /// Get the current platform adapter.
  ///
  /// Returns the adapter for the current platform:
  /// - Android: [androidAdapter]
  /// - iOS: [iosAdapter]
  /// - Web: [webAdapter]
  ///
  /// Returns `null` if:
  /// - SDK not initialized
  /// - No adapter registered for current platform
  ///
  /// Example:
  /// ```dart
  /// final adapter = Nutrient.currentAdapter;
  /// if (adapter != null) {
  ///   adapter.events.listen((event) {
  ///     print('Event: $event');
  ///   });
  /// }
  /// ```
  @Deprecated(
    'The process-global adapter slot is deprecated. Register a controller type '
    'with Nutrient.addAdapterClass<T>() and select it via '
    'NutrientDocumentView<T>; access the controller through that view\'s '
    'onControllerReady. Will be removed in a future release.',
  )
  static NutrientPlatformAdapter? get currentAdapter {
    if (!_initialized) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidAdapter;
      case TargetPlatform.iOS:
        return _iosAdapter;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        // Web is handled by kIsWeb check
        return _webAdapter;
    }
  }

  // ── Per-view adapter factories (type-keyed) ─────────────────────────────────

  /// Register a builder for controller type [T].
  ///
  /// `NutrientDocumentView<T>` calls the builder to produce a **fresh instance
  /// per view**, so concurrent views never share state. Register once at
  /// startup:
  ///
  /// ```dart
  /// Nutrient.addAdapterClass<ReaderController>(() => createReaderAdapter());
  /// ```
  ///
  /// The builder must return a type that is also a [NutrientPlatformAdapter]
  /// (the bundled `AndroidAdapter` / `IOSAdapter` / `NutrientWebAdapter` bases
  /// already are). Registering the same [T] again replaces the previous builder.
  static void addAdapterClass<T extends NutrientController>(
    T Function() create,
  ) {
    _factories[T] = create;
  }

  /// Remove a builder previously registered for [T] via [addAdapterClass].
  static void removeAdapterClass<T extends NutrientController>() {
    _factories.remove(T);
  }

  /// Whether a builder is registered for [T].
  static bool hasAdapterClass<T extends NutrientController>() =>
      _factories.containsKey(T);

  /// Build the controller for a `NutrientDocumentView<T>`.
  ///
  /// Resolution order:
  /// 1. a builder registered via [addAdapterClass] for [T] (fresh instance);
  /// 2. when no specific type was requested (`T == NutrientController`, i.e. a
  ///    bare `NutrientDocumentView()`), a **fresh** platform default viewer per
  ///    view — resolved *before* the shared slot so concurrent bare views never
  ///    collide on one controller;
  /// 3. otherwise, a *typed* instance registered through the deprecated global
  ///    slots ([initialize]'s `androidAdapter:`/etc.) when it matches [T].
  ///
  /// Throws [StateError] with an actionable message when [T] is a specific type
  /// with no registration — surfacing the misconfiguration instead of a silent
  /// null. Intended for the SDK's views; apps use [addAdapterClass] +
  /// `NutrientDocumentView<T>`.
  static T buildAdapter<T extends NutrientController>() {
    final factory = _factories[T];
    if (factory != null) return factory() as T;

    // No specific controller type requested (a bare `NutrientDocumentView()`):
    // build a FRESH platform default viewer per view. Resolve this BEFORE the
    // shared global slot so two simultaneous bare views each own their own
    // controller (multi-view safe + disposed by the view) instead of clobbering
    // the one process-shared default — the A1 collision this design prevents.
    if (T == NutrientController) {
      final fallback = _makeDefaultAdapter();
      if (fallback is T) return fallback as T;
    }

    // Same, for a bare `NutrientInstantView()`: build a FRESH platform default
    // Instant controller per view (implements NutrientInstantController, so the
    // Instant sync methods are available on the surfaced controller).
    if (T == NutrientInstantController) {
      final fallback = _makeDefaultInstantAdapter();
      if (fallback is T) return fallback as T;
    }

    // Back-compat: a *typed* controller registered through the (deprecated)
    // global slots — only reached for a concrete T (a bare view took the
    // fresh-default path above). The slot's static type (NutrientPlatformAdapter)
    // is unrelated to T so `is T` can't promote; the real adapters implement
    // both, so the runtime check + cast is sound.
    final slot = _adapterSlotForCurrentPlatform();
    if (slot is T) return slot as T;

    throw StateError(
      'No adapter registered for $T. Pass `adapter:` to NutrientDocumentView, '
      'or register a factory with Nutrient.addAdapterClass<$T>(() => ...).',
    );
  }

  static NutrientPlatformAdapter? _adapterSlotForCurrentPlatform() {
    if (kIsWeb) return _webAdapter;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidAdapter;
      case TargetPlatform.iOS:
        return _iosAdapter;
      default:
        return _webAdapter;
    }
  }

  static NutrientPlatformAdapter? _makeDefaultAdapter() {
    final platform = NutrientFlutterPlatform.instance;
    if (platform == null) return null;
    try {
      return platform.createDefaultAdapter();
    } on UnimplementedError {
      return null;
    }
  }

  static NutrientPlatformAdapter? _makeDefaultInstantAdapter() {
    final platform = NutrientFlutterPlatform.instance;
    if (platform == null) return null;
    try {
      return platform.createDefaultInstantAdapter();
    } on UnimplementedError {
      return null;
    }
  }

  /// Whether [controller] is the process-shared adapter resolved from the
  /// (deprecated) global slots for the current platform — i.e. not a per-view
  /// instance that the view created and therefore owns.
  ///
  /// `NutrientDocumentView` uses this to decide adapter ownership: a controller
  /// it built from a factory (or the platform default) is disposed with the
  /// view, whereas the shared global adapter is left alone. Exposed (rather than
  /// reading the deprecated [currentAdapter]) so the SDK's own views don't trip
  /// the deprecation.
  static bool isSharedAdapter(NutrientController controller) =>
      identical(controller, _adapterSlotForCurrentPlatform());

  /// Get the Android platform adapter.
  ///
  /// Returns `null` if no Android adapter is registered.
  @Deprecated(
    'The global adapter slots are deprecated. Register a controller type with '
    'Nutrient.addAdapterClass<T>() and select it via NutrientDocumentView<T>. '
    'Will be removed in a future release.',
  )
  static NutrientPlatformAdapter? get androidAdapter => _androidAdapter;

  /// Get the iOS platform adapter.
  ///
  /// Returns `null` if no iOS adapter is registered.
  @Deprecated(
    'The global adapter slots are deprecated. Register a controller type with '
    'Nutrient.addAdapterClass<T>() and select it via NutrientDocumentView<T>. '
    'Will be removed in a future release.',
  )
  static NutrientPlatformAdapter? get iosAdapter => _iosAdapter;

  /// Get the Web platform adapter.
  ///
  /// Returns `null` if no Web adapter is registered.
  @Deprecated(
    'The global adapter slots are deprecated. Register a controller type with '
    'Nutrient.addAdapterClass<T>() and select it via NutrientDocumentView<T>. '
    'Will be removed in a future release.',
  )
  static NutrientPlatformAdapter? get webAdapter => _webAdapter;

  /// The version of the Nutrient Flutter bindings.
  ///
  /// This is the Dart/Flutter SDK version (the
  /// `nutrient_flutter_platform_interface` package version) — not the native
  /// PSPDFKit framework version. Keep it in sync with `pubspec.yaml` on each
  /// release.
  ///
  /// Example: `"1.1.0"`
  static String get version => _version;

  /// Single source of truth for [version]. Bump alongside `pubspec.yaml`.
  static const String _version = '1.1.0';

  /// Get the Android license key.
  ///
  /// Returns `null` if SDK not initialized or no Android key provided.
  static String? get androidLicenseKey => _androidLicenseKey;

  /// Get the iOS license key.
  ///
  /// Returns `null` if SDK not initialized or no iOS key provided.
  static String? get iosLicenseKey => _iosLicenseKey;

  /// Get the Web license key.
  ///
  /// Returns `null` if SDK not initialized or no Web key provided.
  static String? get webLicenseKey => _webLicenseKey;

  /// Get the license key for the current platform.
  ///
  /// Returns the appropriate license key based on the current platform.
  /// Returns `null` if SDK not initialized or no key for current platform.
  static String? get currentLicenseKey {
    if (!_initialized) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidLicenseKey;
      case TargetPlatform.iOS:
        return _iosLicenseKey;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        // Web is handled by kIsWeb check
        return _webLicenseKey;
    }
  }

  // Note: PDF generation (new-document / HTML→PDF) is intentionally not part
  // of this curated static surface. It's a sizeable native feature that needs
  // a typed cross-platform API; the plan (see catalog `CATALOG.md` row 29) is
  // to expose it as `NutrientPlatformAdapter.generatePdf(...)`. Until then,
  // reach the native processors through the platform adapter's native
  // accessors. The earlier `generatePdf*` stubs that only threw
  // `UnimplementedError` have been removed so the static surface has no
  // non-functional members.

  /// Whether the SDK has been initialized.
  static bool get isInitialized => _initialized;

  /// Reset the SDK state (for testing only).
  ///
  /// **WARNING**: This should only be used in tests.
  /// Calling this in production code may cause unexpected behavior.
  @visibleForTesting
  static Future<void> reset() async {
    await _androidAdapter?.dispose();
    await _iosAdapter?.dispose();
    await _webAdapter?.dispose();

    _androidAdapter = null;
    _iosAdapter = null;
    _webAdapter = null;
    _factories.clear();
    _androidLicenseKey = null;
    _iosLicenseKey = null;
    _webLicenseKey = null;
    _initialized = false;
  }
}
