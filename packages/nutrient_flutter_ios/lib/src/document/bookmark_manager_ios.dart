///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:objective_c/objective_c.dart' as objc;

import '../bindings/nutrient_ios_bindings.dart';
import 'nutrient_document_ios.dart';

/// iOS implementation of [BookmarkManagerInterface].
///
/// Uses FFI bindings to the Nutrient iOS SDK's [PSPDFBookmarkManager].
/// Obtained via `document.bookmarks`.
class BookmarkManagerIOS implements BookmarkManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentIOS document;

  BookmarkManagerIOS(this.document);

  PSPDFBookmarkManager _requireBookmarkManager() {
    final doc = document.requireDocument();
    final mgr = doc.bookmarkManager;
    if (mgr == null) {
      throw StateError(
        'BookmarkManagerIOS: bookmarkManager not available on document.',
      );
    }
    return mgr;
  }

  // ---------------------------------------------------------------------------
  // Static converters
  // ---------------------------------------------------------------------------

  /// Converts a native [PSPDFBookmark] to a Dart [Bookmark].
  static Bookmark toBookmark(PSPDFBookmark nativeBookmark) {
    final pageIndex = nativeBookmark.pageIndex;
    final name = nativeBookmark.name?.toDartString();
    final displayName = nativeBookmark.displayName.toDartString();
    return Bookmark(
      pdfBookmarkId: displayName,
      name: name ?? displayName,
      // Emit the canonical GoTo-action shape so the `Bookmark.pageIndex`
      // extension getter (in `nutrient_flutter/.../bookmark_extensions.dart`)
      // resolves — it gates on `action['type'] == 'goTo'` before reading
      // `pageIndex`. Android and Web already emit this shape.
      actionJson: jsonEncode({'type': 'goTo', 'pageIndex': pageIndex}),
    );
  }

  /// Extracts the page index from a [Bookmark]'s actionJson.
  static int pageIndexFromBookmark(Bookmark bookmark) {
    if (bookmark.actionJson == null) return 0;
    try {
      final actionMap =
          jsonDecode(bookmark.actionJson!) as Map<String, dynamic>;
      return (actionMap['pageIndex'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<Bookmark>> getBookmarks() async {
    final mgr = _requireBookmarkManager();
    final result = <Bookmark>[];
    for (final item in mgr.bookmarks.asDart()) {
      result.add(toBookmark(PSPDFBookmark.as(item)));
    }
    return result;
  }

  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    final mgr = _requireBookmarkManager();
    final pageIndex = pageIndexFromBookmark(bookmark);
    // `addBookmarkForPageAtIndex:` ignores `bookmark.name` and throws if a
    // bookmark already exists on that page. Build a `PSPDFMutableBookmark`
    // ourselves so the name persists and `addBookmark:` upserts cleanly.
    final mutable = PSPDFMutableBookmark.alloc().initWithPageIndex(pageIndex);
    if (bookmark.name != null) {
      mutable.name$1 = bookmark.name!.toNSString();
    }
    mgr.addBookmark(mutable);
    return toBookmark(mutable);
  }

  @override
  Future<bool> removeBookmark(Bookmark bookmark) async {
    final mgr = _requireBookmarkManager();
    final pageIndex = pageIndexFromBookmark(bookmark);
    // Get all bookmarks and find by name to avoid removing the wrong one
    // when multiple bookmarks exist on the same page.
    PSPDFBookmark? target;
    for (final item in mgr.bookmarks.asDart()) {
      final b = PSPDFBookmark.as(item);
      if (b.pageIndex == pageIndex &&
          (bookmark.name == null || b.name?.toDartString() == bookmark.name)) {
        target = b;
        break;
      }
    }
    if (target == null) return false;
    mgr.removeBookmark(target);
    return true;
  }

  @override
  Future<bool> updateBookmark(Bookmark bookmark) async {
    // iOS SDK does not have a direct update API for bookmarks.
    // Remove and re-add with updated values.
    final mgr = _requireBookmarkManager();
    final pageIndex = pageIndexFromBookmark(bookmark);
    // Find by name to avoid removing the wrong bookmark when multiple exist.
    PSPDFBookmark? target;
    for (final item in mgr.bookmarks.asDart()) {
      final b = PSPDFBookmark.as(item);
      if (b.pageIndex == pageIndex &&
          (bookmark.name == null || b.name?.toDartString() == bookmark.name)) {
        target = b;
        break;
      }
    }
    if (target == null) return false;
    mgr.removeBookmark(target);
    await addBookmark(bookmark);
    return true;
  }

  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    final mgr = _requireBookmarkManager();
    final result = <Bookmark>[];
    for (final item in mgr.bookmarks.asDart()) {
      final native = PSPDFBookmark.as(item);
      if (native.pageIndex == pageIndex) {
        result.add(toBookmark(native));
      }
    }
    return result;
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    final mgr = _requireBookmarkManager();
    return mgr.bookmarkForPageAtIndex(pageIndex) != null;
  }
}
