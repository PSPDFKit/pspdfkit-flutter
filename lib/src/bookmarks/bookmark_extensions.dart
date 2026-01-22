///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'package:nutrient_flutter/src/api/nutrient_api.g.dart';

/// Extension methods for the [Bookmark] class to provide convenience
/// constructors and utility methods.
extension BookmarkExtensions on Bookmark {
  /// Returns the page index this bookmark points to.
  ///
  /// Returns null if the bookmark doesn't have a valid GoTo action.
  int? get pageIndex {
    if (actionJson == null) return null;
    try {
      final json = jsonDecode(actionJson!);
      if (json['type'] == 'goTo') {
        return json['pageIndex'] as int?;
      }
    } catch (_) {}
    return null;
  }

  /// Returns true if this bookmark points to the specified page.
  bool isForPage(int pageIndex) => this.pageIndex == pageIndex;

  /// Converts this bookmark to Instant JSON format.
  Map<String, dynamic> toInstantJson() {
    return {
      'v': 1,
      'type': 'pspdfkit/bookmark',
      if (pdfBookmarkId != null) 'pdfBookmarkId': pdfBookmarkId,
      if (name != null) 'name': name,
      if (actionJson != null) 'action': jsonDecode(actionJson!),
    };
  }

  /// Creates a copy of this bookmark with the specified fields replaced.
  Bookmark copyWith({
    String? pdfBookmarkId,
    String? name,
    String? actionJson,
  }) {
    return Bookmark(
      pdfBookmarkId: pdfBookmarkId ?? this.pdfBookmarkId,
      name: name ?? this.name,
      actionJson: actionJson ?? this.actionJson,
    );
  }
}

/// Factory methods for creating [Bookmark] instances.
///
/// Since Pigeon-generated classes don't support factory constructors,
/// these are provided as static methods in a separate class.
class BookmarkFactory {
  BookmarkFactory._();

  /// Creates a bookmark that navigates to a specific page.
  ///
  /// This is a convenience method for the common case of creating
  /// a bookmark that simply navigates to a page.
  ///
  /// Example:
  /// ```dart
  /// final bookmark = BookmarkFactory.forPage(
  ///   pageIndex: 5,
  ///   name: 'Chapter 2',
  /// );
  /// await document.addBookmark(bookmark);
  /// ```
  static Bookmark forPage({
    required int pageIndex,
    String? name,
    String? pdfBookmarkId,
  }) {
    final actionJson = jsonEncode({
      'type': 'goTo',
      'pageIndex': pageIndex,
      'destinationType': 'fitPage',
    });

    return Bookmark(
      pdfBookmarkId: pdfBookmarkId,
      name: name ?? 'Page ${pageIndex + 1}',
      actionJson: actionJson,
    );
  }

  /// Creates a bookmark from Instant JSON format.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'v': 1,
  ///   'type': 'pspdfkit/bookmark',
  ///   'name': 'My Bookmark',
  ///   'action': {'type': 'goTo', 'pageIndex': 5, 'destinationType': 'fitPage'},
  /// };
  /// final bookmark = BookmarkFactory.fromInstantJson(json);
  /// ```
  static Bookmark fromInstantJson(Map<String, dynamic> json) {
    String? actionJson;
    if (json['action'] != null) {
      actionJson = jsonEncode(json['action']);
    }

    return Bookmark(
      pdfBookmarkId: json['pdfBookmarkId'] as String?,
      name: json['name'] as String?,
      actionJson: actionJson,
    );
  }
}
