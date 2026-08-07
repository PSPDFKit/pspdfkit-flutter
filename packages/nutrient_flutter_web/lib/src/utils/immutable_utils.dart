///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Utilities for working with Immutable.js data structures from the Web SDK.
///
/// The Nutrient Web SDK returns Immutable.js `List` and `Record` objects
/// which cannot be directly converted to Dart objects using `dartify()`.
/// These utilities provide safe conversion methods.
class ImmutableList {
  ImmutableList._();

  /// Converts an Immutable.js List to a Dart `List<JSObject>`.
  ///
  /// Uses the `.size` property and `.get(index)` method to iterate.
  /// Returns an empty list if [immutableList] is null or has no `size`.
  static List<JSObject> toList(JSAny? immutableList) {
    if (immutableList == null) return [];

    final jsObj = immutableList as JSObject;
    final sizeVal = jsObj['size'];
    if (sizeVal == null) return [];

    final size = (sizeVal as JSNumber).toDartInt;
    final result = <JSObject>[];

    for (var i = 0; i < size; i++) {
      final item = jsObj.callMethod('get'.toJS, i.toJS);
      if (item != null) {
        result.add(item as JSObject);
      }
    }

    return result;
  }

  /// Converts an Immutable.js List to a Dart list using the iterator protocol.
  ///
  /// Uses `.values()` iterator with `.next()` / `.done` / `.value` pattern.
  /// This is useful when the list contains mixed types.
  static List<JSObject> toListViaIterator(JSAny? immutableList) {
    if (immutableList == null) return [];

    final jsObj = immutableList as JSObject;
    final iterator = jsObj.callMethod('values'.toJS) as JSObject;
    final result = <JSObject>[];

    while (true) {
      final next = iterator.callMethod('next'.toJS) as JSObject;
      final done = next['done'];
      if (done != null && (done as JSBoolean).toDart) break;

      final value = next['value'];
      if (value != null) {
        result.add(value as JSObject);
      }
    }

    return result;
  }

  /// Returns the size of an Immutable.js List, or 0 if null/invalid.
  static int size(JSAny? immutableList) {
    if (immutableList == null) return 0;
    final jsObj = immutableList as JSObject;
    final sizeVal = jsObj['size'];
    if (sizeVal == null) return 0;
    return (sizeVal as JSNumber).toDartInt;
  }
}

/// Utilities for working with Immutable.js Record objects.
class ImmutableRecord {
  ImmutableRecord._();

  /// Calls `set(key, value)` on an Immutable.js Record, returning the new record.
  ///
  /// Immutable.js Records are immutable — `set()` returns a new instance.
  static JSObject set(JSObject record, String key, JSAny? value) {
    return record.callMethod('set'.toJS, key.toJS, value) as JSObject;
  }

  /// Gets a property from an Immutable.js Record using `get(key)`.
  static JSAny? get(JSObject record, String key) {
    return record.callMethod('get'.toJS, key.toJS);
  }
}
