///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../nutrient_web_bindings.dart';
import '../utils/immutable_utils.dart';
import '../utils/namespace_utils.dart';

/// Provides bookmark CRUD operations on a Nutrient Web SDK instance.
///
/// Accessible via [NutrientWebAdapter.bookmarkOperations] after the instance
/// is loaded.
class NutrientBookmarkOperations {
  final NutrientWebInstance _instance;

  NutrientBookmarkOperations(this._instance);

  /// Gets all bookmarks as Dart maps.
  ///
  /// Each map has: `name`, `pdfBookmarkId`, and `action` (with `type`, `pageIndex`).
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final result = await _instance.getBookmarks().toDart;
    if (result == null) return [];

    final items = ImmutableList.toList(result);
    return items.map(_webBookmarkToMap).toList();
  }

  /// Adds a bookmark to the document.
  ///
  /// The [bookmark] map should contain:
  /// - `name`: the bookmark display name
  /// - `action`: optional map with `type` and `pageIndex` (for `goTo` actions)
  Future<Map<String, dynamic>?> addBookmark(
      Map<String, dynamic> bookmark) async {
    final ns = NutrientNamespace.getAsJSObject();

    // Build the action
    JSAny? action;
    if (bookmark['action'] != null || bookmark['actionJson'] != null) {
      Map<String, dynamic> actionData;
      if (bookmark['actionJson'] is String) {
        actionData = jsonDecode(bookmark['actionJson'] as String)
            as Map<String, dynamic>;
      } else if (bookmark['action'] is Map) {
        actionData = Map<String, dynamic>.from(bookmark['action'] as Map);
      } else {
        actionData = {};
      }
      action = _createWebAction(ns, actionData);
    }

    // Create the bookmark
    final bookmarkClass = ns['Bookmark'] as JSFunction?;
    if (bookmarkClass == null) {
      throw StateError('Bookmark class not found in Web SDK namespace');
    }

    final props = <String, dynamic>{
      'name': bookmark['name'],
    };
    final webBookmark = bookmarkClass.callAsConstructor(props.jsify());
    if (action != null) {
      // Set action via Immutable.js set()
      final withAction =
          ImmutableRecord.set(webBookmark as JSObject, 'action', action);
      await _instance.create(withAction as JSAny).toDart;
    } else {
      await _instance.create(webBookmark as JSAny).toDart;
    }

    // Return the last bookmark (most recently created)
    final bookmarks = await getBookmarks();
    return bookmarks.isNotEmpty ? bookmarks.last : null;
  }

  /// Removes a bookmark from the document.
  ///
  /// Matches by `pdfBookmarkId`, `name`, or page index from action.
  /// Returns true if successfully removed.
  Future<bool> removeBookmark(Map<String, dynamic> bookmark) async {
    final result = await _instance.getBookmarks().toDart;
    if (result == null) return false;

    final items = ImmutableList.toList(result);
    final targetPdfId = bookmark['pdfBookmarkId'];
    final targetName = bookmark['name'];

    // Extract target page index
    int? targetPageIndex;
    if (bookmark['pageIndex'] != null) {
      targetPageIndex = bookmark['pageIndex'] as int;
    } else if (bookmark['action'] is Map) {
      targetPageIndex = (bookmark['action'] as Map)['pageIndex'] as int?;
    } else if (bookmark['actionJson'] is String) {
      final actionData = jsonDecode(bookmark['actionJson'] as String);
      targetPageIndex = actionData['pageIndex'] as int?;
    }

    for (final item in items) {
      final itemPdfId = (item['pdfBookmarkId'] as JSString?)?.toDart;
      final itemName = (item['name'] as JSString?)?.toDart;

      // Match by pdfBookmarkId
      if (targetPdfId != null && itemPdfId == targetPdfId) {
        await _instance.delete(itemPdfId!).toDart;
        return true;
      }

      // Match by name
      if (targetName != null && itemName == targetName) {
        await _instance.delete(itemName!).toDart;
        return true;
      }

      // Match by page index from action
      if (targetPageIndex != null) {
        final action = item['action'] as JSObject?;
        if (action != null) {
          final actionPageIndex = (action['pageIndex'] as JSNumber?)?.toDartInt;
          if (actionPageIndex == targetPageIndex) {
            final id = itemPdfId ?? itemName;
            if (id != null) {
              await _instance.delete(id).toDart;
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  /// Updates a bookmark by removing and re-adding it.
  ///
  /// Returns true if successfully updated.
  Future<bool> updateBookmark(Map<String, dynamic> bookmark) async {
    await removeBookmark(bookmark);
    await addBookmark(bookmark);
    return true;
  }

  /// Gets bookmarks for a specific page.
  Future<List<Map<String, dynamic>>> getBookmarksForPage(int pageIndex) async {
    final allBookmarks = await getBookmarks();
    return allBookmarks.where((b) {
      final action = b['action'] as Map<String, dynamic>?;
      return action != null && action['pageIndex'] == pageIndex;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts a Web SDK bookmark JS object to a Dart map.
  Map<String, dynamic> _webBookmarkToMap(JSObject webBookmark) {
    final result = <String, dynamic>{
      'pdfBookmarkId': (webBookmark['pdfBookmarkId'] as JSString?)?.toDart,
      'name': (webBookmark['name'] as JSString?)?.toDart,
    };

    // Convert action
    final action = webBookmark['action'] as JSObject?;
    if (action != null) {
      final actionMap = _actionToMap(action);
      if (actionMap.isNotEmpty) {
        result['action'] = actionMap;
        result['actionJson'] = jsonEncode(actionMap);
        // Extract pageIndex for convenience
        if (actionMap['pageIndex'] != null) {
          result['pageIndex'] = actionMap['pageIndex'];
        }
      }
    }

    return result;
  }

  /// Converts a Web SDK action to a Dart map.
  Map<String, dynamic> _actionToMap(JSObject action) {
    final ns = NutrientNamespace.getAsJSObject();
    final actionsNs = ns['Actions'] as JSObject?;
    if (actionsNs == null) return {};

    // Check GoToAction
    final goToClass = actionsNs['GoToAction'];
    if (goToClass != null && action.instanceof(goToClass as JSFunction)) {
      return {
        'type': 'goTo',
        'pageIndex': (action['pageIndex'] as JSNumber?)?.toDartInt,
        'destinationType': 'fitPage',
      };
    }

    // Check URIAction
    final uriClass = actionsNs['URIAction'];
    if (uriClass != null && action.instanceof(uriClass as JSFunction)) {
      return {
        'type': 'uri',
        'uri': (action['uri'] as JSString?)?.toDart,
      };
    }

    return {};
  }

  /// Creates a Web SDK action from action data.
  JSAny? _createWebAction(
    JSObject ns,
    Map<String, dynamic> actionData,
  ) {
    final type = actionData['type'];
    final actionsNs = ns['Actions'] as JSObject?;
    if (actionsNs == null) return null;

    if (type == 'goTo') {
      final goToClass = actionsNs['GoToAction'] as JSFunction?;
      if (goToClass == null) return null;
      return goToClass.callAsConstructor(
        <String, dynamic>{
          'pageIndex': actionData['pageIndex'] ?? 0,
        }.jsify(),
      );
    } else if (type == 'uri') {
      final uriClass = actionsNs['URIAction'] as JSFunction?;
      if (uriClass == null) return null;
      return uriClass.callAsConstructor(
        <String, dynamic>{
          'uri': actionData['uri'],
        }.jsify(),
      );
    }

    return null;
  }
}
