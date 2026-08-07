///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/services.dart';
import 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart' as pigeon;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Native implementation of bookmark management for iOS and Android platforms.
class BookmarkManagerNative {
  late final pigeon.BookmarkManagerApi _api;
  final String documentId;

  BookmarkManagerNative({required this.documentId}) {
    _api = pigeon.BookmarkManagerApi(
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      messageChannelSuffix: '${documentId}_bookmark_manager',
    );
    _api.initialize(documentId);
  }

  /// Gets all bookmarks in the document.
  Future<List<Bookmark>> getBookmarks() async {
    final dtos = await _api.getBookmarks();
    return dtos.map(_fromDto).toList();
  }

  /// Adds a new bookmark to the document.
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    final dto = await _api.addBookmark(_toDto(bookmark));
    return _fromDto(dto);
  }

  /// Removes a bookmark from the document.
  Future<bool> removeBookmark(Bookmark bookmark) =>
      _api.removeBookmark(_toDto(bookmark));

  /// Updates an existing bookmark.
  Future<bool> updateBookmark(Bookmark bookmark) =>
      _api.updateBookmark(_toDto(bookmark));

  /// Gets bookmarks for a specific page.
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    final dtos = await _api.getBookmarksForPage(pageIndex);
    return dtos.map(_fromDto).toList();
  }

  /// Checks if a bookmark exists for a specific page.
  Future<bool> hasBookmarkForPage(int pageIndex) =>
      _api.hasBookmarkForPage(pageIndex);

  static Bookmark _fromDto(pigeon.Bookmark dto) => Bookmark(
        pdfBookmarkId: dto.pdfBookmarkId,
        name: dto.name,
        actionJson: dto.actionJson,
      );

  static pigeon.Bookmark _toDto(Bookmark b) => pigeon.Bookmark(
        pdfBookmarkId: b.pdfBookmarkId,
        name: b.name,
        actionJson: b.actionJson,
      );
}
