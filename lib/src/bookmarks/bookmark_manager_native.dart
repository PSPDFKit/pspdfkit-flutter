///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/services.dart';
import 'package:nutrient_flutter/src/api/nutrient_api.g.dart';

/// Native implementation of bookmark management for iOS and Android platforms.
class BookmarkManagerNative {
  late final BookmarkManagerApi _api;
  final String documentId;

  BookmarkManagerNative({required this.documentId}) {
    // Create API instance with channel based on documentId
    _api = BookmarkManagerApi(
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      messageChannelSuffix: '${documentId}_bookmark_manager',
    );
    _api.initialize(documentId);
  }

  /// Gets all bookmarks in the document.
  Future<List<Bookmark>> getBookmarks() async {
    return _api.getBookmarks();
  }

  /// Adds a new bookmark to the document.
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    return _api.addBookmark(bookmark);
  }

  /// Removes a bookmark from the document.
  Future<bool> removeBookmark(Bookmark bookmark) async {
    return _api.removeBookmark(bookmark);
  }

  /// Updates an existing bookmark.
  Future<bool> updateBookmark(Bookmark bookmark) async {
    return _api.updateBookmark(bookmark);
  }

  /// Gets bookmarks for a specific page.
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    return _api.getBookmarksForPage(pageIndex);
  }

  /// Checks if a bookmark exists for a specific page.
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    return _api.hasBookmarkForPage(pageIndex);
  }
}
