///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:typed_data';

import 'annotation_manager_interface.dart';
import 'bookmark_manager_interface.dart';
import 'form_manager_interface.dart';
import '../models/document_save_options.dart';
import '../models/page_info.dart';

/// Abstract interface representing an open PDF document.
///
/// Concrete implementations are provided by each platform package:
/// - `NutrientDocumentAndroid` in `nutrient_flutter_android`
/// - `NutrientDocumentIOS` in `nutrient_flutter_ios`
/// - `NutrientDocumentWeb` in `nutrient_flutter_web`
///
/// ## Accessing a Document
///
/// Via the controller (view-attached):
///
/// ```dart
/// NutrientView<MyController>(
///   documentPath: 'assets/document.pdf',
///   onControllerReady: (controller) async {
///     final pageCount = await controller.document.getPageCount();
///     final bookmarks = await controller.document.bookmarks.getBookmarks();
///     await controller.document.annotations.addAnnotationJson(json);
///   },
/// )
/// ```
///
/// Headless (no-UI):
///
/// ```dart
/// final doc = await adapter.openDocument('path/to/doc.pdf');
/// await doc.save();
/// await doc.close();
/// ```
///
/// ## Managers
///
/// Domain-specific operations are grouped into managers:
/// - [annotations] — annotation CRUD, search, XFDF export/import
/// - [bookmarks] — bookmark CRUD
/// - [forms] — form field get/set
///
/// Each manager is independently extensible via factory methods on the
/// platform document implementation.
abstract class NutrientDocumentInterface {
  // ---------------------------------------------------------------------------
  // Managers
  // ---------------------------------------------------------------------------

  /// Annotation operations (CRUD, search, XFDF export/import).
  AnnotationManagerInterface get annotations;

  /// Bookmark operations (CRUD, page filtering).
  BookmarkManagerInterface get bookmarks;

  /// Form field operations (get/set values, list fields).
  FormManagerInterface get forms;

  // ---------------------------------------------------------------------------
  // Document info
  // ---------------------------------------------------------------------------

  /// Returns the total number of pages in the document.
  Future<int> getPageCount();

  /// Returns information about the page at [pageIndex].
  Future<PageInfo> getPageInfo(int pageIndex);

  // ---------------------------------------------------------------------------
  // Save / export
  // ---------------------------------------------------------------------------

  /// Saves the document.
  ///
  /// [outputPath] — if provided, saves to this path; otherwise saves in-place.
  /// [options] — optional save options (passwords, flatten, etc.).
  Future<bool> save({String? outputPath, DocumentSaveOptions? options});

  /// Exports the document as raw PDF bytes.
  ///
  /// [options] — optional save options applied during export.
  Future<Uint8List> exportPdf({DocumentSaveOptions? options});

  /// Whether the document has unsaved changes that [save] would persist.
  ///
  /// Platform semantics differ in what the underlying SDK can report:
  ///
  /// | Platform | Backed by | Covers |
  /// |---|---|---|
  /// | Android | annotation ∥ form ∥ bookmark provider `hasUnsavedChanges()` | annotations, forms, bookmarks |
  /// | iOS | `Document.hasDirtyAnnotations` | annotations (form and bookmark changes may not be reflected) |
  /// | Web | `Instance.hasUnsavedChanges()` | annotations, forms, bookmarks, comments |
  ///
  /// For exact dirty tracking on iOS — or to react to changes as they happen —
  /// combine this with event-based tracking on `controller.events` (see the
  /// manual-save catalog example and the dirty-state tracking guide).
  Future<bool> hasUnsavedChanges();

  // ---------------------------------------------------------------------------
  // Instant JSON
  // ---------------------------------------------------------------------------

  /// Applies Instant JSON [annotationsJson] to the document.
  Future<bool> applyInstantJson(String annotationsJson);

  /// Exports the current annotations as an Instant JSON string.
  Future<String?> exportInstantJson();

  // ---------------------------------------------------------------------------
  // Author
  // ---------------------------------------------------------------------------

  /// Sets the annotation author/creator name.
  Future<void> setAuthorName(String name);

  /// Returns the current annotation author/creator name.
  Future<String> getAuthorName();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Closes the document and releases all associated resources.
  ///
  /// Must be called when done with a headless document opened via
  /// `adapter.openDocument()`. View-attached documents are closed
  /// automatically when the view is disposed.
  Future<bool> close();
}
