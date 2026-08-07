///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as iface;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide AnnotationType;

import 'bindings/nutrient_android_sdk_bindings.dart' hide Nutrient;
import 'document/nutrient_document_android.dart';
import 'events/android_nutrient_event.dart';
import 'utils/annotation_tool_android_mapping.dart';
import 'utils/jni_file.dart';
import 'utils/jni_rect_f.dart';

/// Android platform adapter for Nutrient SDK.
///
/// This is the base adapter class for Android platform. Extend this class to create
/// custom adapters that implement the **adapter-as-controller pattern**.
///
/// ## Adapter-as-Controller Pattern
///
/// The adapter-as-controller pattern allows your adapter to serve as both:
/// 1. A platform adapter (handles Android SDK lifecycle and native access)
/// 2. A controller (provides cross-platform APIs to your app)
///
/// ```
/// AndroidAdapter (this class)
///        ↑ extends
/// YourAndroidAdapter ─────► implements YourController
///        │
///        └── The adapter IS the controller
/// ```
///
/// ## Creating a Custom Adapter
///
/// ```dart
/// // 1. Define your controller interface
/// abstract class MyController extends NutrientController {
///   Future<int> getPageCount();
///   Future<int> getCurrentPageIndex();
/// }
///
/// // 2. Create adapter that implements your controller
/// class MyAndroidAdapter extends AndroidAdapter implements MyController {
///   PdfDocument? _document;
///   PdfFragment? _fragment;
///   DocumentListener? _documentListener;
///
///   @override
///   Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
///     _fragment = pdfFragment;
///     // Set up document listener to receive document when loaded
///     _documentListener = DocumentListener.implement(
///       $DocumentListener(
///         onDocumentLoaded: (doc) => _document = doc,
///         // ... other callbacks
///       ),
///     );
///     pdfFragment.addDocumentListener(_documentListener!);
///   }
///
///   @override
///   Future<int> getPageCount() => Future.value(_document?.getPageCount() ?? 0);
///
///   @override
///   Future<int> getCurrentPageIndex() => Future.value(_fragment?.getPageIndex() ?? 0);
/// }
/// ```
///
/// ## Pre-Build Configuration
///
/// Customize the PdfUiFragmentBuilder before building via [configureFragment]:
///
/// ```dart
/// @override
/// Future<void> configureFragment(
///   NutrientViewHandle handle,
///   PdfUiFragmentBuilder builder,
///   Context context,
/// ) async {
///   await super.configureFragment(handle, builder, context);
///
///   // Create custom configuration
///   final config = PdfActivityConfiguration$Builder(context)
///     .scrollDirection(PageScrollDirection.HORIZONTAL)
///     .layoutMode(PageLayoutMode.SINGLE)
///     .build();
///
///   builder.configuration(config);
/// }
/// ```
///
/// ## Android SDK Access
///
/// Native SDK objects are available in lifecycle callbacks:
///
/// ```dart
/// @override
/// Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
///   // Set up document listener to receive native callbacks
///   _documentListener = DocumentListener.implement(
///     $DocumentListener(
///       onDocumentLoaded: (document) {
///         final pageCount = document.getPageCount();
///         debugPrint('Document has $pageCount pages');
///       },
///       onPageChanged: (document, pageIndex) {
///         debugPrint('Page changed to $pageIndex');
///       },
///     ),
///   );
///   pdfFragment.addDocumentListener(_documentListener!);
/// }
/// ```
///
/// ## Available Native Objects
///
/// - [PdfUiFragment] - Main UI component for displaying PDFs
/// - [PdfDocument] - Document model with page management
/// - [PdfFragment] - Lower-level fragment for document display
/// - [Context] - Android context for resource access
///
/// ## Lifecycle Callbacks
///
/// - [configureFragment] - Called before building, for pre-build configuration
/// - [onFragmentAttached] - Called when PdfUiFragment is attached
/// - [onPdfFragmentReady] - Called when PdfFragment is ready for document listeners
/// - [onFragmentDetached] - Called when fragment is detached (cleanup)
///
/// ## JNI Memory Management
///
/// Objects passed to adapter callbacks are managed by the platform.
/// Store references as needed but clean up in [onFragmentDetached].
///
/// ## Registration
///
/// ```dart
/// await Nutrient.initialize(
///   androidLicenseKey: 'YOUR_LICENSE_KEY',
///   androidAdapter: MyAndroidAdapter(),
/// );
/// ```
///
/// ## Documentation
///
/// - Nutrient Android SDK: https://www.nutrient.io/guides/android/
/// - API Reference: https://www.nutrient.io/api/android/kdoc/
abstract class AndroidAdapter extends NutrientController
    implements NutrientPlatformAdapter {
  @override
  TargetPlatform get platform => TargetPlatform.android;

  // ---------------------------------------------------------------------------
  // Android-specific event stream
  // ---------------------------------------------------------------------------

  final StreamController<AndroidNutrientEvent> _androidEventController =
      StreamController<AndroidNutrientEvent>.broadcast();

  /// A broadcast stream of Android-only Nutrient SDK events.
  ///
  /// Covers native Android callbacks that have no cross-platform equivalent.
  /// Cross-platform events are available on `controller.events`.
  ///
  /// ```dart
  /// final adapter = controller as AndroidAdapter;
  /// adapter.androidEvents.listen((event) {
  ///   switch (event) {
  ///     case AndroidAnnotationZOrderChangedEvent(:final pageIndex):
  ///       print('Z-order changed on page $pageIndex');
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<AndroidNutrientEvent> get androidEvents =>
      _androidEventController.stream;

  /// Emits an Android-only event to all [androidEvents] subscribers.
  ///
  /// Call this from subclasses to push platform-specific events. Silently
  /// no-ops if the controller has been disposed.
  @protected
  void emitAndroidEvent(AndroidNutrientEvent event) {
    if (!_androidEventController.isClosed) _androidEventController.add(event);
  }

  // ---------------------------------------------------------------------------
  // JNI listener references (held to prevent GC and for cleanup)
  // ---------------------------------------------------------------------------

  DocumentListener? _documentListener;
  AnnotationProvider$OnAnnotationUpdatedListener? _annotationUpdatedListener;
  OnAnnotationSelectedListener? _annotationSelectedListener;
  FormManager$OnFormElementUpdatedListener? _formElementUpdatedListener;
  TextSelectionManager$OnTextSelectionChangeListener?
      _textSelectionChangeListener;

  // ---------------------------------------------------------------------------
  // Package-internal accessors
  // ---------------------------------------------------------------------------

  /// Package-internal access to the view handle for document classes.
  ///
  /// [NutrientDocumentAndroid] lives in the same package and needs access to the
  /// native instances registered in the view handle.
  @internal
  NutrientViewHandle? get internalViewHandle => viewHandle;

  // ---------------------------------------------------------------------------
  // Typed native accessors (raw escape hatch)
  //
  // These return the underlying Android SDK JNI objects directly — no
  // wrapping, no opinion. Use them to reach any Android-only capability
  // that isn't exposed on the cross-platform [NutrientController] /
  // managers (form creation, typed form listeners, advanced annotation
  // providers, etc.).
  //
  // The accessors return `null` until the platform view has registered
  // the corresponding native instance; safe to call eagerly with `?.`
  // chains.
  // ---------------------------------------------------------------------------

  /// The native [PdfDocument] JNI instance, or `null` if not yet registered.
  PdfDocument? get nativePdfDocument =>
      viewHandle?.getNativeInstance('pdfDocument') as PdfDocument?;

  /// The native [PdfFragment] JNI instance, or `null` if not yet registered.
  PdfFragment? get nativePdfFragment =>
      viewHandle?.getNativeInstance('pdfFragment') as PdfFragment?;

  /// The native [PdfUiFragment] JNI instance, or `null` if not yet registered.
  PdfUiFragment? get nativePdfUiFragment =>
      viewHandle?.getNativeInstance('pdfUiFragment') as PdfUiFragment?;

  /// Convenience accessor for the [FormProvider] on the active document.
  ///
  /// Returns `null` until a document is loaded. Once available, exposes the
  /// full Android form API — `getFormFields()`, `addFormElement(s)ToPage*()`,
  /// `removeFormElementFromPage*()`, `getTabOrder*()`, and all 5
  /// `addOn*FormFieldUpdatedListener` registrations.
  ///
  /// ```dart
  /// adapter.nativeFormProvider
  ///     ?.getFormFieldWithFullyQualifiedName('First Name'.toJString())
  ///     ?.reset();
  /// ```
  FormProvider? get nativeFormProvider => nativePdfDocument?.getFormProvider();

  /// The active [PdfActivityConfiguration] for the displayed viewer, or `null`
  /// before the UI fragment attaches.
  ///
  /// Unlike the `configureFragment` builder — which is gone once the fragment is
  /// built — this is re-fetchable any time the UI fragment is live. Read it to
  /// inspect the applied configuration, or pair it with [nativePdfUiFragment]'s
  /// `setConfiguration(...)` to reconfigure the running viewer.
  PdfActivityConfiguration? get nativeConfiguration =>
      nativePdfUiFragment?.configuration;

  /// The host Android `Activity` backing the viewer, or `null` when unavailable
  /// (it is engine-scoped).
  ///
  /// Returned as a raw [JObject] rather than a typed handle: `android.app.Activity`
  /// isn't in the jnigen config, so the generated `Activity` binding is a
  /// method-less stub. Use this when you need to hand the Activity to a JNI call
  /// that expects one, or to a type you generate yourself.
  JObject? get nativeActivity =>
      viewHandle?.getNativeInstance('pdfActivity') as JObject?;

  /// Runs [action] on the Android **main (platform) thread** and completes with
  /// its result.
  ///
  /// ## Why this exists — the main-thread trap
  ///
  /// Dart JNI calls issued from your adapter run on Flutter's UI thread, which
  /// on Android is **not** the platform/main thread. View-mutating
  /// [PdfFragment] calls (`zoomTo`, `setPageIndex`, `scrollTo`,
  /// `enterAnnotationCreationMode`, …) take a "run immediately if the view is
  /// laid out" fast path that only executes when invoked from the main thread.
  /// Called off it they **silently no-op** — there is no exception, the view
  /// simply doesn't change.
  ///
  /// Wrap any such call in [runOnMainThread] so the JNI invocations inside the
  /// closure execute on the main thread:
  ///
  /// ```dart
  /// await adapter.runOnMainThread(() {
  ///   adapter.nativePdfFragment?.setPageIndex(3, true);
  /// });
  /// ```
  ///
  /// Read-only JNI calls (`getPageCount`, `getZoomScale`, projection/coordinate
  /// reads, …) are safe from either thread and don't need this — reach for it
  /// whenever a native call *changes* the view and appears to do nothing.
  ///
  /// The native objects you touch inside [action] must be the jnigen-generated
  /// instances from the adapter's accessors ([nativePdfFragment],
  /// [nativePdfDocument], …); they are global-reference backed and therefore
  /// valid across threads. Capture them outside the closure (as in the example)
  /// so the accessor lookup itself stays on the calling isolate.
  ///
  /// This is the safe, public counterpart to the internal per-view
  /// `MethodChannel` hop that [zoomToRect] uses.
  Future<T> runOnMainThread<T>(FutureOr<T> Function() action) {
    return ui.runOnPlatformThread<T>(action);
  }

  // ---------------------------------------------------------------------------
  // Document
  // ---------------------------------------------------------------------------

  NutrientDocumentAndroid? _document;

  @override
  NutrientDocumentInterface get document => _document ??= createDocument();

  /// Creates the [NutrientDocumentAndroid] for this adapter.
  ///
  /// Override to provide a custom document implementation:
  /// ```dart
  /// class MyDocument extends NutrientDocumentAndroid {
  ///   MyDocument(super.adapter);
  ///   @override
  ///   AnnotationManagerAndroid createAnnotationManager() => MyAnnotations(this);
  /// }
  ///
  /// class MyAndroidAdapter extends AndroidAdapter {
  ///   @override
  ///   NutrientDocumentAndroid createDocument() => MyDocument(this);
  /// }
  /// ```
  @protected
  NutrientDocumentAndroid createDocument() => NutrientDocumentAndroid(this);

  /// Opens a document without a view (headless access).
  ///
  /// Loads a [PdfDocument] directly via [PdfDocumentLoader] (JNI) and wraps it
  /// in a [NutrientDocumentAndroid] in headless mode — no fragment is created.
  /// All managers and document operations resolve to this isolated instance.
  ///
  /// Note: [PdfDocumentLoader.openDocument] is synchronous and will block the
  /// calling thread while metadata is loaded. For large documents this may be
  /// noticeable on the UI isolate.
  ///
  /// Call [NutrientDocumentInterface.close] when done to release the JNI
  /// reference.
  ///
  /// ```dart
  /// final doc = await adapter.openDocument('path/to/doc.pdf');
  /// final count = await doc.getPageCount();
  /// await doc.close();
  /// ```
  @override
  Future<NutrientDocumentInterface> openDocument(
    String path, {
    String? password,
  }) async {
    // Opening a document needs a Context. jni 1.0 moved the Android context
    // accessors to package:jni_flutter; use the application context to avoid
    // leaking an Activity through long-lived native references on the
    // PdfDocument (the previous Jni.getCurrentActivity() accessor is gone).
    final context = androidApplicationContext.as(Context.type);
    final uri = _createUri(path);
    try {
      final PdfDocument document;
      if (isImageDocumentPath(path)) {
        // Image documents (JPG/PNG/TIFF/…) open via the image loader; the
        // backing PdfDocument drives the same headless interface as a PDF.
        final imageDocument = ImageDocumentLoader.openDocument(context, uri);
        final backing = imageDocument.getDocument();
        imageDocument.release();
        if (backing == null) {
          throw StateError(
              'AndroidAdapter.openDocument: image document at "$path" '
              'has no backing PdfDocument.');
        }
        document = backing;
      } else {
        document = (password != null && password.isNotEmpty)
            ? PdfDocumentLoader.openDocument(context, uri, password.toJString())
            : PdfDocumentLoader.openDocument$2(context, uri);
      }
      return NutrientDocumentAndroid.headless(this, document);
    } finally {
      uri.release();
    }
  }

  static int _headlessBytesCounter = 0;

  @override
  Future<NutrientDocumentInterface> openDocumentFromBytes(
    Uint8List bytes, {
    String? password,
  }) async {
    // The Android loader takes a file URI; persist the bytes to a temp file
    // and open that. A monotonic counter guarantees a unique cache key (and
    // temp file) per call — `identityHashCode` is not collision-free across
    // different byte arrays. The temp file lives in the OS temp dir until
    // `DocumentPathResolver.clearAll()` or the OS reclaims it.
    final path = await DocumentPathResolver.instance.resolveBytes(
      bytes,
      cacheKey: 'android-headless-bytes-${_headlessBytesCounter++}',
    );
    return openDocument(path, password: password);
  }

  /// Builds a [Uri] from [path], prefixing `file://` for plain absolute paths
  /// — mirrors `NutrientViewAndroid._createUri`.
  static Uri _createUri(String path) {
    final candidate = (path.startsWith('file://') ||
            path.startsWith('content://') ||
            path.startsWith('http://') ||
            path.startsWith('https://'))
        ? path
        : 'file://$path';
    final uri = Uri.parse(candidate.toJString());
    if (uri == null) {
      throw ArgumentError('Failed to parse URI: $candidate');
    }
    return uri;
  }

  // ---------------------------------------------------------------------------
  // Annotation processing
  // ---------------------------------------------------------------------------

  /// Processes the annotations of the document at [sourcePath] and writes the
  /// result to [destinationPath].
  ///
  /// Mirrors the legacy plugin's `FlutterPdfDocument.processAnnotations`: opens
  /// [sourcePath] headlessly via [PdfDocumentLoader], builds a
  /// [PdfProcessorTask] that changes either every annotation
  /// ([iface.AnnotationType.all]) or only [type]'s native equivalent, and
  /// synchronously processes it into [destinationPath] via
  /// [PdfProcessor.processDocument].
  ///
  /// For an in-place call ([sourcePath] and [destinationPath] resolve to the
  /// same file) the result is written to a sibling temp file and moved over
  /// the destination once processing succeeds — the native
  /// `PdfProcessor.processDocument` refuses an output file that points at its
  /// own source (`IllegalStateException`). This matches the iOS adapter's
  /// in-place handling and preserves the original on failure.
  ///
  /// The processing itself runs in a short-lived worker isolate:
  /// `PdfProcessor.processDocument` rewrites the whole document synchronously
  /// on the calling thread (its own docs say not to run it on the main
  /// thread), so running it on the root isolate froze the UI for the whole
  /// write. The closure captures only sendable values (paths and enum
  /// constants); every JNI reference is created and released inside the
  /// worker, and the application context is a process-global reference that
  /// is safe to use from any thread.
  @override
  Future<bool> processAnnotations(
    String sourcePath,
    iface.AnnotationType type,
    iface.AnnotationProcessingMode mode,
    String destinationPath,
  ) {
    return Isolate.run(
      () => _processAnnotationsSync(sourcePath, type, mode, destinationPath),
    );
  }

  /// Synchronous body of [processAnnotations]. Runs inside a worker isolate —
  /// must stay `static` so the [Isolate.run] closure doesn't capture the
  /// adapter (JNI wrappers and stream controllers aren't sendable).
  static bool _processAnnotationsSync(
    String sourcePath,
    iface.AnnotationType type,
    iface.AnnotationProcessingMode mode,
    String destinationPath,
  ) {
    // Detect in-place processing: the native processor throws if the output
    // file is the source. Write to a sibling temp file (same directory ⇒
    // same filesystem, so the rename below is atomic) and move it over the
    // destination only after a successful write.
    final inPlace = _normalizedPath(io.File(sourcePath)) ==
        _normalizedPath(io.File(destinationPath));
    final writeTargetPath =
        inPlace ? '$destinationPath.nutrient-processing.tmp' : destinationPath;
    final writeTargetFile = io.File(writeTargetPath);
    if (inPlace && writeTargetFile.existsSync()) {
      writeTargetFile.deleteSync();
    }

    final context = androidApplicationContext.as(Context.type);
    final uri = _createUri(sourcePath);
    PdfDocument? document;
    PdfProcessorTask? baseTask;
    PdfProcessorTask? task;
    PdfProcessorTask$AnnotationProcessingMode? nativeMode;
    AnnotationType? nativeType;
    JObject? destinationFile;
    File? javaFile;
    try {
      document = PdfDocumentLoader.openDocument$2(context, uri);

      nativeMode = _annotationProcessingModeToNative(mode);
      baseTask = PdfProcessorTask.fromDocument(document);
      if (type == iface.AnnotationType.all) {
        task = baseTask.changeAllAnnotations(nativeMode);
      } else {
        nativeType = _annotationTypeToNative(type);
        task = baseTask.changeAnnotationsOfType(nativeType, nativeMode);
      }

      if (task == null) {
        throw StateError(
            'AndroidAdapter.processAnnotations: failed to build a PdfProcessorTask '
            'for "$sourcePath".');
      }

      destinationFile = JniFile.fromPath(writeTargetPath);
      javaFile = destinationFile.as(File.type);
      PdfProcessor.processDocument(task, javaFile);
      if (inPlace) {
        // Rename over the source only after the write succeeded. The open
        // native document still reads the old inode until released below.
        writeTargetFile.renameSync(destinationPath);
      }
      return true;
    } catch (_) {
      if (inPlace && writeTargetFile.existsSync()) {
        // Don't leave a partial temp file behind on failure.
        writeTargetFile.deleteSync();
      }
      rethrow;
    } finally {
      // Release every JNI reference here — including the intermediate
      // baseTask/nativeMode/nativeType and the `.as(File.type)` wrapper —
      // so the exception paths (corrupt source, failed task build, failed
      // write) don't leak global refs.
      javaFile?.release();
      destinationFile?.release();
      task?.release();
      nativeType?.release();
      baseTask?.release();
      nativeMode?.release();
      document?.release();
      uri.release();
      context.release();
    }
  }

  /// Absolute, normalized filesystem path, used to detect the in-place
  /// processing case (source and destination pointing at the same file).
  /// Resolves `.`/`..` segments and relative paths; symlinks are not resolved.
  static String _normalizedPath(io.File file) =>
      file.absolute.uri.normalizePath().toFilePath();

  /// Maps the cross-platform [iface.AnnotationProcessingMode] to the native
  /// `PdfProcessorTask.AnnotationProcessingMode`. `embed` maps to `KEEP` — the
  /// native enum has no `EMBED` member; this matches the legacy plugin's
  /// `ProcessorHelper.processModeFromString`.
  static PdfProcessorTask$AnnotationProcessingMode
      _annotationProcessingModeToNative(
    iface.AnnotationProcessingMode mode,
  ) {
    switch (mode) {
      case iface.AnnotationProcessingMode.flatten:
        return PdfProcessorTask$AnnotationProcessingMode.FLATTEN;
      case iface.AnnotationProcessingMode.remove:
        return PdfProcessorTask$AnnotationProcessingMode.DELETE;
      case iface.AnnotationProcessingMode.embed:
        return PdfProcessorTask$AnnotationProcessingMode.KEEP;
      case iface.AnnotationProcessingMode.print:
        return PdfProcessorTask$AnnotationProcessingMode.PRINT;
    }
  }

  /// Maps the cross-platform [iface.AnnotationType] to the native
  /// `com.pspdfkit.annotations.AnnotationType`, matching the legacy plugin's
  /// `FlutterPdfDocument.processAnnotations` `when` block exactly (including
  /// `image` → `STAMP`, and `none`/`undefined` → `NONE`).
  ///
  /// [iface.AnnotationType.all] is not handled here — callers branch on it
  /// before calling this, since it maps to `changeAllAnnotations` rather than
  /// a native `AnnotationType` value.
  static AnnotationType _annotationTypeToNative(iface.AnnotationType type) {
    switch (type) {
      case iface.AnnotationType.all:
      case iface.AnnotationType.none:
      case iface.AnnotationType.undefined:
        return AnnotationType.NONE;
      case iface.AnnotationType.link:
        return AnnotationType.LINK;
      case iface.AnnotationType.highlight:
        return AnnotationType.HIGHLIGHT;
      case iface.AnnotationType.strikeout:
        return AnnotationType.STRIKEOUT;
      case iface.AnnotationType.underline:
        return AnnotationType.UNDERLINE;
      case iface.AnnotationType.squiggly:
        return AnnotationType.SQUIGGLY;
      case iface.AnnotationType.freeText:
        return AnnotationType.FREETEXT;
      case iface.AnnotationType.ink:
        return AnnotationType.INK;
      case iface.AnnotationType.square:
        return AnnotationType.SQUARE;
      case iface.AnnotationType.circle:
        return AnnotationType.CIRCLE;
      case iface.AnnotationType.line:
        return AnnotationType.LINE;
      case iface.AnnotationType.note:
        return AnnotationType.NOTE;
      case iface.AnnotationType.stamp:
        return AnnotationType.STAMP;
      case iface.AnnotationType.caret:
        return AnnotationType.CARET;
      case iface.AnnotationType.media:
        return AnnotationType.RICHMEDIA;
      case iface.AnnotationType.screen:
        return AnnotationType.SCREEN;
      case iface.AnnotationType.widget:
        return AnnotationType.WIDGET;
      case iface.AnnotationType.file:
        return AnnotationType.FILE;
      case iface.AnnotationType.sound:
        return AnnotationType.SOUND;
      case iface.AnnotationType.polygon:
        return AnnotationType.POLYGON;
      case iface.AnnotationType.polyline:
        return AnnotationType.POLYLINE;
      case iface.AnnotationType.popup:
        return AnnotationType.POPUP;
      case iface.AnnotationType.watermark:
        return AnnotationType.WATERMARK;
      case iface.AnnotationType.trapNet:
        return AnnotationType.TRAPNET;
      case iface.AnnotationType.type3d:
        return AnnotationType.TYPE3D;
      case iface.AnnotationType.redact:
        return AnnotationType.REDACT;
      case iface.AnnotationType.image:
        return AnnotationType.STAMP;
    }
  }

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Default implementation - can be overridden
  }

  @override
  Future<void> dispose() async {
    await detachView();
    await super.dispose();
  }

  /// Called by [NutrientViewAndroid] when its platform view is being torn
  /// down.
  ///
  /// Performs per-view cleanup — closes the view-attached document and
  /// invokes [onFragmentDetached] — without permanently disposing the
  /// underlying [NutrientController]. Use this instead of [dispose] when
  /// the adapter is registered globally (via `Nutrient.initialize`) and
  /// must remain usable for subsequent views.
  Future<void> detachView() async {
    // Run per-view cleanup at most once per attach. Capture-and-null the
    // document synchronously (before the first await) so a concurrent second
    // call can't double-close it. See [consumeViewAttached].
    if (!consumeViewAttached()) return;
    final document = _document;
    _document = null;
    await document?.close();
    await onFragmentDetached();
  }

  /// Configure the PdfUiFragmentBuilder before building the fragment.
  ///
  /// This method is called before the fragment is built, allowing
  /// subclasses to customize the configuration.
  ///
  /// The builder allows you to set:
  /// - Activity configuration (scroll direction, layout mode, fit mode, etc.)
  /// - Document passwords
  /// - Content signatures
  /// - And other PdfUiFragmentBuilder options
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> configureFragment(
  ///   NutrientViewHandle handle,
  ///   PdfUiFragmentBuilder builder,
  ///   Context context,
  /// ) async {
  ///   await super.configureFragment(handle, builder, context);
  ///
  ///   // Create custom configuration
  ///   final config = PdfActivityConfiguration$Builder(context)
  ///     .scrollDirection(PageScrollDirection.HORIZONTAL)
  ///     .layoutMode(PageLayoutMode.SINGLE)
  ///     .fitMode(PageFitMode.FIT_TO_WIDTH)
  ///     .build();
  ///
  ///   builder.configuration(config);
  /// }
  /// ```
  Future<void> configureFragment(
    NutrientViewHandle handle,
    PdfUiFragmentBuilder builder,
    Context context,
  ) async {
    debugPrint('[AndroidAdapter] Configuring fragment for: ${handle.viewId}');
    // Subclasses can override to customize the PdfUiFragmentBuilder
  }

  /// Called when the PdfUiFragment is created and attached.
  ///
  /// This is the primary entry point for accessing native instances.
  /// The fragment reference remains valid until [onFragmentDetached] is called.
  ///
  /// **Parameters:**
  /// - `fragment` - Native PdfUiFragment instance via JNI
  /// - `context` - Android Context for resource access
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// Future<void> onFragmentAttached(
  ///   PdfUiFragment fragment,
  ///   Context context,
  /// ) async {
  ///   // Access fragment methods through JNI
  ///   final config = fragment.getConfiguration();
  ///   debugPrint('Fragment attached with config');
  /// }
  /// ```
  Future<void> onFragmentAttached(
    PdfUiFragment fragment,
    Context context,
  ) async {}

  /// Called when the PdfFragment is ready and attached.
  ///
  /// Use this callback to set up document listeners and access the fragment's APIs.
  /// The document instance can be obtained from the fragment using `pdfFragment.getDocument()`,
  /// or better yet, use a `DocumentListener` to receive the document when it's loaded.
  ///
  /// **Parameters:**
  /// - `pdfFragment` - The PdfFragment for accessing document and fragment APIs
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// ```
  ///
  /// Called internally by the SDK when the [PdfFragment] is ready. Wires up
  /// the built-in JNI listeners that feed [events] and [androidEvents], then
  /// calls [onFragmentReady] for subclass customisation.
  ///
  /// Do not override this method directly — override [onFragmentReady] instead.
  Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
    _setupEventListeners(pdfFragment);
    await onFragmentReady(pdfFragment);
  }

  /// Called after [onPdfFragmentReady] finishes wiring the built-in listeners.
  ///
  /// Override this to set up your own document listeners or access the native
  /// fragment APIs. The SDK event listeners are already registered at this
  /// point, so [events] and [androidEvents] are live.
  ///
  /// ```dart
  /// @override
  /// Future<void> onFragmentReady(PdfFragment pdfFragment) async {
  ///   final document = pdfFragment.getDocument();
  ///   if (document != null) {
  ///     debugPrint('Document: ${document.getPageCount()} pages');
  ///   }
  /// }
  /// ```
  @protected
  Future<void> onFragmentReady(PdfFragment pdfFragment) async {}

  void _setupEventListeners(PdfFragment pdfFragment) {
    // Document lifecycle + navigation
    _documentListener = DocumentListener.implement(
      $DocumentListener(
        onDocumentLoaded: (doc) => emitEvent(DocumentLoadedEvent(document)),
        onDocumentLoadFailed: (err) =>
            emitEvent(DocumentErrorEvent(err.toString())),
        onDocumentSave: (doc, opts) => true, // allow saves to proceed
        onDocumentSaved: (doc) => emitEvent(const DocumentSavedEvent()),
        onDocumentSaveFailed: (doc, err) =>
            emitAndroidEvent(AndroidDocumentSaveFailedEvent(err.toString())),
        onDocumentSaveCancelled: (doc) =>
            emitAndroidEvent(const AndroidDocumentSaveCancelledEvent()),
        onPageChanged: (doc, pageIndex) =>
            emitEvent(PageChangedEvent(pageIndex)),
        onPageClick: (doc, pageIndex, motionEvent, pointF, annotation) {
          emitEvent(PageClickedEvent(
            pageIndex,
            point: pointF != null ? Offset(pointF.x, pointF.y) : null,
          ));
          return false; // do not consume the click
        },
        onDocumentZoomed: (doc, pageIndex, zoomScale) => emitAndroidEvent(
            AndroidDocumentZoomedEvent(pageIndex, zoomScale.toDouble())),
        onDocumentClick: () => false,
        onPageUpdated: (doc, pageIndex) {},
      ),
    );
    pdfFragment.addDocumentListener(_documentListener!);

    // Annotation CRUD
    _annotationUpdatedListener =
        AnnotationProvider$OnAnnotationUpdatedListener.implement(
      $AnnotationProvider$OnAnnotationUpdatedListener(
        onAnnotationCreated: (ann) =>
            emitEvent(AnnotationCreatedEvent([_annotationToJson(ann)])),
        onAnnotationUpdated: (ann) =>
            emitEvent(AnnotationUpdatedEvent([_annotationToJson(ann)])),
        onAnnotationRemoved: (ann) =>
            emitEvent(AnnotationDeletedEvent([_annotationToJson(ann)])),
        onAnnotationZOrderChanged: (pageIndex, above, below) {
          emitAndroidEvent(AndroidAnnotationZOrderChangedEvent(
            pageIndex,
            _annotationListToJson(above),
            _annotationListToJson(below),
          ));
        },
      ),
    );
    pdfFragment.addOnAnnotationUpdatedListener(_annotationUpdatedListener!);

    // Annotation selection / deselection
    _annotationSelectedListener = OnAnnotationSelectedListener.implement(
      $OnAnnotationSelectedListener(
        onPrepareAnnotationSelection: (controller, ann, isLongPress) => true,
        // jni 1.0's listener callbacks deliver a non-null Annotation.
        onAnnotationSelected: (ann, isLongPress) {
          emitEvent(AnnotationSelectedEvent([_annotationToJson(ann)]));
        },
        onAnnotationSelectionFinished: (annotations, isLongPress) {},
        onAnnotationDeselected: (ann, b) {
          emitEvent(AnnotationDeselectedEvent([_annotationToJson(ann)]));
        },
        // Added to the SDK listener interface in 11.5; no cross-platform event
        // maps to it yet, so it's a no-op.
        onAnnotationWritingModeChanged: (active) {},
      ),
    );
    pdfFragment.addOnAnnotationSelectedListener(_annotationSelectedListener!);

    // Form field updates
    _formElementUpdatedListener =
        FormManager$OnFormElementUpdatedListener.implement(
      $FormManager$OnFormElementUpdatedListener(
        onFormElementUpdated: (formElement) {
          emitEvent(
              FormFieldUpdatedEvent(_annotationToJson(formElement.annotation)));
        },
      ),
    );
    pdfFragment.addOnFormElementUpdatedListener(_formElementUpdatedListener!);

    // Text selection
    _textSelectionChangeListener =
        TextSelectionManager$OnTextSelectionChangeListener.implement(
      $TextSelectionManager$OnTextSelectionChangeListener(
        onBeforeTextSelectionChange: (before, after) => true,
        onAfterTextSelectionChange: (before, after) {
          final text = after?.text?.toDartString();
          emitEvent(TextSelectionChangedEvent(text));
        },
      ),
    );
    pdfFragment.addOnTextSelectionChangeListener(_textSelectionChangeListener!);
  }

  /// Serialises a native [Annotation] to InstantJSON, never throwing.
  ///
  /// These conversions run inside JNI listener callbacks dispatched through a
  /// `java.lang.reflect.Proxy`. A throwable escaping such a callback surfaces
  /// as an `UndeclaredThrowableException` on the Android main thread and
  /// crashes the whole process — so it must be contained here.
  ///
  /// `toInstantJson()` throws `IllegalStateException: Can't create json from
  /// annotation when annotation is not attached!` for an annotation the SDK has
  /// already detached from its provider. Deleting a *selected* annotation hits
  /// this on multiple listeners in sequence — `onAnnotationDeselected` (the
  /// SDK deselects before removing) and `onAnnotationRemoved` — since the
  /// annotation is detached by the time either fires. In that case we fall back
  /// to a minimal `{ "uuid": … }` payload so listeners still get a stable
  /// identifier instead of a crash. (Delete/deselect consumers only need to
  /// know *which* annotation it was.) Used by every annotation-event callback
  /// (create / update / remove / select / deselect / form-field update).
  String _annotationToJson(Annotation ann) {
    try {
      return ann.toInstantJson().toDartString(releaseOriginal: true);
    } catch (e) {
      String? uuid;
      try {
        uuid = ann.uuid.toDartString(releaseOriginal: true);
      } catch (_) {
        uuid = null;
      }
      debugPrint('[AndroidAdapter] toInstantJson failed for annotation '
          '(uuid: $uuid): $e — emitting minimal payload');
      return jsonEncode({'uuid': uuid, 'type': 'pspdfkit/unknown'});
    }
  }

  List<String> _annotationListToJson(JList<Annotation> annotations) {
    final result = <String>[];
    for (var i = 0; i < annotations.size(); i++) {
      result.add(_annotationToJson(annotations.get(i)!));
    }
    return result;
  }

  /// Called when the fragment is about to be detached.
  ///
  /// Clean up any native references or listeners here.
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// Future<void> onFragmentDetached() async {
  ///   await super.onFragmentDetached();
  ///   // Additional cleanup
  /// }
  /// ```
  @mustCallSuper
  Future<void> onFragmentDetached() async {
    _documentListener = null;
    _annotationUpdatedListener = null;
    _annotationSelectedListener = null;
    _formElementUpdatedListener = null;
    _textSelectionChangeListener = null;
    await _androidEventController.close();
  }

  // ---------------------------------------------------------------------------
  // Viewport and zoom
  // ---------------------------------------------------------------------------

  PdfFragment _requireFragment(String methodName) {
    final fragment = nativePdfFragment;
    if (fragment == null) {
      throw StateError(
          '$methodName called before the PdfFragment was attached. '
          'Wait for onPdfFragmentReady before invoking view-controller methods.');
    }
    return fragment;
  }

  @override
  Future<ui.Rect> getVisibleRect(int pageIndex) async {
    final fragment = _requireFragment('getVisibleRect');
    final rectF = JniRectF.empty();
    try {
      final hasVisible =
          fragment.getVisiblePdfRect(rectF.as(RectF.type), pageIndex);
      if (!hasVisible) {
        // Page isn't visible (e.g. page index outside viewport). Return an
        // empty rect rather than fabricating a coordinate.
        return ui.Rect.zero;
      }
      // PSPDFKit uses PDF page coordinates with a bottom-left origin (y grows
      // upward), so the native RectF's `top` holds the LARGER y value and
      // `bottom` the smaller. The cross-platform contract (and the iOS
      // implementation) report the visible rect with `top` = the bottom edge
      // (smaller y) and a positive height, so swap top/bottom here.
      final raw = JniRectF.toFlutterRect(rectF);
      return ui.Rect.fromLTRB(raw.left, raw.bottom, raw.right, raw.top);
    } finally {
      rectF.release();
    }
  }

  @override
  Future<void> zoomToRect(int pageIndex, ui.Rect rect) async {
    // `PdfFragment.zoomTo` must run on the Android main thread — its
    // "run immediately if laid out" path only executes synchronously when
    // called from the UI thread, and a direct JNI call runs on the Flutter UI
    // thread instead, so the view mutation silently no-ops. [runOnMainThread]
    // (which wraps `dart:ui` `runOnPlatformThread`) executes the JNI calls
    // inside the closure on the platform/main thread, so the zoom applies —
    // the safe public primitive replaces the internal-only per-view
    // `MethodChannel` hop this method used to take.
    //
    // The native RectF uses PDF page coordinates (bottom-left origin, y up), so
    // its `top` field holds the larger y. The incoming [rect] follows the
    // cross-platform / iOS contract where `rect.top` is the bottom edge and the
    // rect extends upward, so map `top` → `rect.top + rect.height` and
    // `bottom` → `rect.top`.
    final fragment = _requireFragment('zoomToRect');
    await runOnMainThread(() {
      final rectF = JniRectF.ltrb(
        rect.left,
        rect.top + rect.height,
        rect.left + rect.width,
        rect.top,
      );
      try {
        fragment.zoomTo$1(rectF.as(RectF.type), pageIndex, 0);
      } finally {
        rectF.release();
      }
    });
  }

  @override
  Future<double> getZoomScale(int pageIndex) async {
    return _requireFragment('getZoomScale').getZoomScale(pageIndex);
  }

  // ---------------------------------------------------------------------------
  // Annotation creation mode
  // ---------------------------------------------------------------------------

  @override
  Future<bool?> enterAnnotationCreationMode(
      [iface.AnnotationTool? annotationTool]) async {
    final fragment = _requireFragment('enterAnnotationCreationMode');
    final tool = annotationTool ?? iface.AnnotationTool.inkPen;
    final androidTool = toAndroidAnnotationTool(tool);
    if (androidTool == null) {
      // No Android equivalent for this tool.
      return false;
    }
    try {
      // The Kotlin SDK deprecated enterAnnotationCreationMode in favour of
      // enterAnnotatingMode (same behaviour, renamed). The current jnigen
      // bindings only expose the deprecated method; revisit when bindings
      // are regenerated. (HYB-959)
      fragment.enterAnnotationCreationMode$1(androidTool);
      return true;
    } finally {
      androidTool.release();
    }
  }

  @override
  Future<bool?> exitAnnotationCreationMode() async {
    _requireFragment('exitAnnotationCreationMode').exitCurrentlyActiveMode();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Toolbar customization
  // ---------------------------------------------------------------------------

  /// Custom main-toolbar item id → Dart `onPressed`, kept so native taps can
  /// be dispatched back to the right callback.
  final Map<String, ui.VoidCallback> _toolbarItemCallbacks = {};

  /// Replaces the main toolbar's custom items with the [CustomToolbarItem]s in
  /// [items]. Built-in items are ignored on Android (reordering the native
  /// built-ins is a web-only capability — see the parity matrix on
  /// [ToolbarItem]). Re-callable any time to add, remove, enable, or disable
  /// custom buttons.
  ///
  /// The descriptors are serialized to the native [NutrientPdfUiFragment] over
  /// the per-view method channel; taps return via `onMainToolbarItemTapped` and
  /// are routed to the matching [CustomToolbarItem.onPressed].
  @override
  Future<void> setMainToolbarItems(List<ToolbarItem> items) async {
    final handle = viewHandle;
    if (handle == null) return;

    final custom = items.whereType<CustomToolbarItem>().toList();

    _toolbarItemCallbacks
      ..clear()
      ..addEntries(custom
          .where((item) => item.onPressed != null)
          .map((item) => MapEntry(item.id, item.onPressed!)));

    final payload = <Map<String, dynamic>>[
      for (final item in custom)
        {
          'id': item.id,
          if (item.title != null) 'title': item.title,
          if (item.disabled != null) 'disabled': item.disabled,
        },
    ];

    try {
      final channel =
          MethodChannel('com.nutrient.fragment_container.${handle.viewId}');
      await channel.invokeMethod<void>('setMainToolbarItems', {
        'items': payload,
      });
    } catch (e) {
      debugPrint(
          '[AndroidAdapter] setMainToolbarItems failed: ${e.runtimeType}');
    }
  }

  /// Routes a native main-toolbar tap (identified by [id]) to the matching
  /// [CustomToolbarItem.onPressed]. Called by [NutrientViewAndroid] from the
  /// per-view method channel; not part of the public API.
  void handleMainToolbarItemTapped(String id) {
    _toolbarItemCallbacks[id]?.call();
  }

  /// Replaces the annotation **creation** toolbar (the tool picker) with [items]
  /// — reorder, add, remove, or group the annotation tools. Serializes each item
  /// (tool name or `{representative, items}` group) and sends it to the native
  /// [NutrientPdfUiFragment], which applies a `MenuItemGroupingRule`.
  @override
  Future<void> setAnnotationToolbarItems(
      List<AnnotationToolbarItem> items) async {
    final handle = viewHandle;
    if (handle == null) return;

    final payload = <Object>[
      for (final item in items)
        switch (item) {
          AnnotationToolGroup(:final representative, :final items) => {
              'representative': representative.name,
              'items': [for (final tool in items) tool.name],
            },
          iface.AnnotationTool tool => tool.name,
        },
    ];

    try {
      final channel =
          MethodChannel('com.nutrient.fragment_container.${handle.viewId}');
      await channel.invokeMethod<void>('setAnnotationToolbarItems', {
        'items': payload,
      });
    } catch (e) {
      debugPrint(
          '[AndroidAdapter] setAnnotationToolbarItems failed: ${e.runtimeType}');
    }
  }

  /// Replaces the annotation **editing** toolbar (selected-annotation bar) with
  /// [items]. Style items collapse to the style picker; `note`/`delete` map to
  /// their toolbar buttons (handled natively by the editing grouping rule).
  @override
  Future<void> setAnnotationEditingToolbarItems(
      List<AnnotationEditingItem> items) async {
    final handle = viewHandle;
    if (handle == null) return;

    final payload = [for (final item in items) item.name];

    try {
      final channel =
          MethodChannel('com.nutrient.fragment_container.${handle.viewId}');
      await channel.invokeMethod<void>('setAnnotationEditingToolbarItems', {
        'items': payload,
      });
    } catch (e) {
      debugPrint(
          '[AndroidAdapter] setAnnotationEditingToolbarItems failed: ${e.runtimeType}');
    }
  }

  // ---------------------------------------------------------------------------
  // Coordinate conversion
  // ---------------------------------------------------------------------------

  @override
  Future<Offset> convertViewPointToPdfPoint(int pageIndex, Offset point) async {
    final fragment = _requireFragment('convertViewPointToPdfPoint');
    final projection = fragment.viewProjection;
    final pointF = PointF.new$1(point.dx, point.dy);
    try {
      projection.toPdfPoint(pointF, pageIndex);
      return Offset(pointF.x, pointF.y);
    } finally {
      pointF.release();
      projection.release();
    }
  }

  @override
  Future<Offset> convertPdfPointToViewPoint(int pageIndex, Offset point) async {
    final fragment = _requireFragment('convertPdfPointToViewPoint');
    final projection = fragment.viewProjection;
    final pointF = PointF.new$1(point.dx, point.dy);
    try {
      projection.toViewPoint(pointF, pageIndex);
      return Offset(pointF.x, pointF.y);
    } finally {
      pointF.release();
      projection.release();
    }
  }
}

/// The SDK's built-in default Android adapter — the no-customization viewer.
///
/// [AndroidAdapter] is abstract so customizing apps subclass it, but with
/// nothing overridden you get the full default Android viewer. This is what
/// [Nutrient.initialize] registers when the caller doesn't pass an
/// `androidAdapter`. Subclass [AndroidAdapter] yourself if you need to override
/// any of its hooks.
class DefaultAndroidAdapter extends AndroidAdapter {}
