import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api/nutrient_api.g.dart' show AnnotationType, AnnotationProcessingMode;
import 'interfaces/nutrient_document_interface.dart';
import 'nutrient_view_handle.dart';

/// Platform adapter interface for extending Nutrient functionality.
///
/// Platform adapters provide lifecycle hooks and access to native SDK instances,
/// enabling deep customization without forking the plugin.
///
/// ## Overview
///
/// The core plugin provides:
/// - Document display via [NutrientView]
/// - Native instance access via platform-specific adapters
///
/// Platform adapters provide:
/// - Lifecycle hooks (view creation, document loading, cleanup)
/// - Direct access to native SDK instances
/// - Custom event handling and business logic
///
/// ## Implementation
///
/// Extend the platform-specific base adapter:
///
/// ### Android (JNI Bindings)
/// ```dart
/// class MyAndroidAdapter extends AndroidAdapter {
///   @override
///   Future<void> onFragmentAttached(
///     PdfUiFragment fragment,
///     Context context,
///   ) async {
///     // Access fragment methods through JNI
///     final config = fragment.getConfiguration();
///   }
///
///   @override
///   Future<void> onDocumentLoaded(
///     PdfDocument document,
///     PdfFragment pdfFragment,
///   ) async {
///     // Access document properties
///     final pageCount = document.getPageCount();
///   }
///
///   @override
///   Future<void> onFragmentDetached() async {
///     // Clean up resources
///   }
/// }
/// ```
///
/// ### iOS (FFI Bindings)
/// ```dart
/// class MyIOSAdapter extends IOSAdapter {
///   @override
///   Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
///     await super.onPlatformViewCreated(handle);
///     // Access iOS-specific APIs through handle
///     // Implementation depends on iOS adapter structure
///   }
/// }
/// ```
///
/// ### Web (JavaScript Interop)
/// ```dart
/// class MyWebAdapter extends NutrientWebAdapter {
///   @override
///   Future<void> configureLoad(
///     NutrientViewHandle handle,
///     Map<String, dynamic> config,
///   ) async {
///     await super.configureLoad(handle, config);
///     config['layoutMode'] = 'SINGLE';
///     config['theme'] = 'DARK';
///   }
///
///   @override
///   Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
///     await super.onPlatformViewCreated(handle);
///     final instance = getInstance(handle);
///     // Use instance to access Web SDK APIs
///   }
/// }
/// ```
///
/// ## Registration
///
/// Register adapters during initialization:
/// ```dart
/// await Nutrient.initialize(
///   licenseKey: 'YOUR_LICENSE_KEY',
///   androidAdapter: MyAndroidAdapter(),
///   iosAdapter: MyIOSAdapter(),
///   webAdapter: MyWebAdapter(),
/// );
/// ```
///
/// ## Error handling in lifecycle hooks
///
/// The lifecycle hooks ([onPlatformViewCreated], the platform-specific
/// `onFragmentReady` / `onViewControllerReady` / `onInstanceLoaded`, and the
/// `configure*` hooks) are `Future<void>` and may throw. The SDK **awaits each
/// hook and catches any error** so a failing hook can't tear the view down —
/// the error is logged and the view still renders. Hooks are **not** retried,
/// so a hook that needs to recover from a failure must handle it itself (wrap
/// the risky work in its own `try`/`catch`).
abstract class NutrientPlatformAdapter {
  /// The platform this adapter targets.
  ///
  /// Vestigial: it only ever validated which global slot an adapter went into,
  /// and those slots are deprecated. Nothing reads it now — controllers are
  /// selected by type via [Nutrient.addAdapterClass] / `NutrientDocumentView<T>`.
  @Deprecated(
    'Vestigial now that the global adapter slots are deprecated — nothing reads '
    'it. Will be removed in a future release.',
  )
  TargetPlatform get platform;

  /// Called when the platform view is created.
  ///
  /// Use this for early initialization that doesn't require the native SDK instances.
  /// For Android, prefer using [onFragmentAttached] to access native instances.
  ///
  Future<void> onPlatformViewCreated(NutrientViewHandle handle);

  /// Opens a document without displaying a viewer (headless mode).
  ///
  /// Returns a [NutrientDocumentInterface] that gives access to the full
  /// document API — annotations, bookmarks, forms, save, export, etc. — with
  /// no UI required.
  ///
  /// [path] — file path or content URI to the PDF document.
  /// [password] — password for encrypted documents; omit for unprotected files.
  ///
  /// The returned document holds native resources. Call [NutrientDocumentInterface.close]
  /// when done to release them.
  ///
  /// Example:
  /// ```dart
  /// final doc = await adapter.openDocument('assets/document.pdf');
  /// await doc.annotations.exportXfdf();
  /// await doc.save(outputPath: '/tmp/out.pdf');
  /// await doc.close();
  /// ```
  Future<NutrientDocumentInterface> openDocument(
    String path, {
    String? password,
  });

  /// Opens a document from in-memory [bytes] without a viewer (headless).
  ///
  /// Use when the document isn't available as a file. The native adapters
  /// persist the bytes to a temporary file and load that; the web adapter
  /// wraps them in a blob URL. Otherwise identical to [openDocument] — the
  /// returned document holds native resources, so call
  /// [NutrientDocumentInterface.close] when done.
  ///
  /// ```dart
  /// final bytes = await File('report.pdf').readAsBytes();
  /// final doc = await adapter.openDocumentFromBytes(bytes);
  /// final pages = await doc.getPageCount();
  /// await doc.close();
  /// ```
  ///
  /// The default throws [UnsupportedError]; the bundled Android/iOS/web
  /// adapters override it.
  Future<NutrientDocumentInterface> openDocumentFromBytes(
    Uint8List bytes, {
    String? password,
  }) {
    throw UnsupportedError(
      'openDocumentFromBytes is not supported by this adapter.',
    );
  }

  /// Processes the annotations of the document at [sourcePath] and writes the
  /// result to [destinationPath], mirroring the legacy SDK's annotation
  /// processing.
  ///
  /// [type] selects which annotation type to process (use `AnnotationType.all`
  /// for every annotation); [mode] chooses how — flatten, remove, embed, or
  /// print. The source document is opened, processed, and released internally,
  /// so no open document/view is required.
  ///
  /// Backs [Nutrient.processAnnotations]. The default throws
  /// [UnsupportedError]; the Android and iOS adapters override it (Web has no
  /// equivalent and keeps throwing).
  Future<bool> processAnnotations(
    String sourcePath,
    AnnotationType type,
    AnnotationProcessingMode mode,
    String destinationPath,
  ) {
    throw UnsupportedError(
      'processAnnotations is not supported by this adapter.',
    );
  }

  /// Dispose of this adapter and clean up resources.
  ///
  /// Called when the adapter is being removed.
  /// Clean up listeners, streams, and native resources.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> dispose() async {
  ///   await _eventController.close();
  ///   // Clean up native listeners
  /// }
  /// ```
  Future<void> dispose();
}
