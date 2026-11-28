///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:jni/jni.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide Bookmark, DocumentSaveOptions;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as iface show Bookmark;

import '../bindings/nutrient_android_sdk_bindings.dart'
    hide Nutrient, DocumentSaveOptions, Bookmark;
import '../bindings/nutrient_android_sdk_bindings.dart' as sdk show Bookmark;
import 'nutrient_document_android.dart';

/// Android implementation of [BookmarkManagerInterface].
///
/// Uses JNI bindings to the Nutrient Android SDK's [BookmarkProvider].
/// Obtained via `document.bookmarks`.
class BookmarkManagerAndroid implements BookmarkManagerInterface {
  final NutrientDocumentAndroid document;

  BookmarkManagerAndroid(this.document);

  BookmarkProvider _requireProvider() =>
      document.requireDocument().getBookmarkProvider();

  @override
  Future<List<iface.Bookmark>> getBookmarks() async {
    final provider = _requireProvider();
    final jBookmarks = provider.getBookmarks();
    final result = <iface.Bookmark>[];
    for (int i = 0; i < jBookmarks.size(); i++) {
      final b = jBookmarks.get(i);
      if (b == null) continue;
      result.add(toBookmark(b));
      b.release();
    }
    jBookmarks.release();
    return result;
  }

  @override
  Future<iface.Bookmark> addBookmark(iface.Bookmark bookmark) async {
    final jBookmark = fromBookmark(bookmark);
    _requireProvider().addBookmark(jBookmark);
    jBookmark.release();
    return bookmark;
  }

  @override
  Future<bool> removeBookmark(iface.Bookmark bookmark) async {
    final jBookmark = fromBookmark(bookmark);
    final result = _requireProvider().removeBookmark(jBookmark);
    jBookmark.release();
    return result;
  }

  @override
  Future<bool> updateBookmark(iface.Bookmark bookmark) async {
    final provider = _requireProvider();
    final jOld = fromBookmark(bookmark);
    provider.removeBookmark(jOld);
    jOld.release();
    final jNew = fromBookmark(bookmark);
    provider.addBookmark(jNew);
    jNew.release();
    return true;
  }

  @override
  Future<List<iface.Bookmark>> getBookmarksForPage(int pageIndex) async {
    final all = await getBookmarks();
    return all.where((b) => pageIndexFromBookmark(b) == pageIndex).toList();
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    final bookmarks = await getBookmarksForPage(pageIndex);
    return bookmarks.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Static converters
  // ---------------------------------------------------------------------------

  /// Convert a JNI [sdk.Bookmark] to a Dart [iface.Bookmark].
  static iface.Bookmark toBookmark(sdk.Bookmark jBookmark) {
    final uuid = jBookmark.uuid.toDartString(releaseOriginal: true);
    final pageIndex = jBookmark.pageIndex?.intValue();
    final name = jBookmark.name?.toDartString(releaseOriginal: true);
    final actionJson = pageIndex != null
        ? jsonEncode({'type': 'goTo', 'pageIndex': pageIndex})
        : null;
    return iface.Bookmark(
      pdfBookmarkId: uuid,
      name: name,
      actionJson: actionJson,
    );
  }

  /// Create a JNI [sdk.Bookmark] from a Dart [iface.Bookmark].
  static sdk.Bookmark fromBookmark(iface.Bookmark bookmark) {
    final pageIndex = pageIndexFromBookmark(bookmark) ?? 0;
    if (bookmark.pdfBookmarkId != null) {
      return sdk.Bookmark.new$2(
        bookmark.pdfBookmarkId!.toJString(),
        bookmark.name?.toJString(),
        pageIndex,
      );
    } else if (bookmark.name != null) {
      return sdk.Bookmark.new$1(
        bookmark.name!.toJString(),
        pageIndex,
      );
    }
    return sdk.Bookmark(pageIndex);
  }

  /// Extract page index from a Dart [iface.Bookmark]'s actionJson.
  static int? pageIndexFromBookmark(iface.Bookmark bookmark) {
    if (bookmark.actionJson == null) return null;
    try {
      final action = jsonDecode(bookmark.actionJson!) as Map<String, dynamic>;
      return action['pageIndex'] as int?;
    } catch (_) {
      return null;
    }
  }
}
