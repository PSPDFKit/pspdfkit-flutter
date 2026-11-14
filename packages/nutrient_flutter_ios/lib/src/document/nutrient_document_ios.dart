///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:objective_c/objective_c.dart' as objc;

import '../bindings/nutrient_ios_bindings.dart';
import '../ios_platform_adapter.dart';
import 'annotation_manager_ios.dart';
import 'bookmark_manager_ios.dart';
import 'form_manager_ios.dart';

/// iOS implementation of [NutrientDocumentInterface].
///
/// Uses FFI bindings to the Nutrient iOS SDK via [PSPDFDocument] and
/// [PSPDFViewController] instances registered in the [NutrientViewHandle].
///
/// Domain-specific operations are delegated to managers:
/// - [annotations] — [AnnotationManagerIOS]
/// - [bookmarks] — [BookmarkManagerIOS]
/// - [forms] — [FormManagerIOS]
///
/// Each manager has a factory method (`createAnnotationManager()`, etc.)
/// that can be overridden in subclasses for customization.
/// Factory type for creating a custom annotation manager.
typedef AnnotationManagerFactory =
    AnnotationManagerInterface Function(NutrientDocumentIOS document);

/// Factory type for creating a custom bookmark manager.
typedef BookmarkManagerFactory =
    BookmarkManagerInterface Function(NutrientDocumentIOS document);

/// Factory type for creating a custom form manager.
typedef FormManagerFactory =
    FormManagerInterface Function(NutrientDocumentIOS document);

class NutrientDocumentIOS implements NutrientDocumentInterface {
  /// The adapter that owns this document.
  final IOSAdapter adapter;

  final AnnotationManagerFactory? _annotationManagerFactory;
  final BookmarkManagerFactory? _bookmarkManagerFactory;
  final FormManagerFactory? _formManagerFactory;

  /// Headless [PSPDFDocument], if this document was created via
  /// [IOSAdapter.openDocument]. `null` for view-attached documents (and for
  /// headless documents after [close] has been called).
  PSPDFDocument? _headlessDocument;

  /// NSURL passed to the headless [PSPDFDocument]. Held alongside the
  /// document because PSPDFKit's `PSPDFSecurityScopedURL` keeps an unsafe
  /// reference to the original URL — releasing the Dart wrapper while the
  /// document is still alive causes an EXC_BAD_ACCESS in
  /// `-[PSPDFSecurityScopedURL dealloc]` when the document finalizes.
  // ignore: unused_field
  objc.NSURL? _headlessUrl;

  /// Whether this document was created via [IOSAdapter.openDocument].
  /// Stays `true` even after [close] is called.
  final bool _isHeadless;

  NutrientDocumentIOS(
    this.adapter, {
    AnnotationManagerFactory? annotationManagerFactory,
    BookmarkManagerFactory? bookmarkManagerFactory,
    FormManagerFactory? formManagerFactory,
  }) : _annotationManagerFactory = annotationManagerFactory,
       _bookmarkManagerFactory = bookmarkManagerFactory,
       _formManagerFactory = formManagerFactory,
       _isHeadless = false;

  /// Headless constructor — wraps a [PSPDFDocument] loaded directly via FFI
  /// without going through a view controller. Operations resolve to this
  /// document instead of the adapter's view-attached one.
  ///
  /// [url] is the [objc.NSURL] passed to `[[PSPDFDocument alloc] initWithURL:]`
  /// — it's held on this instance so its Dart wrapper outlives [document].
  NutrientDocumentIOS.headless(
    this.adapter,
    PSPDFDocument document,
    objc.NSURL url, {
    AnnotationManagerFactory? annotationManagerFactory,
    BookmarkManagerFactory? bookmarkManagerFactory,
    FormManagerFactory? formManagerFactory,
  }) : _annotationManagerFactory = annotationManagerFactory,
       _bookmarkManagerFactory = bookmarkManagerFactory,
       _formManagerFactory = formManagerFactory,
       _headlessDocument = document,
       _headlessUrl = url,
       _isHeadless = true;

  // ---------------------------------------------------------------------------
  // Native access (package-visible for managers)
  // ---------------------------------------------------------------------------

  /// Returns the [PSPDFDocument] backing this document.
  ///
  /// For headless documents, returns the directly-loaded [PSPDFDocument].
  /// For view-attached documents, resolves through the adapter's view handle.
  PSPDFDocument requireDocument() {
    if (_isHeadless) {
      final headless = _headlessDocument;
      if (headless == null) {
        throw StateError('NutrientDocumentIOS: this document has been closed.');
      }
      return headless;
    }

    final handle = adapter.internalViewHandle;
    if (handle == null) {
      throw StateError(
        'NutrientDocumentIOS: no view handle — is the controller ready?',
      );
    }
    final vc =
        handle.getNativeInstance('viewController') as PSPDFViewController?;
    if (vc == null) {
      throw StateError(
        'NutrientDocumentIOS: viewController not registered in handle.',
      );
    }
    final doc = vc.document;
    if (doc == null) {
      throw StateError(
        'NutrientDocumentIOS: no document set on PSPDFViewController.',
      );
    }
    return doc;
  }

  /// Non-throwing variant of [requireDocument]. Returns `null` instead of
  /// throwing when the document is unavailable (closed, view not attached,
  /// or no document set on the view controller).
  ///
  /// Use this when probing for native-document availability — e.g. from
  /// [IOSAdapter.nativeDocument] before the view has settled.
  PSPDFDocument? get maybeDocument {
    try {
      return requireDocument();
    } on StateError {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Managers
  // ---------------------------------------------------------------------------

  late final AnnotationManagerInterface _annotations =
      _annotationManagerFactory?.call(this) ?? AnnotationManagerIOS(this);
  late final BookmarkManagerInterface _bookmarks =
      _bookmarkManagerFactory?.call(this) ?? BookmarkManagerIOS(this);
  late final FormManagerInterface _forms =
      _formManagerFactory?.call(this) ?? FormManagerIOS(this);

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
    return requireDocument().pageCount;
  }

  @override
  Future<PageInfo> getPageInfo(int pageIndex) async {
    final doc = requireDocument();
    final info = doc.pageInfoForPageAtIndex(pageIndex);
    if (info == null) {
      throw StateError('No page info for page $pageIndex');
    }
    final size = info.size;
    return PageInfo(
      pageIndex: pageIndex,
      width: size.width,
      height: size.height,
      rotation: info.savedRotation.value,
      // `substituteWithPlainLabel: false` returns null when the page has no
      // explicit label so we don't synthesise "1", "2", … and confuse callers.
      label: doc
          .pageLabelForPageAtIndex(pageIndex, substituteWithPlainLabel: false)
          ?.toDartString(),
    );
  }

  // ---------------------------------------------------------------------------
  // Save / export
  // ---------------------------------------------------------------------------
  //
  // iOS [DocumentSaveOptions] coverage mirrors the legacy `nutrient_flutter`
  // plugin (`FlutterPdfDocument.swift:284-381`) exactly — no more, no less:
  //
  // | Option               | In-place save (`save`, no outputPath) | Export (`outputPath` / `exportPdf`) |
  // |----------------------|----------------------------------------|--------------------------------------|
  // | userPassword         | ✓ security options                      | ✓ security options                    |
  // | ownerPassword        | ✓ security options                      | ✓ security options                    |
  // | permissions          | ✓ security options                      | ✓ security options                    |
  // | incremental          | ✓ save strategy (append/rewrite)        | N/A — Processor always rewrites       |
  // | flatten              | N/A (not applied in-place on iOS)       | ✓ via PSPDFProcessor                  |
  // | excludeAnnotations   | N/A (not applied in-place on iOS)       | ✓ via PSPDFProcessor                  |
  // | saveForPrinting      | Not mapped — no iOS SaveOption/Processor equivalent used by the legacy plugin. |
  // | pdfVersion           | Not mapped — no direct iOS API; legacy iOS never applied this either. |
  // | includeComments      | Not mapped — server-backed (Instant) concept, not a standalone-document iOS API. |
  // | outputFormat         | Not mapped — web/standalone(non-iOS) concept; no PSPDFProcessor equivalent used by the legacy plugin. |
  // | optimize             | Not mapped — legacy iOS did not wire this to `PSPDFDocumentSaveStrategyRewriteAndOptimizeFileSize`. |
  //
  // Unsupported options are silently ignored (matching the legacy Swift
  // implementation's coverage), not rejected — callers targeting multiple
  // platforms can pass a superset of options and rely on each platform to
  // apply what it supports.
  //
  // One deliberate deviation from legacy: an unset `permissions` list grants
  // all permissions instead of none (legacy `iosDocumentPermissions` mapped
  // `nil` to `[]`, so a password-only save produced a fully-locked PDF). See
  // `_permissionsMask`.

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) async {
    final doc = requireDocument();
    if (outputPath == null) {
      // Save in place (the original "Manual Save" behaviour), with the
      // `incremental` save-strategy and security options applied via the
      // `saveWithOptions:error:` options dictionary — mirrors
      // `FlutterPdfDocument.save(outputPath: nil, ...)`.
      final saveOptions = _buildInPlaceSaveOptions(options);
      return doc.saveWithOptions_error(saveOptions);
    }
    // Save As: PSPDFDocument has no direct "save to a new URL" on this binding
    // surface. Mirrors `FlutterPdfDocument.save(outputPath: ..., ...)`, which
    // uses PSPDFProcessor to write a new file directly — write straight to
    // outputPath via PSPDFProcessor instead of round-tripping through
    // exportPdf()'s in-memory bytes.
    _flushPendingChanges(doc);
    final configuration = _buildProcessorConfiguration(doc, options);
    final securityOptions = _buildSecurityOptions(options);
    final processor = PSPDFProcessor.alloc()
        .initWithConfiguration_securityOptions(
          configuration,
          securityOptions: securityOptions,
        );
    final outputURL = objc.NSURL.fileURLWithPath(outputPath.toNSString());
    // writeToFileURL:error: throws if a file already exists at the URL —
    // matches Processor.write(toFileURL:) on the legacy Swift side, which
    // relies on the same underlying precondition. Remove any existing file
    // first so repeated "Save As" calls to the same path succeed.
    final existing = File(outputPath);
    if (await existing.exists()) {
      await existing.delete();
    } else {
      final parent = existing.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
    }
    return processor.writeToFileURL_error(outputURL);
  }

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) async {
    final doc = requireDocument();
    _flushPendingChanges(doc);

    // Fast path: no export-only options requested (flatten/excludeAnnotations)
    // and no security options — read the current PDF bytes directly, same as
    // before this change. PSPDFProcessor always rewrites the whole file, so
    // skipping it when nothing needs transforming avoids an unnecessary
    // reprocessing pass.
    if (!_needsProcessor(options)) {
      return _readCurrentPdfBytes(doc);
    }

    final configuration = _buildProcessorConfiguration(doc, options);
    final securityOptions = _buildSecurityOptions(options);
    final processor = PSPDFProcessor.alloc()
        .initWithConfiguration_securityOptions(
          configuration,
          securityOptions: securityOptions,
        );
    final data = processor.dataWithError();
    if (data == null) {
      throw StateError('NutrientDocumentIOS: PSPDFProcessor export failed');
    }
    return data.toList();
  }

  /// Backed by `PSPDFDocument.hasDirtyAnnotations` — the only public
  /// document-level dirty check the iOS SDK exposes. It covers annotation
  /// changes; core-level form and bookmark changes may not be reflected
  /// (the SDK's comprehensive `hasUnsavedChanges` is private API). Combine
  /// with event-based tracking on `controller.events` for exact dirtiness —
  /// see the dirty-state tracking guide.
  @override
  Future<bool> hasUnsavedChanges() async {
    return requireDocument().hasDirtyAnnotations;
  }

  /// Whether [options] requires routing `exportPdf` through `PSPDFProcessor`
  /// rather than reading the document's current bytes directly.
  bool _needsProcessor(DocumentSaveOptions? options) {
    if (options == null) return false;
    return options.flatten == true ||
        options.excludeAnnotations == true ||
        options.userPassword != null ||
        options.ownerPassword != null;
  }

  /// Reads the document's current PDF bytes without going through
  /// `PSPDFProcessor` — for in-memory documents via `PSPDFDocument.data`, for
  /// file-based documents via the first document provider's file URL.
  Uint8List _readCurrentPdfBytes(PSPDFDocument doc) {
    final data = doc.data;
    if (data != null) {
      return data.toList();
    }
    final providers = doc.documentProviders.asDart();
    if (providers.isEmpty) {
      throw StateError('NutrientDocumentIOS: no document providers available');
    }
    final provider = PSPDFDocumentProvider.as(providers.first);
    final fileURL = provider.fileURL;
    if (fileURL == null) {
      throw StateError(
        'NutrientDocumentIOS: document provider has no file URL',
      );
    }
    final fileData = objc.NSData.dataWithContentsOfURL(fileURL);
    if (fileData == null) {
      throw StateError('NutrientDocumentIOS: could not read PDF file data');
    }
    return fileData.toList();
  }

  /// Flushes unsaved changes to disk before export/processing — matches the
  /// unconditional `doc.saveWithOptions_error(null)` call that used to sit at
  /// the top of `exportPdf` (kept as its own step now that `save` and
  /// `exportPdf` both need it, with different downstream option handling).
  void _flushPendingChanges(PSPDFDocument doc) {
    doc.saveWithOptions_error(null);
  }

  /// Builds the `saveWithOptions:error:` options dictionary for an in-place
  /// save, mirroring `FlutterPdfDocument.save`'s "Save in place with options"
  /// branch: `incremental` maps to `PSPDFDocumentSaveOptionStrategy`
  /// (true → append, false → rewrite; unset → SDK default of append), and
  /// security options (if any) map to `PSPDFDocumentSaveOptionSecurityOptions`.
  /// Returns `null` when [options] is `null` or contributes nothing — passing
  /// `nil` to `saveWithOptions:error:` is equivalent to an empty dictionary.
  objc.NSDictionary? _buildInPlaceSaveOptions(DocumentSaveOptions? options) {
    if (options == null) return null;

    final dict = objc.NSMutableDictionary.dictionary();
    var hasEntries = false;

    final incremental = options.incremental;
    if (incremental != null) {
      // PSPDFDocumentSaveStrategy: Append=0, Rewrite=1 (PSPDFDocument.h).
      final strategy = incremental
          ? PSPDFDocumentSaveStrategy.PSPDFDocumentSaveStrategyAppend
          : PSPDFDocumentSaveStrategy.PSPDFDocumentSaveStrategyRewrite;
      dict.setObject(
        objc.NSNumberCreation.numberWithUnsignedInteger(strategy.value),
        forKey: PSPDFDocumentSaveOptionStrategy,
      );
      hasEntries = true;
    }

    final securityOptions = _buildSecurityOptions(options);
    if (securityOptions != null) {
      dict.setObject(
        securityOptions,
        forKey: PSPDFDocumentSaveOptionSecurityOptions,
      );
      hasEntries = true;
    }

    return hasEntries ? dict : null;
  }

  /// Builds a `PSPDFDocumentSecurityOptions` from [options], mirroring
  /// `FlutterPdfDocument.makeSecurityOptions`. Returns `null` when neither
  /// `userPassword` nor `ownerPassword` is set — matching the legacy guard
  /// (`options.userPassword != nil || options.ownerPassword != nil`), so an
  /// options object that only sets e.g. `flatten` doesn't spuriously encrypt
  /// the output with empty passwords.
  PSPDFDocumentSecurityOptions? _buildSecurityOptions(
    DocumentSaveOptions? options,
  ) {
    if (options == null) return null;
    if (options.userPassword == null && options.ownerPassword == null) {
      return null;
    }

    final permissionsMask = _permissionsMask(options.permissions);
    return PSPDFDocumentSecurityOptions.alloc()
        .initWithOwnerPassword_userPassword_keyLength_permissions_error(
          options.ownerPassword?.toNSString(),
          userPassword: options.userPassword?.toNSString(),
          keyLength: PSPDFDocumentSecurityOptionsKeyLengthAutomatic,
          documentPermissions: permissionsMask,
        );
  }

  /// Converts [permissions] to the `PSPDFDocumentPermissions` bitmask,
  /// mirroring `FlutterPdfDocument.iosDocumentPermissions` for a provided
  /// list: null entries are skipped, contributing no bits — matching the
  /// legacy Swift `switch` statement's `default: break` for a `nil` case
  /// value.
  ///
  /// An unset (`null`) list grants *all* permissions rather than none:
  /// permissions bits are what user-password holders are *allowed* to do, so
  /// mapping "not specified" to no-flags would turn a password-only save into
  /// a fully-locked document. This matches Android (unset fields keep the
  /// document's default save options, all-permissions for a previously
  /// unencrypted document) and the Web mapping's all-permissions backfill.
  /// Pass an explicit list (or an empty one) to restrict.
  int _permissionsMask(List<DocumentPermissions?>? permissions) {
    if (permissions == null) return _allPermissionsMask;
    var mask = PSPDFDocumentPermissions.PSPDFDocumentPermissionsNoFlags;
    for (final permission in permissions) {
      switch (permission) {
        case DocumentPermissions.printing:
          mask |= PSPDFDocumentPermissions.PSPDFDocumentPermissionsPrinting;
        case DocumentPermissions.modification:
          mask |= PSPDFDocumentPermissions.PSPDFDocumentPermissionsModification;
        case DocumentPermissions.extract:
          mask |= PSPDFDocumentPermissions.PSPDFDocumentPermissionsExtract;
        case DocumentPermissions.annotationsAndForms:
          mask |= PSPDFDocumentPermissions
              .PSPDFDocumentPermissionsAnnotationsAndForms;
        case DocumentPermissions.fillForms:
          mask |= PSPDFDocumentPermissions.PSPDFDocumentPermissionsFillForms;
        case DocumentPermissions.extractAccessibility:
          mask |= PSPDFDocumentPermissions
              .PSPDFDocumentPermissionsExtractAccessibility;
        case DocumentPermissions.assemble:
          mask |= PSPDFDocumentPermissions.PSPDFDocumentPermissionsAssemble;
        case DocumentPermissions.printHighQuality:
          mask |=
              PSPDFDocumentPermissions.PSPDFDocumentPermissionsPrintHighQuality;
        case null:
          break;
      }
    }
    return mask;
  }

  /// Every `PSPDFDocumentPermissions` flag OR'd together — the generated
  /// bindings expose no `PSPDFDocumentPermissionsAll` constant.
  static const int _allPermissionsMask =
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsPrinting |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsModification |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsExtract |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsAnnotationsAndForms |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsFillForms |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsExtractAccessibility |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsAssemble |
      PSPDFDocumentPermissions.PSPDFDocumentPermissionsPrintHighQuality;

  /// Builds a `PSPDFProcessorConfiguration` for [doc] with `flatten` /
  /// `excludeAnnotations` applied, mirroring
  /// `FlutterPdfDocument.applyAnnotationOptions`. `flatten` takes priority over
  /// `excludeAnnotations` when both are set, matching the legacy
  /// `if...else if` — the two are mutually exclusive per-annotation outcomes
  /// (flattened vs removed), so only one can apply.
  PSPDFProcessorConfiguration _buildProcessorConfiguration(
    PSPDFDocument doc,
    DocumentSaveOptions? options,
  ) {
    final configuration = PSPDFProcessorConfiguration.alloc().initWithDocument(
      doc,
    );
    if (configuration == null) {
      throw StateError(
        'NutrientDocumentIOS: failed to create PSPDFProcessorConfiguration',
      );
    }

    if (options?.flatten == true) {
      configuration.modifyAnnotationsOfTypes_change(
        PSPDFAnnotationType.PSPDFAnnotationTypeAll,
        annotationChange: PSPDFAnnotationChange.PSPDFAnnotationChangeFlatten,
      );
    } else if (options?.excludeAnnotations == true) {
      configuration.modifyAnnotationsOfTypes_change(
        PSPDFAnnotationType.PSPDFAnnotationTypeAll,
        annotationChange: PSPDFAnnotationChange.PSPDFAnnotationChangeRemove,
      );
    }

    return configuration;
  }

  // ---------------------------------------------------------------------------
  // Instant JSON
  // ---------------------------------------------------------------------------

  @override
  Future<bool> applyInstantJson(String annotationsJson) async {
    final doc = requireDocument();
    final docProvider = doc.documentProviderForPageAtIndex(0);
    if (docProvider == null) return false;
    final nsData = utf8.encode(annotationsJson).toNSData();
    // PSPDFDataContainerProvider's no-arg `+new` (which Dart's default
    // constructor invokes via `init`) throws an Objective-C exception
    // because the class requires data at init time. Crash signature:
    //   *** -[PSPDFDataContainerProvider init] (SIGABRT)
    // Use `alloc + initWithData:` to bind the data atomically.
    final dataProvider = PSPDFDataContainerProvider.alloc().initWithData(
      nsData,
    );
    return doc.applyInstantJSONFromDataProvider(
      dataProvider,
      toDocumentProvider: docProvider,
      lenient: true,
    );
  }

  @override
  Future<String?> exportInstantJson() async {
    final doc = requireDocument();
    final docProvider = doc.documentProviderForPageAtIndex(0);
    if (docProvider == null) return null;
    final data = doc.generateInstantJSONFromDocumentProvider(docProvider);
    if (data == null) return null;
    return utf8.decode(data.toList());
  }

  // ---------------------------------------------------------------------------
  // Author name
  // ---------------------------------------------------------------------------

  @override
  Future<void> setAuthorName(String name) async {
    requireDocument().defaultAnnotationUsername = name.toNSString();
  }

  @override
  Future<String> getAuthorName() async {
    return requireDocument().defaultAnnotationUsername?.toDartString() ?? '';
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<bool> close() async {
    // For headless documents, force a deterministic teardown order: release
    // the PSPDFDocument's Dart wrapper synchronously *before* the NSURL
    // wrapper, so PSPDFDocument's dealloc cascade (which ends in
    // PSPDFSecurityScopedURL.dealloc) runs while the URL is still live.
    // Relying on Dart GC to finalise the two wrappers in order would
    // re-open the EXC_BAD_ACCESS this PR fixed in the synchronous path.
    final document = _headlessDocument;
    final url = _headlessUrl;
    if (document != null) {
      _headlessDocument = null;
      document.ref.release();
    }
    if (url != null) {
      _headlessUrl = null;
      url.ref.release();
    }
    // View-attached documents are closed when the view disposes.
    return true;
  }
}
