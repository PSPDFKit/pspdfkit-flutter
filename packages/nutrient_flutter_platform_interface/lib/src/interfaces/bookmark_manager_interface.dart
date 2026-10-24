///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import '../models/bookmark.dart';

/// Abstract interface for bookmark operations on a PDF document.
///
/// Concrete implementations are provided by each platform package:
/// - `BookmarkManagerAndroid` in `nutrient_flutter_android`
/// - `BookmarkManagerIOS` in `nutrient_flutter_ios`
/// - `BookmarkManagerWeb` in `nutrient_flutter_web`
///
/// Access via [NutrientDocumentInterface.bookmarks] or
/// [NutrientController.document.bookmarks].
abstract class BookmarkManagerInterface {
  /// Returns all bookmarks in the document.
  Future<List<Bookmark>> getBookmarks();

  /// Adds [bookmark] to the document and returns the saved bookmark
  /// (which may have a platform-assigned [Bookmark.pdfBookmarkId]).
  Future<Bookmark> addBookmark(Bookmark bookmark);

  /// Removes [bookmark] from the document.
  Future<bool> removeBookmark(Bookmark bookmark);

  /// Updates [bookmark] in the document.
  Future<bool> updateBookmark(Bookmark bookmark);

  /// Returns all bookmarks that target [pageIndex].
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex);

  /// Returns `true` if there is at least one bookmark targeting [pageIndex].
  Future<bool> hasBookmarkForPage(int pageIndex);
}
