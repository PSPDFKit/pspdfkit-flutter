///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
// Import the platform interface, hiding names that conflict with JNI bindings.
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide Bookmark, DocumentSaveOptions, DocumentPermissions, PdfVersion;
// Re-import conflicting names under the 'iface' prefix for explicit use.
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as iface show DocumentSaveOptions, DocumentPermissions, PdfVersion;

import '../android_platform_adapter.dart';
// Hide JNI types that conflict with platform-interface types.
import '../bindings/nutrient_android_sdk_bindings.dart'
    hide Nutrient, DocumentSaveOptions, Bookmark;
// Re-import the native DocumentSaveOptions under the 'sdk' prefix — its
// simple name is hidden above to avoid colliding with the Pigeon-era
// platform-interface type (aliased as iface.DocumentSaveOptions).
import '../bindings/nutrient_android_sdk_bindings.dart' as sdk
    show DocumentSaveOptions;
import '../utils/jni_file.dart';
import '../utils/jni_io.dart';
import 'annotation_manager_android.dart';
import 'bookmark_manager_android.dart';
import 'form_manager_android.dart';

/// Android implementation of [NutrientDocumentInterface].
///
/// Uses JNI bindings to the Nutrient Android SDK.
/// Obtained via [AndroidAdapter.document].
///
/// Domain-specific operations are delegated to managers:
/// - [annotations] — [AnnotationManagerAndroid]
/// - [bookmarks] — [BookmarkManagerAndroid]
/// - [forms] — [FormManagerAndroid]
///
/// Each manager has a factory method (`createAnnotationManager()`, etc.)
/// that can be overridden in subclasses for customization.
/// Factory type for creating a custom annotation manager.
typedef AnnotationManagerFactory = AnnotationManagerInterface Function(
    NutrientDocumentAndroid document);

/// Factory type for creating a custom bookmark manager.
typedef BookmarkManagerFactory = BookmarkManagerInterface Function(
    NutrientDocumentAndroid document);

/// Factory type for creating a custom form manager.
typedef FormManagerFactory = FormManagerInterface Function(
    NutrientDocumentAndroid document);

class NutrientDocumentAndroid implements NutrientDocumentInterface {
  /// The adapter that owns this document.
  final AndroidAdapter adapter;

  final AnnotationManagerFactory? _annotationManagerFactory;
  final BookmarkManagerFactory? _bookmarkManagerFactory;
  final FormManagerFactory? _formManagerFactory;

  /// Headless [PdfDocument], if this document was created via
  /// [AndroidAdapter.openDocument]. `null` for view-attached documents (and
  /// for headless documents after [close] has been called).
  PdfDocument? _headlessDocument;

  /// Whether this document was created via [AndroidAdapter.openDocument].
  /// Stays `true` even after [close] is called.
  final bool _isHeadless;

  /// Creates a new Android document implementation.
  ///
  /// Optionally pass factory closures to customize individual managers
  /// without subclassing the document:
  ///
  /// ```dart
  /// NutrientDocumentAndroid(adapter,
  ///   annotationManagerFactory: (doc) => MyAnnotations(doc),
  ///   bookmarkManagerFactory: (doc) => FilteredBookmarks(doc),
  /// )
  /// ```
  NutrientDocumentAndroid(
    this.adapter, {
    AnnotationManagerFactory? annotationManagerFactory,
    BookmarkManagerFactory? bookmarkManagerFactory,
    FormManagerFactory? formManagerFactory,
  })  : _annotationManagerFactory = annotationManagerFactory,
        _bookmarkManagerFactory = bookmarkManagerFactory,
        _formManagerFactory = formManagerFactory,
        _isHeadless = false;

  /// Headless constructor — wraps a [PdfDocument] loaded directly via JNI
  /// without going through a fragment. Operations resolve to this document
  /// instead of the adapter's view-attached one.
  NutrientDocumentAndroid.headless(
    this.adapter,
    PdfDocument document, {
    AnnotationManagerFactory? annotationManagerFactory,
    BookmarkManagerFactory? bookmarkManagerFactory,
    FormManagerFactory? formManagerFactory,
  })  : _annotationManagerFactory = annotationManagerFactory,
        _bookmarkManagerFactory = bookmarkManagerFactory,
        _formManagerFactory = formManagerFactory,
        _headlessDocument = document,
        _isHeadless = true;

  // ---------------------------------------------------------------------------
  // Native access (package-visible for managers)
  // ---------------------------------------------------------------------------

  /// Returns the native [PdfDocument] JNI instance.
  ///
  /// For headless documents, returns the directly-loaded [PdfDocument].
  /// For view-attached documents, resolves through the adapter's view handle.
  /// Throws [StateError] if the view handle is not attached, the document
  /// is not yet registered (i.e., before `onPdfFragmentReady`), or the
  /// headless document has been closed.
  PdfDocument requireDocument() {
    if (_isHeadless) {
      final headless = _headlessDocument;
      if (headless == null) {
        throw StateError(
            'NutrientDocumentAndroid: this document has been closed.');
      }
      return headless;
    }

    final handle = adapter.internalViewHandle;
    if (handle == null) {
      throw StateError(
          'NutrientDocumentAndroid: no view handle — is the controller ready?');
    }
    final doc = handle.getNativeInstance('pdfDocument') as PdfDocument?;
    if (doc == null) {
      throw StateError(
        'NutrientDocumentAndroid: pdfDocument not registered in handle. '
        'Ensure onPdfFragmentReady has been called.',
      );
    }
    return doc;
  }

  // ---------------------------------------------------------------------------
  // Managers
  // ---------------------------------------------------------------------------

  late final AnnotationManagerInterface _annotations =
      _annotationManagerFactory?.call(this) ?? AnnotationManagerAndroid(this);
  late final BookmarkManagerInterface _bookmarks =
      _bookmarkManagerFactory?.call(this) ?? BookmarkManagerAndroid(this);
  late final FormManagerInterface _forms =
      _formManagerFactory?.call(this) ?? FormManagerAndroid(this);

  @override
  AnnotationManagerInterface get annotations => _annotations;

  @override
  BookmarkManagerInterface get bookmarks => _bookmarks;

  @override
  FormManagerInterface get forms => _forms;

  // ---------------------------------------------------------------------------
  // Document info
  // ---------------------------------------------------------------------------

  @override
  Future<int> getPageCount() async {
    return requireDocument().getPageCount();
  }

  @override
  Future<PageInfo> getPageInfo(int pageIndex) async {
    final doc = requireDocument();
    final size = doc.getPageSize(pageIndex);
    final rotation = doc.getPageRotation(pageIndex);
    // `substituteWithPlainLabel=false` returns null when the page has no
    // explicit label so we don't synthesise "1", "2", … and confuse callers.
    final labelJStr = doc.getPageLabel(pageIndex, false);
    final label = labelJStr?.toDartString(releaseOriginal: true);
    return PageInfo(
      pageIndex: pageIndex,
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      rotation: rotation,
      label: label,
    );
  }

  // ---------------------------------------------------------------------------
  // Save / export
  // ---------------------------------------------------------------------------

  /// Native-permission mapping for [iface.DocumentPermissions], mirroring
  /// legacy's `documentPermissionsMap`
  /// (nutrient_flutter/android/.../FlutterPdfDocument.kt).
  static DocumentPermissions _nativePermission(
    iface.DocumentPermissions permission,
  ) {
    return switch (permission) {
      iface.DocumentPermissions.printing => DocumentPermissions.PRINTING,
      iface.DocumentPermissions.modification =>
        DocumentPermissions.MODIFICATION,
      iface.DocumentPermissions.extract => DocumentPermissions.EXTRACT,
      iface.DocumentPermissions.annotationsAndForms =>
        DocumentPermissions.ANNOTATIONS_AND_FORMS,
      iface.DocumentPermissions.fillForms => DocumentPermissions.FILL_FORMS,
      iface.DocumentPermissions.extractAccessibility =>
        DocumentPermissions.EXTRACT_ACCESSIBILITY,
      iface.DocumentPermissions.assemble => DocumentPermissions.ASSEMBLE,
      iface.DocumentPermissions.printHighQuality =>
        DocumentPermissions.PRINT_HIGH_QUALITY,
    };
  }

  /// Native [PdfVersion] mapping for [iface.PdfVersion], mirroring legacy's
  /// `pdfVersionMap`. The enum constant names line up 1:1 with the native
  /// SDK's, so this is a direct switch rather than a lookup table.
  static PdfVersion _nativePdfVersion(iface.PdfVersion version) {
    return switch (version) {
      iface.PdfVersion.pdf_1_0 => PdfVersion.PDF_1_0,
      iface.PdfVersion.pdf_1_1 => PdfVersion.PDF_1_1,
      iface.PdfVersion.pdf_1_2 => PdfVersion.PDF_1_2,
      iface.PdfVersion.pdf_1_3 => PdfVersion.PDF_1_3,
      iface.PdfVersion.pdf_1_4 => PdfVersion.PDF_1_4,
      iface.PdfVersion.pdf_1_5 => PdfVersion.PDF_1_5,
      iface.PdfVersion.pdf_1_6 => PdfVersion.PDF_1_6,
      iface.PdfVersion.pdf_1_7 => PdfVersion.PDF_1_7,
    };
  }

  /// Converts the Dart [iface.DocumentSaveOptions] into a native
  /// `com.pspdfkit.document.DocumentSaveOptions`, mirroring legacy's
  /// `convertDocumentSaveOptions`
  /// (nutrient_flutter/android/.../FlutterPdfDocument.kt:968-978).
  ///
  /// Starts from [doc]'s defaults and overrides only the fields the Dart
  /// options actually set, so unset fields fall back to the document's
  /// current save-option defaults exactly like legacy does.
  ///
  /// NOT mapped (legacy parity — these have no equivalent on the native
  /// Android `DocumentSaveOptions` type): [iface.DocumentSaveOptions.ownerPassword],
  /// [iface.DocumentSaveOptions.saveForPrinting],
  /// [iface.DocumentSaveOptions.includeComments],
  /// [iface.DocumentSaveOptions.outputFormat]. `flatten` /
  /// `excludeAnnotations` are applied to the [PdfProcessorTask] instead (see
  /// [exportPdf]), not to this options object.
  ///
  /// The returned object must be released after use, by calling `release()`.
  sdk.DocumentSaveOptions _convertDocumentSaveOptions(
    PdfDocument doc,
    iface.DocumentSaveOptions options,
  ) {
    final saveOptions = doc.getDefaultDocumentSaveOptions();

    final userPassword = options.userPassword;
    if (userPassword != null) {
      final jPassword = userPassword.toJString();
      try {
        saveOptions.password = jPassword;
      } finally {
        jPassword.release();
      }
    }

    final permissions = options.permissions;
    if (permissions != null) {
      // jnigen doesn't bind EnumSet's static factories (noneOf/of/copyOf
      // aren't in the generated surface), so rather than constructing a
      // fresh EnumSet we mutate the defaults' EnumSet through the generic
      // java.util.Collection interface, which every Set implementation
      // (including EnumSet) supports via ordinary virtual dispatch.
      // DocumentSaveOptions.getPermissions() returns the live backing set
      // (`return permissions;` — android/sdk-nutrient/.../DocumentSaveOptions.java),
      // but assign the mutated set back through setPermissions anyway so
      // this doesn't silently drop permissions if the getter ever starts
      // returning a defensive copy.
      final nativePermissions = saveOptions.permissions;
      try {
        final collection = nativePermissions.as(JCollection.type)
            as JCollection<DocumentPermissions>;
        collection.clear();
        for (final permission in permissions) {
          if (permission == null) continue;
          final native = _nativePermission(permission);
          try {
            collection.add(native);
          } finally {
            native.release();
          }
        }
        saveOptions.permissions = nativePermissions;
      } finally {
        nativePermissions.release();
      }
    }

    final incremental = options.incremental;
    if (incremental != null) {
      saveOptions.incremental = incremental;
    }

    final pdfVersion = options.pdfVersion;
    if (pdfVersion != null) {
      final native = _nativePdfVersion(pdfVersion);
      try {
        saveOptions.pdfVersion = native;
      } finally {
        native.release();
      }
    }

    return saveOptions;
  }

  @override
  Future<bool> save({
    String? outputPath,
    iface.DocumentSaveOptions? options,
  }) async {
    final doc = requireDocument();
    if (outputPath != null) {
      // Mirror legacy: route path-saves through PdfProcessor so annotations
      // (including ones only materialised via Instant JSON) are written
      // correctly into the new file, and so `flatten` / `excludeAnnotations`
      // can be applied.
      PdfProcessorTask task = PdfProcessorTask.fromDocument(doc);
      if (options?.flatten == true) {
        final flattened = task.changeAllAnnotations(
            PdfProcessorTask$AnnotationProcessingMode.FLATTEN);
        if (flattened != null) {
          task.release();
          task = flattened;
        }
      } else if (options?.excludeAnnotations == true) {
        final without = task.changeAllAnnotations(
            PdfProcessorTask$AnnotationProcessingMode.DELETE);
        if (without != null) {
          task.release();
          task = without;
        }
      }

      final saveOptions = options != null
          ? _convertDocumentSaveOptions(doc, options)
          : doc.getDefaultDocumentSaveOptions();
      final outputFile = JniFile.fromPath(outputPath);
      try {
        PdfProcessor.processDocument$1(
            task, outputFile.as(File.type), saveOptions);
      } finally {
        outputFile.release();
        saveOptions.release();
        task.release();
      }
    } else if (options != null) {
      final saveOptions = _convertDocumentSaveOptions(doc, options);
      try {
        doc.saveIfModified$1(saveOptions);
      } finally {
        saveOptions.release();
      }
    } else {
      doc.saveIfModified();
    }
    return true;
  }

  @override
  Future<Uint8List> exportPdf({iface.DocumentSaveOptions? options}) async {
    final doc = requireDocument();
    // 1. Build a PdfProcessorTask from the live document. The task carries
    //    the annotation-processing mode (flatten / delete) — DocumentSaveOptions
    //    on its own can't express it.
    PdfProcessorTask task = PdfProcessorTask.fromDocument(doc);
    if (options?.flatten == true) {
      final flattened = task.changeAllAnnotations(
          PdfProcessorTask$AnnotationProcessingMode.FLATTEN);
      if (flattened != null) {
        task.release();
        task = flattened;
      }
    } else if (options?.excludeAnnotations == true) {
      final without = task.changeAllAnnotations(
          PdfProcessorTask$AnnotationProcessingMode.DELETE);
      if (without != null) {
        task.release();
        task = without;
      }
    }

    // 2. Resolve save options. The legacy plugin reuses the document's
    //    defaults and overrides only the fields it understands; mirror that
    //    via _convertDocumentSaveOptions for password / permissions /
    //    incremental / pdf-version, plus the optimize flag below.
    final saveOptions = options != null
        ? _convertDocumentSaveOptions(doc, options)
        : doc.getDefaultDocumentSaveOptions();
    if (options?.optimize == true) {
      saveOptions.rewriteAndOptimizeFileSize = true;
    }

    // 3. Synchronously process the document into a temp file. The async
    //    Flowable overload would force a Schedulers / DisposableSubscriber
    //    binding chain — `processDocument(...)` blocks on the calling
    //    thread, which is fine because we're already on an isolate worker
    //    via the `async` method.
    final tempFile = JniFile.createTempFile('nutrient_export_', '.pdf');
    final path = JniFile.getAbsolutePath(tempFile);
    try {
      PdfProcessor.processDocument$1(task, tempFile.as(File.type), saveOptions);
      // 4. Read the bytes back through dart:io. The JNI helpers only know
      //    about the file *handle*; the bytes live on the regular FS.
      final bytes = await io.File(path).readAsBytes();
      return bytes;
    } finally {
      JniFile.delete(tempFile);
      tempFile.release();
      saveOptions.release();
      task.release();
    }
  }

  /// Composes the three provider-level dirty checks — annotations, forms,
  /// and bookmarks — the same coverage as the legacy Pigeon
  /// `androidHasUnsaved*Changes` methods combined.
  @override
  Future<bool> hasUnsavedChanges() async {
    final doc = requireDocument();
    final annotationProvider = doc.getAnnotationProvider();
    try {
      if (annotationProvider.hasUnsavedChanges()) return true;
    } finally {
      annotationProvider.release();
    }
    final formProvider = doc.getFormProvider();
    try {
      if (formProvider.hasUnsavedChanges()) return true;
    } finally {
      formProvider.release();
    }
    final bookmarkProvider = doc.getBookmarkProvider();
    try {
      return bookmarkProvider.hasUnsavedChanges();
    } finally {
      bookmarkProvider.release();
    }
  }

  // ---------------------------------------------------------------------------
  // Instant JSON
  // ---------------------------------------------------------------------------

  @override
  Future<bool> applyInstantJson(String annotationsJson) async {
    final doc = requireDocument();
    // `importDocumentJson` is a Kotlin `suspend` fn the jnigen bindings can't
    // call; the SDK's `importDocumentJsonBlocking` companion is `@JvmStatic`
    // and callable — same trap/escape as [AnnotationProviderBlocking].
    final dataProvider =
        bytesDataProvider(utf8.encode(annotationsJson), uid: 'instant-json');
    try {
      DocumentJsonFormatter.importDocumentJsonBlocking(doc, dataProvider);
      return true;
    } catch (_) {
      // Malformed/incompatible Instant JSON — mirror iOS, which returns the
      // SDK's boolean instead of throwing.
      return false;
    } finally {
      dataProvider.release();
    }
  }

  @override
  Future<String?> exportInstantJson() async {
    final doc = requireDocument();
    final byteStream = ByteArrayOutputStreamJni.create();
    try {
      // The blocking binding has no 2-arg overload, so mirror the SDK
      // default (`InstantJsonVersion.entries.last()`) by passing the last
      // `values()` entry — the latest protocol version.
      final versions = InstantJsonVersion.values()!;
      final latest = versions[versions.length - 1]!;
      try {
        DocumentJsonFormatter.exportDocumentJsonBlocking(
          doc,
          byteStream as OutputStream,
          latest,
        );
      } finally {
        latest.release();
        versions.release();
      }
      return utf8.decode(ByteArrayOutputStreamJni.toBytes(byteStream));
    } finally {
      byteStream.release();
    }
  }

  // ---------------------------------------------------------------------------
  // Author name
  // ---------------------------------------------------------------------------

  @override
  Future<void> setAuthorName(String name) async {
    // Author name is the global "annotation creator" preference on Android
    // (new annotations are attributed to it). Set it via PSPDFKitPreferences
    // against the cached application context.
    final context = androidApplicationContext.as(Context.type);
    final prefs = PSPDFKitPreferences.get(context);
    final jName = name.toJString();
    try {
      prefs.annotationCreator = jName;
    } finally {
      jName.release();
      prefs.release();
      context.release();
    }
  }

  @override
  Future<String> getAuthorName() async {
    final context = androidApplicationContext.as(Context.type);
    final prefs = PSPDFKitPreferences.get(context);
    final fallback = ''.toJString();
    try {
      final result = prefs.getAnnotationCreator(fallback);
      return result?.toDartString(releaseOriginal: true) ?? '';
    } finally {
      fallback.release();
      prefs.release();
      context.release();
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<bool> close() async {
    // For headless documents, release the JNI reference so the native
    // PdfDocument can be garbage-collected. Subsequent manager calls will
    // throw via requireDocument.
    final headless = _headlessDocument;
    if (headless != null) {
      _headlessDocument = null;
      headless.release();
    }
    // View-attached documents are closed when the view disposes.
    return true;
  }
}
