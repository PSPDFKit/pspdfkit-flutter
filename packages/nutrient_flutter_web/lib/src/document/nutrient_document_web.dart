///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import '../generated/nutrient_web_bindings.g.dart' as nutrient_web;
import '../operations/annotation_operations.dart';
import '../operations/bookmark_operations.dart';
import '../operations/document_operations.dart';
import '../operations/form_operations.dart';
import '../utils/document_save_options_web_mapping.dart';
import '../web_platform_adapter.dart';
import '../web_sdk_namespace.dart' as sdk;
import 'annotation_manager_web.dart';
import 'bookmark_manager_web.dart';
import 'form_manager_web.dart';

/// Web implementation of [NutrientDocumentInterface].
///
/// Delegates to [NutrientDocumentOperations] for document-level operations.
/// Obtained via [NutrientWebAdapter.document].
///
/// Domain-specific operations are delegated to managers:
/// - [annotations] — [AnnotationManagerWeb]
/// - [bookmarks] — [BookmarkManagerWeb]
/// - [forms] — [FormManagerWeb]
///
/// Each manager has a factory method (`createAnnotationManager()`, etc.)
/// that can be overridden in subclasses for customization.
/// Factory type for creating a custom annotation manager.
typedef AnnotationManagerFactory = AnnotationManagerInterface Function(
    NutrientDocumentWeb document);

/// Factory type for creating a custom bookmark manager.
typedef BookmarkManagerFactory = BookmarkManagerInterface Function(
    NutrientDocumentWeb document);

/// Factory type for creating a custom form manager.
typedef FormManagerFactory = FormManagerInterface Function(
    NutrientDocumentWeb document);

class NutrientDocumentWeb implements NutrientDocumentInterface {
  /// The adapter that owns this document.
  final NutrientWebAdapter adapter;

  final AnnotationManagerFactory? _annotationManagerFactory;
  final BookmarkManagerFactory? _bookmarkManagerFactory;
  final FormManagerFactory? _formManagerFactory;

  /// Headless web instance, if this document was created via
  /// [NutrientWebAdapter.openDocument]. `null` for view-attached documents
  /// and for headless documents after [close] has been called.
  nutrient_web.Instance? _headlessInstance;

  /// Per-document operations, populated only when headless. View-attached
  /// documents fall back to the adapter's view-bound operations. Cleared
  /// when [close] runs on a headless document.
  NutrientAnnotationOperations? _ownAnnOps;
  NutrientDocumentOperations? _ownDocOps;
  NutrientFormOperations? _ownFormOps;
  NutrientBookmarkOperations? _ownBookmarkOps;

  /// Whether this document was created via [NutrientWebAdapter.openDocument].
  /// Stays `true` after [close] so subsequent manager calls fail with a
  /// clear "document has been closed" error rather than silently falling
  /// back to the adapter's view-bound operations.
  final bool _isHeadless;

  /// Whether [close] has been called on a headless document.
  bool _closed = false;

  NutrientDocumentWeb(
    this.adapter, {
    AnnotationManagerFactory? annotationManagerFactory,
    BookmarkManagerFactory? bookmarkManagerFactory,
    FormManagerFactory? formManagerFactory,
  })  : _annotationManagerFactory = annotationManagerFactory,
        _bookmarkManagerFactory = bookmarkManagerFactory,
        _formManagerFactory = formManagerFactory,
        _headlessInstance = null,
        _ownAnnOps = null,
        _ownDocOps = null,
        _ownFormOps = null,
        _ownBookmarkOps = null,
        _isHeadless = false;

  /// Headless constructor — wraps an instance loaded with `headless: true`.
  ///
  /// Operations are scoped to [instance] only, isolated from the adapter's
  /// view-bound operations. [close] will unload this instance.
  NutrientDocumentWeb.headless(
    this.adapter,
    nutrient_web.Instance instance, {
    AnnotationManagerFactory? annotationManagerFactory,
    BookmarkManagerFactory? bookmarkManagerFactory,
    FormManagerFactory? formManagerFactory,
  })  : _annotationManagerFactory = annotationManagerFactory,
        _bookmarkManagerFactory = bookmarkManagerFactory,
        _formManagerFactory = formManagerFactory,
        _headlessInstance = instance,
        _ownAnnOps = NutrientAnnotationOperations(instance),
        _ownDocOps = NutrientDocumentOperations(instance),
        _ownFormOps = NutrientFormOperations(instance),
        _ownBookmarkOps = NutrientBookmarkOperations(instance),
        _isHeadless = true;

  /// Throws if [close] has been called on a headless document. Mirrors the
  /// iOS / Android `requireDocument()` "document has been closed" guard so
  /// post-close calls fail with a clear Dart-level error rather than
  /// undefined behaviour at the JS layer.
  void _throwIfClosed() {
    if (_isHeadless && _closed) {
      throw StateError(
        'NutrientDocumentWeb: this document has been closed.',
      );
    }
  }

  /// Annotation operations backing this document — own ops if headless,
  /// otherwise the adapter's view-bound ops. Used by [AnnotationManagerWeb].
  NutrientAnnotationOperations? get internalAnnotationOperations {
    _throwIfClosed();
    return _ownAnnOps ?? adapter.internalAnnotationOperations;
  }

  /// Document operations backing this document — own ops if headless,
  /// otherwise the adapter's view-bound ops.
  NutrientDocumentOperations? get internalDocumentOperations {
    _throwIfClosed();
    return _ownDocOps ?? adapter.internalDocumentOperations;
  }

  /// Form operations backing this document — own ops if headless,
  /// otherwise the adapter's view-bound ops. Used by [FormManagerWeb].
  NutrientFormOperations? get internalFormOperations {
    _throwIfClosed();
    return _ownFormOps ?? adapter.internalFormOperations;
  }

  /// Bookmark operations backing this document — own ops if headless,
  /// otherwise the adapter's view-bound ops. Used by [BookmarkManagerWeb].
  NutrientBookmarkOperations? get internalBookmarkOperations {
    _throwIfClosed();
    return _ownBookmarkOps ?? adapter.internalBookmarkOperations;
  }

  NutrientDocumentOperations get _docOps {
    final ops = internalDocumentOperations;
    if (ops == null) {
      throw StateError(
        'NutrientDocumentWeb: instance not loaded — is onInstanceLoaded called?',
      );
    }
    return ops;
  }

  // ---------------------------------------------------------------------------
  // Managers
  // ---------------------------------------------------------------------------

  late final AnnotationManagerInterface _annotations =
      _annotationManagerFactory?.call(this) ?? AnnotationManagerWeb(this);
  late final BookmarkManagerInterface _bookmarks =
      _bookmarkManagerFactory?.call(this) ?? BookmarkManagerWeb(this);
  late final FormManagerInterface _forms =
      _formManagerFactory?.call(this) ?? FormManagerWeb(this);

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
    return _docOps.pageCount;
  }

  @override
  Future<PageInfo> getPageInfo(int pageIndex) async {
    final info = _docOps.pageInfoForIndex(pageIndex);
    if (info == null) {
      throw RangeError.value(
        pageIndex,
        'pageIndex',
        'Page index out of range for this document',
      );
    }
    return PageInfo(
      pageIndex: pageIndex,
      width: info.width,
      height: info.height,
      rotation: info.rotation.toInt(),
      label: info.label,
    );
  }

  // ---------------------------------------------------------------------------
  // Save / export
  // ---------------------------------------------------------------------------

  /// Saves the document in place.
  ///
  /// [outputPath] is meaningless on Web — there is no filesystem to save to,
  /// so a non-null value throws [UnsupportedError] rather than being
  /// silently ignored. Use [exportPdf] to get the saved document's bytes and
  /// hand them to the browser's download flow (e.g. via an `<a download>`
  /// link or the File System Access API) instead.
  ///
  /// [options] is currently not applied by the Web SDK's `Instance.save()`
  /// (which always does a full in-place save); use [exportPdf] if you need
  /// [DocumentSaveOptions] such as `flatten` or `permissions` applied to the
  /// output.
  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) async {
    if (outputPath != null) {
      throw UnsupportedError(
        'save(outputPath: ...) is not supported on Web — there is no '
        'filesystem to save to. Use exportPdf() to get the saved document '
        'bytes and hand them to the browser download flow instead.',
      );
    }
    await _docOps.save();
    return true;
  }

  /// Exports the document as raw PDF bytes.
  ///
  /// See [webExportFlagsFor] for the full mapping of [DocumentSaveOptions]
  /// fields to the Web SDK's `Instance.exportPDF(flags)` flags, including
  /// which fields have no Web equivalent.
  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) async {
    final exportOptions = options != null ? webExportFlagsFor(options) : null;
    return _docOps.exportPdf(options: exportOptions);
  }

  /// Backed by the Web SDK's `Instance.hasUnsavedChanges()` — a composite
  /// signal covering annotation, form, bookmark, and comment changes.
  @override
  Future<bool> hasUnsavedChanges() async {
    return _docOps.hasUnsavedChanges();
  }

  // ---------------------------------------------------------------------------
  // Instant JSON
  // ---------------------------------------------------------------------------

  @override
  Future<bool> applyInstantJson(String annotationsJson) async {
    await _docOps.applyInstantJson(annotationsJson);
    return true;
  }

  @override
  Future<String?> exportInstantJson() async {
    return _docOps.exportInstantJson();
  }

  // ---------------------------------------------------------------------------
  // Author name
  // ---------------------------------------------------------------------------

  @override
  Future<void> setAuthorName(String name) async {
    _docOps.setAnnotationCreatorName(name);
  }

  @override
  Future<String> getAuthorName() async {
    // Web SDK does not expose a getter for the annotation creator name.
    throw UnsupportedError('getAuthorName is not supported on Web');
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<bool> close() async {
    final instance = _headlessInstance;
    if (instance != null) {
      // Headless instance: tell the SDK to unload it via the namespace
      // shim, which picks NutrientViewer or PSPDFKit at runtime.
      try {
        sdk.unloadInstance(instance);
      } catch (_) {
        // Best-effort: even if unload throws, we've released our references.
      }
      // Drop references to the unloaded instance and its operations so any
      // subsequent manager call hits _throwIfClosed() instead of poking the
      // freed JS instance via stale ops.
      _headlessInstance = null;
      _ownAnnOps = null;
      _ownDocOps = null;
      _ownFormOps = null;
      _ownBookmarkOps = null;
      _closed = true;
      return true;
    }
    // View-attached documents are closed when the view is destroyed.
    return true;
  }
}
