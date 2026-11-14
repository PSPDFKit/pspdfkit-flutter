///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import '../operations/bookmark_operations.dart';
import 'nutrient_document_web.dart';

/// Web implementation of [BookmarkManagerInterface].
///
/// Delegates to [NutrientBookmarkOperations] accessed via the adapter.
/// Obtained via `document.bookmarks`.
class BookmarkManagerWeb implements BookmarkManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentWeb document;

  BookmarkManagerWeb(this.document);

  NutrientBookmarkOperations get _ops {
    final ops = document.internalBookmarkOperations;
    if (ops == null) {
      throw StateError(
        'BookmarkManagerWeb: instance not loaded — is onInstanceLoaded called?',
      );
    }
    return ops;
  }

  @override
  Future<List<Bookmark>> getBookmarks() async {
    final maps = await _ops.getBookmarks();
    return maps.map(Bookmark.fromJson).toList();
  }

  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    final result = await _ops.addBookmark(bookmark.toJson());
    return result != null ? Bookmark.fromJson(result) : bookmark;
  }

  @override
  Future<bool> removeBookmark(Bookmark bookmark) async {
    return _ops.removeBookmark(bookmark.toJson());
  }

  @override
  Future<bool> updateBookmark(Bookmark bookmark) async {
    return _ops.updateBookmark(bookmark.toJson());
  }

  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    final maps = await _ops.getBookmarksForPage(pageIndex);
    return maps.map(Bookmark.fromJson).toList();
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    final bookmarks = await getBookmarksForPage(pageIndex);
    return bookmarks.isNotEmpty;
  }
}
