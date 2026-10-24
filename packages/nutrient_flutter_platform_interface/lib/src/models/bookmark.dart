///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// A PDF bookmark.
class Bookmark {
  /// Platform-specific bookmark identifier.
  final String? pdfBookmarkId;

  /// Display name of the bookmark.
  final String? name;

  /// JSON-encoded action associated with this bookmark (e.g. GoTo action).
  final String? actionJson;

  const Bookmark({
    this.pdfBookmarkId,
    this.name,
    this.actionJson,
  });

  /// Creates a [Bookmark] from a JSON map.
  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        pdfBookmarkId: json['pdfBookmarkId'] as String?,
        name: json['name'] as String?,
        actionJson: json['actionJson'] as String?,
      );

  /// Converts this bookmark to a JSON map.
  Map<String, dynamic> toJson() => {
        if (pdfBookmarkId != null) 'pdfBookmarkId': pdfBookmarkId,
        if (name != null) 'name': name,
        if (actionJson != null) 'actionJson': actionJson,
      };

  @override
  String toString() => 'Bookmark(pdfBookmarkId: $pdfBookmarkId, name: $name)';
}
